import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    // Advance past the MockInterceptor's 500ms simulated delay so
    // pending timers resolve before the test tears down.
    await tester.pump(const Duration(seconds: 1));

    // Verify the home screen renders with the user greeting
    expect(find.textContaining('Maxframe'), findsOneWidget);
  });
}
