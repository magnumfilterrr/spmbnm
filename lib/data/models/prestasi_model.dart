class PrestasiModel {
  final int? id;
  final String pesertaId;
  final String? jenis;
  final String? tingkat;
  final String? namaPrestasi;
  final String? tahun;
  final String? penyelenggara;

  PrestasiModel({
    this.id,
    required this.pesertaId,
    this.jenis,
    this.tingkat,
    this.namaPrestasi,
    this.tahun,
    this.penyelenggara,
  });

  factory PrestasiModel.fromMap(Map<String, dynamic> map) => PrestasiModel(
        id: map['id'],
        pesertaId: map['peserta_id'],
        jenis: map['jenis'],
        tingkat: map['tingkat'],
        namaPrestasi: map['nama_prestasi'],
        tahun: map['tahun'],
        penyelenggara: map['penyelenggara'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'peserta_id': pesertaId,
        'jenis': jenis,
        'tingkat': tingkat,
        'nama_prestasi': namaPrestasi,
        'tahun': tahun,
        'penyelenggara': penyelenggara,
      };
}