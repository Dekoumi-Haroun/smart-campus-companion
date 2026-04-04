import 'package:flutter/material.dart';

/// Semantic color palette for SmartCampus.
///
/// We define colors here instead of scattering hex codes across widgets.
/// Both light and dark variants are provided so [AppTheme] can reference them.
class AppColors {
  AppColors._();

  // ── Brand Colors ──
  static const Color primary = Color(0xFF1565C0); // University Blue
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);
  static const Color secondary = Color(0xFF26A69A); // Teal accent
  static const Color secondaryLight = Color(0xFF64D8CB);
  static const Color secondaryDark = Color(0xFF00766C);

  // ── Light Theme ──
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1C1C1E);
  static const Color lightOnSurface = Color(0xFF2C2C2E);

  // ── Dark Theme ──
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnBackground = Color(0xFFE5E5E7);
  static const Color darkOnSurface = Color(0xFFF2F2F7);

  // ── Semantic Colors ──
  // Each semantic color has a corresponding "on" color for text/icons placed
  // on top of it, ensuring a contrast ratio of at least 4.5:1.
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF388E3C);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF57C00);
  static const Color onWarning = Color(0xFF000000); // dark text on orange
  static const Color info = Color(0xFF1976D2);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ── Category Tag Colors (for announcements) ──
  static const Color tagAcademic = Color(0xFF5C6BC0);
  static const Color tagSports = Color(0xFF66BB6A);
  static const Color tagGeneral = Color(0xFFFF7043);
  static const Color tagUrgent = Color(0xFFEF5350);
}
