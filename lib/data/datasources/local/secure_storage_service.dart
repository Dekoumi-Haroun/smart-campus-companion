import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// OWASP: Tokens and sensitive credentials are stored via platform-native
// secure storage (iOS Keychain / Android EncryptedSharedPreferences).
// Never log token values. deleteAll() is used on logout to prevent
// token leakage. No sensitive data is persisted in plain SharedPreferences.

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();
}
