import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spmb_app/data/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardBloc(this._dashboardRepository) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
  }

  Future<void> _onLoad(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final stats = await _dashboardRepository.getDashboardStats();
      emit(DashboardLoaded(
        total: stats['total'],
        laki: stats['laki'],
        perempuan: stats['perempuan'],
        perJurusan: Map<String, int>.from(stats['per_jurusan']),
        perJalur: Map<String, int>.from(stats['per_jalur']),
      ));
    } catch (e) {
      emit(DashboardError('Gagal memuat data: $e'));
    }
  }
}