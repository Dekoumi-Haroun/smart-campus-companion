import 'package:permission_handler/permission_handler.dart';

import '../../data/repositories/settings_repository.dart';
import 'background_task_service.dart';
import 'bluetooth_service.dart';
import 'notification_service.dart';
import 'permission_service.dart';

/// The features the app gates on a permission / consent.
///
/// Each feature has its own mapping from [FeatureKey] to the relevant
/// OS permission, the app-level revocation flag (if any), and the
/// side-effects that run on grant/revoke (e.g. cancelling scheduled
/// notifications when the user revokes Notifications).
enum FeatureKey { location, camera, notifications, bluetooth, sensors }

/// The bucket a feature falls into, used by both the UI pill and the
/// feature services that early-out when the user has revoked access.
enum FeatureState {
  /// OS granted AND user hasn't revoked in-app. Feature is usable.
  granted,

  /// No runtime prompt required (e.g. accelerometer). Always usable.
  auto,

  /// OS said yes, but the user later flipped the in-app Revoke toggle.
  revokedByApp,

  /// OS said no (denied) and/or the user has never been prompted.
  denied,

  /// Same as [denied] but it was never requested on this install.
  notRequested,

  /// OS denied with the "don't ask again" checkbox ticked. Only the
  /// app settings screen can recover this.
  permanentlyDenied,

  /// OS reports the permission as restricted (e.g. parental controls).
  restricted,
}

/// A read-only snapshot of a feature's effective status.
class FeatureStatus {
  final FeatureKey key;
  final FeatureState state;

  const FeatureStatus({required this.key, required this.state});

  /// True when calling the underlying API is expected to succeed.
  bool get isUsable =>
      state == FeatureState.granted || state == FeatureState.auto;

  /// True when the user's own in-app toggle is the blocker.
  bool get isRevokedByApp => state == FeatureState.revokedByApp;

  /// True when the OS needs the system-settings page to recover.
  bool get needsSystemSettings => state == FeatureState.permanentlyDenied;
}

/// Result of a grant/revoke action invoked from the UI.
enum FeatureActionResult {
  /// Feature is now usable.
  granted,

  /// App-level revoke succeeded; OS permission may still be granted.
  revoked,

  /// User declined the OS prompt.
  denied,

  /// OS prompt is no longer available; send the user to system settings.
  permanentlyDenied,

  /// Feature has no permission to grant (e.g. sensors).
  notApplicable,
}

/// Single source of truth for every permission-gated feature.
///
/// The service composes three collaborators:
///
///   * [PermissionService] — raw `permission_handler` reads/writes.
///   * [SettingsRepository] — app-level revocation + consent flags.
///   * Feature-specific side-effect services (notifications, bluetooth)
///     that need to tear down scheduled work on revoke and start it up
///     again on grant.
///
/// Call sites ask [status] before performing an action, and route
/// user-visible grant/revoke taps through [grant] and [revoke]. The
/// rest of the app never talks to `permission_handler` directly.
class FeaturePermissionService {
  final PermissionService _permissions;
  final SettingsRepository _settings;
  final BluetoothService _bluetooth;

  FeaturePermissionService({
    required SettingsRepository settings,
    PermissionService permissions = const PermissionService(),
    BluetoothService? bluetooth,
  }) : _settings = settings,
       _permissions = permissions,
       _bluetooth = bluetooth ?? const BluetoothService();

  /// Returns the effective [FeatureStatus] for [key].
  Future<FeatureStatus> status(FeatureKey key) async {
    switch (key) {
      case FeatureKey.sensors:
        return const FeatureStatus(
          key: FeatureKey.sensors,
          state: FeatureState.auto,
        );

      case FeatureKey.location:
        if (_settings.getLocationRevoked()) {
          return const FeatureStatus(
            key: FeatureKey.location,
            state: FeatureState.revokedByApp,
          );
        }
        final os = await _permissions.checkStatus(Permission.location);
        return FeatureStatus(
          key: FeatureKey.location,
          state: _foldOsStatus(
            os,
            hasBeenRequested: _settings.getLocationRequested(),
          ),
        );

      case FeatureKey.camera:
        if (_settings.getCameraRevoked()) {
          return const FeatureStatus(
            key: FeatureKey.camera,
            state: FeatureState.revokedByApp,
          );
        }
        final os = await _permissions.checkStatus(Permission.camera);
        return FeatureStatus(
          key: FeatureKey.camera,
          state: _foldOsStatus(
            os,
            hasBeenRequested: _settings.getCameraRequested(),
          ),
        );

      case FeatureKey.notifications:
        if (!_settings.getNotificationsEnabled()) {
          return const FeatureStatus(
            key: FeatureKey.notifications,
            state: FeatureState.revokedByApp,
          );
        }
        final os = await _permissions.checkStatus(Permission.notification);
        return FeatureStatus(
          key: FeatureKey.notifications,
          state: _foldOsStatus(
            os,
            hasBeenRequested: _settings.getNotificationsRequested(),
          ),
        );

      case FeatureKey.bluetooth:
        // OS state is read first so that a hard-block (permanent denial
        // of any underlying permission) always wins — the user needs the
        // system-settings affordance even if they later toggled the
        // in-app opt-in off.
        final os = await _bluetooth.checkStatus();
        if (os == BluetoothStatus.permissionDenied) {
          return const FeatureStatus(
            key: FeatureKey.bluetooth,
            state: FeatureState.permanentlyDenied,
          );
        }
        final enabled = _settings.getBluetoothEnabled();
        final requested = _settings.getBluetoothRequested();
        if (!enabled) {
          return FeatureStatus(
            key: FeatureKey.bluetooth,
            state: requested
                ? FeatureState.revokedByApp
                : FeatureState.notRequested,
          );
        }
        return FeatureStatus(
          key: FeatureKey.bluetooth,
          state: switch (os) {
            BluetoothStatus.available => FeatureState.granted,
            BluetoothStatus.unavailable => FeatureState.denied,
            // Already handled above — kept for exhaustiveness.
            BluetoothStatus.permissionDenied => FeatureState.permanentlyDenied,
          },
        );
    }
  }

