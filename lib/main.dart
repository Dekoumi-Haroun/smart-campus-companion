import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/repositories/settings_repository.dart';

/// Application entry point.
///
/// Initializes [SettingsRepository] before running the app so that
/// persisted preferences (theme, notifications, language) are available
/// synchronously from the first frame.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent UX.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final settingsRepository = SettingsRepository();
  await settingsRepository.init();

  runApp(App(settingsRepository: settingsRepository));
}
