import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/secure_storage_service.dart';
import '../datasources/remote/api_client.dart';
import '../models/auth_user_model.dart';

/// Concrete implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  static const _tokenTtl = Duration(hours: 24);

  static const _keyToken = 'auth_token';
  static const _keyEmail = 'auth_email';
  static const _keyDisplayName = 'auth_display_name';
  static const _keyIssuedAt = 'auth_token_issued_at';
  static const _keyIsAdmin = 'auth_is_admin';

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  }) : _apiClient = apiClient,
       _secureStorage = secureStorage;

  @override
  Future<AuthUser> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final model = AuthUserModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      final user = model.toEntity();

      await Future.wait([
        _secureStorage.write(_keyToken, user.token),
        _secureStorage.write(_keyEmail, user.email),
        _secureStorage.write(_keyDisplayName, user.displayName),
        _secureStorage.write(_keyIssuedAt, user.tokenIssuedAt.toIso8601String()),
        _secureStorage.write(_keyIsAdmin, user.isAdmin ? '1' : '0'),
      ]);

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException('Invalid email or password.');
      }
      throw const NetworkException();
    }
  }

  @override
  Future<AuthUser?> getStoredSession() async {
    final token = await _secureStorage.read(_keyToken);
    if (token == null) return null;

    final issuedAtStr = await _secureStorage.read(_keyIssuedAt);
    if (issuedAtStr == null) return null;

    final issuedAt = DateTime.tryParse(issuedAtStr);
    if (issuedAt == null) return null;

    if (DateTime.now().difference(issuedAt) > _tokenTtl) {
      await logout();
      return null;
    }

    final email = await _secureStorage.read(_keyEmail) ?? '';
    final displayName = await _secureStorage.read(_keyDisplayName) ?? '';
    final isAdminStr = await _secureStorage.read(_keyIsAdmin);
    final isAdmin = isAdminStr == '1';

    return AuthUser(
      email: email,
      displayName: displayName,
      token: token,
      tokenIssuedAt: issuedAt,
      isAdmin: isAdmin,
    );
  }

  @override
  Future<bool> isSessionValid() async {
    final issuedAtStr = await _secureStorage.read(_keyIssuedAt);
    if (issuedAtStr == null) return false;

    final issuedAt = DateTime.tryParse(issuedAtStr);
    if (issuedAt == null) return false;

    return DateTime.now().difference(issuedAt) <= _tokenTtl;
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }
}
