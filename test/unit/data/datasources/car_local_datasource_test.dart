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
  late CarLocalDataSourceImpl dataSource;
  late MockDatabaseService mockDatabaseService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockDatabase = MockDatabase();
    dataSource = CarLocalDataSourceImpl(mockDatabaseService);
  });

  final tDateTime = DateTime(2023, 1, 1);
  final tCarModel = CarModel(
    id: 1,
    brand: 'BMW',
    shape: 'Sedan',
    name: 'X5',
    createdAt: tDateTime,
    updatedAt: tDateTime,
  );

  final tCarMap = {
    'id': 1,
    'brand': 'BMW',
    'shape': 'Sedan',
    'name': 'X5',
    'informations': null,
    'is_piggy_bank': 0,
    'plays_music': 0,
    'photo': null,
    'created_at': tDateTime.millisecondsSinceEpoch,
    'updated_at': tDateTime.millisecondsSinceEpoch,
  };

  void setUpMockDatabase() {
    when(mockDatabaseService.database).thenAnswer((_) async => mockDatabase);
  }

  group('insertCar', () {
    test('should return id when database insert is successful', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);

      // act
      final result = await dataSource.insertCar(tCarModel);

      // assert
      expect(result, 1);
      verify(mockDatabase.insert('cars', tCarModel.toMap()));
    });

    test('should throw CacheException when database insert fails', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.insert(any, any)).thenThrow(Exception('Insert failed'));

      // act
      final call = dataSource.insertCar;

      // assert
      expect(() => call(tCarModel), throwsA(isA<CacheException>()));
    });
  });

  group('updateCar', () {
    test('should complete when database update is successful', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      // act
      await dataSource.updateCar(tCarModel);

      // assert
      verify(mockDatabase.update(
        'cars',
        tCarModel.toMap(),
        where: 'id = ?',
        whereArgs: [1],
      ));
    });

    test('should throw CacheException when database update fails', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenThrow(Exception('Update failed'));

      // act
      final call = dataSource.updateCar;

      // assert
      expect(() => call(tCarModel), throwsA(isA<CacheException>()));
    });
  });

  group('deleteCar', () {
    const tId = 1;

    test('should complete when database delete is successful', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.delete(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      // act
      await dataSource.deleteCar(tId);

      // assert
      verify(mockDatabase.delete(
        'cars',
        where: 'id = ?',
        whereArgs: [tId],
      ));
    });

    test('should throw CacheException when database delete fails', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.delete(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenThrow(Exception('Delete failed'));

      // act
      final call = dataSource.deleteCar;

      // assert
      expect(() => call(tId), throwsA(isA<CacheException>()));
    });
  });

  group('getCarById', () {
    const tId = 1;

    test('should return CarModel when car is found', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => [tCarMap]);

      // act
      final result = await dataSource.getCarById(tId);

      // assert
      expect(result, isA<CarModel>());
      expect(result?.id, 1);
      expect(result?.brand, 'BMW');
      verify(mockDatabase.query(
        'cars',
        where: 'id = ?',
        whereArgs: [tId],
        limit: 1,
      ));
    });

    test('should return null when car is not found', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => []);

      // act
      final result = await dataSource.getCarById(tId);

      // assert
      expect(result, null);
    });

    test('should throw CacheException when database query fails', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        limit: anyNamed('limit'),
      )).thenThrow(Exception('Query failed'));

      // act
      final call = dataSource.getCarById;

      // assert
      expect(() => call(tId), throwsA(isA<CacheException>()));
    });
  });

  group('getCars', () {
    test('should return list of CarModels when query is successful', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => [tCarMap]);

      // act
      final result = await dataSource.getCars();

      // assert
      expect(result, isA<List<CarModel>>());
      expect(result.length, 1);
      expect(result.first.id, 1);
      verify(mockDatabase.query(
        'cars',
        where: null,
        whereArgs: null,
        orderBy: 'name COLLATE NOCASE ASC',
        limit: null,
        offset: null,
      ));
    });

    test('should return filtered list when filter is provided', () async {
      // arrange
      const filter = FilterModel(brand: 'BMW');
      setUpMockDatabase();
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => [tCarMap]);

      // act
      final result = await dataSource.getCars(filter: filter);

      // assert
      expect(result, isA<List<CarModel>>());
      verify(mockDatabase.query(
        'cars',
        where: 'brand = ?',
        whereArgs: ['BMW'],
        orderBy: 'name COLLATE NOCASE ASC',
        limit: null,
        offset: null,
      ));
    });

    test('should return list with correct sorting when sort options are provided', () async {
      // arrange
      const filter = FilterModel(
        sortBy: SortOption.brand,
        sortAscending: false,
      );
      setUpMockDatabase();
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => [tCarMap]);

      // act
      final result = await dataSource.getCars(filter: filter);

      // assert
      expect(result, isA<List<CarModel>>());
      verify(mockDatabase.query(
        'cars',
        where: null,
        whereArgs: null,
        orderBy: 'brand COLLATE NOCASE DESC',
        limit: null,
        offset: null,
      ));
    });

    test('should throw CacheException when database query fails', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenThrow(Exception('Query failed'));

      // act
      final call = dataSource.getCars;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('getCarCount', () {
    test('should return count when query is successful', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.rawQuery(any, any))
          .thenAnswer((_) async => [{'count': 5}]);

      // act
      final result = await dataSource.getCarCount();

      // assert
      expect(result, 5);
      verify(mockDatabase.rawQuery(
        'SELECT COUNT(*) as count FROM cars',
        null,
      ));
    });

    test('should return filtered count when filter is provided', () async {
      // arrange
      const filter = FilterModel(brand: 'BMW');
      setUpMockDatabase();
      when(mockDatabase.rawQuery(any, any))
          .thenAnswer((_) async => [{'count': 3}]);

      // act
      final result = await dataSource.getCarCount(filter: filter);

      // assert
      expect(result, 3);
      verify(mockDatabase.rawQuery(
        'SELECT COUNT(*) as count FROM cars WHERE brand = ?',
        ['BMW'],
      ));
    });

    test('should return 0 when count is null', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.rawQuery(any, any))
          .thenAnswer((_) async => [{'count': null}]);

      // act
      final result = await dataSource.getCarCount();

      // assert
      expect(result, 0);
    });

    test('should throw CacheException when database query fails', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.rawQuery(any, any))
          .thenThrow(Exception('Query failed'));

      // act
      final call = dataSource.getCarCount;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('getDistinctBrands', () {
    test('should return list of brands when query is successful', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.rawQuery(any))
          .thenAnswer((_) async => [
        {'brand': 'BMW'},
        {'brand': 'Audi'},
        {'brand': 'Mercedes'},
      ]);

      // act
      final result = await dataSource.getDistinctBrands();

      // assert
      expect(result, ['BMW', 'Audi', 'Mercedes']);
      verify(mockDatabase.rawQuery(
        'SELECT DISTINCT brand FROM cars WHERE brand IS NOT NULL AND brand != "" ORDER BY brand COLLATE NOCASE ASC',
      ));
    });

    test('should filter out empty brands', () async {
      // arrange
      setUpMockDatabase();
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
      expect(result, ['BMW', 'Audi']);
    });

    test('should throw CacheException when database query fails', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.rawQuery(any))
          .thenThrow(Exception('Query failed'));

      // act
      final call = dataSource.getDistinctBrands;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('getDistinctShapes', () {
    test('should return list of shapes when query is successful', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.rawQuery(any))
          .thenAnswer((_) async => [
        {'shape': 'Sedan'},
        {'shape': 'SUV'},
        {'shape': 'Hatchback'},
      ]);

      // act
      final result = await dataSource.getDistinctShapes();

      // assert
      expect(result, ['Sedan', 'SUV', 'Hatchback']);
      verify(mockDatabase.rawQuery(
        'SELECT DISTINCT shape FROM cars WHERE shape IS NOT NULL AND shape != "" ORDER BY shape COLLATE NOCASE ASC',
      ));
    });

    test('should throw CacheException when database query fails', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.rawQuery(any))
          .thenThrow(Exception('Query failed'));

      // act
      final call = dataSource.getDistinctShapes;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('getAllCarsForExport', () {
    test('should return all cars ordered by creation date when query is successful', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.query(any, orderBy: anyNamed('orderBy')))
          .thenAnswer((_) async => [tCarMap]);

      // act
      final result = await dataSource.getAllCarsForExport();

      // assert
      expect(result, isA<List<CarModel>>());
      expect(result.length, 1);
      verify(mockDatabase.query('cars', orderBy: 'created_at ASC'));
    });

    test('should throw CacheException when database query fails', () async {
      // arrange
      setUpMockDatabase();
      when(mockDatabase.query(any, orderBy: anyNamed('orderBy')))
          .thenThrow(Exception('Query failed'));

      // act
      final call = dataSource.getAllCarsForExport;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });
}