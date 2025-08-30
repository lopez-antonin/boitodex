import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:boitodex/data/models/car_model.dart';
import 'package:boitodex/domain/entities/car.dart';

void main() {
  group('CarModel', () {
    final tDateTime = DateTime(2023, 1, 1);
    final tPhotoBytes = Uint8List.fromList([1, 2, 3, 4]);

    final tCarModel = CarModel(
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

    final tMap = {
      'id': 1,
      'brand': 'BMW',
      'shape': 'Sedan',
      'name': 'X5',
      'informations': 'Test info',
      'is_piggy_bank': 1,
      'plays_music': 0,
      'photo': tPhotoBytes,
      'created_at': tDateTime.millisecondsSinceEpoch,
      'updated_at': tDateTime.millisecondsSinceEpoch,
    };

    group('fromMap', () {
      test('should return CarModel with all fields populated', () {
        // act
        final result = CarModel.fromMap(tMap);

        // assert
        expect(result, tCarModel);
        expect(result.id, 1);
        expect(result.brand, 'BMW');
        expect(result.shape, 'Sedan');
        expect(result.name, 'X5');
        expect(result.informations, 'Test info');
        expect(result.isPiggyBank, true);
        expect(result.playsMusic, false);
        expect(result.photo, tPhotoBytes);
        expect(result.createdAt, tDateTime);
        expect(result.updatedAt, tDateTime);
      });

      test('should return CarModel with default values when fields are missing', () {
        // arrange
        final mapWithMissingFields = {
          'id': null,
          'brand': null,
          'shape': null,
          'name': null,
          'informations': null,
          'is_piggy_bank': null,
          'plays_music': null,
          'photo': null,
          'created_at': null,
          'updated_at': null,
        };

        // act
        final result = CarModel.fromMap(mapWithMissingFields);

        // assert
        expect(result.id, null);
        expect(result.brand, '');
        expect(result.shape, '');
        expect(result.name, '');
        expect(result.informations, null);
        expect(result.isPiggyBank, false);
        expect(result.playsMusic, false);
        expect(result.photo, null);
        // createdAt and updatedAt should be set to current time when null
        expect(result.createdAt, isA<DateTime>());
        expect(result.updatedAt, isA<DateTime>());
      });
    });

    group('toMap', () {
      test('should return Map with all fields', () {
        // act
        final result = tCarModel.toMap();

        // assert
        expect(result, tMap);
      });

      test('should convert boolean fields to integers', () {
        // act
        final result = tCarModel.toMap();

        // assert
        expect(result['is_piggy_bank'], 1);
        expect(result['plays_music'], 0);
      });

      test('should convert DateTime to milliseconds', () {
        // act
        final result = tCarModel.toMap();

        // assert
        expect(result['created_at'], tDateTime.millisecondsSinceEpoch);
        expect(result['updated_at'], tDateTime.millisecondsSinceEpoch);
      });
    });

    group('fromEntity', () {
      test('should create CarModel from Car entity', () {
        // arrange
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

        // act
        final result = CarModel.fromEntity(tCar);

        // assert
        expect(result, tCarModel);
        expect(result.id, tCar.id);
        expect(result.brand, tCar.brand);
        expect(result.shape, tCar.shape);
        expect(result.name, tCar.name);
        expect(result.informations, tCar.informations);
        expect(result.isPiggyBank, tCar.isPiggyBank);
        expect(result.playsMusic, tCar.playsMusic);
        expect(result.photo, tCar.photo);
        expect(result.createdAt, tCar.createdAt);
        expect(result.updatedAt, tCar.updatedAt);
      });
    });

    group('toJson', () {
      test('should return JSON map without sensitive data', () {
        // act
        final result = tCarModel.toJson();

        // assert
        expect(result, {
          'brand': 'BMW',
          'shape': 'Sedan',
          'name': 'X5',
          'informations': 'Test info',
          'isPiggyBank': true,
          'playsMusic': false,
          'hasPhoto': true,
          'createdAt': tDateTime.toIso8601String(),
          'updatedAt': tDateTime.toIso8601String(),
        });
      });

      test('should indicate hasPhoto as false when photo is null', () {
        // arrange
        final carWithoutPhoto = CarModel(
          brand: 'BMW',
          shape: 'Sedan',
          name: 'X5',
          photo: null,
          createdAt: tDateTime,
          updatedAt: tDateTime,
        );

        // act
        final result = carWithoutPhoto.toJson();

        // assert
        expect(result['hasPhoto'], false);
      });
    });
  });
}