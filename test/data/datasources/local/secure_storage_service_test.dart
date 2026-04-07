import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/data/datasources/local/secure_storage_service.dart';

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
  late SecureStorageService service;

  setUp(() {
    fakeStorage = FakeFlutterSecureStorage();
    service = SecureStorageService(storage: fakeStorage);
  });

  group('SecureStorageService', () {
    test('read returns null for a missing key', () async {
      final result = await service.read('missing');
      expect(result, isNull);
    });

    test('write then read returns the stored value', () async {
      await service.write('token', 'abc123');
      final result = await service.read('token');
      expect(result, 'abc123');
    });

    test('write overwrites an existing value', () async {
      await service.write('token', 'old');
      await service.write('token', 'new');
      final result = await service.read('token');
      expect(result, 'new');
    });

    test('delete removes a specific key', () async {
      await service.write('a', '1');
      await service.write('b', '2');
      await service.delete('a');
      expect(await service.read('a'), isNull);
      expect(await service.read('b'), '2');
    });

    test('deleteAll clears all stored values', () async {
      await service.write('a', '1');
      await service.write('b', '2');
      await service.deleteAll();
      expect(await service.read('a'), isNull);
      expect(await service.read('b'), isNull);
    });
  });
}
