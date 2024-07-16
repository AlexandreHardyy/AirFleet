import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/position.dart';
import 'package:frontend/storage/user.dart';
import 'package:frontend/utils/ticker.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:io' show Platform;

import 'package:toastification/toastification.dart';

part 'socket_io_event.dart';

part 'socket_io_state.dart';

final String? socketIoUrl = kIsWeb
    ? dotenv.env['SOCKET_IO_URL']
    : (Platform.isAndroid
        ? dotenv.env['SOCKET_IO_URL_ANDROID']
        : dotenv.env['SOCKET_IO_URL']);

class SocketIoBloc extends Bloc<SocketIoEvent, SocketIoState> {
  final Ticker _ticker = const Ticker();
  StreamSubscription<int>? tickerSubscription;

  @override
  Future<void> close() {
    tickerSubscription?.cancel();
    return super.close();
  }

  SocketIoBloc()
      : super(
            SocketIoState(status: SocketIoStatus.initial, listenedEvents: {})) {
    on<SocketIoInitialized>(_onSocketIoInitialized);
    on<SocketIoConnected>(_onSocketIoConnected);
    on<SocketIoDisconnected>(_onSocketIoDisconnected);
    on<SocketIoLoading>(_onSocketIoLoading);
    on<SocketIoError>(_onSocketIoError);
    on<SocketIoCreateSession>(_onSocketCreateSession);
    on<SocketIoListenEvent>(_onSocketListenEvent);
    on<SocketIoStopListeningEvent>(_onSocketStopListeningEvent);
  }

  Future<void> _onSocketIoInitialized(
      SocketIoInitialized event, Emitter<SocketIoState> emit) async {
    emit(state.copyWith(status: SocketIoStatus.loading));

    try {
      final bearerToken = await UserStore.getToken();
      final socket = io(
          '$socketIoUrl/flights',
          OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .setExtraHeaders({'Bearer': bearerToken})
              .build());

      socket.onConnect((_) {
        print('Connection established');
      });
      socket.onDisconnect((_) => print('Connection Disconnection'));
      socket.onConnectError((err) => print("Connection error: $err"));
      socket.onError((err) => print("Error: $err"));

      socket.on('error', (data) {
        toastification.show(
          title: Text(data),
          autoCloseDuration: const Duration(seconds: 5),
          primaryColor: CupertinoColors.systemRed,
        );
      });

      emit(state.copyWith(
        // We set the status to disconnected because the socket is not connected yet
        status: SocketIoStatus.disconnected,
        socket: socket,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SocketIoStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSocketIoConnected(
      SocketIoConnected event, Emitter<SocketIoState> emit) {
    emit(state.copyWith(
      status: SocketIoStatus.connected,
      socket: event.socket,
    ));
  }

  void _onSocketIoDisconnected(
      SocketIoDisconnected event, Emitter<SocketIoState> emit) {
    emit(state.copyWith(
      status: SocketIoStatus.disconnected,
    ));
  }

  void _onSocketIoLoading(SocketIoLoading event, Emitter<SocketIoState> emit) {
    emit(state.copyWith(
      status: SocketIoStatus.loading,
    ));
  }

  void _onSocketIoError(SocketIoError event, Emitter<SocketIoState> emit) {
    emit(state.copyWith(
      status: SocketIoStatus.error,
      errorMessage: event.errorMessage,
    ));
  }

  void _onSocketCreateSession(
      SocketIoCreateSession event, Emitter<SocketIoState> emit) {
    state.socket!.emit("createSession", "${event.flightId}");

    emit(state.copyWith(
      status: SocketIoStatus.connected,
    ));
  }

  void updatePilotPosition(int flightId) async {
    final currentPosition = await determinePosition();
    state.socket!.connect();

    final message = {
      'flightId': flightId,
      'latitude': currentPosition.latitude,
      'longitude': currentPosition.longitude,
    };

    state.socket!
        .emit("pilotPositionUpdate", const JsonEncoder().convert(message));
  }

  void startFlightTakeoff(int flightId) {
    print("startFlightTakeoff");
    state.socket!.emit("flightTakeoff", "$flightId");

    tickerSubscription?.cancel();
    tickerSubscription = _ticker
        .tick(interval: 4)
        .listen((duration) => updatePilotPosition(flightId));
  }

  void _onSocketListenEvent(
      SocketIoListenEvent event, Emitter<SocketIoState> emit) {
    if (state.listenedEvents.containsKey(event.eventId)) {
      return;
    }

    state.socket!.on(event.event, event.callback);
    emit(state.copyWith(
      listenedEvents: state.listenedEvents
        ..putIfAbsent(event.eventId, () => event.event),
    ));
  }

  void _onSocketStopListeningEvent(
      SocketIoStopListeningEvent event, Emitter<SocketIoState> emit) {
    if (!state.listenedEvents.containsKey(event.eventId)) {
      return;
    }

    state.socket!.off(state.listenedEvents[event.eventId]!);
    emit(state.copyWith(
      listenedEvents: state.listenedEvents..remove(event.eventId),
    ));
  }
}
