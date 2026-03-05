class CreateTableSQL {
  // Tabel Users (Login)
  static const String users = '''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      nama TEXT
    )
  ''';

  // Tabel Utama Peserta Didik
  static const String pesertaDidik = '''
    CREATE TABLE peserta_didik (
      id TEXT PRIMARY KEY,
      -- Header
      tanggal TEXT,
      no_reg TEXT,
      tingkat TEXT,
      program TEXT,
      cara_daftar TEXT,
      nama_kolektif TEXT,
      jalur_pendaftaran TEXT,
      jurusan_1 TEXT,
      jurusan_2 TEXT,

      -- Identitas
      nama_lengkap TEXT NOT NULL,
      jenis_kelamin TEXT,
      nisn TEXT,
      nis TEXT,
      no_seri_ijazah TEXT,
      no_seri_skhun TEXT,
      no_ujian_nasional TEXT,
      nik TEXT,
      npsn_sekolah_asal TEXT,
      nama_sekolah_asal TEXT,
      tempat_lahir TEXT,
      tgl_lahir TEXT,
      agama TEXT,
      berkebutuhan_khusus TEXT,

      -- Alamat
      alamat TEXT,
      rt TEXT,
      rw TEXT,
      dusun TEXT,
      kelurahan TEXT,
      kode_pos TEXT,
      kecamatan TEXT,
      kabupaten TEXT,
      propinsi TEXT,

      -- Kontak & Lainnya
      alat_transportasi TEXT,
      jenis_tinggal TEXT,
      no_telp TEXT,
      no_hp TEXT,
      email TEXT,

      -- KKS/KPS/KIP
      no_kks TEXT,
      penerima_kps TEXT,
      no_kps TEXT,
      usulan_pip TEXT,
      penerima_kip TEXT,
      no_kip TEXT,
      nama_di_kip TEXT,
      alasan_menolak_kip TEXT,
      no_registrasi_akta TEXT,
      lintang TEXT,
      bujur TEXT,

      -- Data Ayah
      nama_ayah TEXT,
      thn_lahir_ayah TEXT,
      kebutuhan_khusus_ayah TEXT,
      pekerjaan_ayah TEXT,
      pendidikan_ayah TEXT,
      penghasilan_ayah TEXT,

      -- Data Ibu
      nama_ibu TEXT,
      thn_lahir_ibu TEXT,
      kebutuhan_khusus_ibu TEXT,
      pekerjaan_ibu TEXT,
      pendidikan_ibu TEXT,
      penghasilan_ibu TEXT,

      -- Data Wali
      nama_wali TEXT,
      thn_lahir_wali TEXT,
      pekerjaan_wali TEXT,
      pendidikan_wali TEXT,
      penghasilan_wali TEXT,

      -- Data Periodik Fisik
      tinggi_badan REAL,
      berat_badan REAL,
      jarak_sekolah REAL,
      waktu_tempuh INTEGER,
      jml_saudara INTEGER,

      created_at TEXT,
      updated_at TEXT
    )
  ''';

  // Tabel Prestasi (relasi ke peserta_didik)
  static const String prestasi = '''
    CREATE TABLE prestasi (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      peserta_id TEXT NOT NULL,
      jenis TEXT,
      tingkat TEXT,
      nama_prestasi TEXT,
      tahun TEXT,
      penyelenggara TEXT,
      FOREIGN KEY (peserta_id) REFERENCES peserta_didik(id)
    )
  ''';

  // Tabel Beasiswa (relasi ke peserta_didik)
  static const String beasiswa = '''
    CREATE TABLE beasiswa (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      peserta_id TEXT NOT NULL,
      jenis TEXT,
      penyelenggara TEXT,
      tahun_mulai TEXT,
      tahun_selesai TEXT,
      FOREIGN KEY (peserta_id) REFERENCES peserta_didik(id)
    )
  ''';
}