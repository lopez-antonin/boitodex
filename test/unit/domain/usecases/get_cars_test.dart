import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/domain/entities/car.dart';
import 'package:boitodex/domain/entities/filter.dart';
import 'package:boitodex/domain/repositories/car_repository.dart';
import 'package:boitodex/domain/usecases/cars/get_cars.dart';

import 'get_cars_test.mocks.dart';

@GenerateMocks([CarRepository])
void main() {
  group('GetCars', () {
    late GetCars usecase;
    late MockCarRepository mockRepository;

    setUp(() {
      mockRepository = MockCarRepository();
      usecase = GetCars(mockRepository);
    });

    final testCars = [
      Car(
        id: 1,
        brand: 'BMW',
        shape: 'Berline',
        name: 'Serie 3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Car(
        id: 2,
        brand: 'Audi',
        shape: 'SUV',
        name: 'Q5',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('should get cars when repository call is successful', () async {
      // arrange
      when(mockRepository.getCars())
          .thenAnswer((_) async => Right(testCars));

      // act
      final result = await usecase();

      // assert
      expect(result, Right(testCars));
      verify(mockRepository.getCars()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get cars with filter when provided', () async {
      // arrange
      const filter = CarFilter(brand: 'BMW');
      when(mockRepository.getCars(filter: filter))
          .thenAnswer((_) async => Right([testCars.first]));

      // act
      final result = await usecase(filter: filter);

      // assert
      expect(result, Right([testCars.first]));
      verify(mockRepository.getCars(filter: filter)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get cars with pagination parameters', () async {
      // arrange
      const limit = 10;
      const offset = 20;
      when(mockRepository.getCars(limit: limit, offset: offset))
          .thenAnswer((_) async => Right(testCars));

      // act
      final result = await usecase(limit: limit, offset: offset);

      // assert
      expect(result, Right(testCars));
      verify(mockRepository.getCars(limit: limit, offset: offset)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get cars with all parameters', () async {
      // arrange
      const filter = CarFilter(brand: 'BMW', nameQuery: 'Serie');
      const limit = 10;
      const offset = 20;
      when(mockRepository.getCars(
        filter: filter,
        limit: limit,
        offset: offset,
      )).thenAnswer((_) async => Right([testCars.first]));

      // act
      final result = await usecase(
        filter: filter,
        limit: limit,
        offset: offset,
      );

      // assert
      expect(result, Right([testCars.first]));
      verify(mockRepository.getCars(
        filter: filter,
        limit: limit,
        offset: offset,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository call fails', () async {
      // arrange
      const failure = CacheFailure('Database error');
      when(mockRepository.getCars())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.getCars()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no cars found', () async {
      // arrange
      when(mockRepository.getCars())
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right([]));
      verify(mockRepository.getCars()).called(1);
    });

    test('should handle different failure types', () async {
      // arrange
      const serverFailure = ServerFailure('Server error');
      when(mockRepository.getCars())
          .thenAnswer((_) async => const Left(serverFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left(serverFailure));
      verify(mockRepository.getCars()).called(1);
    });
  });
}