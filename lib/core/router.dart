import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../presentation/screens/auth/biometric_prompt_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/campus_map/campus_map_screen.dart';
import '../presentation/screens/timetable/timetable_detail_screen.dart';
import '../presentation/widgets/main_shell.dart';
import '../presentation/screens/not_found_screen.dart';

/// Centralized route generator.
///
/// All navigation goes through here, which gives us:
/// 1. A single place to manage every route in the app.
/// 2. Easy argument passing via [RouteSettings.arguments].
/// 3. Deep-link support for notifications (Sprint 5).
///
/// Usage in [MaterialApp]: `onGenerateRoute: AppRouter.generateRoute`
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Auth ──
      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);

      case AppRoutes.biometricPrompt:
        return _buildRoute(const BiometricPromptScreen(), settings);

      // ── Main App Shell (tabs) ──
      case AppRoutes.home:
        final initialTab = settings.arguments is int
            ? settings.arguments as int
            : 0;
        return _buildRoute(MainShell(initialTab: initialTab), settings);

      // ── Timetable Detail (notification deep link) ──
      case AppRoutes.timetableDetail:
        final itemId = settings.arguments as String;
        return _buildRoute(TimetableDetailScreen(itemId: itemId), settings);

      case AppRoutes.campusMap:
        return _buildRoute(const CampusMapScreen(), settings);

      // ── 404 Fallback ──
      default:
        return _buildRoute(const NotFoundScreen(), settings);
    }
  }

  /// Helper to create a [MaterialPageRoute] with consistent settings.
  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
