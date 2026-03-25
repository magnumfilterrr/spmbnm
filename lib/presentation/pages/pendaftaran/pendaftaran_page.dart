import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spmb_app/core/constants/app_strings.dart';
import 'package:spmb_app/core/theme/app_theme.dart';
import 'package:spmb_app/core/utils/responsive_helper.dart';
import 'package:spmb_app/core/utils/validators.dart';
import 'package:spmb_app/data/models/beasiswa_model.dart';
import 'package:spmb_app/data/models/peserta_model.dart';
import 'package:spmb_app/data/models/prestasi_model.dart';
import 'package:spmb_app/data/repositories/peserta_repository.dart';
import 'package:spmb_app/logic/dashboard/dashboard_bloc.dart';
import 'package:spmb_app/logic/dashboard/dashboard_event.dart';
import 'package:spmb_app/logic/pendaftaran/pendaftaran_bloc.dart';
import 'package:spmb_app/logic/pendaftaran/pendaftaran_event.dart';
import 'package:spmb_app/logic/pendaftaran/pendaftaran_state.dart';
import 'package:spmb_app/presentation/pages/pendaftaran/widgets/cetak_kartu.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class PendaftaranPage extends StatefulWidget {
  final PesertaModel? peserta;
  const PendaftaranPage({super.key, this.peserta});

  @override
  State<PendaftaranPage> createState() => _PendaftaranPageState();
}

