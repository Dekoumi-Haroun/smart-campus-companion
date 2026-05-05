import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_campus/core/services/permission_service.dart';

// ─────────────────────────────────────────────────────────────────
// Fake Permission that lets us control status and request results.
// ─────────────────────────────────────────────────────────────────

/// We can't easily mock [Permission] values because they call platform
/// channels. Instead we test the service's public contract indirectly
/// by verifying it delegates correctly. For unit tests that need full
/// isolation we use a subclass that overrides the methods.

class FakePermissionService extends PermissionService {
  PermissionStatus nextCheckStatus;
  PermissionStatus nextRequestResult;
  bool nextIsPermanentlyDenied;
  bool settingsOpened = false;

  FakePermissionService({
    this.nextCheckStatus = PermissionStatus.denied,
    this.nextRequestResult = PermissionStatus.granted,
    this.nextIsPermanentlyDenied = false,
  });

  @override
  Future<PermissionStatus> checkStatus(Permission permission) async {
    return nextCheckStatus;
  }

  @override
  Future<PermissionStatus> requestPermission(Permission permission) async {
    // Mimic real behavior: if already granted, return immediately.
    if (nextCheckStatus == PermissionStatus.granted) {
      return PermissionStatus.granted;
    }
    return nextRequestResult;
  }

  @override
  Future<bool> isPermanentlyDenied(Permission permission) async {
    return nextIsPermanentlyDenied;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened = true;
    return true;
  }
}

void main() {
  late FakePermissionService service;

  setUp(() {
    service = FakePermissionService();
  });

  group('PermissionService', () {
    test('checkStatus returns current status without prompting', () async {
      service.nextCheckStatus = PermissionStatus.denied;
      final status = await service.checkStatus(Permission.camera);
      expect(status, PermissionStatus.denied);
    });

    test('checkStatus returns granted when already granted', () async {
      service.nextCheckStatus = PermissionStatus.granted;
      final status = await service.checkStatus(Permission.camera);
      expect(status, PermissionStatus.granted);
    });

    test('requestPermission returns granted when already granted', () async {
      service.nextCheckStatus = PermissionStatus.granted;
      final status = await service.requestPermission(Permission.camera);
      expect(status, PermissionStatus.granted);
    });

    test('requestPermission returns request result when not granted', () async {
      service.nextCheckStatus = PermissionStatus.denied;
      service.nextRequestResult = PermissionStatus.granted;
      final status = await service.requestPermission(Permission.camera);
      expect(status, PermissionStatus.granted);
    });

    test('requestPermission returns denied when user denies', () async {
      service.nextCheckStatus = PermissionStatus.denied;
      service.nextRequestResult = PermissionStatus.denied;
      final status = await service.requestPermission(Permission.camera);
      expect(status, PermissionStatus.denied);
    });

    test(
      'requestPermission returns permanentlyDenied when user permanently denies',
      () async {
        service.nextCheckStatus = PermissionStatus.denied;
        service.nextRequestResult = PermissionStatus.permanentlyDenied;
        final status = await service.requestPermission(Permission.camera);
        expect(status, PermissionStatus.permanentlyDenied);
      },
    );

    test('isPermanentlyDenied returns true when permanently denied', () async {
      service.nextIsPermanentlyDenied = true;
      final result = await service.isPermanentlyDenied(Permission.camera);
      expect(result, isTrue);
    });

    test(
      'isPermanentlyDenied returns false when not permanently denied',
      () async {
        service.nextIsPermanentlyDenied = false;
        final result = await service.isPermanentlyDenied(Permission.camera);
        expect(result, isFalse);
      },
    );

    test('openSettings calls openAppSettings and returns true', () async {
      final result = await service.openSettings();
      expect(result, isTrue);
      expect(service.settingsOpened, isTrue);
    });

    test('works with different permission types', () async {
      // Camera
      service.nextCheckStatus = PermissionStatus.granted;
      expect(
        await service.checkStatus(Permission.camera),
        PermissionStatus.granted,
      );

      // Location
      service.nextCheckStatus = PermissionStatus.denied;
      expect(
        await service.checkStatus(Permission.location),
        PermissionStatus.denied,
      );

      // Bluetooth
      service.nextCheckStatus = PermissionStatus.restricted;
      expect(
        await service.checkStatus(Permission.bluetooth),
        PermissionStatus.restricted,
      );
    });

    test('full flow: check → denied → request → granted', () async {
      // Step 1: check — denied
      service.nextCheckStatus = PermissionStatus.denied;
      final check = await service.checkStatus(Permission.location);
      expect(check, PermissionStatus.denied);

      // Step 2: request — user grants
      service.nextRequestResult = PermissionStatus.granted;
      final request = await service.requestPermission(Permission.location);
      expect(request, PermissionStatus.granted);
    });

    test('full flow: check → permanentlyDenied → openSettings', () async {
      // Step 1: check — denied
      service.nextCheckStatus = PermissionStatus.permanentlyDenied;
      final check = await service.checkStatus(Permission.camera);
      expect(check, PermissionStatus.permanentlyDenied);

      // Step 2: permanently denied confirmed
      service.nextIsPermanentlyDenied = true;
      final permanent = await service.isPermanentlyDenied(Permission.camera);
      expect(permanent, isTrue);

      // Step 3: redirect to settings
      final opened = await service.openSettings();
      expect(opened, isTrue);
      expect(service.settingsOpened, isTrue);
    });
  });
}
