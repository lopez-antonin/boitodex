import '../database/database.dart';
import '../models/car.dart';
import '../models/filter.dart';

/// Service class for car-related business logic
class CarService {
  final AppDatabase _database = AppDatabase();

  /// Add a new car to the collection
  Future<bool> addCar(Car car) async {
    try {
      await _database.insertCar(car);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update an existing car
  Future<bool> updateCar(Car car) async {
    try {
      await _database.updateCar(car);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a car from the collection
  Future<bool> deleteCar(int id) async {
    try {
      await _database.deleteCar(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get a specific car by ID
  Future<Car?> getCar(int id) async {
    try {
      return await _database.getCarById(id);
    } catch (e) {
      return null;
    }
  }

  /// Get cars with filtering and pagination
  Future<List<Car>> getCars({
    CarFilter? filter,
    int? limit,
    int? offset,
  }) async {
    try {
      return await _database.getCars(filter: filter, limit: limit, offset: offset);
    } catch (e) {
      return [];
    }
  }

  /// Get total count of cars matching filter
  Future<int> getCarCount({CarFilter? filter}) async {
    try {
      return await _database.getCarCount(filter: filter);
    } catch (e) {
      return 0;
    }
  }

  /// Get list of unique brands for filter dropdown
  Future<List<String>> getBrands() async {
    try {
      return await _database.getDistinctBrands();
    } catch (e) {
      return [];
    }
  }

  /// Get list of unique shapes for filter dropdown
  Future<List<String>> getShapes() async {
    try {
      return await _database.getDistinctShapes();
    } catch (e) {
      return [];
    }
  }

  /// Get all cars for export
  Future<List<Car>> getAllCarsForExport() async {
    try {
      return await _database.getAllCarsForExport();
    } catch (e) {
      return [];
    }
  }
}