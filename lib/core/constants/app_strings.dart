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

  // ── Campus Safety Sheet ──
  static const String safetyContactSecurity = 'Security';
  static const String safetyContactMedical = 'Medical';
  static const String safetyContactFire = 'Fire';
  static const String safetyNumberSecurity = '041-XXX-XXX';
  static const String safetyNumberMedical = '041-XXX-XXX';
  static const String safetyNumberFire = '14';
  static const String callSecurityNow = 'Call Security Now';
  static const String close = 'Close';
  static const String callFailedMessage =
      'Could not launch the dialer on this device.';
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
  static const String eventStatusUpcoming = 'Upcoming';
  static const String eventStatusOngoing = 'Ongoing';
  static const String eventStatusCompleted = 'Completed';
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
  static const String bluetoothEnabledSubtitle =
      'Use campus beacons & indoor hints';
  static const String bluetoothActivated = 'Activated — campus beacons ready';
  static const String bluetoothDeactivated = 'Deactivated';
  static const String bluetoothDeniedBody =
      'Bluetooth permission was denied, so campus-beacon features stay off. '
      'You can grant it from your device settings and try again.';
  static const String nfc = 'NFC';
  static const String nfcConceptual = 'Conceptual';

  // ── Storage & Data (Settings) ──
  static const String storageAndData = 'Storage & Data';
  static const String cacheAnnouncements = 'Announcements';
  static const String cacheEvents = 'Events';
  static const String cacheTimetable = 'Timetable';
  static const String cacheImages = 'Images';
  static const String clearCache = 'Clear Cache';
  static const String clearCacheConfirmTitle = 'Clear cached data?';
  static const String clearCacheConfirmMessage =
      'This removes downloaded announcements, events, timetable, and attached '
      'photos from this device. The next time you open those screens the app '
      'will refetch them.';
  static const String cacheCleared = 'Cache cleared';
  static const String totalCached = 'Total:';
  static const String ofCachedData = 'of cached data';
  static const String lastSynced = 'Last synced:';

  // ── Permissions summary (Settings) ──
  static const String permissionsSection = 'Permissions';
  static const String permLocationLabel = 'Location';
  static const String permLocationSubtitle = 'Used for campus map navigation';
  static const String permCameraLabel = 'Camera';
  static const String permCameraSubtitle = 'Attach photos to event notes';
  static const String permNotificationsLabel = 'Notifications';
  static const String permNotificationsSubtitle = 'Class reminders & alerts';
  static const String permSensorsLabel = 'Sensors';
  static const String permSensorsSubtitle = 'Shake to refresh (accelerometer)';
  static const String permBluetoothLabel = 'Bluetooth';
  static const String permBluetoothSubtitle = 'Campus check-in (future)';
  static const String permStatusGranted = 'Granted';
  static const String permStatusDenied = 'Denied';
  static const String permStatusNotRequested = 'Not Requested';
  static const String permStatusPermanentlyDenied = 'Blocked';
  static const String permStatusRestricted = 'Restricted';
  static const String permStatusAuto = 'Auto';
  static const String permStatusRevokedInApp = 'Revoked';

  // ── Permission row actions (expanded state) ──
  static const String grantPermission = 'Grant Permission';
  static const String revokePermission = 'Revoke Permission';
  static const String revokedActiveBody =
      'This permission is currently active. You can revoke it to disable this '
      'feature.';
  static const String revokedByAppBody =
      'You revoked this feature in-app. Grant it again to use it.';
  static const String deniedBody =
      'This permission is not granted yet. Tap the button below to request it.';
  static const String permanentlyDeniedBody =
      'This permission was permanently denied. Grant it from your device '
      'settings, then return here.';
  static const String autoBody =
      'No runtime permission is required for this feature.';
  static const String cameraRevokedInApp =
      'Camera is disabled in Settings → Permissions. Re-enable it there to '
      'attach photos again.';
  static const String locationRevokedInApp =
      'Location is disabled in Settings → Permissions. Re-enable it there to '
      'use the campus map.';
  static const String openAppPermissions = 'Open Permissions';
  static const String actionRevoked = 'Permission revoked';
  static const String actionGranted = 'Permission granted';
  static const String actionOsDenied =
      'The system permission prompt was denied.';
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

  // ── Auth (Sprint 6) ──
  static const String loginTitle = 'Welcome to SmartCampus';
  static const String loginSubtitle = 'Sign in to continue';
  static const String emailHint = 'Email';
  static const String passwordHint = 'Password';
  static const String loginButton = 'Sign In';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPassword =
      'Password must be at least 6 characters';
  static const String loginFailed = 'Invalid email or password';
  static const String biometricPromptTitle = 'Verify Your Identity';
  static const String biometricPromptSubtitle =
      'Use biometrics to unlock SmartCampus';
  static const String biometricFallback = 'Use Password Instead';
  static const String tryAgain = 'Try Again';
  static const String enableBiometric = 'Biometric Login';
  static const String biometricLoginDescription =
      'Use fingerprint or face recognition to unlock';
  static const String biometricNotAvailable =
      'Biometric authentication is not available on this device';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
  static const String logoutConfirmTitle = 'Log Out';
  static const String logoutConfirmMessage =
      'Are you sure you want to log out?';
  static const String cancel = 'Cancel';
  static const String demoCredentials =
      'Demo: student@smartcampus.dev / campus123';

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

  // ── Admin ──
  static const String adminPanel = 'Admin Panel';
  static const String adminDashboard = 'Dashboard';
  static const String adminBadge = 'ADMIN';
  static const String manageAnnouncements = 'Manage Announcements';
  static const String manageEvents = 'Manage Events';
  static const String manageTimetable = 'Manage Timetable';
  static const String newAnnouncement = 'New Announcement';
  static const String newEvent = 'New Event';
  static const String newClass = 'New Class';
  static const String editAnnouncement = 'Edit Announcement';
  static const String editEvent = 'Edit Event';
  static const String editClass = 'Edit Class';
  static const String deleteConfirmTitle = 'Delete Item';
  static const String deleteConfirmMessage =
      'This action cannot be undone. Are you sure?';
  static const String delete = 'Delete';
  static const String titleLabel = 'Title';
  static const String bodyLabel = 'Content';
  static const String categoryLabel = 'Category';
  static const String sourceLabel = 'Source';
  static const String summaryLabel = 'Summary';
  static const String readTimeLabel = 'Read time (minutes)';
  static const String locationLabel = 'Location';
  static const String descriptionLabel = 'Description';
  static const String dateLabel = 'Date & Time';
  static const String endDateLabel = 'End Time (optional)';
  static const String attendeeCountLabel = 'Attendee count';
  static const String courseNameLabel = 'Course Name';
  static const String instructorLabel = 'Instructor';
  static const String roomLabel = 'Room';
  static const String dayOfWeekLabel = 'Day';
  static const String startTimeLabel = 'Start Time (HH:MM)';
  static const String endTimeLabel = 'End Time (HH:MM)';
  static const String statusLabel = 'Status';
  static const String fieldRequired = 'This field is required';
  static const String invalidTimeFormat = 'Use HH:MM format (e.g. 09:30)';
  static const String adminCredentials =
      'Admin: admin@smartcampus.dev / admin123';
  static const String accessDenied =
      'Access denied. Admin privileges required.';
}
