import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

/// Application entry point.
///
/// Keeps main() minimal — all configuration lives in [App].
/// Future sprints will add initialization here for:
/// - Notification service (Sprint 5)
/// - Background task registration (Sprint 5)
/// - Secure storage initialization (Sprint 3)
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent UX.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const App());
}
