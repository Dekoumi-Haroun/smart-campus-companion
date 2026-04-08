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

  /// Checks if Bluetooth permission is granted.
  ///
  /// Never throws — platform errors return [BluetoothStatus.unavailable].
  Future<BluetoothStatus> checkStatus() async {
    try {
      final status = await _permissionService.checkStatus(Permission.bluetooth);
      if (status.isGranted) return BluetoothStatus.available;
      if (status.isPermanentlyDenied) return BluetoothStatus.permissionDenied;
      return BluetoothStatus.unavailable;
    } catch (_) {
      return BluetoothStatus.unavailable;
    }
  }

  /// Requests Bluetooth permission and returns the resulting status.
  ///
  /// Never throws — platform errors return [BluetoothStatus.unavailable].
  Future<BluetoothStatus> requestPermission() async {
    try {
      final status = await _permissionService.requestPermission(
        Permission.bluetooth,
      );
      if (status.isGranted) return BluetoothStatus.available;
      if (status.isPermanentlyDenied) return BluetoothStatus.permissionDenied;
      return BluetoothStatus.unavailable;
    } catch (_) {
      return BluetoothStatus.unavailable;
    }
  }
}

enum BluetoothStatus { available, unavailable, permissionDenied }
