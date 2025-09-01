import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabletap_frontend/main.dart';

void main() {
  testWidgets('TableTap app loads correctly', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Check if MaterialApp widget is found
    expect(find.byType(MaterialApp), findsOneWidget);

    // Check if login screen loads initially
    expect(find.text('Login to your account'), findsOneWidget);
  });
}
