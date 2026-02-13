// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chats_cubit.dart';

enum ChatsStatus {
  initial,
  loading,
  success,
  failure,
}

extension ChatsStateX on ChatsState {
  bool get isInitial => status == ChatsStatus.initial;
  bool get isLoading => status == ChatsStatus.loading;
  bool get isSuccess => status == ChatsStatus.success;
  bool get isFailure => status == ChatsStatus.failure;
}

class ChatsState {
  final ChatsStatus status;
  final String? message;
  final List<Chat> chats;

  ChatsState({
    required this.status,
    this.message,
    this.chats = const [],
  });

  ChatsState copyWith({
    ChatsStatus? status,
    String? message,
    List<Chat>? chats,
  }) {
    return ChatsState(
      status: status ?? this.status,
      message: message ?? this.message,
      chats: chats ?? this.chats,
    );
  }

  @override
  String toString() {
    return 'ChatsState(status: $status, message: $message, chats: ${chats.length})';
  }
}
