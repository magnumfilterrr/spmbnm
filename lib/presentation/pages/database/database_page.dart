import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:spmb_app/core/constants/app_strings.dart';
import 'package:spmb_app/core/theme/app_theme.dart';
import 'package:spmb_app/core/utils/responsive_helper.dart';
import 'package:spmb_app/data/models/peserta_model.dart';
import 'package:spmb_app/logic/dashboard/dashboard_bloc.dart';
import 'package:spmb_app/logic/dashboard/dashboard_event.dart';
import 'package:spmb_app/logic/database/database_bloc.dart';
import 'package:spmb_app/logic/database/database_event.dart';
import 'package:spmb_app/logic/database/database_state.dart';
import 'package:spmb_app/presentation/pages/pendaftaran/pendaftaran_page.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  final _searchCtrl = TextEditingController();
  String? _filterJurusan;
  String? _filterJalur;
  String? _filterGender;
  int _rowsPerPage = 10;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocListener<DatabaseBloc, DatabaseState>(
        listener: (context, state) {
          if (state is DatabaseExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Export berhasil: ${state.filePath}'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          } else if (state is DatabaseExportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildHeader(),
            _buildToolbar(),
            _buildFilterBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      color: AppTheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Database Peserta Didik',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              Text('Data seluruh peserta didik baru',
                  style:
                      TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
          Row(
            children: [
              _buildExportButton(),
              // const SizedBox(width: 8),
              // ElevatedButton.icon(
              //   onPressed: () => _openFormTambah(),
              //   icon: const Icon(Icons.add),
              //   label: const Text('Tambah'),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── TOOLBAR (Search) ────────────────────────────────
  Widget _buildToolbar() {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama, NISN, atau no. registrasi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<DatabaseBloc>().add(LoadPeserta());
                        },
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (v) {
                if (v.isEmpty) {
                  context.read<DatabaseBloc>().add(LoadPeserta());
                } else {
                  context.read<DatabaseBloc>().add(SearchPeserta(v));
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DatabaseBloc>().add(LoadPeserta()),
          ),
        ],
      ),
    );
  }

  // ─── FILTER BAR ──────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text('Filter: ',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary)),
            const SizedBox(width: 8),
            _buildFilterChipDropdown(
              label: 'Jurusan',
              value: _filterJurusan,
              items: AppStrings.jurusan,
              onChanged: (v) {
                setState(() => _filterJurusan = v);
                _applyFilter();
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChipDropdown(
              label: 'Jalur',
              value: _filterJalur,
              items: AppStrings.jalurPendaftaran,
              onChanged: (v) {
                setState(() => _filterJalur = v);
                _applyFilter();
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChipDropdown(
              label: 'Gender',
              value: _filterGender,
              items: const ['L', 'P'],
              onChanged: (v) {
                setState(() => _filterGender = v);
                _applyFilter();
              },
            ),
            if (_filterJurusan != null ||
                _filterJalur != null ||
                _filterGender != null) ...[
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('Reset Filter'),
                avatar: const Icon(Icons.close, size: 16),
                onPressed: _resetFilter,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChipDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: (v) => onChanged(v == value ? null : v),
      itemBuilder: (_) => items
          .map((e) => PopupMenuItem(
                value: e,
                child: Row(
                  children: [
                    if (e == value)
                      const Icon(Icons.check,
                          size: 16, color: AppTheme.primary),
                    if (e == value) const SizedBox(width: 6),
                    Text(e),
                  ],
                ),
              ))
          .toList(),
      child: Chip(
        label: Text(value ?? label),
        avatar: Icon(
          Icons.filter_list,
          size: 16,
          color: value != null ? AppTheme.primary : AppTheme.textSecondary,
        ),
        backgroundColor:
            value != null ? AppTheme.primary.withOpacity(0.1) : null,
        labelStyle: TextStyle(
          color: value != null ? AppTheme.primary : AppTheme.textPrimary,
          fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  // ─── CONTENT ─────────────────────────────────────────
  Widget _buildContent() {
    return BlocBuilder<DatabaseBloc, DatabaseState>(
      builder: (context, state) {
        if (state is DatabaseLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DatabaseError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppTheme.error),
                const SizedBox(height: 12),
                Text(state.message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      context.read<DatabaseBloc>().add(LoadPeserta()),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        if (state is DatabaseLoaded) {
          if (state.pesertaList.isEmpty) return _buildEmptyState();
          return ResponsiveHelper.isMobile(context)
              ? _buildMobileList(state.pesertaList)
              : _buildDataTable(state.pesertaList);
        }
        return const SizedBox();
      },
    );
  }

  // ─── DATA TABLE (Desktop/Tablet) ─────────────────────
  Widget _buildDataTable(List<PesertaModel> list) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 16,
          minWidth: 900,
          headingRowColor:
              WidgetStateProperty.all(AppTheme.primary.withOpacity(0.08)),
          columns: const [
            DataColumn2(label: Text('No'), fixedWidth: 50),
            DataColumn2(label: Text('No. Reg'), size: ColumnSize.S),
            DataColumn2(label: Text('Nama Lengkap'), size: ColumnSize.L),
            DataColumn2(label: Text('L/P'), fixedWidth: 50),
            DataColumn2(label: Text('Jurusan 1'), size: ColumnSize.M),
            DataColumn2(label: Text('Jalur'), size: ColumnSize.S),
            DataColumn2(label: Text('Cara Daftar'), size: ColumnSize.S),
            DataColumn2(label: Text('Tgl Daftar'), size: ColumnSize.S),
            DataColumn2(label: Text('Aksi'), fixedWidth: 120),
          ],
          rows: list.asMap().entries.map((e) {
            final i = e.key;
            final p = e.value;
            return DataRow2(
              cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text(p.noReg ?? '-')),
                DataCell(Text(p.namaLengkap, overflow: TextOverflow.ellipsis)),
                DataCell(Text(p.jenisKelamin ?? '-')),
                DataCell(Text(
                  _shortJurusan(p.jurusan1),
                  overflow: TextOverflow.ellipsis,
                )),
                DataCell(_JalurBadge(jalur: p.jalurPendaftaran)),
                DataCell(Text(p.caraDaftar)),
                DataCell(Text(_formatDate(p.createdAt))),
                DataCell(Row(
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined,
                          color: AppTheme.primary, size: 20),
                      onPressed: () => _openFormEdit(p),
                    ),
                    IconButton(
                      tooltip: 'Hapus',
                      icon: const Icon(Icons.delete_outline,
                          color: AppTheme.error, size: 20),
                      onPressed: () => _confirmDelete(p),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── MOBILE LIST ─────────────────────────────────────
  Widget _buildMobileList(List<PesertaModel> list) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final p = list[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(p.namaLengkap,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('NISN: ${p.nisn ?? '-'} • ${p.jenisKelamin ?? '-'}'),
                Text(_shortJurusan(p.jurusan1)),
                Text('Jalur: ${p.jalurPendaftaran ?? '-'}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'hapus', child: Text('Hapus')),
              ],
              onSelected: (v) {
                if (v == 'edit') _openFormEdit(p);
                if (v == 'hapus') _confirmDelete(p);
              },
            ),
          ),
        );
      },
    );
  }

  // ─── EMPTY STATE ─────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 72, color: AppTheme.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('Belum ada data peserta',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          const Text('Tambahkan peserta baru melalui form pendaftaran',
              style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openFormTambah,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Peserta'),
          ),
        ],
      ),
    );
  }

  // ─── EXPORT BUTTON ───────────────────────────────────
  Widget _buildExportButton() {
    return PopupMenuButton<String>(
      onSelected: (v) async {
        final columns = await _showExportColumnDialog();
        if (columns == null || columns.isEmpty) return;
        if (v == 'excel') _exportExcel(columns);
        if (v == 'pdf') _exportPdf(columns);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'excel',
          child: Row(children: [
            Icon(Icons.table_chart, color: Colors.green),
            SizedBox(width: 8),
            Text('Export Excel'),
          ]),
        ),
        const PopupMenuItem(
          value: 'pdf',
          child: Row(children: [
            Icon(Icons.picture_as_pdf, color: Colors.red),
            SizedBox(width: 8),
            Text('Export PDF'),
          ]),
        ),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.download),
        label: const Text('Export'),
      ),
    );
  }

  // ─── DIALOG PILIH KOLOM EXPORT ───────────────────────
  Future<List<String>?> _showExportColumnDialog() async {
    final allColumns = {
      'No': true,
      'No Registrasi': true,
      'Nama Lengkap': true,
      'Jenis Kelamin': true,
      'NISN': true,
      'NIS': false,
      'NIK': false,
      'Tempat Lahir': false,
      'Tanggal Lahir': false,
      'Agama': false,
      'Sekolah Asal': true,
      'Jurusan 1': true,
      'Jurusan 2': false,
      'Jalur Pendaftaran': true,
      'Cara Daftar': true,
      'Alamat': false,
      'RT': false,
      'RW': false,
      'Kelurahan': false,
      'Kecamatan': false,
      'Kabupaten': false,
      'Propinsi': false,
      'No HP': true,
      'Email': false,
      'No KKS': false,
      'Penerima KPS': false,
      'Nama Ayah': true,
      'Pekerjaan Ayah': false,
      'Pendidikan Ayah': false,
      'Penghasilan Ayah': false,
      'Nama Ibu': true,
      'Pekerjaan Ibu': false,
      'Pendidikan Ibu': false,
      'Penghasilan Ibu': false,
      'Tinggi Badan': false,
      'Berat Badan': false,
      'Tanggal Daftar': true,
    };

    final selected = Map<String, bool>.from(allColumns);

    return showDialog<List<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Pilih Kolom Export'),
          content: SizedBox(
            width: 400,
            height: 500,
            child: Column(
              children: [
                // Select All / Deselect All
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setStateDialog(() {
                        selected.updateAll((_, __) => true);
                      }),
                      child: const Text('Pilih Semua'),
                    ),
                    TextButton(
                      onPressed: () => setStateDialog(() {
                        selected.updateAll((_, __) => false);
                      }),
                      child: const Text('Hapus Semua'),
                    ),
                    const Spacer(),
                    Text(
                      '${selected.values.where((v) => v).length} dipilih',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const Divider(),
                // Daftar Kolom
                Expanded(
                  child: ListView(
                    children: selected.keys.map((col) {
                      return CheckboxListTile(
                        dense: true,
                        title: Text(col, style: const TextStyle(fontSize: 14)),
                        value: selected[col],
                        activeColor: AppTheme.primary,
                        onChanged: (v) =>
                            setStateDialog(() => selected[col] = v ?? false),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final chosen = selected.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .toList();
                if (chosen.isEmpty) return;
                Navigator.pop(ctx, chosen);
              },
              child: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── EXPORT EXCEL ────────────────────────────────────
  Future<void> _exportExcel(List<String> selectedColumns) async {
    final state = context.read<DatabaseBloc>().state;
    if (state is! DatabaseLoaded) return;

    try {
      final excel = Excel.createExcel();
      final sheet = excel['Data Peserta'];

      // Header sesuai pilihan
      for (var i = 0; i < selectedColumns.length; i++) {
        final cell =
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(selectedColumns[i]);
        cell.cellStyle = CellStyle(bold: true);
      }

      // Data
      for (var i = 0; i < state.pesertaList.length; i++) {
        final p = state.pesertaList[i];
        final rowData = _mapPesertaToColumns(p, selectedColumns, i + 1);
        for (var j = 0; j < rowData.length; j++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
              .value = TextCellValue(rowData[j]);
        }
      }

      final bytes = excel.save()!;
      final now = DateTime.now();
      final fileName =
          'data_peserta_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.xlsx';

      if (kIsWeb) {
        // handle web download
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Excel disimpan: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal export: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  // ─── EXPORT PDF ──────────────────────────────────────
  Future<void> _exportPdf(List<String> selectedColumns) async {
    final now = DateTime.now();
    final tanggalCetak =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final namaFile =
        'data_peserta_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final state = context.read<DatabaseBloc>().state;
    if (state is! DatabaseLoaded) return;

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (ctx) => [
            pw.Text('Data Peserta Didik Baru',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Dicetak: $tanggalCetak',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: selectedColumns,
              data: state.pesertaList.asMap().entries.map((e) {
                return _mapPesertaToColumns(
                    e.value, selectedColumns, e.key + 1);
              }).toList(),
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey100),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
        name: namaFile,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal export PDF: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  List<String> _mapPesertaToColumns(
      PesertaModel p, List<String> columns, int no) {
    final map = {
      'No': '$no',
      'No Registrasi': p.noReg ?? '-',
      'Nama Lengkap': p.namaLengkap,
      'Jenis Kelamin': p.jenisKelamin ?? '-',
      'NISN': p.nisn ?? '-',
      'NIS': p.nis ?? '-',
      'NIK': p.nik ?? '-',
      'Tempat Lahir': p.tempatLahir ?? '-',
      'Tanggal Lahir': p.tglLahir ?? '-',
      'Agama': p.agama ?? '-',
      'Sekolah Asal': p.namaSekolahAsal ?? '-',
      'Jurusan 1': p.jurusan1 ?? '-',
      'Jurusan 2': p.jurusan2 ?? '-',
      'Jalur Pendaftaran': p.jalurPendaftaran ?? '-',
      'Cara Daftar': p.caraDaftar,
      'Alamat': p.alamat ?? '-',
      'RT': p.rt ?? '-',
      'RW': p.rw ?? '-',
      'Kelurahan': p.kelurahan ?? '-',
      'Kecamatan': p.kecamatan ?? '-',
      'Kabupaten': p.kabupaten ?? '-',
      'Propinsi': p.propinsi ?? '-',
      'No HP': p.noHp ?? '-',
      'Email': p.email ?? '-',
      'No KKS': p.noKks ?? '-',
      'Penerima KPS': p.penerimaKps ?? '-',
      'Nama Ayah': p.namaAyah ?? '-',
      'Pekerjaan Ayah': p.pekerjaanAyah ?? '-',
      'Pendidikan Ayah': p.pendidikanAyah ?? '-',
      'Penghasilan Ayah': p.penghasilanAyah ?? '-',
      'Nama Ibu': p.namaIbu ?? '-',
      'Pekerjaan Ibu': p.pekerjaanIbu ?? '-',
      'Pendidikan Ibu': p.pendidikanIbu ?? '-',
      'Penghasilan Ibu': p.penghasilanIbu ?? '-',
      'Tinggi Badan': p.tinggiBadan?.toString() ?? '-',
      'Berat Badan': p.beratBadan?.toString() ?? '-',
      'Tanggal Daftar': _formatDate(p.createdAt),
    };
    return columns.map((c) => map[c] ?? '-').toList();
  }

  // ─── ACTIONS ─────────────────────────────────────────
  void _openFormTambah() {
    if (ResponsiveHelper.isDesktop(context)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.9,
            child: const PendaftaranPage(),
          ),
        ),
      );
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const PendaftaranPage()));
    }
  }

  void _openFormEdit(PesertaModel peserta) {
    if (ResponsiveHelper.isDesktop(context)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.9,
            child: PendaftaranPage(peserta: peserta),
          ),
        ),
      ).then((_) => context.read<DatabaseBloc>().add(LoadPeserta()));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PendaftaranPage(peserta: peserta)),
      ).then((_) => context.read<DatabaseBloc>().add(LoadPeserta()));
    }
  }

  void _confirmDelete(PesertaModel peserta) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text(
            'Yakin ingin menghapus data "${peserta.namaLengkap}"?\nData tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DatabaseBloc>().add(DeletePeserta(peserta.id));
              context.read<DashboardBloc>().add(LoadDashboard());
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    context.read<DatabaseBloc>().add(FilterPeserta(
          jurusan: _filterJurusan,
          jalur: _filterJalur,
          jenisKelamin: _filterGender,
        ));
  }

  void _resetFilter() {
    setState(() {
      _filterJurusan = null;
      _filterJalur = null;
      _filterGender = null;
    });
    context.read<DatabaseBloc>().add(LoadPeserta());
  }

  // ─── HELPERS ─────────────────────────────────────────
  String _shortJurusan(String? jurusan) {
    const map = {
      'Manajemen Perkantoran dan Layanan Bisnis': 'MPLB',
      'Pemasaran Bisnis Ritel': 'PBR',
      'Desain Komunikasi Visual': 'DKV',
      'Teknik Kendaraan Ringan': 'TKR',
    };
    return map[jurusan] ?? jurusan ?? '-';
  }

  String _formatDate(String? date) {
    if (date == null) return '-';
    try {
      final dt = DateTime.parse(date);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      return '$day/$month/$year';
    } catch (_) {
      return date;
    }
  }
}

// ─── JALUR BADGE ─────────────────────────────────────
class _JalurBadge extends StatelessWidget {
  final String? jalur;
  const _JalurBadge({this.jalur});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'Prestasi': Colors.orange,
      'Tahfidz': Colors.green,
      'Reguler': AppTheme.primary,
    };
    final color = colors[jalur] ?? AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        jalur ?? '-',
        style:
            TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
