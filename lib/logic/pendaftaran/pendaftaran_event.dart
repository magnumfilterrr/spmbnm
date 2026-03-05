import 'package:equatable/equatable.dart';
import 'package:spmb_app/data/models/beasiswa_model.dart';
import 'package:spmb_app/data/models/peserta_model.dart';
import 'package:spmb_app/data/models/prestasi_model.dart';

abstract class PendaftaranEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitPendaftaran extends PendaftaranEvent {
  final PesertaModel peserta;
  final List<PrestasiModel> prestasi;
  final List<BeasiswaModel> beasiswa;

  SubmitPendaftaran({
    required this.peserta,
    required this.prestasi,
    required this.beasiswa,
  });

  @override
  List<Object?> get props => [peserta, prestasi, beasiswa];
}

class UpdatePendaftaran extends PendaftaranEvent {
  final PesertaModel peserta;
  final List<PrestasiModel> prestasi;
  final List<BeasiswaModel> beasiswa;

  UpdatePendaftaran({
    required this.peserta,
    required this.prestasi,
    required this.beasiswa,
  });

  @override
  List<Object?> get props => [peserta, prestasi, beasiswa];
}

class ResetPendaftaran extends PendaftaranEvent {}