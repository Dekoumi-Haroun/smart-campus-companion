import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:smart_campus/app.dart';
import 'package:smart_campus/data/repositories/settings_repository.dart';

void main() {
  testWidgets('App renders and shows auth loading state', (
    WidgetTester tester,
  ) async {
    // Initialize sqflite for desktop/CI platforms.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Provide empty in-memory SharedPreferences for the test environment.
    SharedPreferences.setMockInitialValues({});

    final settingsRepo = SettingsRepository();
    await settingsRepo.init();

    await tester.pumpWidget(App(settingsRepository: settingsRepo));

    // Advance past the MockInterceptor's 500ms simulated delay so
    // pending timers resolve before the test tears down.
    await tester.pump(const Duration(seconds: 1));

    // The app shows a loading state while checking auth status.
    // SecureStorage platform channels are unavailable in test, so the
    // auth check doesn't complete — verify the app renders the loading
    // overlay. The overlay Scaffold now sits on top of an always-mounted
    // Navigator (so deep links don't race the initial auth transition),
    // which means the tree may contain more than one Scaffold; the
    // unambiguous signal is the loading spinner itself.
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
