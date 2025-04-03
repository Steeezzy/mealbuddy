import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealb/main.dart';

void main() {
  group('MealBuddy App Tests', () {
    testWidgets('App should render correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MealBuddyApp());

      // Verify that the app renders without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have correct theme', (WidgetTester tester) async {
      await tester.pumpWidget(const MealBuddyApp());

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.colorScheme.primary, Colors.green);
      expect(app.debugShowCheckedModeBanner, false);
    });

    testWidgets('App should show HomePage', (WidgetTester tester) async {
      await tester.pumpWidget(const MealBuddyApp());
      await tester.pumpAndSettle();

      // Verify that HomePage is rendered
      expect(find.text('MealBuddy'), findsOneWidget);
    });
  });
}
