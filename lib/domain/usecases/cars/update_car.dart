import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/car.dart';
import '../../repositories/car_repository.dart';

class UpdateCar {
  final CarRepository repository;

  UpdateCar(this.repository);

  Future<Either<Failure, void>> call(Car car) async {
    return await repository.updateCar(car);
  }
}