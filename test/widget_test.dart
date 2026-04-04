import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    // Verify the app name appears
    expect(find.text('SmartCampus'), findsOneWidget);
  });
}
