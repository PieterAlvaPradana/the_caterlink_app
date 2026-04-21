import 'package:flutter_test/flutter_test.dart';

import 'package:the_caterlink_app/main.dart';
import 'package:the_caterlink_app/screens/login_screen.dart';

void main() {
  testWidgets('Canteen App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CanteenApp());

    // Verify that the app launches successfully.
    expect(find.text('Canteen App'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
