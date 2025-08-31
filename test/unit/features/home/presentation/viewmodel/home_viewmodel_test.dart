import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:boitodex/core/error/failures.dart';
import 'package:boitodex/domain/entities/car.dart';
import 'package:boitodex/domain/entities/filter.dart';
import 'package:boitodex/domain/usecases/cars/get_cars.dart';
import 'package:boitodex/domain/usecases/cars/delete_car.dart';
import 'package:boitodex/domain/usecases/export/export_cars.dart';
import 'package:boitodex/domain/repositories/car_repository.dart';
import 'package:boitodex/features/home/presentation/viewmodel/home_viewmodel.dart';

import 'home_viewmodel_test.mocks.dart';

@GenerateMocks([GetCars, DeleteCar, ExportCars, CarRepository])
void main() {
  group('HomeViewModel', () {
    late HomeViewModel viewModel;
    late MockGetCars mockGetCars;
    late MockDeleteCar mockDeleteCar;
    late MockExportCars mockExportCars;
    late MockCarRepository mockRepository;

    setUp(() {
      mockGetCars = MockGetCars();
      mockDeleteCar = MockDeleteCar();
      mockExportCars = MockExportCars();
      mockRepository = MockCarRepository();

      // Configure the repository property of mockGetCars
      when(mockGetCars.repository).thenReturn(mockRepository);

      viewModel = HomeViewModel(
        getCars: mockGetCars,
        deleteCar: mockDeleteCar,
        exportCars: mockExportCars,
      );
    });

    tearDown(() {
      viewModel.dispose();
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

    test('initial state should be correct', () {
      expect(viewModel.cars, isEmpty);
      expect(viewModel.brands, isEmpty);
      expect(viewModel.shapes, isEmpty);
      expect(viewModel.filter, equals(const CarFilter()));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasMoreData, isTrue);
      expect(viewModel.errorMessage, isNull);
    });

    group('loadData', () {
      test('should load cars successfully', () async {
        // arrange
        when(mockRepository.getBrands()).thenAnswer((_) async => const Right(['BMW', 'Audi']));
        when(mockRepository.getShapes()).thenAnswer((_) async => const Right(['Berline', 'SUV']));
        when(mockGetCars(
          filter: any(named: 'filter'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => Right(testCars));

        // act
        await viewModel.loadData();

        // assert
        expect(viewModel.cars, equals(testCars));
        expect(viewModel.brands, equals(['BMW', 'Audi']));
        expect(viewModel.shapes, equals(['Berline', 'SUV']));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
      });

      test('should set error message when loading fails', () async {
        // arrange
        when(mockRepository.getBrands()).thenAnswer((_) async => const Right([]));
        when(mockRepository.getShapes()).thenAnswer((_) async => const Right([]));
        when(mockGetCars(
          filter: any(named: 'filter'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => const Left(CacheFailure('Database error')));

        // act
        await viewModel.loadData();

        // assert
        expect(viewModel.cars, isEmpty);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, equals('Database error'));
      });

      test('should handle brands loading failure', () async {
        // arrange
        when(mockRepository.getBrands()).thenAnswer((_) async => const Left(CacheFailure('Brands error')));
        when(mockRepository.getShapes()).thenAnswer((_) async => const Right(['SUV']));
        when(mockGetCars(
          filter: any(named: 'filter'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => Right(testCars));

        // act
        await viewModel.loadData();

        // assert
        expect(viewModel.brands, isEmpty);
        expect(viewModel.shapes, equals(['SUV']));
        expect(viewModel.cars, equals(testCars));
        expect(viewModel.errorMessage, isNull);
      });
    });

    group('deleteCarById', () {
      test('should delete car successfully and refresh list', () async {
        // arrange
        const carId = 1;
        when(mockDeleteCar(carId)).thenAnswer((_) async => const Right(null));
        when(mockRepository.getBrands()).thenAnswer((_) async => const Right([]));
        when(mockRepository.getShapes()).thenAnswer((_) async => const Right([]));
        when(mockGetCars(
          filter: any(named: 'filter'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => const Right([]));

        // act
        final result = await viewModel.deleteCarById(carId);

        // assert
        expect(result, isTrue);
        verify(mockDeleteCar(carId)).called(1);
        expect(viewModel.errorMessage, isNull);
      });

      test('should return false when delete fails', () async {
        // arrange
        const carId = 1;
        when(mockDeleteCar(carId)).thenAnswer((_) async => const Left(CacheFailure('Delete error')));

        // act
        final result = await viewModel.deleteCarById(carId);

        // assert
        expect(result, isFalse);
        expect(viewModel.errorMessage, equals('Delete error'));
      });
    });

    group('exportCollection', () {
      test('should export collection successfully', () async {
        // arrange
        when(mockExportCars()).thenAnswer((_) async => const Right(true));

        // act
        final result = await viewModel.exportCollection();

        // assert
        expect(result, isTrue);
        verify(mockExportCars()).called(1);
        expect(viewModel.errorMessage, isNull);
      });

      test('should handle export failure', () async {
        // arrange
        when(mockExportCars()).thenAnswer((_) async => const Left(ServerFailure('Export error')));

        // act
        final result = await viewModel.exportCollection();

        // assert
        expect(result, isFalse);
        expect(viewModel.errorMessage, equals('Export error'));
      });
    });

    group('updateFilter', () {
      test('should update filter and refresh cars', () async {
        // arrange
        const newFilter = CarFilter(brand: 'BMW');
        when(mockRepository.getBrands()).thenAnswer((_) async => const Right([]));
        when(mockRepository.getShapes()).thenAnswer((_) async => const Right([]));
        when(mockGetCars(
          filter: newFilter,
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => const Right([]));

        // act
        viewModel.updateFilter(newFilter);
        await Future.delayed(Duration.zero); // Wait for async operations

        // assert
        expect(viewModel.filter, equals(newFilter));
      });
    });

    group('onSearchChanged', () {
      test('should update filter with search query after delay', () async {
        // arrange
        const query = 'BMW';
        when(mockRepository.getBrands()).thenAnswer((_) async => const Right([]));
        when(mockRepository.getShapes()).thenAnswer((_) async => const Right([]));
        when(mockGetCars(
          filter: any(named: 'filter'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => const Right([]));

        // act
        viewModel.onSearchChanged(query);
        await Future.delayed(const Duration(milliseconds: 600)); // Wait for timer

        // assert
        expect(viewModel.filter.nameQuery, equals(query));
      });
    });

    test('should clear filters correctly', () async {
      // arrange
      when(mockRepository.getBrands()).thenAnswer((_) async => const Right([]));
      when(mockRepository.getShapes()).thenAnswer((_) async => const Right([]));
      when(mockGetCars(
        filter: any(named: 'filter'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => const Right([]));

      // act
      viewModel.clearFilters();
      await Future.delayed(Duration.zero);

      // assert
      expect(viewModel.filter, equals(const CarFilter()));
    });

    test('should clear error message', () {
      // arrange
      viewModel.clearError();

      // assert
      expect(viewModel.errorMessage, isNull);
    });
  });
}