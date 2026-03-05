import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int total;
  final int laki;
  final int perempuan;
  final Map<String, int> perJurusan;
  final Map<String, int> perJalur;

  DashboardLoaded({
    required this.total,
    required this.laki,
    required this.perempuan,
    required this.perJurusan,
    required this.perJalur,
  });

  @override
  List<Object?> get props => [total, laki, perempuan, perJurusan, perJalur];
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}