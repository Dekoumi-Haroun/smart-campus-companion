import 'package:permission_handler/permission_handler.dart';

/// Centralized utility for runtime permission requests.
///
/// Wraps the `permission_handler` package to provide a single API
/// that all features (camera, location, Bluetooth) use. This ensures
/// consistent behavior for denied and permanently-denied states.
///
/// Constructor accepts an optional [PermissionHandlerPlatform] override
/// for testing — production code uses the default singleton.
class PermissionService {
  const PermissionService();

  /// Requests [permission] at runtime and returns the resulting status.
  ///
  /// If the permission was already granted, returns immediately.
  Future<PermissionStatus> requestPermission(Permission permission) async {
    final current = await permission.status;
    if (current.isGranted) return current;
    return permission.request();
  }

  /// Returns the current status of [permission] without prompting the user.
  Future<PermissionStatus> checkStatus(Permission permission) {
    return permission.status;
  }

  /// Whether [permission] has been permanently denied by the user.
  ///
  /// When `true`, calling [requestPermission] will have no effect —
  /// the user must enable the permission from device settings.
  Future<bool> isPermanentlyDenied(Permission permission) async {
    return permission.isPermanentlyDenied;
  }

  /// Opens the app's system settings page so the user can manually
  /// grant a permanently-denied permission.
  Future<bool> openSettings() {
    return openAppSettings();
  }
}
