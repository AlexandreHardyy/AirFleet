part of 'socket_io_bloc.dart';

enum SocketIoStatus {
  initial,
  connected,
  disconnected,
  loading,
  error,
}

class SocketIoState {
  final SocketIoStatus status;
  final Socket? socket;
  final Set<String> listenedEvents;
  final String? errorMessage;

  SocketIoState({
    required this.status,
    this.socket,
    required this.listenedEvents,
    this.errorMessage,
  });

  SocketIoState copyWith({
    SocketIoStatus? status,
    Socket? socket,
    Set<String>? listenedEvents,
    String? errorMessage,
  }) {
    return SocketIoState(
      status: status ?? this.status,
      socket: socket ?? this.socket,
      listenedEvents: listenedEvents ?? this.listenedEvents,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}