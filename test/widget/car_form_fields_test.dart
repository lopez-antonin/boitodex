import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/features/car_form/presentation/widgets/car_form_fields.dart';

void main() {
  group('CarFormFields', () {
    late TextEditingController brandController;
    late TextEditingController shapeController;
    late TextEditingController nameController;
    late TextEditingController informationsController;
    bool isPiggyBank = false;
    bool playsMusic = false;
    bool piggyBankChanged = false;
    bool playsMusicChanged = false;

    setUp(() {
      brandController = TextEditingController();
      shapeController = TextEditingController();
      nameController = TextEditingController();
      informationsController = TextEditingController();
      isPiggyBank = false;
      playsMusic = false;
      piggyBankChanged = false;
      playsMusicChanged = false;
    });

    tearDown(() {
      brandController.dispose();
      shapeController.dispose();
      nameController.dispose();
      informationsController.dispose();
    });

    Widget createWidget() {
      return MaterialApp(
        home: Scaffold(
          body: Form(
            child: CarFormFields(
              brandController: brandController,
              shapeController: shapeController,
              nameController: nameController,
              informationsController: informationsController,
              isPiggyBank: isPiggyBank,
              playsMusic: playsMusic,
              onPiggyBankChanged: (value) {
                isPiggyBank = value;
                piggyBankChanged = true;
              },
              onPlaysMusicChanged: (value) {
                playsMusic = value;
                playsMusicChanged = true;
              },
            ),
          ),
        ),
      );
    }

    testWidgets('should display all form fields', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Marque *'), findsOneWidget);
      expect(find.text('Forme *'), findsOneWidget);
      expect(find.text('Nom *'), findsOneWidget);
      expect(find.text('Informations'), findsOneWidget);
      expect(find.text('Tirelire'), findsOneWidget);
      expect(find.text('Fait de la musique'), findsOneWidget);
    });

    testWidgets('should validate required fields', (tester) async {
      await tester.pumpWidget(createWidget());

      // Find all TextFormField widgets
      final formFields = find.byType(TextFormField);
      expect(formFields, findsNWidgets(4)); // 4 text fields total

      // Manually trigger validation on each field
      final brandFormField = tester.widget<TextFormField>(formFields.at(0));
      final shapeFormField = tester.widget<TextFormField>(formFields.at(1));
      final nameFormField = tester.widget<TextFormField>(formFields.at(2));

      // Test validation for empty values
      expect(brandFormField.validator!(''), contains('Ce champ est obligatoire'));
      expect(shapeFormField.validator!(''), contains('Ce champ est obligatoire'));
      expect(nameFormField.validator!(''), contains('Ce champ est obligatoire'));

      // Test validation for valid values
      expect(brandFormField.validator!('BMW'), isNull);
      expect(shapeFormField.validator!('Berline'), isNull);
      expect(nameFormField.validator!('Serie 3'), isNull);
    });

    testWidgets('should handle text input correctly', (tester) async {
      await tester.pumpWidget(createWidget());

      // Test brand input
      await tester.enterText(find.byType(TextFormField).at(0), 'BMW');
      expect(brandController.text, equals('BMW'));

      // Test shape input
      await tester.enterText(find.byType(TextFormField).at(1), 'Berline');
      expect(shapeController.text, equals('Berline'));

      // Test name input
      await tester.enterText(find.byType(TextFormField).at(2), 'Serie 3');
      expect(nameController.text, equals('Serie 3'));

      // Test informations input
      await tester.enterText(find.byType(TextFormField).at(3), 'Belle voiture');
      expect(informationsController.text, equals('Belle voiture'));
    });

    testWidgets('should toggle switches correctly', (tester) async {
      await tester.pumpWidget(createWidget());

      // Find switches
      final switches = find.byType(SwitchListTile);
      expect(switches, findsNWidgets(2));

      // Toggle piggy bank switch
      await tester.tap(switches.first);
      await tester.pumpAndSettle();
      expect(piggyBankChanged, isTrue);

      // Toggle music switch
      await tester.tap(switches.last);
      await tester.pumpAndSettle();
      expect(playsMusicChanged, isTrue);
    });

    testWidgets('should display switch subtitles', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Cette voiture est une tirelire'), findsOneWidget);
      expect(find.text('Cette voiture émet des sons'), findsOneWidget);
    });

    testWidgets('should have correct input decoration', (tester) async {
      await tester.pumpWidget(createWidget());

      final formFields = find.byType(TextFormField);

      // Check that all fields have OutlineInputBorder
      for (int i = 0; i < 4; i++) {
        final field = tester.widget<TextFormField>(formFields.at(i));
        final decoration = field.decoration as InputDecoration;
        expect(decoration.border, isA<OutlineInputBorder>());
      }
    });

    testWidgets('should validate informations max length', (tester) async {
      await tester.pumpWidget(createWidget());

      final informationsField = tester.widget<TextFormField>(find.byType(TextFormField).at(3));

      // Test with text within limit
      expect(informationsField.validator!('Short text'), isNull);

      // Test with text exceeding limit
      final longText = 'A' * 501; // Exceeding 500 characters
      final result = informationsField.validator!(longText);
      expect(result, contains('Limite de caractères dépassée'));
    });

    testWidgets('should display hint text for informations field', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Notes, état, origine...'), findsOneWidget);
    });

    testWidgets('should reflect switch states correctly', (tester) async {
      // Test with switches initially on
      isPiggyBank = true;
      playsMusic = true;

      await tester.pumpWidget(createWidget());

      final switches = find.byType(SwitchListTile);
      final piggyBankSwitch = tester.widget<SwitchListTile>(switches.first);
      final musicSwitch = tester.widget<SwitchListTile>(switches.last);

      expect(piggyBankSwitch.value, isTrue);
      expect(musicSwitch.value, isTrue);
    });

    testWidgets('should have card container for switches', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Card), findsOneWidget);

      final card = find.byType(Card);
      final cardWidget = tester.widget<Card>(card);

      // Verify switches are inside the card
      final switchesInCard = find.descendant(
        of: card,
        matching: find.byType(SwitchListTile),
      );
      expect(switchesInCard, findsNWidgets(2));
    });
  });
}