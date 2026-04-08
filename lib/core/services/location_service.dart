import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    show Permission, PermissionStatus, PermissionStatusGetters;

import 'permission_service.dart';

/// Wraps [Geolocator] with permission checks via [PermissionService].
///
/// Provides current position, distance calculations, and
/// GPS-enabled checks. Returns `null` when location is denied.
class LocationService {
  final PermissionService _permissionService;

  const LocationService({
    PermissionService permissionService = const PermissionService(),
  }) : _permissionService = permissionService;

  /// Requests location permission and returns the current position.
  ///
  /// Returns `null` if permission is denied or location services are off.
  Future<LocationResult> getCurrentPosition() async {
    // Check if location services are enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult.serviceDisabled();
    }

    final status = await _permissionService.requestPermission(
      Permission.location,
    );
    if (!status.isGranted) {
      return LocationResult.denied(
        isPermanentlyDenied: status.isPermanentlyDenied,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return LocationResult.success(position);
  }

  /// Calculates the distance in meters between two coordinates.
  double getDistanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Checks whether location services (GPS) are currently enabled.
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Checks the current location permission status without prompting.
  Future<PermissionStatus> checkPermission() {
    return _permissionService.checkStatus(Permission.location);
  }
}

/// Result of a location request.
sealed class LocationResult {
  const LocationResult();

  const factory LocationResult.success(Position position) = LocationSuccess;
  const factory LocationResult.denied({bool isPermanentlyDenied}) =
      LocationDenied;
  const factory LocationResult.serviceDisabled() = LocationServiceDisabled;
}

class LocationSuccess extends LocationResult {
  final Position position;
  const LocationSuccess(this.position);
}

class LocationDenied extends LocationResult {
  final bool isPermanentlyDenied;
  const LocationDenied({this.isPermanentlyDenied = false});
}

class LocationServiceDisabled extends LocationResult {
  const LocationServiceDisabled();
}
