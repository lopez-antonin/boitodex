import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/car.dart';
import '../entities/filter.dart';

abstract class CarRepository {
  Future<Either<Failure, int>> addCar(Car car);
  Future<Either<Failure, void>> updateCar(Car car);
  Future<Either<Failure, void>> deleteCar(int id);
  Future<Either<Failure, Car?>> getCarById(int id);
  Future<Either<Failure, List<Car>>> getCars({
    CarFilter? filter,
    int? limit,
    int? offset,
  });
  Future<Either<Failure, int>> getCarCount({CarFilter? filter});
  Future<Either<Failure, List<String>>> getBrands();
  Future<Either<Failure, List<String>>> getShapes();
  Future<Either<Failure, List<Car>>> getAllCarsForExport();
}