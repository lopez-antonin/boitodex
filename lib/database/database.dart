import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants/app_constants.dart';
import '../models/car.dart';
import '../models/filter.dart';

/// SQLite database manager for the application
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _database;

  /// Get database instance, initializing if needed
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDatabase,
    );
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Create cars table
    await db.execute('''
      CREATE TABLE cars(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand TEXT NOT NULL,
        shape TEXT NOT NULL,
        name TEXT NOT NULL,
        informations TEXT,
        is_piggy_bank INTEGER NOT NULL DEFAULT 0,
        plays_music INTEGER NOT NULL DEFAULT 0,
        photo BLOB,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_cars_brand ON cars(brand)');
    await db.execute('CREATE INDEX idx_cars_shape ON cars(shape)');
    await db.execute('CREATE INDEX idx_cars_name ON cars(name)');
  }

  /// Insert a new car
  Future<int> insertCar(Car car) async {
    final db = await database;
    return await db.insert('cars', car.toMap());
  }

  /// Update an existing car
  Future<int> updateCar(Car car) async {
    final db = await database;
    return await db.update(
      'cars',
      car.toMap(),
      where: 'id = ?',
      whereArgs: [car.id],
    );
  }

  /// Delete a car
  Future<int> deleteCar(int id) async {
    final db = await database;
    return await db.delete(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get a car by ID
  Future<Car?> getCarById(int id) async {
    final db = await database;
    final maps = await db.query(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Car.fromMap(maps.first);
    }
    return null;
  }

  /// Get cars with optional filtering, sorting, and pagination
  Future<List<Car>> getCars({
    CarFilter? filter,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    // Build WHERE clauses based on filter
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

    // Build ORDER BY clause
    String orderBy = 'name COLLATE NOCASE ASC'; // Default sorting
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

    return maps.map((m) => Car.fromMap(m)).toList();
  }

  /// Count cars with optional filter
  Future<int> getCarCount({CarFilter? filter}) async {
    final db = await database;
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
  }

  /// Get distinct brands for filter dropdown
  Future<List<String>> getDistinctBrands() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT DISTINCT brand FROM cars WHERE brand IS NOT NULL AND brand != "" ORDER BY brand COLLATE NOCASE ASC'
    );
    return result
        .map((r) => (r['brand'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Get distinct shapes for filter dropdown
  Future<List<String>> getDistinctShapes() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT DISTINCT shape FROM cars WHERE shape IS NOT NULL AND shape != "" ORDER BY shape COLLATE NOCASE ASC'
    );
    return result
        .map((r) => (r['shape'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Get all cars for export (no filtering)
  Future<List<Car>> getAllCarsForExport() async {
    final db = await database;
    final maps = await db.query('cars', orderBy: 'created_at ASC');
    return maps.map((m) => Car.fromMap(m)).toList();
  }

  /// Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}