import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/repositories/settings_repository.dart';
import 'feature_permission_service.dart';
import 'permission_service.dart';

/// Wraps [ImagePicker] with runtime permission checks via [PermissionService].
///
/// Returns the picked file path or `null` if the user cancels or
/// the permission is denied/permanently denied.
///
/// An optional [SettingsRepository] lets the service respect the
/// in-app "Revoke Camera Permission" toggle — when set, the pick
/// short-circuits with [PickRevoked] so callers can route the user
/// back to Settings → Permissions instead of silently failing.
class ImagePickerService {
  final PermissionService _permissionService;
  final ImagePicker _picker;
  final SettingsRepository? _settings;

  ImagePickerService({
    PermissionService permissionService = const PermissionService(),
    ImagePicker? picker,
    SettingsRepository? settings,
  }) : _permissionService = permissionService,
       _picker = picker ?? ImagePicker(),
       _settings = settings;

  /// Pick a photo from the device camera.
  ///
  /// Returns a [PickResult] with the file path on success, or a
  /// structured denial on failure. Never throws — all platform
  /// exceptions are caught and returned as [PickDenied].
  Future<PickResult> pickFromCamera() async {
    if (_settings?.getCameraRevoked() ?? false) {
      return const PickResult.revoked(feature: FeatureKey.camera);
    }
    try {
      final status = await _permissionService.requestPermission(
        Permission.camera,
      );
      if (!status.isGranted) {
        return PickResult.denied(
          isPermanentlyDenied: status.isPermanentlyDenied,
        );
      }
      final file = await _picker.pickImage(source: ImageSource.camera);
      if (file == null) return const PickResult.cancelled();
      return PickResult.success(file.path);
    } catch (_) {
      // Platform channel or device error — treat as denied.
      return const PickResult.denied();
    }
  }

  /// Pick a photo from the device gallery.
  ///
  /// Gallery access rides on the same in-app Camera toggle because
  /// both surfaces satisfy the "attach a photo" feature, and we want
  /// a single revoke switch — not one per picker source.
  Future<PickResult> pickFromGallery() async {
    if (_settings?.getCameraRevoked() ?? false) {
      return const PickResult.revoked(feature: FeatureKey.camera);
    }
    try {
      final status = await _permissionService.requestPermission(
        Permission.photos,
      );
      // On some platforms photos permission may not be needed,
      // so also try if status is limited or not applicable.
      if (status.isDenied || status.isPermanentlyDenied) {
        // Fallback: try picking directly — some platforms don't require
        // explicit photos permission for the image picker.
        final file = await _picker.pickImage(source: ImageSource.gallery);
        if (file != null) return PickResult.success(file.path);
        return PickResult.denied(
          isPermanentlyDenied: status.isPermanentlyDenied,
        );
      }
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return const PickResult.cancelled();
      return PickResult.success(file.path);
    } catch (_) {
      return const PickResult.denied();
    }
  }
}

/// Result of an image pick operation.
sealed class PickResult {
  const PickResult();

  const factory PickResult.success(String path) = PickSuccess;
  const factory PickResult.denied({bool isPermanentlyDenied}) = PickDenied;
  const factory PickResult.cancelled() = PickCancelled;
  const factory PickResult.revoked({required FeatureKey feature}) = PickRevoked;
}

class PickSuccess extends PickResult {
  final String path;
  const PickSuccess(this.path);
}

class PickDenied extends PickResult {
  final bool isPermanentlyDenied;
  const PickDenied({this.isPermanentlyDenied = false});
}

class PickCancelled extends PickResult {
  const PickCancelled();
}

/// User revoked the in-app Camera permission from Settings. Callers
/// should not prompt the OS — they should tell the user where to flip
/// the app switch back on.
class PickRevoked extends PickResult {
  final FeatureKey feature;
  const PickRevoked({required this.feature});
}
