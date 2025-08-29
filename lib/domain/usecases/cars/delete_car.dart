import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/car_repository.dart';

class DeleteCar {
  final CarRepository repository;

  DeleteCar(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteCar(id);
  }
}