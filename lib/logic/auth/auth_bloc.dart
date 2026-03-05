import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spmb_app/data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(event.username, event.password);
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure('Username atau password salah'));
      }
    } catch (e) {
      emit(AuthFailure('Terjadi kesalahan: $e'));
    }
  }

  void _onLogout(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthLoggedOut());
  }
}