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
    version: 2, // ✅ naikkan version
    onCreate: _createDB,
    onUpgrade: _upgradeDB, // ✅ tambah upgrade
  );
}

Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // ✅ Tambah unique index untuk nisn
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_nisn ON peserta_didik(nisn) WHERE nisn IS NOT NULL AND nisn != ""',
    );
    // ✅ Tambah unique index untuk no_reg
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_no_reg ON peserta_didik(no_reg) WHERE no_reg IS NOT NULL AND no_reg != ""',
    );
  }
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
  Future<String> getDatabasePath() async {
  final dbPath = await getDatabasesPath();
  return join(dbPath, 'pmb.db');
}
}