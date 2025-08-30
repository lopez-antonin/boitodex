import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:boitodex/core/error/exceptions.dart';
import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/data/datasources/local/car_local_datasource.dart';
import 'package:boitodex/data/models/car_model.dart';
import 'package:boitodex/data/models/filter_model.dart';
import 'package:boitodex/data/repositories/car_repository_impl.dart';
import 'package:boitodex/domain/entities/car.dart';
import 'package:boitodex/domain/entities/filter.dart';

import 'car_repository_impl_test.mocks.dart';

@GenerateMocks([CarLocalDataSource])
void main() {
  late CarRepositoryImpl repository;
  late MockCarLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockCarLocalDataSource();
    repository = CarRepositoryImpl(mockLocalDataSource);
  });

  final tDateTime = DateTime(2023, 1, 1);
  final tCar = Car(
    id: 1,
    brand: 'BMW',
    shape: 'Sedan',
    name: 'X5',
    createdAt: tDateTime,
    updatedAt: tDateTime,
  );

  final tCarModel = CarModel(
    id: 1,
    brand: 'BMW',
    shape: 'Sedan',
    name: 'X5',
    createdAt: tDateTime,
    updatedAt: tDateTime,
  );

  final tCarModels = [tCarModel];
  final tFilter = const CarFilter(brand: 'BMW');
  final tFilterModel = const FilterModel(brand: 'BMW');

  group('addCar', () {
    test('should return id when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.insertCar(any))
          .thenAnswer((_) async => 1);

      // act
      final result = await repository.addCar(tCar);

      // assert
      expect(result, const Right(1));
      verify(mockLocalDataSource.insertCar(any));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return CacheFailure when local data source throws CacheException', () async {
      // arrange
      when(mockLocalDataSource.insertCar(any))
          .thenThrow(const CacheException('Insert failed'));

      // act
      final result = await repository.addCar(tCar);

      // assert
      expect(result, const Left(CacheFailure('Insert failed')));
      verify(mockLocalDataSource.insertCar(any));
    });
  });

  group('updateCar', () {
    test('should return void when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.updateCar(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.updateCar(tCar);

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.updateCar(any));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return CacheFailure when local data source throws CacheException', () async {
      // arrange
      when(mockLocalDataSource.updateCar(any))
          .thenThrow(const CacheException('Update failed'));

      // act
      final result = await repository.updateCar(tCar);

      // assert
      expect(result, const Left(CacheFailure('Update failed')));
      verify(mockLocalDataSource.updateCar(any));
    });
  });

  group('deleteCar', () {
    const tId = 1;

    test('should return void when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.deleteCar(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.deleteCar(tId);

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.deleteCar(tId));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return CacheFailure when local data source throws CacheException', () async {
      // arrange
      when(mockLocalDataSource.deleteCar(any))
          .thenThrow(const CacheException('Delete failed'));

      // act
      final result = await repository.deleteCar(tId);

      // assert
      expect(result, const Left(CacheFailure('Delete failed')));
      verify(mockLocalDataSource.deleteCar(tId));
    });
  });

  group('getCarById', () {
    const tId = 1;

    test('should return CarModel when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.getCarById(any))
          .thenAnswer((_) async => tCarModel);

      // act
      final result = await repository.getCarById(tId);

      // assert
      expect(result, Right(tCarModel));
      verify(mockLocalDataSource.getCarById(tId));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return null when car is not found', () async {
      // arrange
      when(mockLocalDataSource.getCarById(any))
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getCarById(tId);

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.getCarById(tId));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return CacheFailure when local data source throws CacheException', () async {
      // arrange
      when(mockLocalDataSource.getCarById(any))
          .thenThrow(const CacheException('Get car failed'));

      // act
      final result = await repository.getCarById(tId);

      // assert
      expect(result, const Left(CacheFailure('Get car failed')));
      verify(mockLocalDataSource.getCarById(tId));
    });
  });

  group('getCars', () {
    test('should return list of cars when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.getCars())
          .thenAnswer((_) async => tCarModels);

      // act
      final result = await repository.getCars();

      // assert
      expect(result, Right(tCarModels));
      verify(mockLocalDataSource.getCars());
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return list of cars with filter when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.getCars(filter: anyNamed('filter')))
          .thenAnswer((_) async => tCarModels);

      // act
      final result = await repository.getCars(filter: tFilter);

      // assert
      expect(result, Right(tCarModels));
      verify(mockLocalDataSource.getCars(
        filter: argThat(
          isA<FilterModel>().having((f) => f.brand, 'brand', 'BMW'),
          named: 'filter',
        ),
      ));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return list of cars with limit and offset when local data source call is successful', () async {
      // arrange
      const limit = 20;
      const offset = 0;
      when(mockLocalDataSource.getCars(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => tCarModels);

      // act
      final result = await repository.getCars(limit: limit, offset: offset);

      // assert
      expect(result, Right(tCarModels));
      verify(mockLocalDataSource.getCars(limit: limit, offset: offset));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return CacheFailure when local data source throws CacheException', () async {
      // arrange
      when(mockLocalDataSource.getCars())
          .thenThrow(const CacheException('Get cars failed'));

      // act
      final result = await repository.getCars();

      // assert
      expect(result, const Left(CacheFailure('Get cars failed')));
      verify(mockLocalDataSource.getCars());
    });
  });

  group('getCarCount', () {
    const tCount = 5;

    test('should return count when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.getCarCount())
          .thenAnswer((_) async => tCount);

      // act
      final result = await repository.getCarCount();

      // assert
      expect(result, const Right(tCount));
      verify(mockLocalDataSource.getCarCount());
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return count with filter when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.getCarCount(filter: anyNamed('filter')))
          .thenAnswer((_) async => tCount);

      // act
      final result = await repository.getCarCount(filter: tFilter);

      // assert
      expect(result, const Right(tCount));
      verify(mockLocalDataSource.getCarCount(
        filter: argThat(
          isA<FilterModel>().having((f) => f.brand, 'brand', 'BMW'),
          named: 'filter',
        ),
      ));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return CacheFailure when local data source throws CacheException', () async {
      // arrange
      when(mockLocalDataSource.getCarCount())
          .thenThrow(const CacheException('Get count failed'));

      // act
      final result = await repository.getCarCount();

      // assert
      expect(result, const Left(CacheFailure('Get count failed')));
      verify(mockLocalDataSource.getCarCount());
    });
  });

  group('getBrands', () {
    const tBrands = ['BMW', 'Audi', 'Mercedes'];

    test('should return list of brands when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.getDistinctBrands())
          .thenAnswer((_) async => tBrands);

      // act
      final result = await repository.getBrands();

      // assert
      expect(result, const Right(tBrands));
      verify(mockLocalDataSource.getDistinctBrands());
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return CacheFailure when local data source throws CacheException', () async {
      // arrange
      when(mockLocalDataSource.getDistinctBrands())
          .thenThrow(const CacheException('Get brands failed'));

      // act
      final result = await repository.getBrands();

      // assert
      expect(result, const Left(CacheFailure('Get brands failed')));
      verify(mockLocalDataSource.getDistinctBrands());
    });
  });

  group('getShapes', () {
    const tShapes = ['Sedan', 'SUV', 'Hatchback'];

    test('should return list of shapes when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.getDistinctShapes())
          .thenAnswer((_) async => tShapes);

      // act
      final result = await repository.getShapes();

      // assert
      expect(result, const Right(tShapes));
      verify(mockLocalDataSource.getDistinctShapes());
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return CacheFailure when local data source throws CacheException', () async {
      // arrange
      when(mockLocalDataSource.getDistinctShapes())
          .thenThrow(const CacheException('Get shapes failed'));

      // act
      final result = await repository.getShapes();

      // assert
      expect(result, const Left(CacheFailure('Get shapes failed')));
      verify(mockLocalDataSource.getDistinctShapes());
    });
  });

  group('getAllCarsForExport', () {
    test('should return all cars when local data source call is successful', () async {
      // arrange
      when(mockLocalDataSource.getAllCarsForExport())
          .thenAnswer((_) async => tCarModels);

      // act
      final result = await repository.getAllCarsForExport();

      // assert
      expect(result, Right(tCarModels));
      verify(mockLocalDataSource.getAllCarsForExport());
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return CacheFailure when local data source throws CacheException', () async {
      // arrange
      when(mockLocalDataSource.getAllCarsForExport())
          .thenThrow(const CacheException('Export failed'));

      // act
      final result = await repository.getAllCarsForExport();

      // assert
      expect(result, const Left(CacheFailure('Export failed')));
      verify(mockLocalDataSource.getAllCarsForExport());
    });
  });
}