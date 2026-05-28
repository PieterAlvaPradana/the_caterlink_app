import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_caterlink_app/main.dart';

void main() {
  testWidgets('App should load', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CanteenApp());

    // Verify that our app starts
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
