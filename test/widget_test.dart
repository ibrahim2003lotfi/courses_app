import 'package:courses_app/onboarding/onboarding_screen.dart';
import 'package:courses_app/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courses_app/main.dart';
import 'package:courses_app/core/utils/onboarding_manager.dart';

void main() {
  // Setup shared preferences for testing
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts with onboarding when not completed', (WidgetTester tester) async {
    // Mock that onboarding is not completed
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/shared_preferences'), (methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp()); // Remove the parameter

    // Verify that onboarding screen is shown
    expect(find.text('مرحبًا بك في منصة الكورسات'), findsOneWidget);
  });

  testWidgets('App starts with main app when onboarding completed', (WidgetTester tester) async {
    // Mock that onboarding is completed
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/shared_preferences'), (methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{OnboardingManager.onboardingCompletedKey: true};
      }
      return null;
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp()); // Remove the parameter

    // You might need to pump multiple times for async operations
    await tester.pumpAndSettle();

    // Verify that main app is shown - adjust this based on your actual WidgetTree
    expect(find.byType(WidgetTree), findsOneWidget);
  });

  testWidgets('Onboarding navigation works correctly', (WidgetTester tester) async {
    // Build onboarding screen
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: const OnboardingScreen(),
      ),
    ));

    // Verify first page is shown
    expect(find.text('مرحبًا بك في منصة الكورسات'), findsOneWidget);
    
    // Tap next button - note: your button says 'متابعة' not 'التالي'
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    // Verify second page is shown
    expect(find.text('ما هو مستواك التعليمي الحالي؟'), findsOneWidget);
  });
}