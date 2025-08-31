import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/domain/entities/car.dart';
import 'package:boitodex/domain/repositories/car_repository.dart';
import 'package:boitodex/domain/usecases/cars/add_car.dart';

import 'add_car_test.mocks.dart';

@GenerateMocks([CarRepository])
void main() {
  group('AddCar', () {
    late AddCar usecase;
    late MockCarRepository mockRepository;

    setUp(() {
      mockRepository = MockCarRepository();
      usecase = AddCar(mockRepository);
    });

    final testCar = Car(
      brand: 'BMW',
      shape: 'Berline',
      name: 'Serie 3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should add car when repository call is successful', () async {
      // arrange
      const expectedId = 1;
      when(mockRepository.addCar(testCar))
          .thenAnswer((_) async => const Right(expectedId));

      // act
      final result = await usecase(testCar);

      // assert
      expect(result, const Right(expectedId));
      verify(mockRepository.addCar(testCar)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository call fails', () async {
      // arrange
      const failure = CacheFailure('Database error');
      when(mockRepository.addCar(testCar))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(testCar);

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.addCar(testCar)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}