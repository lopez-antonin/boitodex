import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/car.dart';
import '../../repositories/car_repository.dart';

class AddCar {
  final CarRepository repository;

  AddCar(this.repository);

  Future<Either<Failure, int>> call(Car car) async {
    return await repository.addCar(car);
  }
}