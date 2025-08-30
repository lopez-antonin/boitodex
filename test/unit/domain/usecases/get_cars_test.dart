import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/domain/entities/car.dart';
import 'package:boitodex/domain/entities/filter.dart';
import 'package:boitodex/domain/repositories/car_repository.dart';
import 'package:boitodex/domain/usecases/cars/get_cars.dart';

import 'add_car_test.mocks.dart';

@GenerateMocks([CarRepository])
void main() {
  late GetCars usecase;
  late MockCarRepository mockRepository;

  setUp(() {
    mockRepository = MockCarRepository();
    usecase = GetCars(mockRepository);
  });

  final tCars = [
    Car(
      id: 1,
      brand: 'BMW',
      shape: 'Sedan',
      name: 'X5',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Car(
      id: 2,
      brand: 'Audi',
      shape: 'SUV',
      name: 'Q7',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  const tFilter = CarFilter(brand: 'BMW');
  const tLimit = 20;
  const tOffset = 0;

  test('should get cars without filter when repository call is successful', () async {
    // arrange
    when(mockRepository.getCars())
        .thenAnswer((_) async => Right(tCars));

    // act
    final result = await usecase();

    // assert
    expect(result, Right(tCars));
    verify(mockRepository.getCars());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should get cars with filter when repository call is successful', () async {
    // arrange
    when(mockRepository.getCars(filter: anyNamed('filter')))
        .thenAnswer((_) async => Right(tCars));

    // act
    final result = await usecase(filter: tFilter);

    // assert
    expect(result, Right(tCars));
    verify(mockRepository.getCars(filter: tFilter));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should get cars with limit and offset when repository call is successful', () async {
    // arrange
    when(mockRepository.getCars(
      limit: anyNamed('limit'),
      offset: anyNamed('offset'),
    )).thenAnswer((_) async => Right(tCars));

    // act
    final result = await usecase(limit: tLimit, offset: tOffset);

    // assert
    expect(result, Right(tCars));
    verify(mockRepository.getCars(limit: tLimit, offset: tOffset));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should get cars with all parameters when repository call is successful', () async {
    // arrange
    when(mockRepository.getCars(
      filter: anyNamed('filter'),
      limit: anyNamed('limit'),
      offset: anyNamed('offset'),
    )).thenAnswer((_) async => Right(tCars));

    // act
    final result = await usecase(
      filter: tFilter,
      limit: tLimit,
      offset: tOffset,
    );

    // assert
    expect(result, Right(tCars));
    verify(mockRepository.getCars(
      filter: tFilter,
      limit: tLimit,
      offset: tOffset,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository call fails', () async {
    // arrange
    when(mockRepository.getCars())
        .thenAnswer((_) async => const Left(CacheFailure('Get cars failed')));

    // act
    final result = await usecase();

    // assert
    expect(result, const Left(CacheFailure('Get cars failed')));
    verify(mockRepository.getCars());
    verifyNoMoreInteractions(mockRepository);
  });
}