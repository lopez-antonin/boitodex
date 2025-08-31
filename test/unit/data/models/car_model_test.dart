import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/data/models/car_model.dart';
import 'package:boitodex/domain/entities/car.dart';

void main() {
  group('CarModel', () {
    final now = DateTime(2023, 1, 1);
    final photoBytes = Uint8List.fromList([1, 2, 3, 4]);

    group('fromMap', () {
      test('should create CarModel from complete map', () {
        final map = {
          'id': 1,
          'brand': 'BMW',
          'shape': 'Berline',
          'name': 'Serie 3',
          'informations': 'Belle voiture',
          'is_piggy_bank': 1,
          'plays_music': 0,
          'photo': photoBytes,
          'created_at': now.millisecondsSinceEpoch,
          'updated_at': now.millisecondsSinceEpoch,
        };

        final carModel = CarModel.fromMap(map);

        expect(carModel.id, equals(1));
        expect(carModel.brand, equals('BMW'));
        expect(carModel.shape, equals('Berline'));
        expect(carModel.name, equals('Serie 3'));
        expect(carModel.informations, equals('Belle voiture'));
        expect(carModel.isPiggyBank, isTrue);
        expect(carModel.playsMusic, isFalse);
        expect(carModel.photo, equals(photoBytes));
        expect(carModel.createdAt, equals(now));
        expect(carModel.updatedAt, equals(now));
      });

      test('should handle null and missing values', () {
        final map = {
          'brand': 'Audi',
          'shape': 'SUV',
          'name': 'Q5',
        };

        final carModel = CarModel.fromMap(map);

        expect(carModel.id, isNull);
        expect(carModel.brand, equals('Audi'));
        expect(carModel.shape, equals('SUV'));
        expect(carModel.name, equals('Q5'));
        expect(carModel.informations, isNull);
        expect(carModel.isPiggyBank, isFalse);
        expect(carModel.playsMusic, isFalse);
        expect(carModel.photo, isNull);
        expect(carModel.createdAt, isA<DateTime>());
        expect(carModel.updatedAt, isA<DateTime>());
      });

      test('should handle empty strings correctly', () {
        final map = {
          'brand': '',
          'shape': '',
          'name': '',
          'informations': null,
          'is_piggy_bank': 0,
          'plays_music': 0,
          'created_at': now.millisecondsSinceEpoch,
          'updated_at': now.millisecondsSinceEpoch,
        };

        final carModel = CarModel.fromMap(map);

        expect(carModel.brand, equals(''));
        expect(carModel.shape, equals(''));
        expect(carModel.name, equals(''));
        expect(carModel.informations, isNull);
      });
    });

    group('toMap', () {
      test('should convert CarModel to map correctly', () {
        final carModel = CarModel(
          id: 1,
          brand: 'BMW',
          shape: 'Berline',
          name: 'Serie 3',
          informations: 'Belle voiture',
          isPiggyBank: true,
          playsMusic: false,
          photo: photoBytes,
          createdAt: now,
          updatedAt: now,
        );

        final map = carModel.toMap();

        expect(map['id'], equals(1));
        expect(map['brand'], equals('BMW'));
        expect(map['shape'], equals('Berline'));
        expect(map['name'], equals('Serie 3'));
        expect(map['informations'], equals('Belle voiture'));
        expect(map['is_piggy_bank'], equals(1));
        expect(map['plays_music'], equals(0));
        expect(map['photo'], equals(photoBytes));
        expect(map['created_at'], equals(now.millisecondsSinceEpoch));
        expect(map['updated_at'], equals(now.millisecondsSinceEpoch));
      });

      test('should handle null values in toMap', () {
        final carModel = CarModel(
          brand: 'Audi',
          shape: 'SUV',
          name: 'Q5',
          createdAt: now,
          updatedAt: now,
        );

        final map = carModel.toMap();

        expect(map['id'], isNull);
        expect(map['informations'], isNull);
        expect(map['is_piggy_bank'], equals(0));
        expect(map['plays_music'], equals(0));
        expect(map['photo'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create CarModel from Car entity', () {
        final car = Car(
          id: 1,
          brand: 'BMW',
          shape: 'Berline',
          name: 'Serie 3',
          informations: 'Belle voiture',
          isPiggyBank: true,
          playsMusic: false,
          photo: photoBytes,
          createdAt: now,
          updatedAt: now,
        );

        final carModel = CarModel.fromEntity(car);

        expect(carModel.id, equals(car.id));
        expect(carModel.brand, equals(car.brand));
        expect(carModel.shape, equals(car.shape));
        expect(carModel.name, equals(car.name));
        expect(carModel.informations, equals(car.informations));
        expect(carModel.isPiggyBank, equals(car.isPiggyBank));
        expect(carModel.playsMusic, equals(car.playsMusic));
        expect(carModel.photo, equals(car.photo));
        expect(carModel.createdAt, equals(car.createdAt));
        expect(carModel.updatedAt, equals(car.updatedAt));
      });
    });

    group('toJson', () {
      test('should convert CarModel to JSON correctly', () {
        final carModel = CarModel(
          brand: 'BMW',
          shape: 'Berline',
          name: 'Serie 3',
          informations: 'Belle voiture',
          isPiggyBank: true,
          playsMusic: false,
          photo: photoBytes,
          createdAt: now,
          updatedAt: now,
        );

        final json = carModel.toJson();

        expect(json['brand'], equals('BMW'));
        expect(json['shape'], equals('Berline'));
        expect(json['name'], equals('Serie 3'));
        expect(json['informations'], equals('Belle voiture'));
        expect(json['isPiggyBank'], isTrue);
        expect(json['playsMusic'], isFalse);
        expect(json['hasPhoto'], isTrue);
        expect(json['createdAt'], equals(now.toIso8601String()));
        expect(json['updatedAt'], equals(now.toIso8601String()));
      });

      test('should handle null values in toJson', () {
        final carModel = CarModel(
          brand: 'Audi',
          shape: 'SUV',
          name: 'Q5',
          createdAt: now,
          updatedAt: now,
        );

        final json = carModel.toJson();

        expect(json['informations'], isNull);
        expect(json['hasPhoto'], isFalse);
        expect(json['isPiggyBank'], isFalse);
        expect(json['playsMusic'], isFalse);
      });
    });

    group('inheritance', () {
      test('should extend Car entity correctly', () {
        final carModel = CarModel(
          brand: 'BMW',
          shape: 'Berline',
          name: 'Serie 3',
          createdAt: now,
          updatedAt: now,
        );

        expect(carModel, isA<Car>());
        expect(carModel.brand, equals('BMW'));
        expect(carModel.shape, equals('Berline'));
        expect(carModel.name, equals('Serie 3'));
      });
    });

    group('roundtrip conversion', () {
      test('should maintain data integrity through map conversion', () {
        final originalCarModel = CarModel(
          id: 1,
          brand: 'BMW',
          shape: 'Berline',
          name: 'Serie 3',
          informations: 'Belle voiture',
          isPiggyBank: true,
          playsMusic: false,
          photo: photoBytes,
          createdAt: now,
          updatedAt: now,
        );

        final map = originalCarModel.toMap();
        final reconstructedCarModel = CarModel.fromMap(map);

        expect(reconstructedCarModel.id, equals(originalCarModel.id));
        expect(reconstructedCarModel.brand, equals(originalCarModel.brand));
        expect(reconstructedCarModel.shape, equals(originalCarModel.shape));
        expect(reconstructedCarModel.name, equals(originalCarModel.name));
        expect(reconstructedCarModel.informations, equals(originalCarModel.informations));
        expect(reconstructedCarModel.isPiggyBank, equals(originalCarModel.isPiggyBank));
        expect(reconstructedCarModel.playsMusic, equals(originalCarModel.playsMusic));
        expect(reconstructedCarModel.photo, equals(originalCarModel.photo));
        expect(reconstructedCarModel.createdAt, equals(originalCarModel.createdAt));
        expect(reconstructedCarModel.updatedAt, equals(originalCarModel.updatedAt));
      });
    });
  });
}