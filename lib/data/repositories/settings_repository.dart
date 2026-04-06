import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps [SharedPreferences] to persist user settings across app restarts.
class SettingsRepository {
  static const _keyThemeMode = 'theme_mode';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyLanguage = 'language';

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
}
