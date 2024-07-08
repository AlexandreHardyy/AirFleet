part of 'message_bloc.dart';

@immutable
sealed class MessageEvent {}

final class MessageLoading extends MessageEvent {}

final class MessageInitialized extends MessageEvent {
  final int flightId;

  MessageInitialized({required this.flightId});
}

final class MessageLoaded extends MessageEvent {
  final List<Message> messages;

  MessageLoaded({required this.messages});
}

final class NewMessage extends MessageEvent {
  final Message message;

  NewMessage({required this.message});
}