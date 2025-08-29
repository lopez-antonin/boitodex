import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/filter.dart';
import '../../domain/repositories/car_repository.dart';
import '../datasources/local/car_local_datasource.dart';
import '../models/car_model.dart';
import '../models/filter_model.dart';

class CarRepositoryImpl implements CarRepository {
  final CarLocalDataSource localDataSource;

  CarRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, int>> addCar(Car car) async {
    try {
      final carModel = CarModel.fromEntity(car);
      final id = await localDataSource.insertCar(carModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateCar(Car car) async {
    try {
      final carModel = CarModel.fromEntity(car);
      await localDataSource.updateCar(carModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCar(int id) async {
    try {
      await localDataSource.deleteCar(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Car?>> getCarById(int id) async {
    try {
      final carModel = await localDataSource.getCarById(id);
      return Right(carModel);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Car>>> getCars({
    CarFilter? filter,
    int? limit,
    int? offset,
  }) async {
    try {
      final filterModel = filter != null ? FilterModel.fromEntity(filter) : null;
      final carModels = await localDataSource.getCars(
        filter: filterModel,
        limit: limit,
        offset: offset,
      );
      return Right(carModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> getCarCount({CarFilter? filter}) async {
    try {
      final filterModel = filter != null ? FilterModel.fromEntity(filter) : null;
      final count = await localDataSource.getCarCount(filter: filterModel);
      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBrands() async {
    try {
      final brands = await localDataSource.getDistinctBrands();
      return Right(brands);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getShapes() async {
    try {
      final shapes = await localDataSource.getDistinctShapes();
      return Right(shapes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Car>>> getAllCarsForExport() async {
    try {
      final carModels = await localDataSource.getAllCarsForExport();
      return Right(carModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}