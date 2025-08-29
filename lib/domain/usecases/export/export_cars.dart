import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../data/models/car_model.dart';
import '../../repositories/car_repository.dart';
import '../../../features/car_form/data/services/export_service.dart';

class ExportCars {
  final CarRepository repository;
  final ExportService exportService;

  ExportCars(this.repository, this.exportService);

  Future<Either<Failure, bool>> call() async {
    final result = await repository.getAllCarsForExport();

    return result.fold(
          (failure) => Left(failure),
          (cars) async {
        try {
          final carModels = cars.map((car) => CarModel.fromEntity(car)).toList();
          final success = await exportService.exportCars(carModels);
          return Right(success);
        } catch (e) {
          return Left(ServerFailure('Export failed: $e'));
        }
      },
    );
  }
}