import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_campus/core/services/location_service.dart';
import 'package:smart_campus/core/services/permission_service.dart';

class FakePermissionService extends PermissionService {
  PermissionStatus nextStatus;
  bool nextIsPermanentlyDenied;

  FakePermissionService({
    this.nextStatus = PermissionStatus.granted,
    this.nextIsPermanentlyDenied = false,
  });

  @override
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return nextStatus;
  }

  @override
  Future<PermissionStatus> checkStatus(Permission permission) async {
    return nextStatus;
  }

  @override
  Future<bool> isPermanentlyDenied(Permission permission) async {
    return nextIsPermanentlyDenied;
  }

  @override
  Future<bool> openSettings() async => true;
}

void main() {
  group('LocationService', () {
    test('getDistanceBetween calculates distance correctly', () {
      const service = LocationService();

      // Known distance: Paris (48.8566, 2.3522) to London (51.5074, -0.1278)
      // ~343 km
      final distance = service.getDistanceBetween(
        48.8566,
        2.3522,
        51.5074,
        -0.1278,
      );

      // Should be roughly 343 km (± 5 km tolerance)
      expect(distance, greaterThan(338000));
      expect(distance, lessThan(348000));
    });

    test('getDistanceBetween returns 0 for same coordinates', () {
      const service = LocationService();

      final distance = service.getDistanceBetween(
        36.7105,
        3.1738,
        36.7105,
        3.1738,
      );

      expect(distance, equals(0.0));
    });

    test('getDistanceBetween works for short campus distances', () {
      const service = LocationService();

      // Two campus POIs ~100m apart
      final distance = service.getDistanceBetween(
        36.7105,
        3.1738,
        36.7112,
        3.1745,
      );

      // Should be roughly 80-120 meters
      expect(distance, greaterThan(50));
      expect(distance, lessThan(200));
    });

    test('checkPermission delegates to PermissionService', () async {
      final fakePermService = FakePermissionService(
        nextStatus: PermissionStatus.denied,
      );
      final service = LocationService(permissionService: fakePermService);

      final status = await service.checkPermission();
      expect(status, PermissionStatus.denied);
    });

    test('checkPermission returns granted when granted', () async {
      final fakePermService = FakePermissionService(
        nextStatus: PermissionStatus.granted,
      );
      final service = LocationService(permissionService: fakePermService);

      final status = await service.checkPermission();
      expect(status, PermissionStatus.granted);
    });
  });
}
