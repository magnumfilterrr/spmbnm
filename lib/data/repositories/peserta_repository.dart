import 'package:spmb_app/data/database/database_helper.dart';
import 'package:spmb_app/data/models/beasiswa_model.dart';
import 'package:spmb_app/data/models/peserta_model.dart';
import 'package:spmb_app/data/models/prestasi_model.dart';

class PesertaRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ─── CREATE ───────────────────────────────────────────
  Future<void> insertPeserta(
    PesertaModel peserta, {
    List<PrestasiModel>? prestasi,
    List<BeasiswaModel>? beasiswa,
  }) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.insert('peserta_didik', peserta.toMap());

      if (prestasi != null) {
        for (final p in prestasi) {
          await txn.insert('prestasi', p.toMap());
        }
      }
      if (beasiswa != null) {
        for (final b in beasiswa) {
          await txn.insert('beasiswa', b.toMap());
        }
      }
    });
  }

  // ─── READ ALL ─────────────────────────────────────────
  Future<List<PesertaModel>> getAllPeserta() async {
    final db = await _db.database;
    final result = await db.query(
      'peserta_didik',
      orderBy: 'created_at DESC',
    );
    return result.map((e) => PesertaModel.fromMap(e)).toList();
  }

  // ─── READ BY ID ───────────────────────────────────────
  Future<PesertaModel?> getPesertaById(String id) async {
    final db = await _db.database;
    final result = await db.query(
      'peserta_didik',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) return PesertaModel.fromMap(result.first);
    return null;
  }

  // ─── READ PRESTASI & BEASISWA ─────────────────────────
  Future<List<PrestasiModel>> getPrestasiByPeserta(String pesertaId) async {
    final db = await _db.database;
    final result = await db.query(
      'prestasi',
      where: 'peserta_id = ?',
      whereArgs: [pesertaId],
    );
    return result.map((e) => PrestasiModel.fromMap(e)).toList();
  }

  Future<List<BeasiswaModel>> getBeasiswaByPeserta(String pesertaId) async {
    final db = await _db.database;
    final result = await db.query(
      'beasiswa',
      where: 'peserta_id = ?',
      whereArgs: [pesertaId],
    );
    return result.map((e) => BeasiswaModel.fromMap(e)).toList();
  }

  // ─── UPDATE ───────────────────────────────────────────
  Future<void> updatePeserta(
    PesertaModel peserta, {
    List<PrestasiModel>? prestasi,
    List<BeasiswaModel>? beasiswa,
  }) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'peserta_didik',
        peserta.toMap(),
        where: 'id = ?',
        whereArgs: [peserta.id],
      );

      // Hapus lama, insert baru
      if (prestasi != null) {
        await txn.delete('prestasi',
            where: 'peserta_id = ?', whereArgs: [peserta.id]);
        for (final p in prestasi) {
          await txn.insert('prestasi', p.toMap());
        }
      }
      if (beasiswa != null) {
        await txn.delete('beasiswa',
            where: 'peserta_id = ?', whereArgs: [peserta.id]);
        for (final b in beasiswa) {
          await txn.insert('beasiswa', b.toMap());
        }
      }
    });
  }

  // ─── DELETE ───────────────────────────────────────────
  Future<void> deletePeserta(String id) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('prestasi', where: 'peserta_id = ?', whereArgs: [id]);
      await txn.delete('beasiswa', where: 'peserta_id = ?', whereArgs: [id]);
      await txn.delete('peserta_didik', where: 'id = ?', whereArgs: [id]);
    });
  }

  // ─── SEARCH ───────────────────────────────────────────
  Future<List<PesertaModel>> searchPeserta(String keyword) async {
    final db = await _db.database;
    final result = await db.query(
      'peserta_didik',
      where: 'nama_lengkap LIKE ? OR nisn LIKE ? OR no_reg LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'created_at DESC',
    );
    return result.map((e) => PesertaModel.fromMap(e)).toList();
  }

  // ─── FILTER ───────────────────────────────────────────
  Future<List<PesertaModel>> filterPeserta({
    String? jurusan,
    String? jalur,
    String? jenisKelamin,
  }) async {
    final db = await _db.database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (jurusan != null) {
      conditions.add('(jurusan_1 = ? OR jurusan_2 = ?)');
      args.addAll([jurusan, jurusan]);
    }
    if (jalur != null) {
      conditions.add('jalur_pendaftaran = ?');
      args.add(jalur);
    }
    if (jenisKelamin != null) {
      conditions.add('jenis_kelamin = ?');
      args.add(jenisKelamin);
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    final result = await db.query(
      'peserta_didik',
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'created_at DESC',
    );
    return result.map((e) => PesertaModel.fromMap(e)).toList();
  }

  // Ambil nomor urut peserta berdasarkan created_at
Future<int> getNomorUrutPeserta(String pesertaId) async {
  final db = await _db.database;
  final result = await db.rawQuery(
    'SELECT id FROM peserta_didik ORDER BY created_at ASC',
  );
  final index = result.indexWhere((row) => row['id'] == pesertaId);
  return index + 1; // mulai dari 1
}

// Hitung ruang dari nomor urut
static int hitungRuang(int nomorUrut, {int kapasitas = 20}) {
  return ((nomorUrut - 1) ~/ kapasitas) + 1;
}
}