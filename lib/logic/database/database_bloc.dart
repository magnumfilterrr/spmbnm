import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spmb_app/data/repositories/peserta_repository.dart';
import 'database_event.dart';
import 'database_state.dart';

class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  final PesertaRepository _pesertaRepository;

  DatabaseBloc(this._pesertaRepository) : super(DatabaseInitial()) {
    on<LoadPeserta>(_onLoad);
    on<SearchPeserta>(_onSearch);
    on<FilterPeserta>(_onFilter);
    on<DeletePeserta>(_onDelete);
    on<ExportData>(_onExport);
  }

  Future<void> _onLoad(LoadPeserta event, Emitter<DatabaseState> emit) async {
    emit(DatabaseLoading());
    try {
      final list = await _pesertaRepository.getAllPeserta();
      emit(DatabaseLoaded(list));
    } catch (e) {
      emit(DatabaseError('Gagal memuat data: $e'));
    }
  }

  Future<void> _onSearch(
      SearchPeserta event, Emitter<DatabaseState> emit) async {
    emit(DatabaseLoading());
    try {
      final list = await _pesertaRepository.searchPeserta(event.keyword);
      emit(DatabaseLoaded(list));
    } catch (e) {
      emit(DatabaseError('Gagal mencari data: $e'));
    }
  }

  Future<void> _onFilter(
      FilterPeserta event, Emitter<DatabaseState> emit) async {
    emit(DatabaseLoading());
    try {
      final list = await _pesertaRepository.filterPeserta(
        jurusan: event.jurusan,
        jalur: event.jalur,
        jenisKelamin: event.jenisKelamin,
      );
      emit(DatabaseLoaded(list));
    } catch (e) {
      emit(DatabaseError('Gagal memfilter data: $e'));
    }
  }

  Future<void> _onDelete(
      DeletePeserta event, Emitter<DatabaseState> emit) async {
    try {
      await _pesertaRepository.deletePeserta(event.id);
      add(LoadPeserta()); // reload setelah hapus
    } catch (e) {
      emit(DatabaseError('Gagal menghapus data: $e'));
    }
  }

  Future<void> _onExport(ExportData event, Emitter<DatabaseState> emit) async {
    emit(DatabaseExporting());
    try {
      // Export logic akan diimplementasi di service terpisah
      emit(DatabaseExportSuccess(''));
    } catch (e) {
      emit(DatabaseExportFailure('Gagal export: $e'));
    }
  }
}
