import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:boitodex/core/error/exceptions.dart';
import 'package:boitodex/data/datasources/local/car_local_datasource.dart';
import 'package:boitodex/data/models/car_model.dart';
import 'package:boitodex/data/models/filter_model.dart';
import 'package:boitodex/data/services/database_service.dart';
import 'package:boitodex/domain/entities/filter.dart';

import 'car_local_datasource_test.mocks.dart';

@GenerateMocks([DatabaseService, Database])
void main() {
  group('CarLocalDataSourceImpl', () {
    late CarLocalDataSourceImpl dataSource;
    late MockDatabaseService mockDatabaseService;
    late MockDatabase mockDatabase;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockDatabase = MockDatabase();
      dataSource = CarLocalDataSourceImpl(mockDatabaseService);
      when(mockDatabaseService.database).thenAnswer((_) async => mockDatabase);
    });

    final testCarModel = CarModel(
      id: 1,
      brand: 'BMW',
      shape: 'Berline',
      name: 'Serie 3',
      informations: 'Belle voiture',
      isPiggyBank: false,
      playsMusic: true,
      photo: Uint8List.fromList([1, 2, 3, 4]),
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 2),
    );

    group('insertCar', () {
      test('should return car id when insert succeeds', () async {
        // arrange
        const expectedId = 1;
        when(mockDatabase.insert('cars', any)).thenAnswer((_) async => expectedId);

        // act
        final result = await dataSource.insertCar(testCarModel);

        // assert
        expect(result, equals(expectedId));
        verify(mockDatabase.insert('cars', testCarModel.toMap())).called(1);
      });

      test('should throw CacheException when insert fails', () async {
        // arrange
        when(mockDatabase.insert('cars', any)).thenThrow(Exception('Insert failed'));

        // act & assert
        expect(
              () => dataSource.insertCar(testCarModel),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('updateCar', () {
      test('should update car successfully', () async {
        // arrange
        when(mockDatabase.update(
          'cars',
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => 1);

        // act
        await dataSource.updateCar(testCarModel);

        // assert
        verify(mockDatabase.update(
          'cars',
          testCarModel.toMap(),
          where: 'id = ?',
          whereArgs: [testCarModel.id],
        )).called(1);
      });

      test('should throw CacheException when update fails', () async {
        // arrange
        when(mockDatabase.update(
          any,
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenThrow(Exception('Update failed'));

        // act & assert
        expect(
              () => dataSource.updateCar(testCarModel),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('deleteCar', () {
      test('should delete car successfully', () async {
        // arrange
        const carId = 1;
        when(mockDatabase.delete(
          'cars',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => 1);

        // act
        await dataSource.deleteCar(carId);

        // assert
        verify(mockDatabase.delete(
          'cars',
          where: 'id = ?',
          whereArgs: [carId],
        )).called(1);
      });

      test('should throw CacheException when delete fails', () async {
        // arrange
        const carId = 1;
        when(mockDatabase.delete(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenThrow(Exception('Delete failed'));

        // act & assert
        expect(
              () => dataSource.deleteCar(carId),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('getCarById', () {
      test('should return car when found', () async {
        // arrange
        const carId = 1;
        when(mockDatabase.query(
          'cars',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => [testCarModel.toMap()]);

        // act
        final result = await dataSource.getCarById(carId);

        // assert
        expect(result, isA<CarModel>());
        expect(result?.id, equals(carId));
        verify(mockDatabase.query(
          'cars',
          where: 'id = ?',
          whereArgs: [carId],
          limit: 1,
        )).called(1);
      });

      test('should return null when car not found', () async {
        // arrange
        const carId = 999;
        when(mockDatabase.query(
          'cars',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => []);

        // act
        final result = await dataSource.getCarById(carId);

        // assert
        expect(result, isNull);
      });

      test('should throw CacheException when query fails', () async {
        // arrange
        const carId = 1;
        when(mockDatabase.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          limit: anyNamed('limit'),
        )).thenThrow(Exception('Query failed'));

        // act & assert
        expect(
              () => dataSource.getCarById(carId),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('getCars', () {
      test('should return list of cars', () async {
        // arrange
        when(mockDatabase.query(
          'cars',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => [testCarModel.toMap()]);

        // act
        final result = await dataSource.getCars();

        // assert
        expect(result, isA<List<CarModel>>());
        expect(result.length, equals(1));
        verify(mockDatabase.query(
          'cars',
          where: null,
          whereArgs: null,
          orderBy: 'name COLLATE NOCASE ASC',
          limit: null,
          offset: null,
        )).called(1);
      });

      test('should apply filter correctly', () async {
        // arrange
        const filter = FilterModel(brand: 'BMW', nameQuery: 'Serie');
        when(mockDatabase.query(
          'cars',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => [testCarModel.toMap()]);

        // act
        final result = await dataSource.getCars(filter: filter);

        // assert
        expect(result, isA<List<CarModel>>());
        verify(mockDatabase.query(
          'cars',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
          limit: null,
          offset: null,
        )).called(1);
      });

      test('should apply pagination correctly', () async {
        // arrange
        const limit = 10;
        const offset = 20;
        when(mockDatabase.query(
          'cars',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => [testCarModel.toMap()]);

        // act
        final result = await dataSource.getCars(limit: limit, offset: offset);

        // assert
        expect(result, isA<List<CarModel>>());
        verify(mockDatabase.query(
          'cars',
          where: null,
          whereArgs: null,
          orderBy: 'name COLLATE NOCASE ASC',
          limit: limit,
          offset: offset,
        )).called(1);
      });

      test('should throw CacheException when query fails', () async {
        // arrange
        when(mockDatabase.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Query failed'));

        // act & assert
        expect(
              () => dataSource.getCars(),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('getCarCount', () {
      test('should return car count', () async {
        // arrange
        const expectedCount = 5;
        when(mockDatabase.rawQuery(any, any))
            .thenAnswer((_) async => [{'count': expectedCount}]);

        // act
        final result = await dataSource.getCarCount();

        // assert
        expect(result, equals(expectedCount));
        verify(mockDatabase.rawQuery(
          'SELECT COUNT(*) as count FROM cars',
          null,
        )).called(1);
      });

      test('should apply filter when getting count', () async {
        // arrange
        const filter = FilterModel(brand: 'BMW');
        const expectedCount = 2;
        when(mockDatabase.rawQuery(any, any))
            .thenAnswer((_) async => [{'count': expectedCount}]);

        // act
        final result = await dataSource.getCarCount(filter: filter);

        // assert
        expect(result, equals(expectedCount));
        verify(mockDatabase.rawQuery(any, any)).called(1);
      });

      test('should return 0 when count is null', () async {
        // arrange
        when(mockDatabase.rawQuery(any, any))
            .thenAnswer((_) async => [{'count': null}]);

        // act
        final result = await dataSource.getCarCount();

        // assert
        expect(result, equals(0));
      });

      test('should throw CacheException when count fails', () async {
        // arrange
        when(mockDatabase.rawQuery(any, any)).thenThrow(Exception('Count failed'));

        // act & assert
        expect(
              () => dataSource.getCarCount(),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('getDistinctBrands', () {
      test('should return list of brands', () async {
        // arrange
        const expectedBrands = ['BMW', 'Audi'];
        when(mockDatabase.rawQuery(any))
            .thenAnswer((_) async => [
          {'brand': 'BMW'},
          {'brand': 'Audi'},
        ]);

        // act
        final result = await dataSource.getDistinctBrands();

        // assert
        expect(result, equals(expectedBrands));
        verify(mockDatabase.rawQuery(
          'SELECT DISTINCT brand FROM cars WHERE brand IS NOT NULL AND brand != "" ORDER BY brand COLLATE NOCASE ASC',
        )).called(1);
      });

      test('should filter out empty brands', () async {
        // arrange
        when(mockDatabase.rawQuery(any))
            .thenAnswer((_) async => [
          {'brand': 'BMW'},
          {'brand': ''},
          {'brand': null},
          {'brand': 'Audi'},
        ]);

        // act
        final result = await dataSource.getDistinctBrands();

        // assert
        expect(result, equals(['BMW', 'Audi']));
      });

      test('should throw CacheException when query fails', () async {
        // arrange
        when(mockDatabase.rawQuery(any)).thenThrow(Exception('Query failed'));

        // act & assert
        expect(
              () => dataSource.getDistinctBrands(),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('getDistinctShapes', () {
      test('should return list of shapes', () async {
        // arrange
        const expectedShapes = ['Berline', 'SUV'];
        when(mockDatabase.rawQuery(any))
            .thenAnswer((_) async => [
          {'shape': 'Berline'},
          {'shape': 'SUV'},
        ]);

        // act
        final result = await dataSource.getDistinctShapes();

        // assert
        expect(result, equals(expectedShapes));
        verify(mockDatabase.rawQuery(
          'SELECT DISTINCT shape FROM cars WHERE shape IS NOT NULL AND shape != "" ORDER BY shape COLLATE NOCASE ASC',
        )).called(1);
      });

      test('should throw CacheException when query fails', () async {
        // arrange
        when(mockDatabase.rawQuery(any)).thenThrow(Exception('Query failed'));

        // act & assert
        expect(
              () => dataSource.getDistinctShapes(),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('getAllCarsForExport', () {
      test('should return all cars ordered by creation date', () async {
        // arrange
        when(mockDatabase.query('cars', orderBy: 'created_at ASC'))
            .thenAnswer((_) async => [testCarModel.toMap()]);

        // act
        final result = await dataSource.getAllCarsForExport();

        // assert
        expect(result, isA<List<CarModel>>());
        expect(result.length, equals(1));
        verify(mockDatabase.query('cars', orderBy: 'created_at ASC')).called(1);
      });

      test('should throw CacheException when export query fails', () async {
        // arrange
        when(mockDatabase.query(any, orderBy: anyNamed('orderBy')))
            .thenThrow(Exception('Export failed'));

        // act & assert
        expect(
              () => dataSource.getAllCarsForExport(),
          throwsA(isA<CacheException>()),
        );
      });
    });
  });
}