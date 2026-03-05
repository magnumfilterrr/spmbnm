class BeasiswaModel {
  final int? id;
  final String pesertaId;
  final String? jenis;
  final String? penyelenggara;
  final String? tahunMulai;
  final String? tahunSelesai;

  BeasiswaModel({
    this.id,
    required this.pesertaId,
    this.jenis,
    this.penyelenggara,
    this.tahunMulai,
    this.tahunSelesai,
  });

  factory BeasiswaModel.fromMap(Map<String, dynamic> map) => BeasiswaModel(
        id: map['id'],
        pesertaId: map['peserta_id'],
        jenis: map['jenis'],
        penyelenggara: map['penyelenggara'],
        tahunMulai: map['tahun_mulai'],
        tahunSelesai: map['tahun_selesai'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'peserta_id': pesertaId,
        'jenis': jenis,
        'penyelenggara': penyelenggara,
        'tahun_mulai': tahunMulai,
        'tahun_selesai': tahunSelesai,
      };
}