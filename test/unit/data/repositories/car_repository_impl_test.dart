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
  group('CarRepositoryImpl', () {
    late CarRepositoryImpl repository;
    late MockCarLocalDataSource mockLocalDataSource;

    setUp(() {
      mockLocalDataSource = MockCarLocalDataSource();
      repository = CarRepositoryImpl(mockLocalDataSource);
    });

    final testCar = Car(
      id: 1,
      brand: 'BMW',
      shape: 'Berline',
      name: 'Serie 3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final testCarModel = CarModel.fromEntity(testCar);

    group('addCar', () {
      test('should return car id when adding car succeeds', () async {
        // arrange
        const expectedId = 1;
        when(mockLocalDataSource.insertCar(any))
            .thenAnswer((_) async => expectedId);

        // act
        final result = await repository.addCar(testCar);

        // assert
        expect(result, const Right(expectedId));
        verify(mockLocalDataSource.insertCar(any)).called(1);
      });

      test('should return CacheFailure when adding car fails', () async {
        // arrange
        when(mockLocalDataSource.insertCar(any))
            .thenThrow(const CacheException('Insert failed'));

        // act
        final result = await repository.addCar(testCar);

        // assert
        expect(result, const Left(CacheFailure('Insert failed')));
        verify(mockLocalDataSource.insertCar(any)).called(1);
      });
    });

    group('updateCar', () {
      test('should return success when updating car succeeds', () async {
        // arrange
        when(mockLocalDataSource.updateCar(any))
            .thenAnswer((_) async {});

        // act
        final result = await repository.updateCar(testCar);

        // assert
        expect(result, const Right(null));
        verify(mockLocalDataSource.updateCar(any)).called(1);
      });

      test('should return CacheFailure when updating car fails', () async {
        // arrange
        when(mockLocalDataSource.updateCar(any))
            .thenThrow(const CacheException('Update failed'));

        // act
        final result = await repository.updateCar(testCar);

        // assert
        expect(result, const Left(CacheFailure('Update failed')));
        verify(mockLocalDataSource.updateCar(any)).called(1);
      });
    });

    group('deleteCar', () {
      test('should return success when deleting car succeeds', () async {
        // arrange
        const carId = 1;
        when(mockLocalDataSource.deleteCar(carId))
            .thenAnswer((_) async {});

        // act
        final result = await repository.deleteCar(carId);

        // assert
        expect(result, const Right(null));
        verify(mockLocalDataSource.deleteCar(carId)).called(1);
      });

      test('should return CacheFailure when deleting car fails', () async {
        // arrange
        const carId = 1;
        when(mockLocalDataSource.deleteCar(carId))
            .thenThrow(const CacheException('Delete failed'));

        // act
        final result = await repository.deleteCar(carId);

        // assert
        expect(result, const Left(CacheFailure('Delete failed')));
        verify(mockLocalDataSource.deleteCar(carId)).called(1);
      });
    });

    group('getCarById', () {
      test('should return car when found', () async {
        // arrange
        const carId = 1;
        when(mockLocalDataSource.getCarById(carId))
            .thenAnswer((_) async => testCarModel);

        // act
        final result = await repository.getCarById(carId);

        // assert
        expect(result, Right(testCarModel));
        verify(mockLocalDataSource.getCarById(carId)).called(1);
      });

      test('should return null when car not found', () async {
        // arrange
        const carId = 999;
        when(mockLocalDataSource.getCarById(carId))
            .thenAnswer((_) async => null);

        // act
        final result = await repository.getCarById(carId);

        // assert
        expect(result, const Right(null));
        verify(mockLocalDataSource.getCarById(carId)).called(1);
      });

      test('should return CacheFailure when getting car fails', () async {
        // arrange
        const carId = 1;
        when(mockLocalDataSource.getCarById(carId))
            .thenThrow(const CacheException('Get failed'));

        // act
        final result = await repository.getCarById(carId);

        // assert
        expect(result, const Left(CacheFailure('Get failed')));
        verify(mockLocalDataSource.getCarById(carId)).called(1);
      });
    });

    group('getCars', () {
      final testCars = [testCarModel];

      test('should return cars list when successful', () async {
        // arrange
        when(mockLocalDataSource.getCars())
            .thenAnswer((_) async => testCars);

        // act
        final result = await repository.getCars();

        // assert
        expect(result, Right(testCars));
        verify(mockLocalDataSource.getCars()).called(1);
      });

      test('should pass filter to datasource', () async {
        // arrange
        const filter = CarFilter(brand: 'BMW');
        when(mockLocalDataSource.getCars(filter: any(named: 'filter')))
            .thenAnswer((_) async => testCars);

        // act
        final result = await repository.getCars(filter: filter);

        // assert
        expect(result, Right(testCars));
        final captured = verify(mockLocalDataSource.getCars(
          filter: captureAnyNamed('filter'),
        )).captured;
        expect(captured.first, isA<FilterModel>());
      });

      test('should pass pagination parameters to datasource', () async {
        // arrange
        const limit = 10;
        const offset = 20;
        when(mockLocalDataSource.getCars(
          limit: limit,
          offset: offset,
        )).thenAnswer((_) async => testCars);

        // act
        final result = await repository.getCars(limit: limit, offset: offset);

        // assert
        expect(result, Right(testCars));
        verify(mockLocalDataSource.getCars(
          limit: limit,
          offset: offset,
        )).called(1);
      });

      test('should return CacheFailure when getting cars fails', () async {
        // arrange
        when(mockLocalDataSource.getCars())
            .thenThrow(const CacheException('Get cars failed'));

        // act
        final result = await repository.getCars();

        // assert
        expect(result, const Left(CacheFailure('Get cars failed')));
        verify(mockLocalDataSource.getCars()).called(1);
      });
    });

    group('getCarCount', () {
      test('should return car count when successful', () async {
        // arrange
        const expectedCount = 5;
        when(mockLocalDataSource.getCarCount())
            .thenAnswer((_) async => expectedCount);

        // act
        final result = await repository.getCarCount();

        // assert
        expect(result, const Right(expectedCount));
        verify(mockLocalDataSource.getCarCount()).called(1);
      });

      test('should pass filter to datasource', () async {
        // arrange
        const filter = CarFilter(brand: 'BMW');
        const expectedCount = 2;
        when(mockLocalDataSource.getCarCount(filter: any(named: 'filter')))
            .thenAnswer((_) async => expectedCount);

        // act
        final result = await repository.getCarCount(filter: filter);

        // assert
        expect(result, const Right(expectedCount));
        verify(mockLocalDataSource.getCarCount(
          filter: any(named: 'filter'),
        )).called(1);
      });

      test('should return CacheFailure when getting count fails', () async {
        // arrange
        when(mockLocalDataSource.getCarCount())
            .thenThrow(const CacheException('Count failed'));

        // act
        final result = await repository.getCarCount();

        // assert
        expect(result, const Left(CacheFailure('Count failed')));
        verify(mockLocalDataSource.getCarCount()).called(1);
      });
    });

    group('getBrands', () {
      test('should return brands list when successful', () async {
        // arrange
        const expectedBrands = ['BMW', 'Audi', 'Mercedes'];
        when(mockLocalDataSource.getDistinctBrands())
            .thenAnswer((_) async => expectedBrands);

        // act
        final result = await repository.getBrands();

        // assert
        expect(result, const Right(expectedBrands));
        verify(mockLocalDataSource.getDistinctBrands()).called(1);
      });

      test('should return CacheFailure when getting brands fails', () async {
        // arrange
        when(mockLocalDataSource.getDistinctBrands())
            .thenThrow(const CacheException('Brands failed'));

        // act
        final result = await repository.getBrands();

        // assert
        expect(result, const Left(CacheFailure('Brands failed')));
        verify(mockLocalDataSource.getDistinctBrands()).called(1);
      });
    });

    group('getShapes', () {
      test('should return shapes list when successful', () async {
        // arrange
        const expectedShapes = ['Berline', 'SUV', 'Coupe'];
        when(mockLocalDataSource.getDistinctShapes())
            .thenAnswer((_) async => expectedShapes);

        // act
        final result = await repository.getShapes();

        // assert
        expect(result, const Right(expectedShapes));
        verify(mockLocalDataSource.getDistinctShapes()).called(1);
      });

      test('should return CacheFailure when getting shapes fails', () async {
        // arrange
        when(mockLocalDataSource.getDistinctShapes())
            .thenThrow(const CacheException('Shapes failed'));

        // act
        final result = await repository.getShapes();

        // assert
        expect(result, const Left(CacheFailure('Shapes failed')));
        verify(mockLocalDataSource.getDistinctShapes()).called(1);
      });
    });

    group('getAllCarsForExport', () {
      test('should return all cars when successful', () async {
        // arrange
        final allCars = [testCarModel, testCarModel];
        when(mockLocalDataSource.getAllCarsForExport())
            .thenAnswer((_) async => allCars);

        // act
        final result = await repository.getAllCarsForExport();

        // assert
        expect(result, Right(allCars));
        verify(mockLocalDataSource.getAllCarsForExport()).called(1);
      });

      test('should return CacheFailure when export fails', () async {
        // arrange
        when(mockLocalDataSource.getAllCarsForExport())
            .thenThrow(const CacheException('Export failed'));

        // act
        final result = await repository.getAllCarsForExport();

        // assert
        expect(result, const Left(CacheFailure('Export failed')));
        verify(mockLocalDataSource.getAllCarsForExport()).called(1);
      });
    });
  });
}