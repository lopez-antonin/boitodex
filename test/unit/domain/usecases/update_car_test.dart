import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/domain/entities/car.dart';
import 'package:boitodex/domain/repositories/car_repository.dart';
import 'package:boitodex/domain/usecases/cars/update_car.dart';

import 'add_car_test.mocks.dart';

@GenerateMocks([CarRepository])
void main() {
  late UpdateCar usecase;
  late MockCarRepository mockRepository;

  setUp(() {
    mockRepository = MockCarRepository();
    usecase = UpdateCar(mockRepository);
  });

  final tCar = Car(
    id: 1,
    brand: 'BMW',
    shape: 'Sedan',
    name: 'X5',
    informations: 'Updated info',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  test('should update car when repository call is successful', () async {
    // arrange
    when(mockRepository.updateCar(any))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(tCar);

    // assert
    expect(result, const Right(null));
    verify(mockRepository.updateCar(tCar));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository call fails', () async {
    // arrange
    when(mockRepository.updateCar(any))
        .thenAnswer((_) async => const Left(CacheFailure('Update failed')));

    // act
    final result = await usecase(tCar);

    // assert
    expect(result, const Left(CacheFailure('Update failed')));
    verify(mockRepository.updateCar(tCar));
    verifyNoMoreInteractions(mockRepository);
  });
}