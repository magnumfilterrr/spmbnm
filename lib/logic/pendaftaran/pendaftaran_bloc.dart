import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spmb_app/data/repositories/peserta_repository.dart';
import 'package:spmb_app/logic/database/database_bloc.dart';
import 'package:spmb_app/logic/database/database_event.dart';
import 'pendaftaran_event.dart';
import 'pendaftaran_state.dart';

class PendaftaranBloc extends Bloc<PendaftaranEvent, PendaftaranState> {
  final PesertaRepository _pesertaRepository;
   final DatabaseBloc _databaseBloc;

  PendaftaranBloc(this._pesertaRepository, this._databaseBloc) : super(PendaftaranInitial()) {
    on<SubmitPendaftaran>(_onSubmit);
    on<UpdatePendaftaran>(_onUpdate);
    on<ResetPendaftaran>(_onReset);
  }

  Future<void> _onSubmit(SubmitPendaftaran event, Emitter<PendaftaranState> emit) async {
  // Cegah submit kalau masih loading
  if (state is PendaftaranLoading) return;
  
  emit(PendaftaranLoading());
  try {
    await _pesertaRepository.insertPeserta(
      event.peserta,
      prestasi: event.prestasi,
      beasiswa: event.beasiswa,
    );
    _databaseBloc.add(LoadPeserta());
    emit(PendaftaranSuccess('Data berhasil disimpan'));
  } catch (e) {
    emit(PendaftaranFailure('Gagal menyimpan data: $e'));
  }
}

  Future<void> _onUpdate(UpdatePendaftaran event, Emitter<PendaftaranState> emit) async {
    emit(PendaftaranLoading());
    try {
      await _pesertaRepository.updatePeserta(
        event.peserta,
        prestasi: event.prestasi,
        beasiswa: event.beasiswa,
      );
      _databaseBloc.add(LoadPeserta());
      emit(PendaftaranSuccess('Data berhasil diperbarui'));
    } catch (e) {
      emit(PendaftaranFailure('Gagal memperbarui data: $e'));
    }
  }

  void _onReset(ResetPendaftaran event, Emitter<PendaftaranState> emit) {
    emit(PendaftaranInitial());
  }
}