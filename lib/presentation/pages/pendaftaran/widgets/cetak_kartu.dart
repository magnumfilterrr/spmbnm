import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:spmb_app/data/models/peserta_model.dart';
import 'package:spmb_app/data/repositories/peserta_repository.dart';

class CetakKartu {
  static Future<void> cetak(BuildContext context, PesertaModel peserta) async {
    final ttdKepala = await rootBundle.load('assets/images/ksp.png');
    final ttdPanitia = await rootBundle.load('assets/images/ketua.png');
    final imgKepala = pw.MemoryImage(ttdKepala.buffer.asUint8List());
    final imgPanitia = pw.MemoryImage(ttdPanitia.buffer.asUint8List());

    // ✅ Load logo sekolah
    pw.MemoryImage? imgLogo;
    try {
      final logoBytes = await rootBundle.load('assets/images/nm.png');
      imgLogo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      imgLogo = null;
    }

    final repo = PesertaRepository();
    final nomorUrut = await repo.getNomorUrutPeserta(peserta.id);
    final ruang = PesertaRepository.hitungRuang(nomorUrut);

    final pdf = pw.Document();

    const pageFormat = PdfPageFormat(
      21.7 * PdfPageFormat.cm,
      13 * PdfPageFormat.cm,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(12),
        build: (ctx) => pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(flex: 5, child: _buildJadwal(imgKepala)),
            pw.SizedBox(width: 12),
            pw.Expanded(
              flex: 5,
              child:
                  _buildKartu(peserta, nomorUrut, ruang, imgPanitia, imgLogo),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'kartu_peserta_${peserta.noReg ?? peserta.id}',
    );
  }

  // ─── JADWAL KEGIATAN ─────────────────────────────────
  static pw.Widget _buildJadwal(pw.MemoryImage imgKepala) {
    final jadwalData = [
      [
        'Pendaftaran SPMB',
        '1 Maret -\n24 April 2026',
        '28 April -\n3 Juli 2026'
      ],
      [
        'Rapat Orang Tua\nPeserta Didik Baru',
        'Selasa,\n30 April 2025',
        'Senin,\n7 Juli 2025'
      ],
      [
        'Daftar Ulang Peserta\nDidik Baru',
        '28 April - 9 Mei2026',
        '7-11 Juli 2026'
      ],
      [
        'Seleksi Tes &\nPenelusuran Pemilihan\nJurusan',
        'Sabtu,\n25 April 2026',
        'Sabtu,\n4 Juli 2026'
      ],
      [
        'Pengumuman Peserta\nDidik yang diterima',
        'Senin,\n27 April 2026',
        'Senin,\n6 Juli 2026'
      ],
      ['Pembekalan MPLS', 'Sabtu,\n11 Juli 2026', ''],
      [
        'Pelaksanaan MPLS &\nOrientasi Ekstrakurikuler',
        '13 - 17 Juli 2026',
        ''
      ],
      [
        'Belajar Efektif Tahun\nPelajaran 2026/2027',
        'Senin,\n20 Juli 2026',
        ''
      ],
    ];

    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('JADWAL KEGIATAN SPMB',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text('SMK NUURUL MUTTAQIIN CISURUPAN',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 9)),
                pw.Text('TAHUN PELAJARAN 2026-2027',
                    style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _tableCell('URAIAN KEGIATAN', isHeader: true),
                  _tableCell('GELOMBANG 1\nHARI/TANGGAL', isHeader: true),
                  _tableCell('GELOMBANG 2\nHARI/TANGGAL', isHeader: true),
                ],
              ),
              ...jadwalData.map((row) => pw.TableRow(
                    children: row.map((cell) => _tableCell(cell)).toList(),
                  )),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Catatan: Jadwal sewaktu-waktu bisa berubah disesuaikan dengan kondisi',
            style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('MENGETAHUI KEPALA:',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Text('SMK NUURUL MUTTAQIIN CISURUPAN',
                      style: const pw.TextStyle(fontSize: 7)),

                  // ✅ Stack: ttd di atas garis + nama
                  pw.Stack(
                    alignment: pw.Alignment.bottomCenter,
                    children: [
                      // Garis + nama (di bawah)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.SizedBox(height: 30), // ruang untuk ttd
                          pw.Container(
                            width: 110,
                            decoration: const pw.BoxDecoration(
                              border:
                                  pw.Border(bottom: pw.BorderSide(width: 0.5)),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text('DASEP GUNAWAN, S.Pd.',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 7)),
                        ],
                      ),

                      // Tanda tangan (di atas, melayang)
                      pw.Positioned(
                        // sesuaikan agar ttd tepat di atas garis
                        child: pw.Image(imgKepala, width: 50, height: 100),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── KARTU PESERTA ───────────────────────────────────
  static pw.Widget _buildKartu(
    PesertaModel peserta,
    int nomorUrut,
    int ruang,
    pw.MemoryImage imgPanitia,
    pw.MemoryImage? imgLogo, // ✅ parameter logo
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ✅ Header kop surat dengan logo di kiri
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logo sekolah
              pw.Container(
                width: 60,
                height: 60,
                child: imgLogo != null
                    ? pw.Image(imgLogo, fit: pw.BoxFit.contain)
                    : pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Center(
                          child: pw.Text('LOGO',
                              style: const pw.TextStyle(fontSize: 6)),
                        ),
                      ),
              ),

              // Garis vertikal pemisah

              // Teks kop surat
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('SMK NUURUL MUTTAQIIN CISURUPAN',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.Text('Jl. Raya Cisurupan No. 160 Cisurupan Garut 44163',
                        style: const pw.TextStyle(fontSize: 6)),
                    pw.Text('Telp / Fax. (0262) 576327',
                        style: const pw.TextStyle(fontSize: 6)),
                    pw.Text('email: smk_nm_grt@yahoo.co.id',
                        style: const pw.TextStyle(fontSize: 6)),
                    pw.Text('website: www.smknuurulmuttaqiin.sch.id',
                        style: const pw.TextStyle(fontSize: 6)),
                    pw.SizedBox(height: 3),
                    pw.Text('KARTU PESERTA PEMINATAN JURUSAN',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.Text('SISTEM PENERIMAAN MURID BARU 2026-2027',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 8)),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 6),
          pw.Divider(thickness: 0.5),
          pw.SizedBox(height: 6),

          // Body: info + foto
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  children: [
                    _infoRow('NO. PESERTA', peserta.noReg ?? '-'),
                    _infoRow('NAMA LENGKAP', peserta.namaLengkap),
                    _infoRow(
                      'TEMPAT/TGL LAHIR',
                      '${peserta.tempatLahir ?? '-'}, ${_formatTgl(peserta.tglLahir)}',
                    ),
                    _infoRow('ALAMAT', _formatAlamat(peserta)),
                    _infoRow('No.HP/WA', peserta.noHp ?? '-'),
                    _infoRow('SEKOLAH ASAL', peserta.namaSekolahAsal ?? '-'),
                  ],
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Column(
                children: [
                  pw.Container(
                    width: 55,
                    height: 70,
                    decoration:
                        pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                    child: pw.Center(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('FOTO',
                              style: const pw.TextStyle(fontSize: 7)),
                          pw.Text('2 X 3',
                              style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Container(
                    width: 55,
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 4, horizontal: 4),
                    decoration:
                        pw.BoxDecoration(border: pw.Border.all(width: 1)),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('RUANG',
                            style: const pw.TextStyle(fontSize: 7)),
                        pw.Text(
                          '$ruang',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 8),

          // Barcode + TTD
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                width: 90,
                height: 28,
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                child: pw.Center(
                  child: pw.Text('|||||||||||||||||||||||||',
                      style: const pw.TextStyle(fontSize: 9)),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Garut, ${_formatTanggalHariIni()}',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Text('KETUA PANITIA,',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.SizedBox(height: 4),
                  pw.Image(imgPanitia, width: 70, height: 60),
                  pw.Container(
                    width: 90,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text('DADANG SAEPUDIN, SE.',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 7)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────
  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(label,
                style:
                    pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 7)),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 7)),
          ),
        ],
      ),
    );
  }

  static String _formatAlamat(PesertaModel peserta) {
    final parts = <String>[];

    // if (peserta.alamat != null && peserta.alamat!.isNotEmpty) {
    //   parts.add(peserta.alamat!);
    // }
    if (peserta.dusun != null && peserta.dusun!.isNotEmpty) {
      parts.add('Dusun ${peserta.dusun!}');
    }
    if (peserta.rt != null &&
        peserta.rt!.isNotEmpty &&
        peserta.rw != null &&
        peserta.rw!.isNotEmpty) {
      parts.add('RT ${peserta.rt!} / RW ${peserta.rw!}');
    } else if (peserta.rt != null && peserta.rt!.isNotEmpty) {
      parts.add('RT ${peserta.rt!}');
    }
    if (peserta.kelurahan != null && peserta.kelurahan!.isNotEmpty) {
      parts.add('Desa ${peserta.kelurahan!}');
    }
    if (peserta.kecamatan != null && peserta.kecamatan!.isNotEmpty) {
      parts.add('Kec. ${peserta.kecamatan!}');
    }
    if (peserta.kabupaten != null && peserta.kabupaten!.isNotEmpty) {
      parts.add('Kab. ${peserta.kabupaten!}');
    }
    if (peserta.propinsi != null && peserta.propinsi!.isNotEmpty) {
      parts.add(peserta.propinsi!);
    }

    return parts.isEmpty ? '-' : parts.join(', ');
  }

  static String _formatTgl(String? tgl) {
    if (tgl == null) return '-';
    try {
      final dt = DateTime.parse(tgl);
      const bulan = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return tgl;
    }
  }

  static String _formatTanggalHariIni() {
    final dt = DateTime.now();
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }
}
