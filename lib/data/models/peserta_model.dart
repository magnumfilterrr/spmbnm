class PesertaModel {
  final String id;
  final String? tanggal;
  final String? noReg;
  final String? tingkat;
  final String? program;
  final String caraDaftar;
  final String? namaKolektif;
  final String? jalurPendaftaran; // ✅ TAMBAHAN
  final String? jurusan1;
  final String? jurusan2;
  final String namaLengkap;
  final String? jenisKelamin;
  final String? nisn;
  final String? nis;
  final String? noSeriIjazah;
  final String? noSeriSkhun;
  final String? noUjianNasional;
  final String? nik;
  final String? npsn;
  final String? namaSekolahAsal;
  final String? tempatLahir;
  final String? tglLahir;
  final String? agama;
  final String? berkebutuhanKhusus;
  final String? alamat;
  final String? rt;
  final String? rw;
  final String? dusun;
  final String? kelurahan;
  final String? kodePos;
  final String? kecamatan;
  final String? kabupaten;
  final String? propinsi;
  final String? alatTransportasi;
  final String? jenisTinggal;
  final String? noTelp;
  final String? noHp;
  final String? email;
  final String? noKks;
  final String? penerimaKps;
  final String? noKps;
  final String? usulanPip;
  final String? penerimaKip;
  final String? noKip;
  final String? namaDiKip;
  final String? alasanMenolakKip;
  final String? noRegistrasiAkta;
  final String? lintang;
  final String? bujur;
  final String? namaAyah;
  final String? thnLahirAyah;
  final String? kebutuhanKhususAyah;
  final String? pekerjaanAyah;
  final String? pendidikanAyah;
  final String? penghasilanAyah;
  final String? namaIbu;
  final String? thnLahirIbu;
  final String? kebutuhanKhususIbu;
  final String? pekerjaanIbu;
  final String? pendidikanIbu;
  final String? penghasilanIbu;
  final String? namaWali;
  final String? thnLahirWali;
  final String? pekerjaanWali;
  final String? pendidikanWali;
  final String? penghasilanWali;
  final double? tinggiBadan;
  final double? beratBadan;
  final double? jarakSekolah;
  final int? waktuTempuh;
  final int? jmlSaudara;
  final String? createdAt;
  final String? updatedAt;

  PesertaModel({
    required this.id,
    this.tanggal,
    this.noReg,
    this.tingkat,
    this.program,
    required this.caraDaftar,
    this.namaKolektif,
    this.jalurPendaftaran, // ✅
    this.jurusan1,
    this.jurusan2,
    required this.namaLengkap,
    this.jenisKelamin,
    this.nisn,
    this.nis,
    this.noSeriIjazah,
    this.noSeriSkhun,
    this.noUjianNasional,
    this.nik,
    this.npsn,
    this.namaSekolahAsal,
    this.tempatLahir,
    this.tglLahir,
    this.agama,
    this.berkebutuhanKhusus,
    this.alamat,
    this.rt,
    this.rw,
    this.dusun,
    this.kelurahan,
    this.kodePos,
    this.kecamatan,
    this.kabupaten,
    this.propinsi,
    this.alatTransportasi,
    this.jenisTinggal,
    this.noTelp,
    this.noHp,
    this.email,
    this.noKks,
    this.penerimaKps,
    this.noKps,
    this.usulanPip,
    this.penerimaKip,
    this.noKip,
    this.namaDiKip,
    this.alasanMenolakKip,
    this.noRegistrasiAkta,
    this.lintang,
    this.bujur,
    this.namaAyah,
    this.thnLahirAyah,
    this.kebutuhanKhususAyah,
    this.pekerjaanAyah,
    this.pendidikanAyah,
    this.penghasilanAyah,
    this.namaIbu,
    this.thnLahirIbu,
    this.kebutuhanKhususIbu,
    this.pekerjaanIbu,
    this.pendidikanIbu,
    this.penghasilanIbu,
    this.namaWali,
    this.thnLahirWali,
    this.pekerjaanWali,
    this.pendidikanWali,
    this.penghasilanWali,
    this.tinggiBadan,
    this.beratBadan,
    this.jarakSekolah,
    this.waktuTempuh,
    this.jmlSaudara,
    this.createdAt,
    this.updatedAt,
  });

  factory PesertaModel.fromMap(Map<String, dynamic> map) {
    return PesertaModel(
      id: map['id'],
      tanggal: map['tanggal'],
      noReg: map['no_reg'],
      tingkat: map['tingkat'],
      program: map['program'],
      caraDaftar: map['cara_daftar'] ?? '',
      namaKolektif: map['nama_kolektif'],
      jalurPendaftaran: map['jalur_pendaftaran'], // ✅
      jurusan1: map['jurusan_1'],
      jurusan2: map['jurusan_2'],
      namaLengkap: map['nama_lengkap'] ?? '',
      jenisKelamin: map['jenis_kelamin'],
      nisn: map['nisn'],
      nis: map['nis'],
      noSeriIjazah: map['no_seri_ijazah'],
      noSeriSkhun: map['no_seri_skhun'],
      noUjianNasional: map['no_ujian_nasional'],
      nik: map['nik'],
      npsn: map['npsn_sekolah_asal'],
      namaSekolahAsal: map['nama_sekolah_asal'],
      tempatLahir: map['tempat_lahir'],
      tglLahir: map['tgl_lahir'],
      agama: map['agama'],
      berkebutuhanKhusus: map['berkebutuhan_khusus'],
      alamat: map['alamat'],
      rt: map['rt'],
      rw: map['rw'],
      dusun: map['dusun'],
      kelurahan: map['kelurahan'],
      kodePos: map['kode_pos'],
      kecamatan: map['kecamatan'],
      kabupaten: map['kabupaten'],
      propinsi: map['propinsi'],
      alatTransportasi: map['alat_transportasi'],
      jenisTinggal: map['jenis_tinggal'],
      noTelp: map['no_telp'],
      noHp: map['no_hp'],
      email: map['email'],
      noKks: map['no_kks'],
      penerimaKps: map['penerima_kps'],
      noKps: map['no_kps'],
      usulanPip: map['usulan_pip'],
      penerimaKip: map['penerima_kip'],
      noKip: map['no_kip'],
      namaDiKip: map['nama_di_kip'],
      alasanMenolakKip: map['alasan_menolak_kip'],
      noRegistrasiAkta: map['no_registrasi_akta'],
      lintang: map['lintang'],
      bujur: map['bujur'],
      namaAyah: map['nama_ayah'],
      thnLahirAyah: map['thn_lahir_ayah'],
      kebutuhanKhususAyah: map['kebutuhan_khusus_ayah'],
      pekerjaanAyah: map['pekerjaan_ayah'],
      pendidikanAyah: map['pendidikan_ayah'],
      penghasilanAyah: map['penghasilan_ayah'],
      namaIbu: map['nama_ibu'],
      thnLahirIbu: map['thn_lahir_ibu'],
      kebutuhanKhususIbu: map['kebutuhan_khusus_ibu'],
      pekerjaanIbu: map['pekerjaan_ibu'],
      pendidikanIbu: map['pendidikan_ibu'],
      penghasilanIbu: map['penghasilan_ibu'],
      namaWali: map['nama_wali'],
      thnLahirWali: map['thn_lahir_wali'],
      pekerjaanWali: map['pekerjaan_wali'],
      pendidikanWali: map['pendidikan_wali'],
      penghasilanWali: map['penghasilan_wali'],
      tinggiBadan: map['tinggi_badan']?.toDouble(),
      beratBadan: map['berat_badan']?.toDouble(),
      jarakSekolah: map['jarak_sekolah']?.toDouble(),
      waktuTempuh: map['waktu_tempuh'],
      jmlSaudara: map['jml_saudara'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'no_reg': noReg,
      'tingkat': tingkat,
      'program': program,
      'cara_daftar': caraDaftar,
      'nama_kolektif': namaKolektif,
      'jalur_pendaftaran': jalurPendaftaran, // ✅
      'jurusan_1': jurusan1,
      'jurusan_2': jurusan2,
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'nisn': nisn,
      'nis': nis,
      'no_seri_ijazah': noSeriIjazah,
      'no_seri_skhun': noSeriSkhun,
      'no_ujian_nasional': noUjianNasional,
      'nik': nik,
      'npsn_sekolah_asal': npsn,
      'nama_sekolah_asal': namaSekolahAsal,
      'tempat_lahir': tempatLahir,
      'tgl_lahir': tglLahir,
      'agama': agama,
      'berkebutuhan_khusus': berkebutuhanKhusus,
      'alamat': alamat,
      'rt': rt,
      'rw': rw,
      'dusun': dusun,
      'kelurahan': kelurahan,
      'kode_pos': kodePos,
      'kecamatan': kecamatan,
      'kabupaten': kabupaten,
      'propinsi': propinsi,
      'alat_transportasi': alatTransportasi,
      'jenis_tinggal': jenisTinggal,
      'no_telp': noTelp,
      'no_hp': noHp,
      'email': email,
      'no_kks': noKks,
      'penerima_kps': penerimaKps,
      'no_kps': noKps,
      'usulan_pip': usulanPip,
      'penerima_kip': penerimaKip,
      'no_kip': noKip,
      'nama_di_kip': namaDiKip,
      'alasan_menolak_kip': alasanMenolakKip,
      'no_registrasi_akta': noRegistrasiAkta,
      'lintang': lintang,
      'bujur': bujur,
      'nama_ayah': namaAyah,
      'thn_lahir_ayah': thnLahirAyah,
      'kebutuhan_khusus_ayah': kebutuhanKhususAyah,
      'pekerjaan_ayah': pekerjaanAyah,
      'pendidikan_ayah': pendidikanAyah,
      'penghasilan_ayah': penghasilanAyah,
      'nama_ibu': namaIbu,
      'thn_lahir_ibu': thnLahirIbu,
      'kebutuhan_khusus_ibu': kebutuhanKhususIbu,
      'pekerjaan_ibu': pekerjaanIbu,
      'pendidikan_ibu': pendidikanIbu,
      'penghasilan_ibu': penghasilanIbu,
      'nama_wali': namaWali,
      'thn_lahir_wali': thnLahirWali,
      'pekerjaan_wali': pekerjaanWali,
      'pendidikan_wali': pendidikanWali,
      'penghasilan_wali': penghasilanWali,
      'tinggi_badan': tinggiBadan,
      'berat_badan': beratBadan,
      'jarak_sekolah': jarakSekolah,
      'waktu_tempuh': waktuTempuh,
      'jml_saudara': jmlSaudara,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  PesertaModel copyWith({
    String? namaLengkap,
    String? jalurPendaftaran,
    String? jurusan1,
    String? jurusan2,
    String? caraDaftar,
    String? namaKolektif,
  }) {
    return PesertaModel(
      id: id,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      caraDaftar: caraDaftar ?? this.caraDaftar,
      jalurPendaftaran: jalurPendaftaran ?? this.jalurPendaftaran, // ✅
      jurusan1: jurusan1 ?? this.jurusan1,
      jurusan2: jurusan2 ?? this.jurusan2,
      namaKolektif: namaKolektif ?? this.namaKolektif,
    );
  }
}