import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../domain/entities/announcement.dart';
import '../domain/entities/event.dart';
import '../domain/entities/timetable_item.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/announcements/admin_announcement_form_screen.dart';
import '../presentation/screens/admin/announcements/admin_announcements_screen.dart';
import '../presentation/screens/admin/events/admin_event_form_screen.dart';
import '../presentation/screens/admin/events/admin_events_screen.dart';
import '../presentation/screens/admin/timetable/admin_timetable_form_screen.dart';
import '../presentation/screens/admin/timetable/admin_timetable_screen.dart';
import '../presentation/screens/auth/biometric_prompt_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/campus_map/campus_map_screen.dart';
import '../presentation/screens/not_found_screen.dart';
import '../presentation/screens/timetable/timetable_detail_screen.dart';
import '../presentation/widgets/main_shell.dart';

/// Centralized route generator.
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Auth ──
      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);

      case AppRoutes.biometricPrompt:
        return _buildRoute(const BiometricPromptScreen(), settings);

      // ── Main App Shell ──
      case AppRoutes.home:
        final initialTab = settings.arguments is int
            ? settings.arguments as int
            : 0;
        return _buildRoute(MainShell(initialTab: initialTab), settings);

      // ── Timetable Detail ──
      case AppRoutes.timetableDetail:
        final itemId = settings.arguments as String;
        return _buildRoute(TimetableDetailScreen(itemId: itemId), settings);

      case AppRoutes.campusMap:
        return _buildRoute(const CampusMapScreen(), settings);

      // ── Admin ──
      case AppRoutes.adminDashboard:
        return _buildRoute(const AdminDashboardScreen(), settings);

      case AppRoutes.adminAnnouncements:
        return _buildRoute(const AdminAnnouncementsScreen(), settings);

      case AppRoutes.adminAnnouncementForm:
        final announcement = settings.arguments as Announcement?;
        return _buildRoute(
          AdminAnnouncementFormScreen(announcement: announcement),
          settings,
        );

      case AppRoutes.adminEvents:
        return _buildRoute(const AdminEventsScreen(), settings);

      case AppRoutes.adminEventForm:
        final event = settings.arguments as Event?;
        return _buildRoute(AdminEventFormScreen(event: event), settings);

      case AppRoutes.adminTimetable:
        return _buildRoute(const AdminTimetableScreen(), settings);

      case AppRoutes.adminTimetableForm:
        final item = settings.arguments as TimetableItem?;
        return _buildRoute(
          AdminTimetableFormScreen(timetableItem: item),
          settings,
        );

      // ── 404 Fallback ──
      default:
        return _buildRoute(const NotFoundScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
