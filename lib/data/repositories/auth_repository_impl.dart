import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/secure_storage_service.dart';
import '../datasources/remote/api_client.dart';
import '../models/auth_user_model.dart';

/// Concrete implementation of [AuthRepository].
///
/// Handles login via API, persists session tokens in [SecureStorageService],
/// and manages token expiry validation.
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  /// Session tokens expire after this duration.
  static const _tokenTtl = Duration(hours: 24);

  // SecureStorage keys.
  static const _keyToken = 'auth_token';
  static const _keyEmail = 'auth_email';
  static const _keyDisplayName = 'auth_display_name';
  static const _keyIssuedAt = 'auth_token_issued_at';

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

      // Persist session in secure storage.
      await Future.wait([
        _secureStorage.write(_keyToken, user.token),
        _secureStorage.write(_keyEmail, user.email),
        _secureStorage.write(_keyDisplayName, user.displayName),
        _secureStorage.write(
          _keyIssuedAt,
          user.tokenIssuedAt.toIso8601String(),
        ),
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

    // Check token expiry.
    if (DateTime.now().difference(issuedAt) > _tokenTtl) {
      await logout();
      return null;
    }

    final email = await _secureStorage.read(_keyEmail) ?? '';
    final displayName = await _secureStorage.read(_keyDisplayName) ?? '';

    return AuthUser(
      email: email,
      displayName: displayName,
      token: token,
      tokenIssuedAt: issuedAt,
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
