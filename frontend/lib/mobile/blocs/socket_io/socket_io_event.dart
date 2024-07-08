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

final class SocketIoMakePriceProposal extends SocketIoEvent {
  final int flightId;
  final double price;

  SocketIoMakePriceProposal({required this.flightId, required this.price});
}

final class SocketIoCancelFlight extends SocketIoEvent {
  final int flightId;

  SocketIoCancelFlight({required this.flightId});
}

final class SocketIoFlightTakeoff extends SocketIoEvent {
  final int flightId;

  SocketIoFlightTakeoff({required this.flightId});
}

final class SocketIoUpdatePilotPosition extends SocketIoEvent {
  final int flightId;

  SocketIoUpdatePilotPosition({required this.flightId});
}

final class SocketIoFlightLanding extends SocketIoEvent {
  final int flightId;

  SocketIoFlightLanding({required this.flightId});
}

// TODO: improve to use an event array
final class SocketIoListenEvent extends SocketIoEvent {
  final String eventId;
  final String event;
  final dynamic Function(dynamic) callback;

  SocketIoListenEvent({
    required this.eventId,
    required this.event,
    required this.callback,
  });
}

final class SocketIoStopListeningEvent extends SocketIoEvent {
  final String eventId;

  SocketIoStopListeningEvent({required this.eventId});
}
