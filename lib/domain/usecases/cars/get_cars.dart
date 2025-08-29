import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/car.dart';
import '../../entities/filter.dart';
import '../../repositories/car_repository.dart';

class GetCars {
  final CarRepository repository;

  GetCars(this.repository);

  Future<Either<Failure, List<Car>>> call({
    CarFilter? filter,
    int? limit,
    int? offset,
  }) async {
    return await repository.getCars(
      filter: filter,
      limit: limit,
      offset: offset,
    );
  }
}