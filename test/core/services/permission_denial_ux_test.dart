import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_campus/core/services/bluetooth_service.dart';
import 'package:smart_campus/core/services/image_picker_service.dart';
import 'package:smart_campus/core/services/permission_service.dart';

// ═══════════════════════════════════════════════════════════════════
// FAKES
// ═══════════════════════════════════════════════════════════════════

class FakePermissionService extends PermissionService {
  PermissionStatus nextCheckStatus;
  PermissionStatus nextRequestStatus;
  bool settingsOpened = false;

  FakePermissionService({
    this.nextCheckStatus = PermissionStatus.denied,
    this.nextRequestStatus = PermissionStatus.denied,
  });

  @override
  Future<PermissionStatus> checkStatus(Permission permission) async {
    return nextCheckStatus;
  }

  @override
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return nextRequestStatus;
  }

  @override
  Future<bool> isPermanentlyDenied(Permission permission) async {
    return nextCheckStatus == PermissionStatus.permanentlyDenied;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened = true;
    return true;
  }
}

class FakeThrowingPermissionService extends PermissionService {
  @override
  Future<PermissionStatus> checkStatus(Permission permission) async {
    throw Exception('Platform error');
  }

  @override
  Future<PermissionStatus> requestPermission(Permission permission) async {
    throw Exception('Platform error');
  }

  @override
  Future<bool> isPermanentlyDenied(Permission permission) async {
    throw Exception('Platform error');
  }

  @override
  Future<bool> openSettings() async => false;
}

void main() {
  group('Permission Denial UX — Camera (ImagePickerService)', () {
    test('pickFromCamera returns PickDenied when permission denied', () async {
      final fakePermService = FakePermissionService(
        nextRequestStatus: PermissionStatus.denied,
      );
      final service = ImagePickerService(permissionService: fakePermService);

      final result = await service.pickFromCamera();
      expect(result, isA<PickDenied>());
      expect((result as PickDenied).isPermanentlyDenied, isFalse);
    });

    test(
      'pickFromCamera returns PickDenied with isPermanentlyDenied when permanent',
      () async {
        final fakePermService = FakePermissionService(
          nextRequestStatus: PermissionStatus.permanentlyDenied,
        );
        final service = ImagePickerService(permissionService: fakePermService);

        final result = await service.pickFromCamera();
        expect(result, isA<PickDenied>());
        expect((result as PickDenied).isPermanentlyDenied, isTrue);
      },
    );

    test('pickFromCamera returns PickDenied on platform exception', () async {
      final service = ImagePickerService(
        permissionService: FakeThrowingPermissionService(),
      );

      final result = await service.pickFromCamera();
      expect(result, isA<PickDenied>());
    });

    test('pickFromGallery returns PickDenied on platform exception', () async {
      final service = ImagePickerService(
        permissionService: FakeThrowingPermissionService(),
      );

      final result = await service.pickFromGallery();
      expect(result, isA<PickDenied>());
    });
  });

  group('Permission Denial UX — Bluetooth (BluetoothService)', () {
    test('checkStatus returns unavailable when denied', () async {
      final fakePermService = FakePermissionService(
        nextCheckStatus: PermissionStatus.denied,
      );
      final service = BluetoothService(permissionService: fakePermService);

      final status = await service.checkStatus();
      expect(status, BluetoothStatus.unavailable);
    });

    test(
      'checkStatus returns permissionDenied when permanently denied',
      () async {
        final fakePermService = FakePermissionService(
          nextCheckStatus: PermissionStatus.permanentlyDenied,
        );
        final service = BluetoothService(permissionService: fakePermService);

        final status = await service.checkStatus();
        expect(status, BluetoothStatus.permissionDenied);
      },
    );

    test('requestPermission returns available after re-granting', () async {
      final fakePermService = FakePermissionService(
        nextCheckStatus: PermissionStatus.denied,
        nextRequestStatus: PermissionStatus.denied,
      );
      final service = BluetoothService(permissionService: fakePermService);

      // First: denied
      var status = await service.requestPermission();
      expect(status, BluetoothStatus.unavailable);

      // User grants via settings
      fakePermService.nextRequestStatus = PermissionStatus.granted;
      status = await service.requestPermission();
      expect(status, BluetoothStatus.available);
    });

    test('checkStatus returns unavailable on platform exception', () async {
      final service = BluetoothService(
        permissionService: FakeThrowingPermissionService(),
      );

      final status = await service.checkStatus();
      expect(status, BluetoothStatus.unavailable);
    });

    test(
      'requestPermission returns unavailable on platform exception',
      () async {
        final service = BluetoothService(
          permissionService: FakeThrowingPermissionService(),
        );

        final status = await service.requestPermission();
        expect(status, BluetoothStatus.unavailable);
      },
    );
  });

  group('Permission Denial UX — PermissionService edge cases', () {
    test('openSettings tracks call correctly', () async {
      final fakeService = FakePermissionService();
      expect(fakeService.settingsOpened, isFalse);

      await fakeService.openSettings();
      expect(fakeService.settingsOpened, isTrue);
    });

    test(
      'full denial flow: denied → permanently denied → open settings',
      () async {
        final fakeService = FakePermissionService(
          nextCheckStatus: PermissionStatus.denied,
          nextRequestStatus: PermissionStatus.denied,
        );

        // Step 1: soft denial
        var status = await fakeService.requestPermission(Permission.camera);
        expect(status, PermissionStatus.denied);

        // Step 2: permanent denial
        fakeService.nextRequestStatus = PermissionStatus.permanentlyDenied;
        status = await fakeService.requestPermission(Permission.camera);
        expect(status, PermissionStatus.permanentlyDenied);

        // Step 3: redirect to settings
        final opened = await fakeService.openSettings();
        expect(opened, isTrue);
        expect(fakeService.settingsOpened, isTrue);
      },
    );

    test('re-granting after denial returns granted status', () async {
      final fakeService = FakePermissionService(
        nextCheckStatus: PermissionStatus.denied,
        nextRequestStatus: PermissionStatus.denied,
      );

      // Denied first
      var status = await fakeService.requestPermission(Permission.location);
      expect(status, PermissionStatus.denied);

      // User enables via settings
      fakeService.nextRequestStatus = PermissionStatus.granted;
      fakeService.nextCheckStatus = PermissionStatus.granted;

      // Now granted
      status = await fakeService.checkStatus(Permission.location);
      expect(status, PermissionStatus.granted);

      status = await fakeService.requestPermission(Permission.location);
      expect(status, PermissionStatus.granted);
    });
  });
}
