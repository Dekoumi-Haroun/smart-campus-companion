import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/data/datasources/local/secure_storage_service.dart';
import 'package:smart_campus/data/datasources/remote/api_client.dart';
import 'package:smart_campus/data/repositories/auth_repository_impl.dart';
import 'package:smart_campus/core/errors/app_exceptions.dart';

/// A fake [FlutterSecureStorage] backed by an in-memory map.
class FakeFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

  FakeFlutterSecureStorage() : super();

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _store[key] = value;
    } else {
      _store.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.clear();
  }
}

void main() {
  late FakeFlutterSecureStorage fakeStorage;
  late SecureStorageService secureStorageService;
  late ApiClient apiClient;
  late AuthRepositoryImpl repo;

  setUp(() {
    fakeStorage = FakeFlutterSecureStorage();
    secureStorageService = SecureStorageService(storage: fakeStorage);
    apiClient = ApiClient();
    repo = AuthRepositoryImpl(
      apiClient: apiClient,
      secureStorage: secureStorageService,
    );
  });

  group('AuthRepositoryImpl', () {
    test(
      'login with valid credentials stores session and returns user',
      () async {
        final user = await repo.login('student@smartcampus.dev', 'campus123');

        expect(user.email, 'student@smartcampus.dev');
        expect(user.displayName, 'Maxframe');
        expect(user.token, isNotEmpty);

        // Verify stored in secure storage.
        final storedToken = await secureStorageService.read('auth_token');
        expect(storedToken, isNotNull);
      },
    );

    test('login with invalid credentials throws AuthException', () async {
      expect(
        () => repo.login('wrong@email.com', 'badpassword'),
        throwsA(isA<AuthException>()),
      );
    });

    test('getStoredSession returns user after login', () async {
      await repo.login('student@smartcampus.dev', 'campus123');
      final user = await repo.getStoredSession();

      expect(user, isNotNull);
      expect(user!.email, 'student@smartcampus.dev');
    });

    test('getStoredSession returns null when no session', () async {
      final user = await repo.getStoredSession();
      expect(user, isNull);
    });

    test('isSessionValid returns true after fresh login', () async {
      await repo.login('student@smartcampus.dev', 'campus123');
      final valid = await repo.isSessionValid();
      expect(valid, isTrue);
    });

    test('isSessionValid returns false when no session', () async {
      final valid = await repo.isSessionValid();
      expect(valid, isFalse);
    });

    test('logout clears all stored session data', () async {
      await repo.login('student@smartcampus.dev', 'campus123');
      await repo.logout();

      final user = await repo.getStoredSession();
      expect(user, isNull);

      final token = await secureStorageService.read('auth_token');
      expect(token, isNull);
    });
  });
}
