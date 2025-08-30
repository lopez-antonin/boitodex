import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/domain/entities/car.dart';

void main() {
  group('Car', () {
    final tDateTime = DateTime(2023, 1, 1);
    final tPhotoBytes = Uint8List.fromList([1, 2, 3, 4]);

    final tCar = Car(
      id: 1,
      brand: 'BMW',
      shape: 'Sedan',
      name: 'X5',
      informations: 'Test info',
      isPiggyBank: true,
      playsMusic: false,
      photo: tPhotoBytes,
      createdAt: tDateTime,
      updatedAt: tDateTime,
    );

    group('copyWith', () {
      test('should return Car with updated fields', () {
        // arrange
        const newName = 'X7';
        const newBrand = 'Audi';

        // act
        final result = tCar.copyWith(
          name: newName,
          brand: newBrand,
        );

        // assert
        expect(result.name, newName);
        expect(result.brand, newBrand);
        expect(result.id, tCar.id);
        expect(result.shape, tCar.shape);
        expect(result.informations, tCar.informations);
        expect(result.isPiggyBank, tCar.isPiggyBank);
        expect(result.playsMusic, tCar.playsMusic);
        expect(result.photo, tCar.photo);
        expect(result.createdAt, tCar.createdAt);
        // updatedAt should be set to current time
        expect(result.updatedAt, isNot(tCar.updatedAt));
        expect(result.updatedAt, isA<DateTime>());
      });

      test('should return Car with same values when no parameters provided', () {
        // act
        final result = tCar.copyWith();

        // assert
        expect(result.id, tCar.id);
        expect(result.brand, tCar.brand);
        expect(result.shape, tCar.shape);
        expect(result.name, tCar.name);
        expect(result.informations, tCar.informations);
        expect(result.isPiggyBank, tCar.isPiggyBank);
        expect(result.playsMusic, tCar.playsMusic);
        expect(result.photo, tCar.photo);
        expect(result.createdAt, tCar.createdAt);
        // updatedAt should be set to current time
        expect(result.updatedAt, isNot(tCar.updatedAt));
      });

      test('should update boolean fields correctly', () {
        // act
        final result = tCar.copyWith(
          isPiggyBank: false,
          playsMusic: true,
        );

        // assert
        expect(result.isPiggyBank, false);
        expect(result.playsMusic, true);
        expect(result.brand, tCar.brand); // other fields unchanged
      });

      test('should update photo field', () {
        // arrange
        final newPhotoBytes = Uint8List.fromList([5, 6, 7, 8]);

        // act
        final result = tCar.copyWith(photo: newPhotoBytes);

        // assert
        expect(result.photo, newPhotoBytes);
        expect(result.photo, isNot(tCar.photo));
      });
    });

    group('props', () {
      test('should include all fields in props for equality comparison', () {
        // act
        final props = tCar.props;

        // assert
        expect(props.length, 10);
        expect(props, contains(tCar.id));
        expect(props, contains(tCar.brand));
        expect(props, contains(tCar.shape));
        expect(props, contains(tCar.name));
        expect(props, contains(tCar.informations));
        expect(props, contains(tCar.isPiggyBank));
        expect(props, contains(tCar.playsMusic));
        expect(props, contains(tCar.photo));
        expect(props, contains(tCar.createdAt));
        expect(props, contains(tCar.updatedAt));
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        // arrange
        final tCar2 = Car(
          id: 1,
          brand: 'BMW',
          shape: 'Sedan',
          name: 'X5',
          informations: 'Test info',
          isPiggyBank: true,
          playsMusic: false,
          photo: tPhotoBytes,
          createdAt: tDateTime,
          updatedAt: tDateTime,
        );

        // act & assert
        expect(tCar, equals(tCar2));
        expect(tCar.hashCode, equals(tCar2.hashCode));
      });

      test('should not be equal when fields differ', () {
        // arrange
        final tCar2 = Car(
          id: 2, // different id
          brand: 'BMW',
          shape: 'Sedan',
          name: 'X5',
          informations: 'Test info',
          isPiggyBank: true,
          playsMusic: false,
          photo: tPhotoBytes,
          createdAt: tDateTime,
          updatedAt: tDateTime,
        );

        // act & assert
        expect(tCar, isNot(equals(tCar2)));
        expect(tCar.hashCode, isNot(equals(tCar2.hashCode)));
      });
    });

    group('default values', () {
      test('should have correct default values', () {
        // arrange & act
        final carWithDefaults = Car(
          brand: 'BMW',
          shape: 'Sedan',
          name: 'X5',
          createdAt: tDateTime,
          updatedAt: tDateTime,
        );

        // assert
        expect(carWithDefaults.id, null);
        expect(carWithDefaults.informations, null);
        expect(carWithDefaults.isPiggyBank, false);
        expect(carWithDefaults.playsMusic, false);
        expect(carWithDefaults.photo, null);
      });
    });
  });
}