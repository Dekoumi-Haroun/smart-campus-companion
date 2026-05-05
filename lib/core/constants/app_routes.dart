/// Centralized route name constants.
class AppRoutes {
  AppRoutes._();

  // ── Main Tabs ──
  static const String home = '/';
  static const String announcements = '/announcements';
  static const String events = '/events';
  static const String settings = '/settings';

  // ── Auth ──
  static const String login = '/login';
  static const String biometricPrompt = '/biometric';

  // ── Detail Screens ──
  static const String eventDetail = '/events/detail';
  static const String announcementDetail = '/announcements/detail';

  // ── Device Features ──
  static const String campusMap = '/map';

  // ── Timetable Detail ──
  static const String timetableDetail = '/timetable/detail';

  // ── Admin ──
  static const String adminDashboard = '/admin';
  static const String adminAnnouncements = '/admin/announcements';
  static const String adminAnnouncementForm = '/admin/announcements/form';
  static const String adminEvents = '/admin/events';
  static const String adminEventForm = '/admin/events/form';
  static const String adminTimetable = '/admin/timetable';
  static const String adminTimetableForm = '/admin/timetable/form';
}