  /// Reads every feature's status in parallel.
  Future<List<FeatureStatus>> snapshot() async {
    return Future.wait(FeatureKey.values.map(status));
  }

  /// User tapped "Grant Permission" on a feature.
  ///
  /// For features with an app-level revocation flag, we first clear the
  /// flag; then if the OS permission isn't already granted, we prompt.
  /// For features with side-effects (notifications, bluetooth) we
  /// restart the corresponding background work.
  Future<FeatureActionResult> grant(FeatureKey key) async {
    switch (key) {
      case FeatureKey.sensors:
        return FeatureActionResult.notApplicable;

      case FeatureKey.location:
        await _settings.setLocationRevoked(false);
        await _settings.setLocationRequested(true);
        final os = await _permissions.requestPermission(Permission.location);
        return _toActionResult(os);

      case FeatureKey.camera:
        await _settings.setCameraRevoked(false);
        await _settings.setCameraRequested(true);
        final os = await _permissions.requestPermission(Permission.camera);
        return _toActionResult(os);

      case FeatureKey.notifications:
        await _settings.setNotificationsEnabled(true);
        await _settings.setNotificationsRequested(true);
        final granted = await NotificationService.instance.requestPermission();
        if (granted) {
          await BackgroundTaskService.instance.registerPeriodicFetch();
          return FeatureActionResult.granted;
        }
        // OS prompt rejected — keep the app flag but report denied.
        final os = await _permissions.checkStatus(Permission.notification);
        return _toActionResult(os);

      case FeatureKey.bluetooth:
        await _settings.setBluetoothRequested(true);
        final bt = await _bluetooth.requestPermission();
        switch (bt) {
          case BluetoothStatus.available:
            await _settings.setBluetoothEnabled(true);
            return FeatureActionResult.granted;
          case BluetoothStatus.permissionDenied:
            await _settings.setBluetoothEnabled(false);
            return FeatureActionResult.permanentlyDenied;
          case BluetoothStatus.unavailable:
            await _settings.setBluetoothEnabled(false);
            return FeatureActionResult.denied;
        }
    }
  }

  /// User tapped "Revoke Permission" on a feature.
  ///
  /// This flips the app-level flag (for features that have one) and
  /// tears down any scheduled work tied to the feature. The OS
  /// permission is *not* touched — we can't revoke it, and leaving it
  /// granted is harmless since every feature service checks [status]
  /// before touching the OS API.
  Future<FeatureActionResult> revoke(FeatureKey key) async {
    switch (key) {
      case FeatureKey.sensors:
        return FeatureActionResult.notApplicable;

      case FeatureKey.location:
        await _settings.setLocationRevoked(true);
        return FeatureActionResult.revoked;

      case FeatureKey.camera:
        await _settings.setCameraRevoked(true);
        return FeatureActionResult.revoked;

      case FeatureKey.notifications:
        await _settings.setNotificationsEnabled(false);
        await NotificationService.instance.cancelAll();
        await BackgroundTaskService.instance.cancelAll();
        return FeatureActionResult.revoked;

      case FeatureKey.bluetooth:
        await _settings.setBluetoothEnabled(false);
        return FeatureActionResult.revoked;
    }
  }

  /// Opens the system settings app so the user can recover a
  /// permanently-denied permission.
  Future<bool> openSystemSettings() => _permissions.openSettings();

  // ────────────────────────── helpers ──────────────────────────

  FeatureState _foldOsStatus(
    PermissionStatus os, {
    required bool hasBeenRequested,
  }) {
    if (os.isGranted) return FeatureState.granted;
    if (os.isPermanentlyDenied) return FeatureState.permanentlyDenied;
    if (os.isRestricted) return FeatureState.restricted;
    if (!hasBeenRequested) return FeatureState.notRequested;
    return FeatureState.denied;
  }

  FeatureActionResult _toActionResult(PermissionStatus os) {
    if (os.isGranted) return FeatureActionResult.granted;
    if (os.isPermanentlyDenied) return FeatureActionResult.permanentlyDenied;
    return FeatureActionResult.denied;
  }
}
