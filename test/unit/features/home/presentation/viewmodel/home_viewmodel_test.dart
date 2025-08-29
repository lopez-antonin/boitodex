import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/domain/entities/car.dart';
import 'package:boitodex/domain/usecases/cars/get_cars.dart';
import 'package:boitodex/domain/usecases/cars/delete_car.dart';
import 'package:boitodex/domain/usecases/export/export_cars.dart';
import 'package:boitodex/features/home/presentation/viewmodel/home_viewmodel.dart';

import 'home_viewmodel_test.mocks.dart';

@GenerateMocks([GetCars, DeleteCar, ExportCars])
void main() {
  late HomeViewModel viewModel;
  late MockGetCars mockGetCars;
  late MockDeleteCar mockDeleteCar;
  late MockExportCars mockExportCars;

  setUp(() {
    mockGetCars = MockGetCars();
    mockDeleteCar = MockDeleteCar();
    mockExportCars = MockExportCars();
    viewModel = HomeViewModel(
      getCars: mockGetCars,
      deleteCar: mockDeleteCar,
      exportCars: mockExportCars,
    );
  });

  tearDown(() {
    viewModel.dispose();
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

  group('loadData', () {
    test('should load cars successfully', () async {
      // arrange
      when(mockGetCars.repository.getBrands())
          .thenAnswer((_) async => const Right(['BMW', 'Audi']));
      when(mockGetCars.repository.getShapes())
          .thenAnswer((_) async => const Right(['Sedan', 'SUV']));
      when(mockGetCars(filter: anyNamed('filter'), limit: anyNamed('limit')))
          .thenAnswer((_) async => Right(tCars));

      // act
      await viewModel.loadData();

      // assert
      expect(viewModel.cars, tCars);
      expect(viewModel.brands, ['BMW', 'Audi']);
      expect(viewModel.shapes, ['Sedan', 'SUV']);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('should set error message when loading fails', () async {
      // arrange
      const tFailure = CacheFailure('Database error');
      when(mockGetCars.repository.getBrands())
          .thenAnswer((_) async => const Left(tFailure));
      when(mockGetCars.repository.getShapes())
          .thenAnswer((_) async => const Right([]));
      when(mockGetCars(filter: anyNamed('filter'), limit: anyNamed('limit')))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      await viewModel.loadData();

      // assert
      expect(viewModel.errorMessage, 'Database error');
      expect(viewModel.isLoading, false);
    });
  });

  group('deleteCarById', () {
    test('should delete car successfully and refresh list', () async {
      // arrange
      const tId = 1;
      when(mockDeleteCar(tId))
          .thenAnswer((_) async => const Right(null));
      when(mockGetCars.repository.getBrands())
          .thenAnswer((_) async => const Right([]));
      when(mockGetCars.repository.getShapes())
          .thenAnswer((_) async => const Right([]));
      when(mockGetCars(filter: anyNamed('filter'), limit: anyNamed('limit')))
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await viewModel.deleteCarById(tId);

      // assert
      expect(result, true);
      verify(mockDeleteCar(tId));
    });

    test('should return false when delete fails', () async {
      // arrange
      const tId = 1;
      const tFailure = CacheFailure('Delete failed');
      when(mockDeleteCar(tId))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await viewModel.deleteCarById(tId);

      // assert
      expect(result, false);
      expect(viewModel.errorMessage, 'Delete failed');
    });
  });
}