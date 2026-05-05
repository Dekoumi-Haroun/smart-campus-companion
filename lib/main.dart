import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/services/background_task_service.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/settings_repository.dart';

/// Application entry point.
///
/// Initializes [SettingsRepository], [NotificationService], and
/// [BackgroundTaskService] before running the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent UX.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final settingsRepository = SettingsRepository();
  await settingsRepository.init();

  // Initialize notification service.
  final notificationService = NotificationService.instance;
  await notificationService.init();

  // Initialize background task service.
  final backgroundTaskService = BackgroundTaskService.instance;
  await backgroundTaskService.init();

  // Start periodic background fetch if notifications are enabled.
  if (settingsRepository.getNotificationsEnabled()) {
    await backgroundTaskService.registerPeriodicFetch();
  }

  runApp(App(settingsRepository: settingsRepository));
}
