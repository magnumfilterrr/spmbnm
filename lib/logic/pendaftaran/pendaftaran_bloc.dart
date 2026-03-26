import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spmb_app/data/repositories/peserta_repository.dart';
import 'package:spmb_app/logic/database/database_bloc.dart';
import 'package:spmb_app/logic/database/database_event.dart';
import 'package:spmb_app/logic/pendaftaran/pendaftaran_event.dart';
import 'package:spmb_app/logic/pendaftaran/pendaftaran_state.dart';

class PendaftaranBloc extends Bloc<PendaftaranEvent, PendaftaranState> {
  final PesertaRepository _pesertaRepository;
  final DatabaseBloc _databaseBloc;
  bool _isProcessing = false; // ✅ guard di level bloc

  PendaftaranBloc(this._pesertaRepository, this._databaseBloc)
      : super(PendaftaranInitial()) {
    on<SubmitPendaftaran>(
      _onSubmit,
      transformer: droppable(), // ✅ drop event duplikat
    );
    on<UpdatePendaftaran>(
      _onUpdate,
      transformer: droppable(),
    );
    on<ResetPendaftaran>(_onReset);
  }

  Future<void> _onSubmit(
      SubmitPendaftaran event, Emitter<PendaftaranState> emit) async {
    if (_isProcessing) return; // ✅ double guard
    _isProcessing = true;
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
    } finally {
      _isProcessing = false; // ✅ selalu reset
    }
  }

  Future<void> _onUpdate(
      UpdatePendaftaran event, Emitter<PendaftaranState> emit) async {
    if (_isProcessing) return;
    _isProcessing = true;
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
    } finally {
      _isProcessing = false;
    }
  }

  void _onReset(ResetPendaftaran event, Emitter<PendaftaranState> emit) {
    _isProcessing = false;
    emit(PendaftaranInitial());
  }
}