import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_campus/core/services/bluetooth_service.dart';
import 'package:smart_campus/core/services/feature_permission_service.dart';
import 'package:smart_campus/core/services/permission_service.dart';
import 'package:smart_campus/data/repositories/settings_repository.dart';

/// A [PermissionService] whose answers are driven per-[Permission].
/// Matches the production signature so the service can be swapped
/// in for any feature key without platform channels getting involved.
class _FakePermissionService extends PermissionService {
  final Map<Permission, PermissionStatus> answers;

  _FakePermissionService(this.answers);

  @override
  Future<PermissionStatus> checkStatus(Permission p) async {
    return answers[p] ?? PermissionStatus.denied;
  }

  @override
  Future<PermissionStatus> requestPermission(Permission p) async {
    return answers[p] ?? PermissionStatus.denied;
  }
}

void main() {
  late SettingsRepository settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsRepository();
    await settings.init();
  });

  // ────────────────────────── Bluetooth ───────────────────────────

  group('FeaturePermissionService.status — bluetooth', () {
    test('OS permanent denial trumps the in-app opt-in flag '
        '(regression: state used to flip to revokedByApp when the toggle '
        'handler wrote enabled=false after an OS-level block)', () async {
      await settings.setBluetoothRequested(true);
      await settings.setBluetoothEnabled(false);

      final perms = _FakePermissionService({
        // Any one permanently-denied sub-permission folds the whole
        // bucket to BluetoothStatus.permissionDenied.
        Permission.bluetoothScan: PermissionStatus.permanentlyDenied,
        Permission.bluetooth: PermissionStatus.granted,
        Permission.bluetoothConnect: PermissionStatus.granted,
      });
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      final status = await service.status(FeatureKey.bluetooth);
      expect(status.state, FeatureState.permanentlyDenied);
      expect(status.needsSystemSettings, isTrue);
    });

    test('not requested yet → notRequested (no OS block)', () async {
      final perms = _FakePermissionService({
        Permission.bluetooth: PermissionStatus.denied,
        Permission.bluetoothScan: PermissionStatus.denied,
        Permission.bluetoothConnect: PermissionStatus.denied,
      });
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      final status = await service.status(FeatureKey.bluetooth);
      expect(status.state, FeatureState.notRequested);
    });

    test('prompted then opted out → revokedByApp', () async {
      await settings.setBluetoothRequested(true);
      await settings.setBluetoothEnabled(false);

      final perms = _FakePermissionService({
        Permission.bluetooth: PermissionStatus.granted,
        Permission.bluetoothScan: PermissionStatus.granted,
        Permission.bluetoothConnect: PermissionStatus.granted,
      });
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      final status = await service.status(FeatureKey.bluetooth);
      expect(status.state, FeatureState.revokedByApp);
    });

    test('opted in + OS granted → granted', () async {
      await settings.setBluetoothRequested(true);
      await settings.setBluetoothEnabled(true);

      final perms = _FakePermissionService({
        Permission.bluetooth: PermissionStatus.granted,
        Permission.bluetoothScan: PermissionStatus.granted,
        Permission.bluetoothConnect: PermissionStatus.granted,
      });
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      final status = await service.status(FeatureKey.bluetooth);
      expect(status.state, FeatureState.granted);
      expect(status.isUsable, isTrue);
    });
  });

  // ───────────────────────── Location / Camera ────────────────────

  group('FeaturePermissionService.status — location', () {
    test('OS denied + never prompted → notRequested '
        '(regression: used to hardcode hasBeenRequested=true and surface '
        'the alarming red "Denied" pill on a fresh install)', () async {
      final perms = _FakePermissionService({
        Permission.location: PermissionStatus.denied,
      });
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      final status = await service.status(FeatureKey.location);
      expect(status.state, FeatureState.notRequested);
    });

    test('OS denied + has been prompted → denied', () async {
      await settings.setLocationRequested(true);
      final perms = _FakePermissionService({
        Permission.location: PermissionStatus.denied,
      });
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      final status = await service.status(FeatureKey.location);
      expect(status.state, FeatureState.denied);
    });

    test('app-level revoked trumps OS grant', () async {
      await settings.setLocationRequested(true);
      await settings.setLocationRevoked(true);
      final perms = _FakePermissionService({
        Permission.location: PermissionStatus.granted,
      });
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      final status = await service.status(FeatureKey.location);
      expect(status.state, FeatureState.revokedByApp);
    });

    test('grant stamps the has-been-requested flag', () async {
      expect(settings.getLocationRequested(), isFalse);
      final perms = _FakePermissionService({
        Permission.location: PermissionStatus.granted,
      });
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      await service.grant(FeatureKey.location);
      expect(settings.getLocationRequested(), isTrue);
    });
  });

  group('FeaturePermissionService.status — camera', () {
    test('OS denied + never prompted → notRequested', () async {
      final perms = _FakePermissionService({
        Permission.camera: PermissionStatus.denied,
      });
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      final status = await service.status(FeatureKey.camera);
      expect(status.state, FeatureState.notRequested);
    });

    test('grant stamps the has-been-requested flag', () async {
      expect(settings.getCameraRequested(), isFalse);
      final perms = _FakePermissionService({
        Permission.camera: PermissionStatus.granted,
      });
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      await service.grant(FeatureKey.camera);
      expect(settings.getCameraRequested(), isTrue);
    });
  });

  // ─────────────────────────── Sensors ────────────────────────────

  group('FeaturePermissionService.status — sensors', () {
    test('always reports auto (no runtime permission)', () async {
      final perms = _FakePermissionService(const {});
      final service = FeaturePermissionService(
        settings: settings,
        permissions: perms,
        bluetooth: BluetoothService(permissionService: perms),
      );

      final status = await service.status(FeatureKey.sensors);
      expect(status.state, FeatureState.auto);
      expect(status.isUsable, isTrue);
    });
  });
}
