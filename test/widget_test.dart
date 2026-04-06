import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/app.dart';
import 'package:smart_campus/data/repositories/settings_repository.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    final settingsRepo = SettingsRepository();
    await settingsRepo.init();

    await tester.pumpWidget(App(settingsRepository: settingsRepo));

    // Advance past the MockInterceptor's 500ms simulated delay so
    // pending timers resolve before the test tears down.
    await tester.pump(const Duration(seconds: 1));

    // Verify the home screen renders with the user greeting
    expect(find.textContaining('Maxframe'), findsOneWidget);
  });
}
