part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthInitialized extends AuthEvent {}
final class AuthLogOut extends AuthEvent {}
final class AuthLogIn extends AuthEvent {}
