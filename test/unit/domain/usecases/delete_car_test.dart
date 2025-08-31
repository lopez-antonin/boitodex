import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/domain/repositories/car_repository.dart';
import 'package:boitodex/domain/usecases/cars/delete_car.dart';

import 'delete_car_test.mocks.dart';

@GenerateMocks([CarRepository])
void main() {
  group('DeleteCar', () {
    late DeleteCar usecase;
    late MockCarRepository mockRepository;

    setUp(() {
      mockRepository = MockCarRepository();
      usecase = DeleteCar(mockRepository);
    });

    test('should delete car when repository call is successful', () async {
      // arrange
      const carId = 1;
      when(mockRepository.deleteCar(carId))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(carId);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.deleteCar(carId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository call fails', () async {
      // arrange
      const carId = 1;
      const failure = CacheFailure('Database error');
      when(mockRepository.deleteCar(carId))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(carId);

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.deleteCar(carId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle different types of failures', () async {
      // arrange
      const carId = 1;
      const serverFailure = ServerFailure('Server error');
      when(mockRepository.deleteCar(carId))
          .thenAnswer((_) async => const Left(serverFailure));

      // act
      final result = await usecase(carId);

      // assert
      expect(result, const Left(serverFailure));
      verify(mockRepository.deleteCar(carId)).called(1);
    });

    test('should work with different car IDs', () async {
      // arrange
      const carId = 999;
      when(mockRepository.deleteCar(carId))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(carId);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.deleteCar(carId)).called(1);
    });
  });
}