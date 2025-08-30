import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/domain/repositories/car_repository.dart';
import 'package:boitodex/domain/usecases/cars/delete_car.dart';

import 'add_car_test.mocks.dart';

@GenerateMocks([CarRepository])
void main() {
  late DeleteCar usecase;
  late MockCarRepository mockRepository;

  setUp(() {
    mockRepository = MockCarRepository();
    usecase = DeleteCar(mockRepository);
  });

  const tId = 1;

  test('should delete car when repository call is successful', () async {
    // arrange
    when(mockRepository.deleteCar(any))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(tId);

    // assert
    expect(result, const Right(null));
    verify(mockRepository.deleteCar(tId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository call fails', () async {
    // arrange
    when(mockRepository.deleteCar(any))
        .thenAnswer((_) async => const Left(CacheFailure('Delete failed')));

    // act
    final result = await usecase(tId);

    // assert
    expect(result, const Left(CacheFailure('Delete failed')));
    verify(mockRepository.deleteCar(tId));
    verifyNoMoreInteractions(mockRepository);
  });
}