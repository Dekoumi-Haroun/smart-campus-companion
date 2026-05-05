import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    show Permission, PermissionStatus, PermissionStatusGetters;

import '../../data/repositories/settings_repository.dart';
import 'feature_permission_service.dart';
import 'permission_service.dart';

/// Wraps [Geolocator] with permission checks via [PermissionService].
///
/// Provides current position, distance calculations, and
/// GPS-enabled checks. Returns `null` when location is denied.
///
/// An optional [SettingsRepository] lets the service honor the in-app
/// "Revoke Location Permission" toggle: when the flag is set, the call
/// short-circuits with [LocationRevoked] instead of prompting the OS,
/// matching the image picker's Camera gate.
class LocationService {
  final PermissionService _permissionService;
  final SettingsRepository? _settings;

  const LocationService({
    PermissionService permissionService = const PermissionService(),
    SettingsRepository? settings,
  }) : _permissionService = permissionService,
       _settings = settings;

  /// Requests location permission and returns the current position.
  ///
  /// Never throws — all platform exceptions (timeout, service disabled,
  /// permission errors) are caught and returned as the appropriate
  /// [LocationResult] variant.
  Future<LocationResult> getCurrentPosition() async {
    if (_settings?.getLocationRevoked() ?? false) {
      return const LocationResult.revoked(feature: FeatureKey.location);
    }
    try {
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
    } on LocationServiceDisabledException {
      return const LocationResult.serviceDisabled();
    } on PermissionDeniedException {
      return const LocationResult.denied();
    } catch (_) {
      // Timeout, platform error, or other unexpected failure.
      return const LocationResult.denied();
    }
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
  const factory LocationResult.revoked({required FeatureKey feature}) =
      LocationRevoked;
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

/// User revoked the in-app Location toggle. Callers should route the
/// user to Settings → Permissions instead of prompting the OS.
class LocationRevoked extends LocationResult {
  final FeatureKey feature;
  const LocationRevoked({required this.feature});
}
