part of 'message_bloc.dart';

enum MessageStatus {
  initial,
  loading,
  loaded,
  error,
}

class MessageState {
  final MessageStatus status;
  final List<Message> messages;
  final String? errorMessage;

  MessageState({
    required this.status,
    required this.messages,
    this.errorMessage,
  });

  MessageState copyWith({
    MessageStatus? status,
    List<Message>? messages,
    String? errorMessage,
  }) {
    return MessageState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}