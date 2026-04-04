/// Centralized route name constants.
/// Using a class with static constants prevents typos and enables IDE autocomplete.
class AppRoutes {
  AppRoutes._(); // Private constructor — this class should not be instantiated.

  // ── Main Tabs ──
  static const String home = '/';
  static const String announcements = '/announcements';
  static const String events = '/events';
  static const String settings = '/settings';

  // ── Auth (Sprint 6) ──
  static const String login = '/login';

  // ── Detail Screens (Future Sprints) ──
  static const String eventDetail = '/events/detail';
  static const String announcementDetail = '/announcements/detail';

  // ── Device Features (Sprint 4) ──
  static const String campusMap = '/map';
}
