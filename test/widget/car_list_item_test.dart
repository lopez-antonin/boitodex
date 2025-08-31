import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/domain/entities/car.dart';
import 'package:boitodex/features/home/presentation/widgets/car_list_item.dart';

void main() {
  group('CarListItem', () {
    late Car testCar;
    bool onTapCalled = false;
    bool onDeleteCalled = false;

    setUp(() {
      testCar = Car(
        id: 1,
        brand: 'BMW',
        shape: 'Berline',
        name: 'Serie 3',
        informations: 'Test informations',
        isPiggyBank: false,
        playsMusic: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      onTapCalled = false;
      onDeleteCalled = false;
    });

    Widget createWidget(Car car) {
      return MaterialApp(
        home: Scaffold(
          body: CarListItem(
            car: car,
            onTap: () => onTapCalled = true,
            onDelete: () => onDeleteCalled = true,
          ),
        ),
      );
    }

    testWidgets('should display car information correctly', (tester) async {
      await tester.pumpWidget(createWidget(testCar));

      expect(find.text('Serie 3'), findsOneWidget);
      expect(find.text('BMW • Berline'), findsOneWidget);
      expect(find.text('Test informations'), findsOneWidget);
    });

    testWidgets('should display special features when enabled', (tester) async {
      final carWithFeatures = testCar.copyWith(
        isPiggyBank: true,
        playsMusic: true,
      );

      await tester.pumpWidget(createWidget(carWithFeatures));

      expect(find.byIcon(Icons.savings), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
      expect(find.text('Tirelire'), findsOneWidget);
      expect(find.text('Musique'), findsOneWidget);
    });

    testWidgets('should not display special features when disabled', (tester) async {
      await tester.pumpWidget(createWidget(testCar));

      expect(find.byIcon(Icons.savings), findsNothing);
      expect(find.byIcon(Icons.music_note), findsNothing);
      expect(find.text('Tirelire'), findsNothing);
      expect(find.text('Musique'), findsNothing);
    });

    testWidgets('should not display informations when null or empty', (tester) async {
      final carWithoutInfo = testCar.copyWith(informations: null);
      await tester.pumpWidget(createWidget(carWithoutInfo));

      expect(find.text('Test informations'), findsNothing);

      final carWithEmptyInfo = testCar.copyWith(informations: '');
      await tester.pumpWidget(createWidget(carWithEmptyInfo));

      expect(find.text('Test informations'), findsNothing);
    });

    testWidgets('should display placeholder image when no photo', (tester) async {
      await tester.pumpWidget(createWidget(testCar));

      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('should display photo when available', (tester) async {
      // Create a simple 2x2 PNG image
      final pngBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
        0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
        0x49, 0x48, 0x44, 0x52, // IHDR
        0x00, 0x00, 0x00, 0x02, // Width: 2
        0x00, 0x00, 0x00, 0x02, // Height: 2
        0x08, 0x06, 0x00, 0x00, 0x00, // Bit depth, color type, compression, filter, interlace
        0x72, 0xB6, 0x0D, 0x24, // CRC
        0x00, 0x00, 0x00, 0x0C, // IDAT chunk length
        0x49, 0x44, 0x41, 0x54, // IDAT
        0x08, 0xD7, 0x63, 0x60, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, // Compressed data
        0xE2, 0x21, 0xBC, 0x33, // CRC
        0x00, 0x00, 0x00, 0x00, // IEND chunk length
        0x49, 0x45, 0x4E, 0x44, // IEND
        0xAE, 0x42, 0x60, 0x82  // CRC
      ]);

      final carWithPhoto = testCar.copyWith(photo: pngBytes);
      await tester.pumpWidget(createWidget(carWithPhoto));

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsNothing);
    });

    testWidgets('should fall back to placeholder when image fails to load', (tester) async {
      final carWithInvalidPhoto = testCar.copyWith(
        photo: Uint8List.fromList([1, 2, 3, 4]), // Invalid image data
      );

      await tester.pumpWidget(createWidget(carWithInvalidPhoto));

      // The errorBuilder should show the placeholder
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('should handle tap correctly', (tester) async {
      await tester.pumpWidget(createWidget(testCar));

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(onTapCalled, isTrue);
    });

    testWidgets('should handle delete button tap correctly', (tester) async {
      await tester.pumpWidget(createWidget(testCar));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(onDeleteCalled, isTrue);
    });

    testWidgets('should have correct card layout', (tester) async {
      await tester.pumpWidget(createWidget(testCar));

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 4)));
    });

    testWidgets('should truncate long informations text', (tester) async {
      final carWithLongInfo = testCar.copyWith(
        informations: 'This is a very long information text that should be truncated to show only two lines maximum',
      );

      await tester.pumpWidget(createWidget(carWithLongInfo));

      final informationsText = tester.widget<Text>(
        find.text('This is a very long information text that should be truncated to show only two lines maximum'),
      );

      expect(informationsText.maxLines, equals(2));
      expect(informationsText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should display only piggy bank feature', (tester) async {
      final carOnlyPiggyBank = testCar.copyWith(
        isPiggyBank: true,
        playsMusic: false,
      );

      await tester.pumpWidget(createWidget(carOnlyPiggyBank));

      expect(find.byIcon(Icons.savings), findsOneWidget);
      expect(find.text('Tirelire'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsNothing);
      expect(find.text('Musique'), findsNothing);
    });

    testWidgets('should display only music feature', (tester) async {
      final carOnlyMusic = testCar.copyWith(
        isPiggyBank: false,
        playsMusic: true,
      );

      await tester.pumpWidget(createWidget(carOnlyMusic));

      expect(find.byIcon(Icons.savings), findsNothing);
      expect(find.text('Tirelire'), findsNothing);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
      expect(find.text('Musique'), findsOneWidget);
    });

    testWidgets('should have correct text styling', (tester) async {
      await tester.pumpWidget(createWidget(testCar));

      final nameText = tester.widget<Text>(find.text('Serie 3'));
      expect(nameText.style?.fontWeight, equals(FontWeight.bold));

      final informationsText = tester.widget<Text>(find.text('Test informations'));
      expect(informationsText.style?.fontStyle, equals(FontStyle.italic));
    });
  });
}