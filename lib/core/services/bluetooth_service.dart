import 'package:permission_handler/permission_handler.dart';

import 'permission_service.dart';

/// Simple wrapper for Bluetooth status checks.
///
/// Uses [PermissionService] to request Bluetooth permissions and
/// checks adapter availability via the permission system.
class BluetoothService {
  final PermissionService _permissionService;

  const BluetoothService({
    PermissionService permissionService = const PermissionService(),
  }) : _permissionService = permissionService;

  /// Permissions that gate the beacon-style Bluetooth features we'd use.
  ///
  /// `Permission.bluetooth` is the pre-Android-12 flag; `bluetoothScan`
  /// and `bluetoothConnect` are the runtime prompts introduced in API 31.
  /// On older Android versions the newer permissions simply report
  /// granted, so requesting all three produces the right UX everywhere.
  static const List<Permission> _btPermissions = [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
  ];

  /// Checks if every required Bluetooth permission is already granted.
  ///
  /// Never throws — platform errors return [BluetoothStatus.unavailable].
  Future<BluetoothStatus> checkStatus() async {
    try {
      final statuses = await Future.wait(
        _btPermissions.map(_permissionService.checkStatus),
      );
      return _fold(statuses);
    } catch (_) {
      return BluetoothStatus.unavailable;
    }
  }

  /// Prompts for every required Bluetooth permission and returns the
  /// aggregate outcome. Permissions already granted are skipped by
  /// [PermissionService.requestPermission].
  ///
  /// Never throws — platform errors return [BluetoothStatus.unavailable].
  Future<BluetoothStatus> requestPermission() async {
    try {
      final statuses = <PermissionStatus>[];
      for (final p in _btPermissions) {
        statuses.add(await _permissionService.requestPermission(p));
      }
      return _fold(statuses);
    } catch (_) {
      return BluetoothStatus.unavailable;
    }
  }

  /// Reduces multiple permission statuses to a single [BluetoothStatus].
  /// Worst-wins: permanent denial beats regular denial beats unavailable.
  BluetoothStatus _fold(List<PermissionStatus> statuses) {
    if (statuses.any((s) => s.isPermanentlyDenied)) {
      return BluetoothStatus.permissionDenied;
    }
    if (statuses.every((s) => s.isGranted)) return BluetoothStatus.available;
    return BluetoothStatus.unavailable;
  }
}

enum BluetoothStatus { available, unavailable, permissionDenied }
