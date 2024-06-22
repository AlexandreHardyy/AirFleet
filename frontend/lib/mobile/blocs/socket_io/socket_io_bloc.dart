import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/storage/user.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:io' show Platform;

part 'socket_io_event.dart';

part 'socket_io_state.dart';

final String? socketIoUrl = kIsWeb ? dotenv.env['SOCKET_IO_URL'] : (Platform.isAndroid ? dotenv.env['SOCKET_IO_URL_ANDROID'] : dotenv.env['SOCKET_IO_URL']);

class SocketIoBloc extends Bloc<SocketIoEvent, SocketIoState> {
  SocketIoBloc()
      : super(
            SocketIoState(status: SocketIoStatus.initial, listenedEvents: {})) {
    on<SocketIoInitialized>(_onSocketIoInitialized);
    on<SocketIoConnected>(_onSocketIoConnected);
    on<SocketIoDisconnected>(_onSocketIoDisconnected);
    on<SocketIoLoading>(_onSocketIoLoading);
    on<SocketIoError>(_onSocketIoError);
    on<SocketIoCreateSession>(_onSocketCreateSession);
    on<SocketIoMakePriceProposal>(_onSocketMakePriceProposal);
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
              .disableAutoConnect()
              .setExtraHeaders({'Bearer': bearerToken})
              .build());
      socket.onConnect((_) {
        print('Connection established');
      });
      socket.onDisconnect((_) => print('Connection Disconnection'));
      socket.onConnectError((err) => print(err));
      socket.onError((err) => print(err));

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
    state.socket!.connect();
    state.socket!.emit("createSession", "${event.flightId}");

    emit(state.copyWith(
      status: SocketIoStatus.connected,
    ));
  }

  void _onSocketMakePriceProposal(
      SocketIoMakePriceProposal event, Emitter<SocketIoState> emit) {
    state.socket!.connect();

    final message = {
      'flightId': event.flightId,
      'price': event.price
    };

    state.socket!.emit("makeFlightProposal", const JsonEncoder().convert(message));

    emit(state.copyWith(
      status: SocketIoStatus.connected,
    ));
  }

  void _onSocketListenEvent(
      SocketIoListenEvent event, Emitter<SocketIoState> emit) {
    if (state.listenedEvents.containsKey(event.eventId)) {
      return;
    }

    state.socket!.on(event.event, event.callback);
    emit(state.copyWith(
      listenedEvents: state.listenedEvents..putIfAbsent(event.eventId, () => event.event)
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
