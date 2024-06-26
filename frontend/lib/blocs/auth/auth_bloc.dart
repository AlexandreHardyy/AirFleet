import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/storage/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState(status: AuthStatus.loading, user: null)) {
    on<AuthInitialized>(_onAuthInitialized);
    on<AuthLogOut>(_onAuthLogOut);
  }

  Future<void> _onAuthInitialized(
      AuthInitialized event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final user = await UserStore.getUser();

    emit(state.copyWith(
        status: user != null ? AuthStatus.connected : AuthStatus.disconnected,
        user: user));
  }

  Future<void> _onAuthLogIn(AuthLogIn event, Emitter<AuthState> emit) async {
    final user = await UserStore.getUser();
    emit(state.copyWith(
        status: user != null ? AuthStatus.connected : AuthStatus.disconnected,
        user: user));
  }

  Future<void> _onAuthLogOut(AuthLogOut event, Emitter<AuthState> emit) async {
    UserService.logOut();
    emit(state.copyWith(status: AuthStatus.disconnected));
  }
}
