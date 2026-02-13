// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_detail_cubit.dart';

enum ChatDetailStatus {
  initial,
  loading,
  success,
  failure,
  sending,
}

extension ChatDetailStateX on ChatDetailState {
  bool get isInitial => status == ChatDetailStatus.initial;
  bool get isLoading => status == ChatDetailStatus.loading;
  bool get isSuccess => status == ChatDetailStatus.success;
  bool get isFailure => status == ChatDetailStatus.failure;
  bool get isSending => status == ChatDetailStatus.sending;
}

class ChatDetailState {
  final ChatDetailStatus status;
  final String? message;
  final List<Message> messages;
  final Chat? currentChat;

  ChatDetailState({
    required this.status,
    this.message,
    this.messages = const [],
    this.currentChat,
  });

  ChatDetailState copyWith({
    ChatDetailStatus? status,
    String? message,
    List<Message>? messages,
    Chat? currentChat,
  }) {
    return ChatDetailState(
      status: status ?? this.status,
      message: message ?? this.message,
      messages: messages ?? this.messages,
      currentChat: currentChat ?? this.currentChat,
    );
  }

  @override
  String toString() {
    return 'ChatDetailState(status: $status, message: $message, messages: ${messages.length}, currentChat: ${currentChat?.user.name})';
  }
}
