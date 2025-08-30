import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/features/home/presentation/widgets/car_list_item.dart';
import 'package:boitodex/domain/entities/car.dart';

void main() {
  group('CarListItem', () {
    final tDateTime = DateTime(2023, 1, 1);
    final tPhotoBytes = Uint8List.fromList([1, 2, 3, 4]);

    late Car tCar;
    bool onTapCalled = false;
    bool onDeleteCalled = false;

    setUp(() {
      onTapCalled = false;
      onDeleteCalled = false;
      tCar = Car(
        id: 1,
        brand: 'BMW',
        shape: 'Sedan',
        name: 'X5',
        informations: 'Test informations',
        isPiggyBank: false,
        playsMusic: false,
        photo: null,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );
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

    testWidgets('should display car basic information', (tester) async {
      // act
      await tester.pumpWidget(createWidget(tCar));

      // assert
      expect(find.text('X5'), findsOneWidget);
      expect(find.text('BMW • Sedan'), findsOneWidget);
      expect(find.text('Test informations'), findsOneWidget);
    });

    testWidgets('should display placeholder when no photo', (tester) async {
      // act
      await tester.pumpWidget(createWidget(tCar));

      // assert
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('should display photo when available', (tester) async {
      // arrange
      final carWithPhoto = tCar.copyWith(photo: tPhotoBytes);

      // act
      await tester.pumpWidget(createWidget(carWithPhoto));

      // assert
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display piggy bank icon when isPiggyBank is true', (tester) async {
      // arrange
      final piggyBankCar = tCar.copyWith(isPiggyBank: true);

      // act
      await tester.pumpWidget(createWidget(piggyBankCar));

      // assert
      expect(find.byIcon(Icons.savings), findsOneWidget);
      expect(find.text('Tirelire'), findsOneWidget);
    });

    testWidgets('should display music icon when playsMusic is true', (tester) async {
      // arrange
      final musicCar = tCar.copyWith(playsMusic: true);

      // act
      await tester.pumpWidget(createWidget(musicCar));

      // assert
      expect(find.byIcon(Icons.music_note), findsOneWidget);
      expect(find.text('Musique'), findsOneWidget);
    });

    testWidgets('should display both icons when both flags are true', (tester) async {
      // arrange
      final specialCar = tCar.copyWith(
        isPiggyBank: true,
        playsMusic: true,
      );

      // act
      await tester.pumpWidget(createWidget(specialCar));

      // assert
      expect(find.byIcon(Icons.savings), findsOneWidget);
      expect(find.text('Tirelire'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
      expect(find.text('Musique'), findsOneWidget);
    });

    testWidgets('should not display special icons when flags are false', (tester) async {
      // act
      await tester.pumpWidget(createWidget(tCar));

      // assert
      expect(find.byIcon(Icons.savings), findsNothing);
      expect(find.text('Tirelire'), findsNothing);
      expect(find.byIcon(Icons.music_note), findsNothing);
      expect(find.text('Musique'), findsNothing);
    });

    testWidgets('should call onTap when list tile is tapped', (tester) async {
      // act
      await tester.pumpWidget(createWidget(tCar));

      // Find and tap the ListTile
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // assert
      expect(onTapCalled, true);
    });

    testWidgets('should call onDelete when delete button is tapped', (tester) async {
      // act
      await tester.pumpWidget(createWidget(tCar));

      // Find and tap the delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      // assert
      expect(onDeleteCalled, true);
    });

    testWidgets('should display delete button with red color', (tester) async {
      // act
      await tester.pumpWidget(createWidget(tCar));

      // Find the IconButton with delete icon
      final deleteButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.delete_outline),
      );

      // assert
      expect(deleteButton.color, Colors.red);
    });

    testWidgets('should truncate long informations text', (tester) async {
      // arrange
      final carWithLongInfo = tCar.copyWith(
        informations: 'This is a very long information text that should be truncated when displayed in the list item to avoid layout issues and keep the UI clean and readable for users.',
      );

      // act
      await tester.pumpWidget(createWidget(carWithLongInfo));

      // Find the Text widget containing informations
      final informationsText = tester.widget<Text>(
        find.textContaining('This is a very long'),
      );

      // assert
      expect(informationsText.maxLines, 2);
      expect(informationsText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should not display informations when null or empty', (tester) async {
      // arrange
      final carWithoutInfo = tCar.copyWith(informations: null);

      // act
      await tester.pumpWidget(createWidget(carWithoutInfo));

      // assert - only basic info should be visible
      expect(find.text('X5'), findsOneWidget);
      expect(find.text('BMW • Sedan'), findsOneWidget);
      // No additional informations text should be found
      expect(find.textContaining('Test informations'), findsNothing);
    });

    testWidgets('should be wrapped in a Card', (tester) async {
      // act
      await tester.pumpWidget(createWidget(tCar));

      // assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have correct card margins', (tester) async {
      // act
      await tester.pumpWidget(createWidget(tCar));

      final card = tester.widget<Card>(find.byType(Card));

      // assert
      expect(card.margin, const EdgeInsets.symmetric(horizontal: 16, vertical: 4));
    });

    testWidgets('should display car name with bold font', (tester) async {
      // act
      await tester.pumpWidget(createWidget(tCar));

      // Find the title Text widget
      final nameText = tester.widget<Text>(find.text('X5'));

      // assert
      expect(nameText.style?.fontWeight, FontWeight.bold);
    });
  });
}