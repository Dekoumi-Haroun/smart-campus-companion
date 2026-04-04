import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../presentation/widgets/main_shell.dart';
import '../presentation/screens/not_found_screen.dart';

/// Centralized route generator.
///
/// All navigation goes through here, which gives us:
/// 1. A single place to manage every route in the app.
/// 2. Easy argument passing via [RouteSettings.arguments].
/// 3. Deep-link support (needed for notifications in Sprint 5).
///
/// Usage in [MaterialApp]: `onGenerateRoute: AppRouter.generateRoute`
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Main App Shell (tabs) ──
      case AppRoutes.home:
        return _buildRoute(const MainShell(), settings);

      // ── Future Routes (Sprints 2–6) ──
      // Uncomment as features are implemented:
      //
      // case AppRoutes.login:
      //   return _buildRoute(const LoginScreen(), settings);
      //
      // case AppRoutes.eventDetail:
      //   final eventId = settings.arguments as String;
      //   return _buildRoute(EventDetailScreen(id: eventId), settings);
      //
      // case AppRoutes.announcementDetail:
      //   final announcementId = settings.arguments as String;
      //   return _buildRoute(AnnouncementDetailScreen(id: announcementId), settings);
      //
      // case AppRoutes.campusMap:
      //   return _buildRoute(const CampusMapScreen(), settings);

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
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
