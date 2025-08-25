import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/car.dart';

class CarDatabase {
  static final CarDatabase _instance = CarDatabase._internal();
  factory CarDatabase() => _instance;
  CarDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cars.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cars(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            brand TEXT NOT NULL,
            shape TEXT NOT NULL,
            name TEXT NOT NULL,
            is_piggy_bank INTEGER NOT NULL,
            plays_music INTEGER NOT NULL,
            photo BLOB
          )
        ''');
      },
    );
  }

  Future<int> insertCar(Car car) async {
    final db = await database;
    return await db.insert('cars', car.toMap());
  }

  Future<int> updateCar(Car car) async {
    final db = await database;
    return await db.update(
      'cars',
      car.toMap(),
      where: 'id = ?',
      whereArgs: [car.id],
    );
  }

  Future<int> deleteCar(int id) async {
    final db = await database;
    return await db.delete(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

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

  /// Retrieve all cars, optional filters:
  /// - brand: exact brand filter (pass null to ignore)
  /// - shape: exact shape filter (pass null to ignore)
  /// - nameQuery: substring search on name (pass null to ignore)
  Future<List<Car>> getAllCars({
    String? brand,
    String? shape,
    String? nameQuery,
  }) async {
    final db = await database;
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (brand != null && brand.isNotEmpty) {
      whereClauses.add('brand = ?');
      whereArgs.add(brand);
    }
    if (shape != null && shape.isNotEmpty) {
      whereClauses.add('shape = ?');
      whereArgs.add(shape);
    }
    if (nameQuery != null && nameQuery.isNotEmpty) {
      whereClauses.add('name LIKE ?');
      whereArgs.add('%$nameQuery%');
    }

    final maps = await db.query(
      'cars',
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return maps.map((m) => Car.fromMap(m)).toList();
  }

  Future<List<String>> getDistinctBrands() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT brand FROM cars ORDER BY brand COLLATE NOCASE ASC');
    return result.map((r) => (r['brand'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
  }

  Future<List<String>> getDistinctShapes() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT shape FROM cars ORDER BY shape COLLATE NOCASE ASC');
    return result.map((r) => (r['shape'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
  }

  /// Close DB (optional)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
