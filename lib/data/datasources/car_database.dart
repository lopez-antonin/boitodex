import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart' as app_exceptions;
import '../models/car_model.dart';
import '../models/filter_model.dart';
import 'package:uuid/uuid.dart';

class CarDatabase {
  static final CarDatabase _instance = CarDatabase._internal();
  factory CarDatabase() => _instance;
  CarDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, AppConstants.databaseName);

      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw app_exceptions.DatabaseException('Erreur lors de l\'initialisation de la base de données: ${e.toString()}');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cars(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        brand TEXT NOT NULL,
        shape TEXT NOT NULL,
        name TEXT NOT NULL,
        is_piggy_bank INTEGER NOT NULL DEFAULT 0,
        plays_music INTEGER NOT NULL DEFAULT 0,
        photo BLOB,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Créer les index pour optimiser les recherches
    await db.execute('CREATE INDEX idx_cars_brand ON cars(brand)');
    await db.execute('CREATE INDEX idx_cars_shape ON cars(shape)');
    await db.execute('CREATE INDEX idx_cars_name ON cars(name)');
    await db.execute('CREATE INDEX idx_cars_uuid ON cars(uuid)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration vers version 2
      await db.execute('ALTER TABLE cars ADD COLUMN uuid TEXT');
      await db.execute('ALTER TABLE cars ADD COLUMN created_at INTEGER');
      await db.execute('ALTER TABLE cars ADD COLUMN updated_at INTEGER');

      // Générer des UUIDs pour les enregistrements existants
      final existingCars = await db.query('cars');
      for (final car in existingCars) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await db.update(
          'cars',
          {
            'uuid': _generateUuid(),
            'created_at': now,
            'updated_at': now,
          },
          where: 'id = ?',
          whereArgs: [car['id']],
        );
      }

      await db.execute('CREATE INDEX idx_cars_uuid ON cars(uuid)');
    }
  }

  Future<int> insertCar(CarModel car) async {
    try {
      final db = await database;
      return await db.insert('cars', car.toMap());
    } catch (e) {
      throw app_exceptions.DatabaseException('Erreur lors de l\'ajout de la voiture: ${e.toString()}');
    }
  }

  Future<int> updateCar(CarModel car) async {
    try {
      final db = await database;
      return await db.update(
        'cars',
        car.toMap(),
        where: 'id = ?',
        whereArgs: [car.id],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException('Erreur lors de la mise à jour de la voiture: ${e.toString()}');
    }
  }

  Future<int> deleteCar(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'cars',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException('Erreur lors de la suppression de la voiture: ${e.toString()}');
    }
  }

  Future<CarModel?> getCarById(int id) async {
    try {
      final db = await database;
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
      throw app_exceptions.DatabaseException('Erreur lors de la récupération de la voiture: ${e.toString()}');
    }
  }

  Future<List<CarModel>> getAllCars({
    FilterModel? filter,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      final whereClauses = <String>[];
      final whereArgs = <Object?>[];

      // Construire les clauses WHERE
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
          whereClauses.add('name LIKE ?');
          whereArgs.add('%${filter.nameQuery}%');
        }
      }

      // Construire la clause ORDER BY
      String orderBy = 'name COLLATE NOCASE ASC'; // Par défaut
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
      throw app_exceptions.DatabaseException('Erreur lors de la récupération des voitures: ${e.toString()}');
    }
  }

  Future<int> getCarCount({FilterModel? filter}) async {
    try {
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
          whereClauses.add('name LIKE ?');
          whereArgs.add('%${filter.nameQuery}%');
        }
      }

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cars${whereClauses.isNotEmpty ? ' WHERE ${whereClauses.join(' AND ')}' : ''}',
        whereArgs.isNotEmpty ? whereArgs : null,
      );

      return result.first['count'] as int? ?? 0;
    } catch (e) {
      throw app_exceptions.DatabaseException('Erreur lors du comptage des voitures: ${e.toString()}');
    }
  }

  Future<List<String>> getDistinctBrands() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
          'SELECT DISTINCT brand FROM cars WHERE brand IS NOT NULL AND brand != "" ORDER BY brand COLLATE NOCASE ASC'
      );
      return result
          .map((r) => (r['brand'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('Erreur lors de la récupération des marques: ${e.toString()}');
    }
  }

  Future<List<String>> getDistinctShapes() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
          'SELECT DISTINCT shape FROM cars WHERE shape IS NOT NULL AND shape != "" ORDER BY shape COLLATE NOCASE ASC'
      );
      return result
          .map((r) => (r['shape'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('Erreur lors de la récupération des formes: ${e.toString()}');
    }
  }

  Future<List<CarModel>> getAllCarsForExport() async {
    try {
      final db = await database;
      final maps = await db.query('cars', orderBy: 'created_at ASC');
      return maps.map((m) => CarModel.fromMap(m)).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('Erreur lors de l\'export des voitures: ${e.toString()}');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  String _generateUuid() {
    return const Uuid().v4();
  }
}