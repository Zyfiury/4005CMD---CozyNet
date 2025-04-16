import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "temperature.db";
  static final _databaseVersion = 1;

  static Database? _database;
  final StreamController<double> _updateController =
      StreamController.broadcast();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE temperature (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value REAL NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  Future<void> insertTemperature(double temp) async {
    final db = await database;
    await db.insert('temperature', {'value': temp});
    _updateController.add(temp);
  }

  Future<List<double>> getHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query(
      'temperature',
      orderBy: 'timestamp DESC',
      limit: 50,
    );
    return data.map((e) => e['value'] as double).toList();
  }

  Stream<double> get temperatureUpdates => _updateController.stream;

  void dispose() {
    _updateController.close();
  }
}
