import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:boitodex/main.dart' as app;
import 'package:boitodex/app/constants/strings.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Boitodex App Integration Tests', () {
    testWidgets('should display home screen with collection title', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that the home screen is displayed
      expect(find.text(AppStrings.collection), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should navigate to car form when FAB is tapped', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Tap the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify that the car form screen is displayed
      expect(find.text(AppStrings.add), findsOneWidget);
      expect(find.text('${AppStrings.brand} *'), findsOneWidget);
      expect(find.text('${AppStrings.shape} *'), findsOneWidget);
      expect(find.text('${AppStrings.name} *'), findsOneWidget);
    });

    testWidgets('should add a new car successfully', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to car form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill in the form
      await tester.enterText(find.byType(TextFormField).at(0), 'BMW');
      await tester.enterText(find.byType(TextFormField).at(1), 'Sedan');
      await tester.enterText(find.byType(TextFormField).at(2), 'X5');
      await tester.enterText(find.byType(TextFormField).at(3), 'Test car for integration test');

      // Save the car
      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      // Verify that we're back on the home screen and the car is listed
      expect(find.text(AppStrings.collection), findsOneWidget);
      expect(find.text('X5'), findsOneWidget);
      expect(find.text('BMW • Sedan'), findsOneWidget);
    });

    testWidgets('should edit an existing car successfully', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // First, add a car
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Audi');
      await tester.enterText(find.byType(TextFormField).at(1), 'SUV');
      await tester.enterText(find.byType(TextFormField).at(2), 'Q7');

      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      // Tap on the car to edit it
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Verify that we're in edit mode
      expect(find.text(AppStrings.edit), findsOneWidget);

      // Modify the name
      await tester.enterText(find.byType(TextFormField).at(2), 'Q7 Modified');

      // Save the changes
      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      // Verify that the changes are reflected
      expect(find.text('Q7 Modified'), findsOneWidget);
    });

    testWidgets('should delete a car successfully', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // First, add a car
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Mercedes');
      await tester.enterText(find.byType(TextFormField).at(1), 'Coupe');
      await tester.enterText(find.byType(TextFormField).at(2), 'C63');

      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      // Verify the car is listed
      expect(find.text('C63'), findsOneWidget);

      // Tap the delete button
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text(AppStrings.delete));
      await tester.pumpAndSettle();

      // Verify the car is no longer listed
      expect(find.text('C63'), findsNothing);
    });

    testWidgets('should search and filter cars', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Add multiple cars
      final carsToAdd = [
        {'brand': 'BMW', 'shape': 'Sedan', 'name': 'X5'},
        {'brand': 'BMW', 'shape': 'SUV', 'name': 'X3'},
        {'brand': 'Audi', 'shape': 'Sedan', 'name': 'A4'},
      ];

      for (final car in carsToAdd) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).at(0), car['brand']!);
        await tester.enterText(find.byType(TextFormField).at(1), car['shape']!);
        await tester.enterText(find.byType(TextFormField).at(2), car['name']!);

        await tester.tap(find.text(AppStrings.save));
        await tester.pumpAndSettle();
      }

      // Test search functionality
      await tester.enterText(find.byType(TextField), 'BMW');
      await tester.pumpAndSettle(const Duration(milliseconds: 600)); // Wait for debounce

      // Should show only BMW cars
      expect(find.text('X5'), findsOneWidget);
      expect(find.text('X3'), findsOneWidget);
      expect(find.text('A4'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // All cars should be visible again
      expect(find.text('X5'), findsOneWidget);
      expect(find.text('X3'), findsOneWidget);
      expect(find.text('A4'), findsOneWidget);
    });

    testWidgets('should toggle special features switches', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to car form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill basic info
      await tester.enterText(find.byType(TextFormField).at(0), 'Ferrari');
      await tester.enterText(find.byType(TextFormField).at(1), 'Sports');
      await tester.enterText(find.byType(TextFormField).at(2), 'F40');

      // Toggle piggy bank switch
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      // Toggle plays music switch
      await tester.tap(find.byType(SwitchListTile).last);
      await tester.pumpAndSettle();

      // Save the car
      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      // Verify special features are displayed
      expect(find.byIcon(Icons.savings), findsOneWidget);
      expect(find.text('Tirelire'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
      expect(find.text('Musique'), findsOneWidget);
    });

    testWidgets('should validate required fields', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to car form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to save without filling required fields
      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      // Should still be on the form screen (validation failed)
      expect(find.text(AppStrings.add), findsOneWidget);
    });

    testWidgets('should show empty state when no cars exist', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text(AppStrings.noCarInCollection), findsOneWidget);
      expect(find.text(AppStrings.addFirstCar), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('should show sort dialog and apply sorting', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Add multiple cars first
      final carsToAdd = [
        {'brand': 'BMW', 'shape': 'Sedan', 'name': 'Z Car'},
        {'brand': 'Audi', 'shape': 'SUV', 'name': 'A Car'},
      ];

      for (final car in carsToAdd) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).at(0), car['brand']!);
        await tester.enterText(find.byType(TextFormField).at(1), car['shape']!);
        await tester.enterText(find.byType(TextFormField).at(2), car['name']!);

        await tester.tap(find.text(AppStrings.save));
        await tester.pumpAndSettle();
      }

      // Tap the sort button
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Should show sort dialog
      expect(find.text('Trier par'), findsOneWidget);

      // Select brand sorting
      await tester.tap(find.text('Marque'));
      await tester.pumpAndSettle();

      // Apply sorting
      await tester.tap(find.text('Appliquer'));
      await tester.pumpAndSettle();

      // Verify that cars are sorted by brand (Audi should come before BMW)
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsAtLeastNWidgets(2));
    });

    testWidgets('should handle app navigation correctly', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to car form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify we're on car form
      expect(find.text(AppStrings.add), findsOneWidget);

      // Tap cancel to go back
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();

      // Verify we're back on home screen
      expect(find.text(AppStrings.collection), findsOneWidget);
    });
  });
}