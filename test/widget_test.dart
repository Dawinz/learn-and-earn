// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learn_earn_mobile/main.dart';

void main() {
  testWidgets('Learn & Earn app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LearnEarnApp());

    // Verify that the app loads with the main navigation
    expect(find.text('Learn & Earn'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Earn'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
