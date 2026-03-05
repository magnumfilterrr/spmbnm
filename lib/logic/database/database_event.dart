import 'package:equatable/equatable.dart';

abstract class DatabaseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPeserta extends DatabaseEvent {}

class SearchPeserta extends DatabaseEvent {
  final String keyword;
  SearchPeserta(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class FilterPeserta extends DatabaseEvent {
  final String? jurusan;
  final String? jalur;
  final String? jenisKelamin;

  FilterPeserta({this.jurusan, this.jalur, this.jenisKelamin});

  @override
  List<Object?> get props => [jurusan, jalur, jenisKelamin];
}

class DeletePeserta extends DatabaseEvent {
  final String id;
  DeletePeserta(this.id);

  @override
  List<Object?> get props => [id];
}

class ExportData extends DatabaseEvent {
  final String format; // 'excel' | 'pdf'
  ExportData(this.format);

  @override
  List<Object?> get props => [format];
}