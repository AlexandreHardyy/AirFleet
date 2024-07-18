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
  final bool isModuleEnabled;
  final String? errorMessage;

  MessageState({
    required this.status,
    required this.messages,
    required this.isModuleEnabled,
    this.errorMessage,
  });

  MessageState copyWith({
    MessageStatus? status,
    List<Message>? messages,
    bool? isModuleEnabled,
    String? errorMessage,
  }) {
    return MessageState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isModuleEnabled: isModuleEnabled ?? this.isModuleEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
