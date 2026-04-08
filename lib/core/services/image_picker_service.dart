import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_service.dart';

/// Wraps [ImagePicker] with runtime permission checks via [PermissionService].
///
/// Returns the picked file path or `null` if the user cancels or
/// the permission is denied/permanently denied.
class ImagePickerService {
  final PermissionService _permissionService;
  final ImagePicker _picker;

  ImagePickerService({
    PermissionService permissionService = const PermissionService(),
    ImagePicker? picker,
  }) : _permissionService = permissionService,
       _picker = picker ?? ImagePicker();

  /// Pick a photo from the device camera.
  ///
  /// Returns a [PickResult] with the file path on success,
  /// or permission status info on denial. Never throws — all
  /// platform exceptions are caught and returned as [PickDenied].
  Future<PickResult> pickFromCamera() async {
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
  /// Returns a [PickResult] with the file path on success,
  /// or permission status info on denial. Never throws — all
  /// platform exceptions are caught and returned as [PickDenied].
  Future<PickResult> pickFromGallery() async {
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
