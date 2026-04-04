/// Static UI strings used across the app.
///
/// Centralizing strings here makes future localization (FR/EN/AR) straightforward:
/// just swap this class with a localization delegate.
class AppStrings {
  AppStrings._();

  // ── App ──
  static const String appName = 'SmartCampus';
  static const String appTagline = 'Your campus companion';

  // ── Navigation ──
  static const String navHome = 'Home';
  static const String navAnnouncements = 'News';
  static const String navEvents = 'Events';
  static const String navSettings = 'Settings';

  // ── Home Screen ──
  static const String welcomeBack = 'Welcome back!';
  static const String nextClass = 'Next Class';
  static const String recentAnnouncements = 'Recent Announcements';
  static const String upcomingEvents = 'Upcoming Events';
  static const String seeAll = 'See All';

  // ── Announcements Screen ──
  static const String announcementsTitle = 'Announcements';
  static const String noAnnouncements = 'No announcements yet';

  // ── Events Screen ──
  static const String eventsTitle = 'Events';
  static const String noEvents = 'No upcoming events';

  // ── Settings Screen ──
  static const String settingsTitle = 'Settings';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String systemTheme = 'Follow System';
  static const String notifications = 'Notifications';
  static const String enableNotifications = 'Enable Notifications';
  static const String language = 'Language';
  static const String account = 'Account';
  static const String logout = 'Log Out';
  static const String about = 'About';
  static const String version = 'Version 1.0.0';

  // ── Common ──
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String errorGeneric = 'Something went wrong';
  static const String offlineBanner = 'You are offline';
  static const String comingSoon = 'Coming Soon';

  // ── 404 ──
  static const String pageNotFound = 'Page Not Found';
  static const String pageNotFoundMessage = 'The page you\'re looking for doesn\'t exist.';
  static const String goHome = 'Go Home';
}
