part of 'socket_io_bloc.dart';

@immutable
sealed class SocketIoEvent {}

final class SocketIoInitialized extends SocketIoEvent {}

final class SocketIoConnected extends SocketIoEvent {
  final Socket socket;

  SocketIoConnected({required this.socket});
}

final class SocketIoDisconnected extends SocketIoEvent {}

final class SocketIoLoading extends SocketIoEvent {}

final class SocketIoError extends SocketIoEvent {
  final String errorMessage;

  SocketIoError({required this.errorMessage});
}

final class SocketIoCreateSession extends SocketIoEvent {
  final int flightId;

  SocketIoCreateSession({required this.flightId});
}

final class SocketIoListenEvent extends SocketIoEvent {
  final String event;
  final dynamic Function(dynamic) callback;

  SocketIoListenEvent({required this.event, required this.callback});
}