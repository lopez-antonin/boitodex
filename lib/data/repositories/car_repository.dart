import '../../core/utils/result.dart';
import '../datasources/car_database.dart';
import '../models/car_model.dart';
import '../models/filter_model.dart';
import '../../core/errors/exceptions.dart';

abstract class CarRepository {
  Future<Result<int>> insertCar(CarModel car);
  Future<Result<int>> updateCar(CarModel car);
  Future<Result<int>> deleteCar(int id);
  Future<Result<CarModel?>> getCarById(int id);
  Future<Result<List<CarModel>>> getAllCars({FilterModel? filter, int? limit, int? offset});
  Future<Result<int>> getCarCount({FilterModel? filter});
  Future<Result<List<String>>> getDistinctBrands();
  Future<Result<List<String>>> getDistinctShapes();
  Future<Result<List<CarModel>>> getAllCarsForExport();
}

class CarRepositoryImpl implements CarRepository {
  final CarDatabase _database;

  CarRepositoryImpl(this._database);

  @override
  Future<Result<int>> insertCar(CarModel car) async {
    try {
      final id = await _database.insertCar(car);
      return Success(id);
    } on DatabaseException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur inattendue lors de l\'ajout: ${e.toString()}');
    }
  }

  @override
  Future<Result<int>> updateCar(CarModel car) async {
    try {
      final result = await _database.updateCar(car);
      return Success(result);
    } on DatabaseException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur inattendue lors de la mise à jour: ${e.toString()}');
    }
  }

  @override
  Future<Result<int>> deleteCar(int id) async {
    try {
      final result = await _database.deleteCar(id);
      return Success(result);
    } on DatabaseException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur inattendue lors de la suppression: ${e.toString()}');
    }
  }

  @override
  Future<Result<CarModel?>> getCarById(int id) async {
    try {
      final car = await _database.getCarById(id);
      return Success(car);
    } on DatabaseException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur inattendue lors de la récupération: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<CarModel>>> getAllCars({FilterModel? filter, int? limit, int? offset}) async {
    try {
      final cars = await _database.getAllCars(filter: filter, limit: limit, offset: offset);
      return Success(cars);
    } on DatabaseException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur inattendue lors de la récupération: ${e.toString()}');
    }
  }

  @override
  Future<Result<int>> getCarCount({FilterModel? filter}) async {
    try {
      final count = await _database.getCarCount(filter: filter);
      return Success(count);
    } on DatabaseException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur inattendue lors du comptage: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<String>>> getDistinctBrands() async {
    try {
      final brands = await _database.getDistinctBrands();
      return Success(brands);
    } on DatabaseException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur inattendue lors de la récupération des marques: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<String>>> getDistinctShapes() async {
    try {
      final shapes = await _database.getDistinctShapes();
      return Success(shapes);
    } on DatabaseException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur inattendue lors de la récupération des formes: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<CarModel>>> getAllCarsForExport() async {
    try {
      final cars = await _database.getAllCarsForExport();
      return Success(cars);
    } on DatabaseException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('Erreur inattendue lors de l\'export: ${e.toString()}');
    }
  }
}