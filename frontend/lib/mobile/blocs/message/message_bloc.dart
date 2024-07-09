import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/local_notification_setup.dart';
import 'package:frontend/models/message.dart';
import 'package:frontend/services/message.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc() : super(MessageState(status: MessageStatus.initial, messages: [])) {
    on<MessageInitialized>(_onMessageInitialized);
    on<MessageLoading>(_onMessageLoading);
    on<MessageLoaded>(_onMessageLoaded);
    on<NewMessage>(_onNewMessage);
  }

  Future<void> _onMessageInitialized(MessageInitialized event, Emitter<MessageState> emit) async {
    emit(state.copyWith(status: MessageStatus.loading));

    final messages = await MessageService.getMessagesByFlightId(event.flightId);

    emit(state.copyWith(
      status: MessageStatus.loaded,
      messages: messages,
    ));
  }

  void _onMessageLoading(MessageLoading event, Emitter<MessageState> emit) {
    emit(state.copyWith(status: MessageStatus.loading));
  }

  void _onMessageLoaded(MessageLoaded event, Emitter<MessageState> emit) {
    emit(state.copyWith(
      status: MessageStatus.loaded,
      messages: event.messages,
    ));
  }

  void _onNewMessage(NewMessage event, Emitter<MessageState> emit) {
    final messages = List<Message>.from(state.messages)..add(event.message);

    LocalNotificationService().showNotification('New message !', 'You have received a new message !');

    emit(state.copyWith(
      status: MessageStatus.loaded,
      messages: messages,
    ));
  }
}