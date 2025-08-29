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
  late AddCar usecase;
  late MockCarRepository mockRepository;

  setUp(() {
    mockRepository = MockCarRepository();
    usecase = AddCar(mockRepository);
  });

  final tCar = Car(
    brand: 'Test Brand',
    shape: 'Test Shape',
    name: 'Test Name',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  const tId = 1;

  test('should add car and return id when repository call is successful', () async {
    // arrange
    when(mockRepository.addCar(any))
        .thenAnswer((_) async => const Right(tId));

    // act
    final result = await usecase(tCar);

    // assert
    expect(result, const Right(tId));
    verify(mockRepository.addCar(tCar));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository call fails', () async {
    // arrange
    when(mockRepository.addCar(any))
        .thenAnswer((_) async => const Left(CacheFailure('Cache error')));

    // act
    final result = await usecase(tCar);

    // assert
    expect(result, const Left(CacheFailure('Cache error')));
    verify(mockRepository.addCar(tCar));
    verifyNoMoreInteractions(mockRepository);
  });
}