part of 'auth_bloc.dart';

enum AuthStatus {
  connected,
  disconnected,
  loading,
  error,
}

class AuthState {
  final User? user;
  final AuthStatus status;

  AuthState({
    required this.user,
    required this.status
  });

  AuthState copyWith({
    User? user,
    AuthStatus? status,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status
    );
  }
}