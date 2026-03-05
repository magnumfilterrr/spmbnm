import 'package:equatable/equatable.dart';
import 'package:spmb_app/data/models/peserta_model.dart';

abstract class DatabaseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DatabaseInitial extends DatabaseState {}
class DatabaseLoading extends DatabaseState {}

class DatabaseLoaded extends DatabaseState {
  final List<PesertaModel> pesertaList;
  DatabaseLoaded(this.pesertaList);

  @override
  List<Object?> get props => [pesertaList];
}

class DatabaseError extends DatabaseState {
  final String message;
  DatabaseError(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseExporting extends DatabaseState {}

class DatabaseExportSuccess extends DatabaseState {
  final String filePath;
  DatabaseExportSuccess(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class DatabaseExportFailure extends DatabaseState {
  final String message;
  DatabaseExportFailure(this.message);

  @override
  List<Object?> get props => [message];
}