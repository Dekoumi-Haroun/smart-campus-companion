import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps [SharedPreferences] to persist user settings across app restarts.
class SettingsRepository {
  static const _keyThemeMode = 'theme_mode';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyLanguage = 'language';
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keyBluetoothEnabled = 'bluetooth_enabled';
  static const _keyBluetoothRequested = 'bluetooth_requested_once';
  static const _keyLastSyncedEpoch = 'last_synced_epoch_ms';
  // App-level revocation flags. True means "user disabled this feature
  // in-app", overriding the OS permission state for every consumer.
  static const _keyAppRevokedCamera = 'app_revoked_camera';
  static const _keyAppRevokedLocation = 'app_revoked_location';
  // Sticky "have we ever prompted the OS for this permission" flags.
  // Lets the Permissions card distinguish a never-prompted install
  // (pill: Not Requested) from a declined prompt (pill: Denied).
  static const _keyRequestedCamera = 'requested_camera_once';
  static const _keyRequestedLocation = 'requested_location_once';
  static const _keyRequestedNotifications = 'requested_notifications_once';

  late final SharedPreferences _prefs;

  /// Must be called once before any read/write.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Theme ──

  ThemeMode getThemeMode() {
    final value = _prefs.getString(_keyThemeMode);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_keyThemeMode, value);
  }

  // ── Notifications ──

  bool getNotificationsEnabled() {
    return _prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_keyNotificationsEnabled, value);
  }

  // ── Language ──

  String getLanguage() {
    return _prefs.getString(_keyLanguage) ?? 'English';
  }

  Future<void> setLanguage(String lang) async {
    await _prefs.setString(_keyLanguage, lang);
  }

  // ── Biometric ──

  bool getBiometricEnabled() {
    return _prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _prefs.setBool(_keyBiometricEnabled, value);
  }

  // ── Bluetooth feature toggle ──
  //
  // Reflects whether the user has *opted in* to Bluetooth-driven features
  // inside this app. System Bluetooth radio state is controlled by the OS
  // and cannot be toggled from Flutter — this flag is the app-level intent
  // that gates campus-beacon use cases.
  bool getBluetoothEnabled() {
    return _prefs.getBool(_keyBluetoothEnabled) ?? false;
  }

  Future<void> setBluetoothEnabled(bool value) async {
    await _prefs.setBool(_keyBluetoothEnabled, value);
  }

  /// Sticky flag: set once the user has been through the Bluetooth
  /// permission prompt for the first time. Drives the "Not Requested"
  /// vs "Denied" label in the Permissions summary section.
  bool getBluetoothRequested() {
    return _prefs.getBool(_keyBluetoothRequested) ?? false;
  }

  Future<void> setBluetoothRequested(bool value) async {
    await _prefs.setBool(_keyBluetoothRequested, value);
  }

  // ── Last sync timestamp ──
  //
  // Stamped by the repositories after a successful remote fetch.
  // Used by the Storage & Data section to show "Last synced X ago".
  DateTime? getLastSynced() {
    final ms = _prefs.getInt(_keyLastSyncedEpoch);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastSynced(DateTime value) async {
    await _prefs.setInt(_keyLastSyncedEpoch, value.millisecondsSinceEpoch);
  }

  /// Convenience wrapper called by the offline-first repositories every
  /// time a remote read succeeds, so the Storage & Data card always shows
  /// an accurate "Last synced" stamp regardless of which repo refreshed.
  Future<void> markSynced() => setLastSynced(DateTime.now());

  Future<void> clearLastSynced() async {
    await _prefs.remove(_keyLastSyncedEpoch);
  }

  // ── App-level feature revocation ──
  //
  // The OS does not let an app revoke its own granted permissions, so
  // the app keeps a second layer of consent: when the user taps
  // "Revoke Permission" inside SmartCampus, we flip one of these flags
  // and every feature service (camera, location, …) treats the
  // permission as denied regardless of the OS verdict.
  bool getCameraRevoked() => _prefs.getBool(_keyAppRevokedCamera) ?? false;
  Future<void> setCameraRevoked(bool value) =>
      _prefs.setBool(_keyAppRevokedCamera, value);

  bool getLocationRevoked() => _prefs.getBool(_keyAppRevokedLocation) ?? false;
  Future<void> setLocationRevoked(bool value) =>
      _prefs.setBool(_keyAppRevokedLocation, value);

  // ── Sticky "has been prompted" flags ──
  //
  // Set the first time the app fires a permission prompt for the
  // corresponding feature. Used by the Permissions card to pick the
  // right empty-state pill ("Not Requested" vs "Denied").
  bool getCameraRequested() => _prefs.getBool(_keyRequestedCamera) ?? false;
  Future<void> setCameraRequested(bool value) =>
      _prefs.setBool(_keyRequestedCamera, value);

  bool getLocationRequested() => _prefs.getBool(_keyRequestedLocation) ?? false;
  Future<void> setLocationRequested(bool value) =>
      _prefs.setBool(_keyRequestedLocation, value);

  bool getNotificationsRequested() =>
      _prefs.getBool(_keyRequestedNotifications) ?? false;
  Future<void> setNotificationsRequested(bool value) =>
      _prefs.setBool(_keyRequestedNotifications, value);
}
