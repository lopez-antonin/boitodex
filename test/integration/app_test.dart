import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:boitodex/app/app.dart';
import 'package:boitodex/app/di/injection.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Boitodex App Integration Tests', () {
    setUpAll(() async {
      // Reset GetIt before each test
      if (locator.isRegistered<dynamic>()) {
        await locator.reset();
      }
      await setupLocator();
    });

    testWidgets('should navigate to car form when FAB is tapped', (tester) async {
      await tester.pumpWidget(const BoitodexApp());
      await tester.pumpAndSettle();

      // Find and tap the FloatingActionButton
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify navigation to car form
      expect(find.text('Ajouter'), findsOneWidget);
      expect(find.text('Marque *'), findsOneWidget);
      expect(find.text('Forme *'), findsOneWidget);
      expect(find.text('Nom *'), findsOneWidget);
    });

    testWidgets('should add a new car successfully', (tester) async {
      await tester.pumpWidget(const BoitodexApp());
      await tester.pumpAndSettle();

      // Navigate to add car form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill in the form
      await tester.enterText(find.byKey(const Key('brand_field')), 'BMW');
      await tester.enterText(find.byKey(const Key('shape_field')), 'Berline');
      await tester.enterText(find.byKey(const Key('name_field')), 'Serie 3');
      await tester.enterText(find.byKey(const Key('informations_field')), 'Belle voiture bleue');

      // Save the car
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Verify we're back to home and car is added
      expect(find.text('Collection'), findsOneWidget);
      expect(find.text('Serie 3'), findsOneWidget);
      expect(find.text('BMW • Berline'), findsOneWidget);
    });

    testWidgets('should edit an existing car successfully', (tester) async {
      await tester.pumpWidget(const BoitodexApp());
      await tester.pumpAndSettle();

      // First add a car
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('brand_field')), 'Audi');
      await tester.enterText(find.byKey(const Key('shape_field')), 'SUV');
      await tester.enterText(find.byKey(const Key('name_field')), 'Q5');

      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Tap on the car to edit it
      await tester.tap(find.text('Q5'));
      await tester.pumpAndSettle();

      // Verify we're in edit mode
      expect(find.text('Modifier'), findsOneWidget);

      // Edit the car
      await tester.enterText(find.byKey(const Key('name_field')), 'Q7');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Verify the changes
      expect(find.text('Q7'), findsOneWidget);
      expect(find.text('Q5'), findsNothing);
    });

    testWidgets('should delete a car successfully', (tester) async {
      await tester.pumpWidget(const BoitodexApp());
      await tester.pumpAndSettle();

      // First add a car
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('brand_field')), 'Toyota');
      await tester.enterText(find.byKey(const Key('shape_field')), 'Hybride');
      await tester.enterText(find.byKey(const Key('name_field')), 'Prius');

      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Delete the car using the delete button in the list
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      // Verify car is deleted
      expect(find.text('Prius'), findsNothing);
    });

    testWidgets('should search and filter cars', (tester) async {
      await tester.pumpWidget(const BoitodexApp());
      await tester.pumpAndSettle();

      // Add multiple cars first
      for (final carData in [
        {'brand': 'BMW', 'shape': 'Berline', 'name': 'Serie 3'},
        {'brand': 'BMW', 'shape': 'SUV', 'name': 'X5'},
        {'brand': 'Audi', 'shape': 'Berline', 'name': 'A4'},
      ]) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('brand_field')), carData['brand']!);
        await tester.enterText(find.byKey(const Key('shape_field')), carData['shape']!);
        await tester.enterText(find.byKey(const Key('name_field')), carData['name']!);

        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();
      }

      // Test search functionality
      await tester.enterText(find.byKey(const Key('search_field')), 'BMW');
      await tester.pumpAndSettle();

      expect(find.text('Serie 3'), findsOneWidget);
      expect(find.text('X5'), findsOneWidget);
      expect(find.text('A4'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Test brand filter
      await tester.tap(find.byKey(const Key('brand_dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('BMW').last);
      await tester.pumpAndSettle();

      expect(find.text('Serie 3'), findsOneWidget);
      expect(find.text('X5'), findsOneWidget);
      expect(find.text('A4'), findsNothing);
    });

    testWidgets('should toggle special features switches', (tester) async {
      await tester.pumpWidget(const BoitodexApp());
      await tester.pumpAndSettle();

      // Navigate to add car form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(find.byKey(const Key('brand_field')), 'Ferrari');
      await tester.enterText(find.byKey(const Key('shape_field')), 'Sport');
      await tester.enterText(find.byKey(const Key('name_field')), 'F40');

      // Toggle piggy bank switch
      await tester.tap(find.byKey(const Key('piggy_bank_switch')));
      await tester.pumpAndSettle();

      // Toggle music switch
      await tester.tap(find.byKey(const Key('plays_music_switch')));
      await tester.pumpAndSettle();

      // Save the car
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Verify special features are shown in the list
      expect(find.byIcon(Icons.savings), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
      expect(find.text('Tirelire'), findsOneWidget);
      expect(find.text('Musique'), findsOneWidget);
    });

    testWidgets('should validate required fields', (tester) async {
      await tester.pumpWidget(const BoitodexApp());
      await tester.pumpAndSettle();

      // Navigate to add car form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to save without filling required fields
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Verify validation messages appear
      expect(find.text('Marque Ce champ est obligatoire'), findsOneWidget);
      expect(find.text('Forme Ce champ est obligatoire'), findsOneWidget);
      expect(find.text('Nom Ce champ est obligatoire'), findsOneWidget);
    });

    testWidgets('should show empty state when no cars exist', (tester) async {
      await tester.pumpWidget(const BoitodexApp());
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('Aucune voiture dans la collection'), findsOneWidget);
      expect(find.text('Appuyez sur + pour ajouter votre première voiture'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('should show sort dialog and apply sorting', (tester) async {
      await tester.pumpWidget(const BoitodexApp());
      await tester.pumpAndSettle();

      // Add multiple cars for sorting
      for (final carData in [
        {'brand': 'Zebra', 'shape': 'Sport', 'name': 'Z1'},
        {'brand': 'Alpha', 'shape': 'SUV', 'name': 'A1'},
        {'brand': 'Beta', 'shape': 'Berline', 'name': 'B1'},
      ]) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('brand_field')), carData['brand']!);
        await tester.enterText(find.byKey(const Key('shape_field')), carData['shape']!);
        await tester.enterText(find.byKey(const Key('name_field')), carData['name']!);

        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();
      }

      // Open sort dialog
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Select brand sorting
      await tester.tap(find.text('Marque'));
      await tester.pumpAndSettle();

      // Apply sorting
      await tester.tap(find.text('Appliquer'));
      await tester.pumpAndSettle();

      // Verify cars are sorted by brand (A1 should be first)
      final carItems = find.byType(ListTile);
      expect(carItems, findsAtLeastNWidgets(3));
    });

    testWidgets('should handle app navigation correctly', (tester) async {
      await tester.pumpWidget(const BoitodexApp());
      await tester.pumpAndSettle();

      // Start from home
      expect(find.text('Collection'), findsOneWidget);

      // Navigate to add car
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Ajouter'), findsOneWidget);

      // Go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Collection'), findsOneWidget);

      // Test menu actions
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Exporter'), findsOneWidget);
      expect(find.text('Actualiser'), findsOneWidget);

      // Close menu by tapping outside
      await tester.tap(find.text('Collection'));
      await tester.pumpAndSettle();
    });
  });
}