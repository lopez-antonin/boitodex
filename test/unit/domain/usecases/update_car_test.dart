import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/domain/entities/car.dart';
import 'package:boitodex/domain/repositories/car_repository.dart';
import 'package:boitodex/domain/usecases/cars/update_car.dart';

import 'update_car_test.mocks.dart';

@GenerateMocks([CarRepository])
void main() {
  group('UpdateCar', () {
    late UpdateCar usecase;
    late MockCarRepository mockRepository;

    setUp(() {
      mockRepository = MockCarRepository();
      usecase = UpdateCar(mockRepository);
    });

    final testCar = Car(
      id: 1,
      brand: 'BMW',
      shape: 'Berline',
      name: 'Serie 3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should update car when repository call is successful', () async {
      // arrange
      when(mockRepository.updateCar(testCar))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(testCar);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.updateCar(testCar)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository call fails', () async {
      // arrange
      const failure = CacheFailure('Database error');
      when(mockRepository.updateCar(testCar))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(testCar);

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.updateCar(testCar)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle different types of failures', () async {
      // arrange
      const validationFailure = ValidationFailure('Invalid car data');
      when(mockRepository.updateCar(testCar))
          .thenAnswer((_) async => const Left(validationFailure));

      // act
      final result = await usecase(testCar);

      // assert
      expect(result, const Left(validationFailure));
      verify(mockRepository.updateCar(testCar)).called(1);
    });

    test('should update car with modified properties', () async {
      // arrange
      final modifiedCar = testCar.copyWith(
        name: 'Serie 5',
        isPiggyBank: true,
        playsMusic: true,
      );
      when(mockRepository.updateCar(modifiedCar))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(modifiedCar);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.updateCar(modifiedCar)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should work with cars containing all properties', () async {
      // arrange
      final fullCar = Car(
        id: 2,
        brand: 'Audi',
        shape: 'SUV',
        name: 'Q5',
        informations: 'Belle voiture familiale',
        isPiggyBank: true,
        playsMusic: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      when(mockRepository.updateCar(fullCar))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(fullCar);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.updateCar(fullCar)).called(1);
    });
  });
}