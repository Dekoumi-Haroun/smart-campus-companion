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
  static const String navMap = 'Map';
  static const String navSettings = 'Settings';

  // ── Home Screen ──
  static const String welcomeBack = 'Welcome back!';
  static const String nextClass = 'Next Class';
  static const String recentAnnouncements = 'Recent Announcements';
  static const String upcomingEvents = 'Upcoming Events';
  static const String seeAll = 'See All';
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  static const String live = 'Live';
  static const String now = 'NOW';
  static const String currentClass = 'Current Class';
  static const String noClassNow = 'No class right now';
  static const String classesCompleted = 'classes today';
  static const String announcements = 'ANNOUNCEMENTS';
  static const String eventsToday = 'Events Today';
  static const String alerts = 'Alerts';
  static const String exportSchedule = 'Export Schedule';
  static const String campusSafety = 'Campus Safety';
  static const String campusSafetyComingSoon = 'Coming in Sprint 4';
  static const String todaysSchedule = "Today's Schedule";
  static const String announcementDetail = 'Announcement';
  static const String eventDetail = 'Event Details';
  static const String share = 'Share';
  static const String save = 'Save';
  static const String remind = 'Remind';
  static const String setReminder = 'Set Reminder';
  static const String reminderSet = 'Reminder Set';
  static const String viewProfile = 'View Profile';
  static const String signOut = 'Sign Out';
  static const String userName = 'Maxframe';
  static const String userEmail = 'maxframe@smartcampus.dev';
  static const String scheduleExported = 'Schedule exported successfully!';

  // ── Announcements Screen ──
  static const String announcementsTitle = 'Announcements';
  static const String noAnnouncements = 'No announcements yet';
  static const String searchAnnouncements = 'Search announcements...';
  static const String noResults = 'No results found';
  static const String noResultsMessage =
      'Try a different search term or filter.';
  static const String filterAll = 'All';
  static const String filterAcademic = 'Academic';
  static const String filterSports = 'Sports';
  static const String filterGeneral = 'General';
  static const String filterUrgent = 'Urgent';
  static const String minRead = 'min read';

  // ── Events Screen ──
  static const String eventsTitle = 'Events';
  static const String noEvents = 'No upcoming events';
  static const String searchEvents = 'Search events...';
  static const String going = 'going';
  static const String reminded = 'Reminded';
  static const String attachPhoto = 'Attach Photo';
  static const String attachPhotoComingSoon =
      'Camera integration coming in Sprint 4';
  static const String changePhoto = 'Change Photo';
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String photoAttached = 'Photo attached successfully';
  static const String reminderSetFor = 'Reminder set for';
  static const String reminderRemovedFor = 'Reminder removed for';

  // ── Shake to Refresh ──
  static const String shakeRefreshing = 'Refreshing...';

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

  // ── Permissions ──
  static const String permissionDeniedTitle = 'Permission Required';
  static const String permissionDeniedGeneric =
      'This feature requires a permission that was denied.';
  static const String permissionPermanentlyDenied =
      'Permission was permanently denied. Please enable it in your device settings.';
  static const String openSettings = 'Open Settings';
  static const String cameraPermissionReason =
      'Camera access is needed to attach photos to events.';
  static const String galleryPermissionReason =
      'Photo library access is needed to choose existing photos.';
  static const String locationPermissionReason =
      'Location access is needed to show your position on the campus map.';
  static const String bluetoothPermissionReason =
      'Bluetooth access is needed to detect campus beacons.';

  // ── Campus Map ──
  static const String campusMapTitle = 'Campus Map';
  static const String centerOnMe = 'Center on me';

  // ── Device Features (Settings) ──
  static const String deviceFeatures = 'Device Features';
  static const String bluetooth = 'Bluetooth';
  static const String bluetoothAvailable = 'Available';
  static const String bluetoothUnavailable = 'Unavailable';
  static const String nfc = 'NFC';
  static const String nfcConceptual = 'Conceptual';
  static const String bluetoothDescription =
      'Bluetooth could be used for campus beacon-based attendance tracking, '
      'indoor navigation, and proximity alerts near lecture halls.';
  static const String nfcDescription =
      'NFC could enable tap-to-check-in for classes, '
      'library card scanning, and quick access to campus resources. '
      'Requires android.nfc permission on Android.';

  // ── Notifications (Sprint 5) ──
  static const String remindMe = 'Remind Me';
  static const String reminderScheduled =
      'Reminder set for 10 min before class';
  static const String reminderCancelled = 'Reminder cancelled';
  static const String notificationsDisabledMessage =
      'Enable notifications in Settings to set reminders';

  // ── Common ──
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String errorGeneric = 'Something went wrong';
  static const String offlineBanner =
      "You're browsing offline - Cached content";
  static const String offline = 'Offline';
  static const String comingSoon = 'Coming Soon';

  // ── 404 ──
  static const String pageNotFound = 'Page Not Found';
  static const String pageNotFoundMessage =
      'The page you\'re looking for doesn\'t exist.';
  static const String goHome = 'Go Home';
}
