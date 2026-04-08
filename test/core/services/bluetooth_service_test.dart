import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_campus/core/services/bluetooth_service.dart';
import 'package:smart_campus/core/services/permission_service.dart';

class FakePermissionService extends PermissionService {
  PermissionStatus nextCheckStatus;
  PermissionStatus nextRequestStatus;

  FakePermissionService({
    this.nextCheckStatus = PermissionStatus.denied,
    this.nextRequestStatus = PermissionStatus.granted,
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
  Future<bool> openSettings() async => true;
}

void main() {
  late FakePermissionService fakePermService;
  late BluetoothService service;

  setUp(() {
    fakePermService = FakePermissionService();
    service = BluetoothService(permissionService: fakePermService);
  });

  group('BluetoothService', () {
    test('checkStatus returns available when granted', () async {
      fakePermService.nextCheckStatus = PermissionStatus.granted;
      final status = await service.checkStatus();
      expect(status, BluetoothStatus.available);
    });

    test('checkStatus returns unavailable when denied', () async {
      fakePermService.nextCheckStatus = PermissionStatus.denied;
      final status = await service.checkStatus();
      expect(status, BluetoothStatus.unavailable);
    });

    test(
      'checkStatus returns permissionDenied when permanently denied',
      () async {
        fakePermService.nextCheckStatus = PermissionStatus.permanentlyDenied;
        final status = await service.checkStatus();
        expect(status, BluetoothStatus.permissionDenied);
      },
    );

    test('requestPermission returns available when user grants', () async {
      fakePermService.nextRequestStatus = PermissionStatus.granted;
      final status = await service.requestPermission();
      expect(status, BluetoothStatus.available);
    });

    test('requestPermission returns unavailable when user denies', () async {
      fakePermService.nextRequestStatus = PermissionStatus.denied;
      final status = await service.requestPermission();
      expect(status, BluetoothStatus.unavailable);
    });

    test(
      'requestPermission returns permissionDenied when permanently denied',
      () async {
        fakePermService.nextRequestStatus = PermissionStatus.permanentlyDenied;
        final status = await service.requestPermission();
        expect(status, BluetoothStatus.permissionDenied);
      },
    );
  });
}
