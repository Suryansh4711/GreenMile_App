// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenmile_fixed/main.dart';

void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup Firebase mock
  Firebase.initializeApp();
}

void main() {
  setupFirebaseCoreMocks();

  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.byType(Image), findsOneWidget); // Logo image

    // Check for main navigation items
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);

    // Check for login button when not authenticated
    expect(find.byIcon(Icons.login), findsOneWidget);
  });
}
