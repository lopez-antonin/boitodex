import 'package:sqflite/sqflite.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/entities/filter.dart';
import '../../models/car_model.dart';
import '../../models/filter_model.dart';
import '../../services/database_service.dart';

abstract class CarLocalDataSource {
  Future<int> insertCar(CarModel car);
  Future<void> updateCar(CarModel car);
  Future<void> deleteCar(int id);
  Future<CarModel?> getCarById(int id);
  Future<List<CarModel>> getCars({
    FilterModel? filter,
    int? limit,
    int? offset,
  });
  Future<int> getCarCount({FilterModel? filter});
  Future<List<String>> getDistinctBrands();
  Future<List<String>> getDistinctShapes();
  Future<List<CarModel>> getAllCarsForExport();
}

class CarLocalDataSourceImpl implements CarLocalDataSource {
  final DatabaseService databaseService;

  CarLocalDataSourceImpl(this.databaseService);

  @override
  Future<int> insertCar(CarModel car) async {
    try {
      final db = await databaseService.database;
      return await db.insert('cars', car.toMap());
    } catch (e) {
      throw CacheException('Failed to insert car: $e');
    }
  }

  @override
  Future<void> updateCar(CarModel car) async {
    try {
      final db = await databaseService.database;
      await db.update(
        'cars',
        car.toMap(),
        where: 'id = ?',
        whereArgs: [car.id],
      );
    } catch (e) {
      throw CacheException('Failed to update car: $e');
    }
  }

  @override
  Future<void> deleteCar(int id) async {
    try {
      final db = await databaseService.database;
      await db.delete(
        'cars',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException('Failed to delete car: $e');
    }
  }

  @override
  Future<CarModel?> getCarById(int id) async {
    try {
      final db = await databaseService.database;
      final maps = await db.query(
        'cars',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return CarModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get car by id: $e');
    }
  }

  @override
  Future<List<CarModel>> getCars({
    FilterModel? filter,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await databaseService.database;
      final whereClauses = <String>[];
      final whereArgs = <Object?>[];

      if (filter != null) {
        if (filter.brand != null && filter.brand!.isNotEmpty) {
          whereClauses.add('brand = ?');
          whereArgs.add(filter.brand);
        }
        if (filter.shape != null && filter.shape!.isNotEmpty) {
          whereClauses.add('shape = ?');
          whereArgs.add(filter.shape);
        }
        if (filter.nameQuery.isNotEmpty) {
          whereClauses.add('(name LIKE ? OR informations LIKE ?)');
          whereArgs.add('%${filter.nameQuery}%');
          whereArgs.add('%${filter.nameQuery}%');
        }
      }

      String orderBy = 'name COLLATE NOCASE ASC';
      if (filter != null) {
        final direction = filter.sortAscending ? 'ASC' : 'DESC';
        switch (filter.sortBy) {
          case SortOption.name:
            orderBy = 'name COLLATE NOCASE $direction';
            break;
          case SortOption.brand:
            orderBy = 'brand COLLATE NOCASE $direction';
            break;
          case SortOption.shape:
            orderBy = 'shape COLLATE NOCASE $direction';
            break;
          case SortOption.createdAt:
            orderBy = 'created_at $direction';
            break;
          case SortOption.updatedAt:
            orderBy = 'updated_at $direction';
            break;
        }
      }

      final maps = await db.query(
        'cars',
        where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );

      return maps.map((m) => CarModel.fromMap(m)).toList();
    } catch (e) {
      throw CacheException('Failed to get cars: $e');
    }
  }

  @override
  Future<int> getCarCount({FilterModel? filter}) async {
    try {
      final db = await databaseService.database;
      final whereClauses = <String>[];
      final whereArgs = <Object?>[];

      if (filter != null) {
        if (filter.brand != null && filter.brand!.isNotEmpty) {
          whereClauses.add('brand = ?');
          whereArgs.add(filter.brand);
        }
        if (filter.shape != null && filter.shape!.isNotEmpty) {
          whereClauses.add('shape = ?');
          whereArgs.add(filter.shape);
        }
        if (filter.nameQuery.isNotEmpty) {
          whereClauses.add('(name LIKE ? OR informations LIKE ?)');
          whereArgs.add('%${filter.nameQuery}%');
          whereArgs.add('%${filter.nameQuery}%');
        }
      }

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cars${whereClauses.isNotEmpty ? ' WHERE ${whereClauses.join(' AND ')}' : ''}',
        whereArgs.isNotEmpty ? whereArgs : null,
      );

      return result.first['count'] as int? ?? 0;
    } catch (e) {
      throw CacheException('Failed to get car count: $e');
    }
  }

  @override
  Future<List<String>> getDistinctBrands() async {
    try {
      final db = await databaseService.database;
      final result = await db.rawQuery(
        'SELECT DISTINCT brand FROM cars WHERE brand IS NOT NULL AND brand != "" ORDER BY brand COLLATE NOCASE ASC',
      );
      return result
          .map((r) => (r['brand'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      throw CacheException('Failed to get distinct brands: $e');
    }
  }

  @override
  Future<List<String>> getDistinctShapes() async {
    try {
      final db = await databaseService.database;
      final result = await db.rawQuery(
        'SELECT DISTINCT shape FROM cars WHERE shape IS NOT NULL AND shape != "" ORDER BY shape COLLATE NOCASE ASC',
      );
      return result
          .map((r) => (r['shape'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      throw CacheException('Failed to get distinct shapes: $e');
    }
  }

  @override
  Future<List<CarModel>> getAllCarsForExport() async {
    try {
      final db = await databaseService.database;
      final maps = await db.query('cars', orderBy: 'created_at ASC');
      return maps.map((m) => CarModel.fromMap(m)).toList();
    } catch (e) {
      throw CacheException('Failed to get cars for export: $e');
    }
  }
}