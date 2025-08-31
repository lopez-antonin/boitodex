import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/domain/entities/car.dart';

void main() {
  group('Car', () {
    final now = DateTime.now();
    final photoBytes = Uint8List.fromList([1, 2, 3, 4]);

    test('should create a car with all properties', () {
      final car = Car(
        id: 1,
        brand: 'BMW',
        shape: 'Berline',
        name: 'Serie 3',
        informations: 'Belle voiture',
        isPiggyBank: true,
        playsMusic: false,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 2),
      );

      expect(car.id, equals(1));
      expect(car.brand, equals('BMW'));
      expect(car.shape, equals('Berline'));
      expect(car.name, equals('Serie 3'));
      expect(car.informations, equals('Belle voiture'));
      expect(car.isPiggyBank, isTrue);
      expect(car.playsMusic, isFalse);
      expect(car.createdAt, equals(DateTime(2023, 1, 1)));
      expect(car.updatedAt, equals(DateTime(2023, 1, 2)));
    });

    test('should create a car with default values', () {
      final car = Car(
        brand: 'Audi',
        shape: 'SUV',
        name: 'Q5',
        createdAt: now,
        updatedAt: now,
      );

      expect(car.id, isNull);
      expect(car.brand, equals('Audi'));
      expect(car.shape, equals('SUV'));
      expect(car.name, equals('Q5'));
      expect(car.informations, isNull);
      expect(car.isPiggyBank, isFalse);
      expect(car.playsMusic, isFalse);
      expect(car.photo, isNull);
      expect(car.createdAt, equals(now));
      expect(car.updatedAt, equals(now));
    });

    group('copyWith', () {
      late Car originalCar;

      setUp(() {
        originalCar = Car(
          id: 1,
          brand: 'BMW',
          shape: 'Berline',
          name: 'Serie 3',
          informations: 'Belle voiture',
          isPiggyBank: false,
          playsMusic: false,
          photo: photoBytes,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
        );
      });

      test('should return Car with updated fields', () {
        final updatedCar = originalCar.copyWith(
          name: 'Serie 5',
          isPiggyBank: true,
          playsMusic: true,
        );

        expect(updatedCar.id, equals(1));
        expect(updatedCar.brand, equals('BMW'));
        expect(updatedCar.shape, equals('Berline'));
        expect(updatedCar.name, equals('Serie 5'));
        expect(updatedCar.informations, equals('Belle voiture'));
        expect(updatedCar.isPiggyBank, isTrue);
        expect(updatedCar.playsMusic, isTrue);
        expect(updatedCar.photo, equals(photoBytes));
        expect(updatedCar.createdAt, equals(DateTime(2023, 1, 1)));
        expect(updatedCar.updatedAt, isNot(equals(DateTime(2023, 1, 2))));
      });

      test('should return same Car when no fields are updated', () {
        final sameCar = originalCar.copyWith();

        expect(sameCar.id, equals(originalCar.id));
        expect(sameCar.brand, equals(originalCar.brand));
        expect(sameCar.shape, equals(originalCar.shape));
        expect(sameCar.name, equals(originalCar.name));
        expect(sameCar.informations, equals(originalCar.informations));
        expect(sameCar.isPiggyBank, equals(originalCar.isPiggyBank));
        expect(sameCar.playsMusic, equals(originalCar.playsMusic));
        expect(sameCar.photo, equals(originalCar.photo));
        expect(sameCar.createdAt, equals(originalCar.createdAt));
        expect(sameCar.updatedAt, isNot(equals(originalCar.updatedAt)));
      });

      test('should update updatedAt automatically', () {
        final now = DateTime.now();
        final updatedCar = originalCar.copyWith(name: 'New Name');

        expect(updatedCar.updatedAt.isAfter(now.subtract(const Duration(seconds: 1))), isTrue);
        expect(updatedCar.createdAt, equals(originalCar.createdAt));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        final car1 = Car(
          id: 1,
          brand: 'BMW',
          shape: 'Berline',
          name: 'Serie 3',
          informations: 'Belle voiture',
          isPiggyBank: true,
          playsMusic: false,
          photo: photoBytes,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
        );

        final car2 = Car(
          id: 1,
          brand: 'BMW',
          shape: 'Berline',
          name: 'Serie 3',
          informations: 'Belle voiture',
          isPiggyBank: true,
          playsMusic: false,
          photo: photoBytes,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
        );

        expect(car1, equals(car2));
        expect(car1.hashCode, equals(car2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final car1 = Car(
          brand: 'BMW',
          shape: 'Berline',
          name: 'Serie 3',
          createdAt: now,
          updatedAt: now,
        );

        final car2 = Car(
          brand: 'Audi',
          shape: 'Berline',
          name: 'Serie 3',
          createdAt: now,
          updatedAt: now,
        );

        expect(car1, isNot(equals(car2)));
        expect(car1.hashCode, isNot(equals(car2.hashCode)));
      });
    });
  });
}