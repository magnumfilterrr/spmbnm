import 'package:equatable/equatable.dart';

abstract class PendaftaranState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PendaftaranInitial extends PendaftaranState {}
class PendaftaranLoading extends PendaftaranState {}

class PendaftaranSuccess extends PendaftaranState {
  final String message;
  PendaftaranSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PendaftaranFailure extends PendaftaranState {
  final String message;
  PendaftaranFailure(this.message);

  @override
  List<Object?> get props => [message];
}