class _PendaftaranPageState extends State<PendaftaranPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  bool get isEdit => widget.peserta != null;
  bool _isSubmitting = false;
  PesertaModel? _savedPeserta;
  PesertaModel? _lastSubmittedPeserta;

  // ─── CONTROLLERS ─────────────────────────────────────
  // Header
  final _noRegCtrl = TextEditingController();
  final _tingkatCtrl = TextEditingController();
  final _programCtrl = TextEditingController();
  final _namaKolektifCtrl = TextEditingController();

  // Identitas
  final _namaCtrl = TextEditingController();
  final _nisnCtrl = TextEditingController();
  final _nisCtrl = TextEditingController();
  final _noIjazahCtrl = TextEditingController();
  final _noSkhunCtrl = TextEditingController();
  final _noUjianCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _npsnCtrl = TextEditingController();
  final _sekolahAsalCtrl = TextEditingController();
  final _tempatLahirCtrl = TextEditingController();
  final _agamaCtrl = TextEditingController();

  // Alamat
  final _alamatCtrl = TextEditingController();
  final _rtCtrl = TextEditingController();
  final _rwCtrl = TextEditingController();
  final _dusunCtrl = TextEditingController();
  final _kelurahanCtrl = TextEditingController();
  final _kodePosCtrl = TextEditingController();
  final _kecamatanCtrl = TextEditingController();
  final _kabupatenCtrl = TextEditingController();
  final _propinsiCtrl = TextEditingController();

  // Kontak
  final _noTelpCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // KKS/KPS/KIP
  final _noKksCtrl = TextEditingController();
  final _noKpsCtrl = TextEditingController();
  final _noKipCtrl = TextEditingController();
  final _namaDiKipCtrl = TextEditingController();
  final _alasanMenolakKipCtrl = TextEditingController();
  final _noAktaCtrl = TextEditingController();
  final _lintangCtrl = TextEditingController();
  final _bujurCtrl = TextEditingController();

  // Ayah
  final _namaAyahCtrl = TextEditingController();
  final _thnAyahCtrl = TextEditingController();
  final _pekerjaanAyahCtrl = TextEditingController();

  // Ibu
  final _namaIbuCtrl = TextEditingController();
  final _thnIbuCtrl = TextEditingController();
  final _pekerjaanIbuCtrl = TextEditingController();

  // Wali
  final _namaWaliCtrl = TextEditingController();
  final _thnWaliCtrl = TextEditingController();
  final _pekerjaanWaliCtrl = TextEditingController();

  // Periodik
  final _tinggiBadanCtrl = TextEditingController();
  final _beratBadanCtrl = TextEditingController();
  final _jarakSekolahCtrl = TextEditingController();
  final _waktuTempuhCtrl = TextEditingController();
  final _jmlSaudaraCtrl = TextEditingController();

  // ─── DROPDOWN VALUES ─────────────────────────────────
  String? _caraDaftar;
  String? _jalurPendaftaran;
  String? _jurusan1;
  String? _jurusan2;
  String? _jenisKelamin;
  String? _berkebutuhanKhusus;
  String? _jenisTinggal;
  String? _alatTransportasi;
  String? _penerimaKps;
  String? _usulanPip;
  String? _penerimaKip;
  String? _kebutuhanKhususAyah;
  String? _pendidikanAyah;
  String? _penghasilanAyah;
  String? _kebutuhanKhususIbu;
  String? _pendidikanIbu;
  String? _penghasilanIbu;
  String? _pendidikanWali;
  String? _penghasilanWali;

  DateTime? _tglLahir;
  // ✅ Validasi per tab sebelum lanjut
  String? _validateTab(int index) {
    switch (index) {
      case 0:
        if (_caraDaftar == null) return 'Cara Daftar wajib dipilih';
        if (_jalurPendaftaran == null) return 'Jalur Pendaftaran wajib dipilih';
        if (_jurusan1 == null) return 'Jurusan Pilihan 1 wajib dipilih';
        if (_caraDaftar == 'Kolektif' &&
            _namaKolektifCtrl.text.trim().isEmpty) {
          return 'Nama Kolektif wajib diisi';
        }
        return null;

      case 1:
        if (_namaCtrl.text.trim().isEmpty) return 'Nama Lengkap wajib diisi';
        if (_jenisKelamin == null) return 'Jenis Kelamin wajib dipilih';
        if (_nisnCtrl.text.trim().isEmpty) return 'NISN wajib diisi';
        if (_nikCtrl.text.trim().isEmpty) return 'NIK wajib diisi';
        if (_tempatLahirCtrl.text.trim().isEmpty)
          return 'Tempat Lahir wajib diisi';
        if (_tglLahir == null) return 'Tanggal Lahir wajib diisi';
        if (_agamaCtrl.text.trim().isEmpty) return 'Agama wajib diisi';
        return null;

      case 2:
        if (_alamatCtrl.text.trim().isEmpty) return 'Alamat wajib diisi';
        if (_dusunCtrl.text.trim().isEmpty) return 'Dusun wajib diisi';
        if (_kelurahanCtrl.text.trim().isEmpty)
          return 'Kelurahan/Desa wajib diisi';
        if (_kecamatanCtrl.text.trim().isEmpty) return 'Kecamatan wajib diisi';
        if (_kabupatenCtrl.text.trim().isEmpty) return 'Kabupaten wajib diisi';
        if (_propinsiCtrl.text.trim().isEmpty) return 'Provinsi wajib diisi';
        if (_noTelpCtrl.text.trim().isEmpty && _noHpCtrl.text.trim().isEmpty) {
          return 'No. Telepon atau No. HP wajib diisi';
        }
        if (_penerimaKip == null) return 'Status Penerima KIP wajib dipilih';
        return null;

      case 3:
        if (_namaAyahCtrl.text.trim().isEmpty) return 'Nama Ayah wajib diisi';
        if (_namaIbuCtrl.text.trim().isEmpty) return 'Nama Ibu wajib diisi';
        return null;

      default:
        return null;
    }
  }

  // Relasi
  List<PrestasiModel> _prestasiList = [];
  List<BeasiswaModel> _beasiswaList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    if (isEdit) {
      _populateData();
      _loadRelasiData();
    } else {
      _generateNoReg(); // ✅ auto generate untuk form baru
    }
  }

  Future<void> _generateNoReg() async {
    final repo = context.read<PesertaRepository>();
    final noReg = await repo.generateNoReg();
    setState(() {
      _noRegCtrl.text = noReg;
    });
  }

  Future<void> _loadRelasiData() async {
    final repo = context.read<PesertaRepository>();
    final prestasi = await repo.getPrestasiByPeserta(widget.peserta!.id);
    final beasiswa = await repo.getBeasiswaByPeserta(widget.peserta!.id);
    setState(() {
      _prestasiList = prestasi;
      _beasiswaList = beasiswa;
    });
  }

  void _populateData() {
    final p = widget.peserta!;
    _noRegCtrl.text = p.noReg ?? '';
    _tingkatCtrl.text = p.tingkat ?? '';
    _programCtrl.text = p.program ?? '';
    _namaKolektifCtrl.text = p.namaKolektif ?? '';
    _namaCtrl.text = p.namaLengkap;
    _nisnCtrl.text = p.nisn ?? '';
    _nisCtrl.text = p.nis ?? '';
    _noIjazahCtrl.text = p.noSeriIjazah ?? '';
    _noSkhunCtrl.text = p.noSeriSkhun ?? '';
    _noUjianCtrl.text = p.noUjianNasional ?? '';
    _nikCtrl.text = p.nik ?? '';
    _npsnCtrl.text = p.npsn ?? '';
    _sekolahAsalCtrl.text = p.namaSekolahAsal ?? '';
    _tempatLahirCtrl.text = p.tempatLahir ?? '';
    _alamatCtrl.text = p.alamat ?? '';
    _agamaCtrl.text = p.agama ?? '';
    _rtCtrl.text = p.rt ?? '';
    _rwCtrl.text = p.rw ?? '';
    _dusunCtrl.text = p.dusun ?? '';
    _kelurahanCtrl.text = p.kelurahan ?? '';
    _kodePosCtrl.text = p.kodePos ?? '';
    _kecamatanCtrl.text = p.kecamatan ?? '';
    _kabupatenCtrl.text = p.kabupaten ?? '';
    _propinsiCtrl.text = p.propinsi ?? '';
    _noTelpCtrl.text = p.noTelp ?? '';
    _noHpCtrl.text = p.noHp ?? '';
    _emailCtrl.text = p.email ?? '';
    _noKksCtrl.text = p.noKks ?? '';
    _noKpsCtrl.text = p.noKps ?? '';
    _noKipCtrl.text = p.noKip ?? '';
    _namaDiKipCtrl.text = p.namaDiKip ?? '';
    _alasanMenolakKipCtrl.text = p.alasanMenolakKip ?? '';
    _noAktaCtrl.text = p.noRegistrasiAkta ?? '';
    _lintangCtrl.text = p.lintang ?? '';
    _bujurCtrl.text = p.bujur ?? '';
    _namaAyahCtrl.text = p.namaAyah ?? '';
    _thnAyahCtrl.text = p.thnLahirAyah ?? '';
    _pekerjaanAyahCtrl.text = p.pekerjaanAyah ?? '';
    _namaIbuCtrl.text = p.namaIbu ?? '';
    _thnIbuCtrl.text = p.thnLahirIbu ?? '';
    _pekerjaanIbuCtrl.text = p.pekerjaanIbu ?? '';
    _namaWaliCtrl.text = p.namaWali ?? '';
    _thnWaliCtrl.text = p.thnLahirWali ?? '';
    _pekerjaanWaliCtrl.text = p.pekerjaanWali ?? '';
    _tinggiBadanCtrl.text = p.tinggiBadan?.toString() ?? '';
    _beratBadanCtrl.text = p.beratBadan?.toString() ?? '';
    _jarakSekolahCtrl.text = p.jarakSekolah?.toString() ?? '';
    _waktuTempuhCtrl.text = p.waktuTempuh?.toString() ?? '';
    _jmlSaudaraCtrl.text = p.jmlSaudara?.toString() ?? '';

    _caraDaftar = p.caraDaftar.isEmpty ? null : p.caraDaftar;
    _jalurPendaftaran = p.jalurPendaftaran;
    _jurusan1 = p.jurusan1;
    _jurusan2 = p.jurusan2;
    _jenisKelamin = p.jenisKelamin;
    _berkebutuhanKhusus = p.berkebutuhanKhusus;
    _jenisTinggal = p.jenisTinggal;
    _alatTransportasi = p.alatTransportasi;
    _penerimaKps = p.penerimaKps;
    _usulanPip = p.usulanPip;
    _penerimaKip = p.penerimaKip;
    _kebutuhanKhususAyah = p.kebutuhanKhususAyah;
    _pendidikanAyah = p.pendidikanAyah;
    _penghasilanAyah = p.penghasilanAyah;
    _kebutuhanKhususIbu = p.kebutuhanKhususIbu;
    _pendidikanIbu = p.pendidikanIbu;
    _penghasilanIbu = p.penghasilanIbu;
    _pendidikanWali = p.pendidikanWali;
    _penghasilanWali = p.penghasilanWali;

    if (p.tglLahir != null) {
      _tglLahir = DateTime.tryParse(p.tglLahir!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // dispose all controllers
    for (final c in [
      _noRegCtrl,
      _tingkatCtrl,
      _programCtrl,
      _namaKolektifCtrl,
      _namaCtrl,
      _nisnCtrl,
      _nisCtrl,
      _noIjazahCtrl,
      _noSkhunCtrl,
      _noUjianCtrl,
      _nikCtrl,
      _npsnCtrl,
      _sekolahAsalCtrl,
      _tempatLahirCtrl,
      _agamaCtrl,
      _alamatCtrl,
      _rtCtrl,
      _rwCtrl,
      _dusunCtrl,
      _kelurahanCtrl,
      _kodePosCtrl,
      _kecamatanCtrl,
      _kabupatenCtrl,
      _propinsiCtrl,
      _noTelpCtrl,
      _noHpCtrl,
      _emailCtrl,
      _noKksCtrl,
      _noKpsCtrl,
      _noKipCtrl,
      _namaDiKipCtrl,
      _alasanMenolakKipCtrl,
      _noAktaCtrl,
      _lintangCtrl,
      _bujurCtrl,
      _namaAyahCtrl,
      _thnAyahCtrl,
      _pekerjaanAyahCtrl,
      _namaIbuCtrl,
      _thnIbuCtrl,
      _pekerjaanIbuCtrl,
      _namaWaliCtrl,
      _thnWaliCtrl,
      _pekerjaanWaliCtrl,
      _tinggiBadanCtrl,
      _beratBadanCtrl,
      _jarakSekolahCtrl,
      _waktuTempuhCtrl,
      _jmlSaudaraCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;

    // ✅ Validasi semua tab wajib sebelum simpan
    final validasiTab = {
      'Data Umum': _validateTab(0),
      'Identitas': _validateTab(1),
      'Alamat & Kontak': _validateTab(2),
      'Data Orang Tua': _validateTab(3),
    };

    // Cek apakah ada error
    for (final entry in validasiTab.entries) {
      if (entry.value != null) {
        // ✅ Langsung pindah ke tab yang error
        final tabIndex = validasiTab.keys.toList().indexOf(entry.key);
        _tabController.animateTo(tabIndex);
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${entry.key}: ${entry.value}',
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        return; // ✅ stop submit
      }
    }

    // ✅ Semua validasi lolos, lanjut simpan
    setState(() => _isSubmitting = true);

    final now = DateTime.now().toIso8601String();
    final id = isEdit ? widget.peserta!.id : const Uuid().v4();

    final prestasiWithId = _prestasiList
        .map((p) => PrestasiModel(
              id: p.id,
              pesertaId: id,
              jenis: p.jenis,
              tingkat: p.tingkat,
              namaPrestasi: p.namaPrestasi,
              tahun: p.tahun,
              penyelenggara: p.penyelenggara,
            ))
        .toList();

    final beasiswaWithId = _beasiswaList
        .map((b) => BeasiswaModel(
              id: b.id,
              pesertaId: id,
              jenis: b.jenis,
              penyelenggara: b.penyelenggara,
              tahunMulai: b.tahunMulai,
              tahunSelesai: b.tahunSelesai,
            ))
        .toList();

    final peserta = PesertaModel(
      id: id,
      tanggal: now.substring(0, 10),
      noReg: _noRegCtrl.text,
      tingkat: _tingkatCtrl.text,
      program: _programCtrl.text,
      caraDaftar: _caraDaftar ?? '',
      namaKolektif: _caraDaftar == 'Kolektif' ? _namaKolektifCtrl.text : null,
      jalurPendaftaran: _jalurPendaftaran,
      jurusan1: _jurusan1,
      jurusan2: _jurusan2,
      namaLengkap: _namaCtrl.text,
      jenisKelamin: _jenisKelamin,
      nisn: _nisnCtrl.text,
      nis: _nisCtrl.text,
      noSeriIjazah: _noIjazahCtrl.text,
      noSeriSkhun: _noSkhunCtrl.text,
      noUjianNasional: _noUjianCtrl.text,
      nik: _nikCtrl.text,
      npsn: _npsnCtrl.text,
      namaSekolahAsal: _sekolahAsalCtrl.text,
      tempatLahir: _tempatLahirCtrl.text,
      tglLahir: _tglLahir?.toIso8601String().substring(0, 10),
      agama: _agamaCtrl.text,
      berkebutuhanKhusus: _berkebutuhanKhusus,
      alamat: _alamatCtrl.text,
      rt: _rtCtrl.text,
      rw: _rwCtrl.text,
      dusun: _dusunCtrl.text,
      kelurahan: _kelurahanCtrl.text,
      kodePos: _kodePosCtrl.text,
      kecamatan: _kecamatanCtrl.text,
      kabupaten: _kabupatenCtrl.text,
      propinsi: _propinsiCtrl.text,
      alatTransportasi: _alatTransportasi,
      jenisTinggal: _jenisTinggal,
      noTelp: _noTelpCtrl.text,
      noHp: _noHpCtrl.text,
      email: _emailCtrl.text,
      noKks: _noKksCtrl.text,
      penerimaKps: _penerimaKps,
      noKps: _noKpsCtrl.text,
      usulanPip: _usulanPip,
      penerimaKip: _penerimaKip,
      noKip: _noKipCtrl.text,
      namaDiKip: _namaDiKipCtrl.text,
      alasanMenolakKip: _alasanMenolakKipCtrl.text,
      noRegistrasiAkta: _noAktaCtrl.text,
      lintang: _lintangCtrl.text,
      bujur: _bujurCtrl.text,
      namaAyah: _namaAyahCtrl.text,
      thnLahirAyah: _thnAyahCtrl.text,
      kebutuhanKhususAyah: _kebutuhanKhususAyah,
      pekerjaanAyah: _pekerjaanAyahCtrl.text,
      pendidikanAyah: _pendidikanAyah,
      penghasilanAyah: _penghasilanAyah,
      namaIbu: _namaIbuCtrl.text,
      thnLahirIbu: _thnIbuCtrl.text,
      kebutuhanKhususIbu: _kebutuhanKhususIbu,
      pekerjaanIbu: _pekerjaanIbuCtrl.text,
      pendidikanIbu: _pendidikanIbu,
      penghasilanIbu: _penghasilanIbu,
      namaWali: _namaWaliCtrl.text,
      thnLahirWali: _thnWaliCtrl.text,
      pekerjaanWali: _pekerjaanWaliCtrl.text,
      pendidikanWali: _pendidikanWali,
      penghasilanWali: _penghasilanWali,
      tinggiBadan: double.tryParse(_tinggiBadanCtrl.text),
      beratBadan: double.tryParse(_beratBadanCtrl.text),
      jarakSekolah: double.tryParse(_jarakSekolahCtrl.text),
      waktuTempuh: int.tryParse(_waktuTempuhCtrl.text),
      jmlSaudara: int.tryParse(_jmlSaudaraCtrl.text),
      createdAt: isEdit ? widget.peserta!.createdAt : now,
      updatedAt: now,
    );

    _lastSubmittedPeserta = peserta;

    if (isEdit) {
      context.read<PendaftaranBloc>().add(UpdatePendaftaran(
            peserta: peserta,
            prestasi: prestasiWithId,
            beasiswa: beasiswaWithId,
          ));
    } else {
      context.read<PendaftaranBloc>().add(SubmitPendaftaran(
            peserta: peserta,
            prestasi: prestasiWithId,
            beasiswa: beasiswaWithId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PendaftaranBloc, PendaftaranState>(
      listener: (context, state) {
        if (state is PendaftaranSuccess) {
          setState(() {
            _isSubmitting = false;
            // ✅ simpan peserta yang baru disimpan
            if (!isEdit) _savedPeserta = _lastSubmittedPeserta;
          });
          context.read<DashboardBloc>().add(LoadDashboard());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          if (isEdit)
            Navigator.pop(context);
          else {
            _formKey.currentState?.reset();
            context.read<PendaftaranBloc>().add(ResetPendaftaran());
          }
        } else if (state is PendaftaranFailure) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildFormHeader(),
              _buildTabBar(),
              Expanded(child: _buildTabViews()),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── FORM HEADER ─────────────────────────────────────
  Widget _buildFormHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.app_registration,
                  color: AppTheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                isEdit ? 'Edit Data Peserta' : 'Form Pendaftaran',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Formulir Peserta Didik Baru',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── TAB BAR ─────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: AppTheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primary,
        tabs: const [
          Tab(text: 'Data Umum'),
          Tab(text: 'Identitas'),
          Tab(text: 'Alamat & Kontak'),
          Tab(text: 'Data Orang Tua'),
          Tab(text: 'Data Periodik'),
          Tab(text: 'Prestasi & Beasiswa'),
        ],
      ),
    );
  }

  // ─── TAB VIEWS ───────────────────────────────────────
  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTabUmum(),
        _buildTabIdentitas(),
        _buildTabAlamat(),
        _buildTabOrangTua(),
        _buildTabPeriodik(),
        _buildTabPrestasi(),
      ],
    );
  }

  // ─── TAB 1: DATA UMUM ────────────────────────────────
  Widget _buildTabUmum() {
    return _TabWrapper(children: [
      _SectionTitle('Informasi Pendaftaran'),
      _buildRow([
        TextFormField(
          controller: _noRegCtrl,
          readOnly: true, // ✅ tidak bisa diedit manual
          decoration: InputDecoration(
            labelText: 'No. Registrasi',
            filled: true,
            fillColor: AppTheme.primary.withOpacity(0.05),
            suffixIcon: const Icon(
              Icons.lock_outline,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        // _buildTextField(_tingkatCtrl, 'Tingkat'),
        // _buildTextField(
        //   _programCtrl,
        //   'Program',
        //   isRequired: true,
        // ),
      ]),
      _buildRow([
        _buildDropdown('Cara Daftar', AppStrings.caraDaftar, _caraDaftar,
            (v) => setState(() => _caraDaftar = v)),
        _buildDropdown('Jalur Pendaftaran', AppStrings.jalurPendaftaran,
            _jalurPendaftaran, (v) => setState(() => _jalurPendaftaran = v),
            isRequired: true),
      ]),
      if (_caraDaftar == 'Kolektif') ...[
        _buildTextField(_namaKolektifCtrl, 'Nama Kolektif', isRequired: true),
      ],
      _SectionTitle('Pilihan Jurusan'),
      _buildRow([
        _buildDropdown('Jurusan Pilihan 1', AppStrings.jurusan, _jurusan1,
            (v) => setState(() => _jurusan1 = v),
            isRequired: true),
        _buildDropdown('Jurusan Pilihan 2', AppStrings.jurusan, _jurusan2,
            (v) => setState(() => _jurusan2 = v)),
      ]),
    ]);
  }

  // ─── TAB 2: IDENTITAS ────────────────────────────────
  Widget _buildTabIdentitas() {
    return _TabWrapper(children: [
      _SectionTitle('Identitas Peserta Didik'),
      _buildTextField(_namaCtrl, 'Nama Lengkap', isRequired: true),
      _buildRow([
        _buildDropdown('Jenis Kelamin', ['L', 'P'], _jenisKelamin,
            (v) => setState(() => _jenisKelamin = v),
            isRequired: true),
        TextFormField(
          controller: _nisnCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10), // ✅ max 10
          ],
          decoration: const InputDecoration(labelText: 'NISN *'),
          validator: (v) {
            if (v == null || v.isEmpty) return 'NISN wajib diisi';
            if (v.length != 10) return 'NISN harus 10 digit';
            return null;
          },
        ),

        // _buildTextField(_nisnCtrl, 'NISN',
        //     isRequired: true,
        //     inputType: TextInputType.number,
        //     validator: Validators.nisn),
        _buildTextField(_nisCtrl, 'NIS', inputType: TextInputType.number),
      ]),
      _buildRow([
        _buildTextField(_noIjazahCtrl, 'No. Seri Ijazah'),
        _buildTextField(_noSkhunCtrl, 'No. Seri SKHUN'),
        _buildTextField(_noUjianCtrl, 'No. Ujian Nasional'),
      ]),
      _buildRow([
        TextFormField(
          controller: _nikCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16), // ✅ max 16
          ],
          decoration: const InputDecoration(labelText: 'NIK (KTP) *'),
          validator: (v) {
            if (v == null || v.isEmpty) return 'NIK wajib diisi';
            if (v.length != 16) return 'NIK harus 16 digit';
            return null;
          },
        ),
        // _buildTextField(_nikCtrl, 'NIK (KTP)',
        //     isRequired: true, inputType: TextInputType.number),
        _buildTextField(_npsnCtrl, 'NPSN Sekolah Asal'),
        _buildTextField(_sekolahAsalCtrl, 'Nama Sekolah Asal'),
      ]),
      _buildRow([
        _buildTextField(
          _tempatLahirCtrl,
          'Tempat Lahir',
          isRequired: true,
        ),
        _buildDatePicker('Tanggal Lahir'),
      ]),
      _buildRow([
        _buildDropdown(
          'Agama',
          AppStrings.agama,
          _agamaCtrl.text.isEmpty ? null : _agamaCtrl.text,
          (v) => setState(() => _agamaCtrl.text = v ?? ''),
          isRequired: true,
        ),
        _buildDropdown(
            'Berkebutuhan Khusus',
            ['Tidak', 'Ya'],
            _berkebutuhanKhusus,
            (v) => setState(() => _berkebutuhanKhusus = v)),
      ]),
      _SectionTitle('Dokumen'),
      _buildRow([
        _buildTextField(_noAktaCtrl, 'No. Registrasi Akta Lahir'),
        _buildTextField(_lintangCtrl, 'Lintang'),
        _buildTextField(_bujurCtrl, 'Bujur'),
      ]),
    ]);
  }

  // ─── TAB 3: ALAMAT & KONTAK ──────────────────────────
  Widget _buildTabAlamat() {
    return _TabWrapper(children: [
      _SectionTitle('Alamat Tempat Tinggal'),
      _buildTextField(_alamatCtrl, 'Alamat Lengkap',
          isRequired: true, maxLines: 2),
      _buildRow([
        _buildTextField(_rtCtrl, 'RT'),
        _buildTextField(_rwCtrl, 'RW'),
        _buildTextField(
          _dusunCtrl,
          'Dusun',
          isRequired: true,
        ),
      ]),
      _buildRow([
        _buildTextField(
          _kelurahanCtrl,
          'Kelurahan/Desa',
          isRequired: true,
        ),
        _buildTextField(_kodePosCtrl, 'Kode Pos',
            inputType: TextInputType.number),
      ]),
      _buildRow([
        _buildTextField(
          _kecamatanCtrl,
          'Kecamatan',
          isRequired: true,
        ),
        _buildTextField(
          _kabupatenCtrl,
          'Kabupaten/Kota',
          isRequired: true,
        ),
        _buildTextField(
          _propinsiCtrl,
          'Propinsi',
          isRequired: true,
        ),
      ]),
      _SectionTitle('Transportasi & Tinggal'),
      _buildRow([
        _buildDropdown('Alat Transportasi', AppStrings.alatTransportasi,
            _alatTransportasi, (v) => setState(() => _alatTransportasi = v)),
        _buildDropdown('Jenis Tinggal', AppStrings.jenisTinggal, _jenisTinggal,
            (v) => setState(() => _jenisTinggal = v)),
      ]),
      _SectionTitle('Kontak'),
      _buildRow([
        _buildTextField(_noTelpCtrl, 'No. Telepon Rumah',
            isRequired: true, inputType: TextInputType.phone),
        _buildTextField(_noHpCtrl, 'No. HP', inputType: TextInputType.phone),
        _buildTextField(_emailCtrl, 'Email',
            inputType: TextInputType.emailAddress, validator: Validators.email),
      ]),
      _SectionTitle('KKS / KPS / KIP'),
      _buildTextField(_noKksCtrl, 'No. KKS'),
      _buildRow([
        _buildDropdown(
          'Penerima KPS',
          ['Ya', 'Tidak'],
          _penerimaKps,
          (v) => setState(() => _penerimaKps = v),
        ),
        _buildTextField(_noKpsCtrl, 'No. KPS'),
      ]),
      _buildRow([
        _buildDropdown('Usulan PIP dari Sekolah', ['Ya', 'Tidak'], _usulanPip,
            (v) => setState(() => _usulanPip = v)),
        _buildDropdown('Penerima KIP', ['Ya', 'Tidak'], _penerimaKip,
            (v) => setState(() => _penerimaKip = v),
            isRequired: true),
      ]),
      if (_penerimaKip == 'Ya') ...[
        _buildRow([
          _buildTextField(_noKipCtrl, 'No. KIP'),
          _buildTextField(_namaDiKipCtrl, 'Nama Tertera di KIP'),
        ]),
      ],
      if (_penerimaKip == 'Tidak') ...[
        _buildTextField(_alasanMenolakKipCtrl, 'Alasan Menolak KIP'),
      ],
    ]);
  }

  // ─── TAB 4: DATA ORANG TUA ───────────────────────────
  Widget _buildTabOrangTua() {
    return _TabWrapper(children: [
      _SectionTitle('Data Ayah Kandung'),
      _buildRow([
        _buildTextField(
          _namaAyahCtrl,
          'Nama Ayah',
          isRequired: true,
        ),
        _buildTextField(_thnAyahCtrl, 'Tahun Lahir',
            inputType: TextInputType.number),
      ]),
      _buildRow([
        _buildDropdown(
            'Berkebutuhan Khusus',
            ['Tidak', 'Ya'],
            _kebutuhanKhususAyah,
            (v) => setState(() => _kebutuhanKhususAyah = v)),
        _buildTextField(_pekerjaanAyahCtrl, 'Pekerjaan'),
      ]),
      _buildRow([
        _buildDropdown('Pendidikan', AppStrings.pendidikan, _pendidikanAyah,
            (v) => setState(() => _pendidikanAyah = v)),
        _buildDropdown('Penghasilan Bulanan', AppStrings.penghasilan,
            _penghasilanAyah, (v) => setState(() => _penghasilanAyah = v)),
      ]),
      _SectionTitle('Data Ibu Kandung'),
      _buildRow([
        _buildTextField(
          _namaIbuCtrl,
          'Nama Ibu',
          isRequired: true,
        ),
        _buildTextField(_thnIbuCtrl, 'Tahun Lahir',
            inputType: TextInputType.number),
      ]),
      _buildRow([
        _buildDropdown(
            'Berkebutuhan Khusus',
            ['Tidak', 'Ya'],
            _kebutuhanKhususIbu,
            (v) => setState(() => _kebutuhanKhususIbu = v)),
        _buildTextField(_pekerjaanIbuCtrl, 'Pekerjaan'),
      ]),
      _buildRow([
        _buildDropdown('Pendidikan', AppStrings.pendidikan, _pendidikanIbu,
            (v) => setState(() => _pendidikanIbu = v)),
        _buildDropdown('Penghasilan Bulanan', AppStrings.penghasilan,
            _penghasilanIbu, (v) => setState(() => _penghasilanIbu = v)),
      ]),
      _SectionTitle('Data Wali'),
      _buildRow([
        _buildTextField(_namaWaliCtrl, 'Nama Wali'),
        _buildTextField(_thnWaliCtrl, 'Tahun Lahir',
            inputType: TextInputType.number),
      ]),
      _buildRow([
        _buildTextField(_pekerjaanWaliCtrl, 'Pekerjaan'),
        _buildDropdown('Pendidikan', AppStrings.pendidikan, _pendidikanWali,
            (v) => setState(() => _pendidikanWali = v)),
      ]),
// ✅ Pisah penghasilan ke row sendiri agar tidak overflow
      _buildRow([
        _buildDropdown('Penghasilan', AppStrings.penghasilan, _penghasilanWali,
            (v) => setState(() => _penghasilanWali = v)),
      ]),
    ]);
  }

  // ─── TAB 5: DATA PERIODIK ────────────────────────────
  Widget _buildTabPeriodik() {
    return _TabWrapper(children: [
      _SectionTitle('Data Fisik'),
      _buildRow([
        _buildTextField(_tinggiBadanCtrl, 'Tinggi Badan (cm)',
            inputType: TextInputType.number),
        _buildTextField(_beratBadanCtrl, 'Berat Badan (kg)',
            inputType: TextInputType.number),
      ]),
      _SectionTitle('Jarak & Waktu ke Sekolah'),
      _buildRow([
        _buildTextField(_jarakSekolahCtrl, 'Jarak (km)',
            inputType: TextInputType.number),
        _buildTextField(_waktuTempuhCtrl, 'Waktu Tempuh (menit)',
            inputType: TextInputType.number),
      ]),
      _SectionTitle('Lainnya'),
      _buildTextField(_jmlSaudaraCtrl, 'Jumlah Saudara Kandung',
          inputType: TextInputType.number),
    ]);
  }

  // ─── TAB 6: PRESTASI & BEASISWA ──────────────────────
  Widget _buildTabPrestasi() {
    final pesertaUntukCetak = isEdit ? widget.peserta : _savedPeserta;
    return _TabWrapper(children: [
      // Prestasi
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _SectionTitle('Data Prestasi'),
          TextButton.icon(
            onPressed: _addPrestasi,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
        ],
      ),
      if (_prestasiList.isEmpty)
        const _EmptyState(message: 'Belum ada data prestasi')
      else
        ..._prestasiList.asMap().entries.map((e) => _PrestasiCard(
              prestasi: e.value,
              onDelete: () => setState(() => _prestasiList.removeAt(e.key)),
            )),

      const SizedBox(height: 16),

      // Beasiswa
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _SectionTitle('Data Beasiswa'),
          TextButton.icon(
            onPressed: _addBeasiswa,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
        ],
      ),
      if (_beasiswaList.isEmpty)
        const _EmptyState(message: 'Belum ada data beasiswa')
      else
        ..._beasiswaList.asMap().entries.map((e) => _BeasiswaCard(
              beasiswa: e.value,
              onDelete: () => setState(() => _beasiswaList.removeAt(e.key)),
            )),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 8),

      // ✅ Cetak Kartu

      if (pesertaUntukCetak != null) ...[
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.print, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text(
              'Kartu Peserta',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => CetakKartu.cetak(context, pesertaUntukCetak),
              icon: const Icon(Icons.print),
              label: const Text('Cetak Kartu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ] else ...[
        const Divider(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Simpan data terlebih dahulu untuk bisa mencetak kartu peserta.',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    ]);
  }

  // ─── BOTTOM BAR ──────────────────────────────────────
  Widget _buildBottomBar() {
    final isLastTab = _tabController.index == 5;
    final isFirstTab = _tabController.index == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali
          isFirstTab
              ? const SizedBox()
              : OutlinedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(_tabController.index - 1);
                    setState(() {});
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali'),
                ),

          Row(
            children: [
              if (isEdit && isLastTab)
                TextButton(
                  onPressed:
                      _isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              const SizedBox(width: 12),
              isLastTab
                  ? ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isSubmitting
                            ? 'Menyimpan...'
                            : isEdit
                                ? 'Simpan Perubahan'
                                : 'Simpan Data',
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        // ✅ Validasi dulu sebelum lanjut
                        final error = _validateTab(_tabController.index);
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(error)),
                                ],
                              ),
                              backgroundColor: AppTheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return; // ✅ stop, tidak pindah tab
                        }
                        // Lanjut ke tab berikutnya
                        _tabController.animateTo(_tabController.index + 1);
                        setState(() {});
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Lanjut'),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── HELPER BUILDERS ─────────────────────────────────
  Widget _buildRow(List<Widget> children) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    if (!isDesktop || children.length == 1) {
      return Column(
        children: children
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c,
                ))
            .toList(),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: c,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    bool isRequired = false,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      maxLines: maxLines,
      inputFormatters: inputType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
      ),
      validator: isRequired
          ? (v) => Validators.required(v, fieldName: label)
          : validator,
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    void Function(String?) onChanged, {
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator:
          isRequired ? (v) => v == null ? '$label harus dipilih' : null : null,
    );
  }

  Widget _buildDatePicker(String label) {
    // ✅ Format tanggal manual tanpa locale
    String formatTanggal(DateTime dt) {
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

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _tglLahir ?? DateTime(2005),
          firstDate: DateTime(1990),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _tglLahir = picked);
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Tanggal Lahir',
            suffixIcon: Icon(Icons.calendar_today_outlined),
          ),
          controller: TextEditingController(
            text: _tglLahir != null ? formatTanggal(_tglLahir!) : '',
          ),
        ),
      ),
    );
  }

  // ─── DIALOG PRESTASI ─────────────────────────────────
  void _addPrestasi() {
    final jenisCtrl = TextEditingController();
    final tingkatCtrl = TextEditingController();
    final namaCtrl = TextEditingController();
    final tahunCtrl = TextEditingController();
    final penyelenggaraCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Prestasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: jenisCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Jenis Prestasi')),
              const SizedBox(height: 8),
              TextField(
                  controller: tingkatCtrl,
                  decoration: const InputDecoration(labelText: 'Tingkat')),
              const SizedBox(height: 8),
              TextField(
                  controller: namaCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nama Prestasi')),
              const SizedBox(height: 8),
              TextField(
                  controller: tahunCtrl,
                  decoration: const InputDecoration(labelText: 'Tahun'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(
                  controller: penyelenggaraCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Penyelenggara')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _prestasiList.add(PrestasiModel(
                  pesertaId: widget.peserta?.id ?? 'temp',
                  jenis: jenisCtrl.text,
                  tingkat: tingkatCtrl.text,
                  namaPrestasi: namaCtrl.text,
                  tahun: tahunCtrl.text,
                  penyelenggara: penyelenggaraCtrl.text,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ─── DIALOG BEASISWA ─────────────────────────────────
  void _addBeasiswa() {
    final jenisCtrl = TextEditingController();
    final penyelenggaraCtrl = TextEditingController();
    final tahunMulaiCtrl = TextEditingController();
    final tahunSelesaiCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Beasiswa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: jenisCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Jenis Beasiswa')),
              const SizedBox(height: 8),
              TextField(
                  controller: penyelenggaraCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Penyelenggara/Sumber')),
              const SizedBox(height: 8),
              TextField(
                  controller: tahunMulaiCtrl,
                  decoration: const InputDecoration(labelText: 'Tahun Mulai'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(
                  controller: tahunSelesaiCtrl,
                  decoration: const InputDecoration(labelText: 'Tahun Selesai'),
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _beasiswaList.add(BeasiswaModel(
                  pesertaId: widget.peserta?.id ?? 'temp',
                  jenis: jenisCtrl.text,
                  penyelenggara: penyelenggaraCtrl.text,
                  tahunMulai: tahunMulaiCtrl.text,
                  tahunSelesai: tahunSelesaiCtrl.text,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

// ─── REUSABLE WIDGETS ─────────────────────────────────

class _TabWrapper extends StatelessWidget {
  final List<Widget> children;
  const _TabWrapper({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary)),
          const Divider(color: AppTheme.border),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child:
          Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
    );
  }
}

class _PrestasiCard extends StatelessWidget {
  final PrestasiModel prestasi;
  final VoidCallback onDelete;
  const _PrestasiCard({required this.prestasi, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.emoji_events, color: AppTheme.primary),
        title: Text(prestasi.namaPrestasi ?? '-'),
        subtitle: Text(
            '${prestasi.jenis ?? ''} • ${prestasi.tingkat ?? ''} • ${prestasi.tahun ?? ''}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _BeasiswaCard extends StatelessWidget {
  final BeasiswaModel beasiswa;
  final VoidCallback onDelete;
  const _BeasiswaCard({required this.beasiswa, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.card_giftcard, color: AppTheme.primary),
        title: Text(beasiswa.jenis ?? '-'),
        subtitle: Text(
            '${beasiswa.penyelenggara ?? ''} • ${beasiswa.tahunMulai ?? ''} - ${beasiswa.tahunSelesai ?? ''}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
