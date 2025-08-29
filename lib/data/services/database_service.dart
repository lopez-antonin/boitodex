import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const String _databaseName = 'boitodex.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
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

    await db.execute('CREATE INDEX idx_cars_brand ON cars(brand)');
    await db.execute('CREATE INDEX idx_cars_shape ON cars(shape)');
    await db.execute('CREATE INDEX idx_cars_name ON cars(name)');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}