import 'package:spmb_app/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DashboardRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await _db.database;

    // Total peserta
    final total = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM peserta_didik'),
        ) ?? 0;

    // Per jenis kelamin
    final laki = Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM peserta_didik WHERE jenis_kelamin = 'L'"),
        ) ?? 0;
    final perempuan = Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM peserta_didik WHERE jenis_kelamin = 'P'"),
        ) ?? 0;

    // Per jurusan
    final jurusanList = [
      'Manajemen Perkantoran dan Layanan Bisnis',
      'Pemasaran Bisnis Ritel',
      'Desain Komunikasi Visual',
      'Teknik Kendaraan Ringan',
    ];
    final Map<String, int> perJurusan = {};
    for (final j in jurusanList) {
      final count = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM peserta_didik WHERE jurusan_1 = ?',
              [j],
            ),
          ) ?? 0;
      perJurusan[j] = count;
    }

    // Per jalur pendaftaran
    final jalurList = ['Prestasi', 'Tahfidz', 'Reguler'];
    final Map<String, int> perJalur = {};
    for (final j in jalurList) {
      final count = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM peserta_didik WHERE jalur_pendaftaran = ?',
              [j],
            ),
          ) ?? 0;
      perJalur[j] = count;
    }

    return {
      'total': total,
      'laki': laki,
      'perempuan': perempuan,
      'per_jurusan': perJurusan,
      'per_jalur': perJalur,
    };
  }
}