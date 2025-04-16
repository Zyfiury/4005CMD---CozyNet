import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabaseHelper {
  static final _databaseName = "user.db";
  static final _databaseVersion = 1;

  static final table = 'users';
  static final columnId = 'id';
  static final columnEmail = 'email';
  static final columnPassword = 'password';
  static final columnHouseName = 'houseName';

  UserDatabaseHelper._privateConstructor();
  static final UserDatabaseHelper instance =
      UserDatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnEmail TEXT NOT NULL,
        $columnPassword TEXT NOT NULL,
        $columnHouseName TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      table,
      where: '$columnEmail = ? AND $columnPassword = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
