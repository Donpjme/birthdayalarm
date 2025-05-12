import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/birthday.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'birthdays.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Add this for future schema changes
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE birthdays(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        notes TEXT,
        phoneNumber TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database schema upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  Future<int> insertBirthday(Birthday birthday) async {
    final db = await database;
    return await db.insert(
      'birthdays',
      {
        'firstName': birthday.firstName,
        'lastName': birthday.lastName,
        'birthDate': birthday.birthDate.toIso8601String(),
        'notes': birthday.notes,
        'phoneNumber': birthday.phoneNumber,
      },
    );
  }

  Future<int> updateBirthday(Birthday birthday) async {
    final db = await database;
    return await db.update(
      'birthdays',
      {
        'firstName': birthday.firstName,
        'lastName': birthday.lastName,
        'birthDate': birthday.birthDate.toIso8601String(),
        'notes': birthday.notes,
        'phoneNumber': birthday.phoneNumber,
      },
      where: 'id = ?',
      whereArgs: [birthday.id],
    );
  }

  Future<List<Birthday>> getBirthdays({int? limit, int? offset}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'birthdays',
      limit: limit,
      offset: offset,
      orderBy: 'birthDate ASC',
    );
    
    return List.generate(maps.length, (i) => Birthday.fromMap(maps[i]));
  }

  Future<void> deleteBirthday(int id) async {
    final db = await database;
    await db.delete(
      'birthdays',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllBirthdays() async {
    final db = await database;
    await db.delete(
      'birthdays',
      where: '1 = 1', // This will delete all rows
    );
  }

  Future<List<Birthday>> searchBirthdays(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'birthdays',
      where: 'firstName LIKE ? OR lastName LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Birthday.fromMap(maps[i]));
  }

  // Add method to check if table exists
  Future<bool> isTableEmpty() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM birthdays');
    return Sqflite.firstIntValue(result) == 0;
  }
}