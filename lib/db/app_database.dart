import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  AppDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'delivery_app.db');

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON'); // ✅
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE delivery_boys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        delivery_boy_id INTEGER NOT NULL,
        delivery_boy_name TEXT,
        office INTEGER DEFAULT 0,
        cod INTEGER DEFAULT 0,
        prepaid INTEGER DEFAULT 0,
        pickup INTEGER DEFAULT 0,
        bfsi INTEGER DEFAULT 0,
        mismatch INTEGER DEFAULT 0,
        UNIQUE(date, delivery_boy_id),
        FOREIGN KEY (delivery_boy_id) REFERENCES delivery_boys(id)
      )
    ''');

    await db.execute('''
  CREATE TABLE prices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL
      CHECK (type IN ('my', 'others'))
      UNIQUE,
    bfsi REAL DEFAULT 0 CHECK (bfsi >= 0),
    cod REAL DEFAULT 0 CHECK (cod >= 0),
    prepaid REAL DEFAULT 0 CHECK (prepaid >= 0),
    pickup REAL DEFAULT 0 CHECK (pickup >= 0)
  )
''');
  }
}
