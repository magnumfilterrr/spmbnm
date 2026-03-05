import 'package:path/path.dart';
import 'package:spmb_app/data/database/tables/peserta_table.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pmb.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(CreateTableSQL.users);
    await db.execute(CreateTableSQL.pesertaDidik);
    await db.execute(CreateTableSQL.prestasi);
    await db.execute(CreateTableSQL.beasiswa);

    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'nama': 'Administrator',
    });
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}