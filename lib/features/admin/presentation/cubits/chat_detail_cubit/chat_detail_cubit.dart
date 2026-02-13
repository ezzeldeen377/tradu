import 'package:crypto_app/core/services/mounted_mixin.dart';
import 'package:crypto_app/features/admin/data/models/chat_model.dart';
import 'package:crypto_app/features/admin/data/models/message_model.dart';
import 'package:crypto_app/features/admin/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'chat_detail_state.dart';

@injectable
class ChatDetailCubit extends Cubit<ChatDetailState>
    with MountedCubit<ChatDetailState> {
  final ChatRepository _repository;

  ChatDetailCubit(this._repository)
    : super(ChatDetailState(status: ChatDetailStatus.initial));

  Future<void> fetchMessages(String chatId, String currentUser) async {
    try {
      emit(state.copyWith(status: ChatDetailStatus.loading));

      final messagesResponse = await _repository.getChatMessages(chatId);
      List<Message> finalMessages = messagesResponse.messages;

      // Add static welcome message for users (not admins)
      if (currentUser == 'user') {
        final welcomeMessage = Message(
          id: -1, // Use negative ID to indicate it's a static message
          chatId: int.parse(chatId),
          senderId: 0,
          senderType: 'admin',
          message:
              'انا مصطفى يسعدني انضمامي إليك لحل مشكلتك\n\nمرحبا بكم بدعم\nيرجى طرح مشكلتك ، او كيف يمكننا مساعدتك ؟',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isRead: true,
        );
        finalMessages = [...finalMessages, welcomeMessage];
      }

      emit(
        state.copyWith(
          status: ChatDetailStatus.success,
          messages: finalMessages,
        ),
      );

      markAsRead(messagesResponse.messages, currentUser);
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailStatus.failure,
          message: e.toString(),
          messages: [],
        ),
      );
    }
  }

  Future<void> fetchMessagesAuto(String chatId) async {
    try {
      final messagesResponse = await _repository.getChatMessages(chatId);

      emit(
        state.copyWith(
          status: ChatDetailStatus.success,
          messages: messagesResponse.messages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailStatus.failure,
          message: e.toString(),
          messages: [],
        ),
      );
    }
  }

  Future<void> sendMessage(String chatId, String content) async {
    if (content.trim().isEmpty) return;

    // Create optimistic message
    final optimisticMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      chatId: int.parse(chatId),
      senderId: 0,
      senderType: 'user',
      message: content,
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
      isRead: false,
    );

    // Add optimistic message to UI
    final updatedMessages = [...state.messages, optimisticMessage];
    emit(
      state.copyWith(
        messages: updatedMessages,
        status: ChatDetailStatus.sending,
      ),
    );

    try {
      final sentMessage = await _repository.sendMessage({
        'chat_id': chatId,
        'message': content,
      });

      // Replace optimistic message with real message
      final messagesWithReal = state.messages
          .map((msg) => msg.id == optimisticMessage.id ? sentMessage : msg)
          .toList();

      emit(
        state.copyWith(
          status: ChatDetailStatus.success,
          messages: messagesWithReal,
        ),
      );
    } catch (e, trace) {
      print(e);
      print(trace);
      // Remove optimistic message on failure
      final messagesWithoutOptimistic = state.messages
          .where((msg) => msg.id != optimisticMessage.id)
          .toList();

      emit(
        state.copyWith(
          status: ChatDetailStatus.failure,
          message: e.toString(),
          messages: messagesWithoutOptimistic,
        ),
      );
    }
  }

  Future<void> sendMessageAsAdmin(String chatId, String content) async {
    if (content.trim().isEmpty) return;

    // Create optimistic message
    final optimisticMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      chatId: int.parse(chatId),
      senderId: 0, // Assuming 0 is the senderId for Admin
      senderType: 'admin',
      message: content,
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
      isRead: false,
    );

    // Add optimistic message to UI
    final updatedMessages = [...state.messages, optimisticMessage];
    emit(
      state.copyWith(
        messages: updatedMessages,
        status: ChatDetailStatus.sending,
      ),
    );

    try {
      final sentMessage = await _repository.sendMessageAsAdmin({
        'user_id': chatId,
        'message': content,
      });

      // Replace optimistic message with real message
      final messagesWithReal = state.messages
          .map((msg) => msg.id == optimisticMessage.id ? sentMessage : msg)
          .toList();

      emit(
        state.copyWith(
          status: ChatDetailStatus.success,
          messages: messagesWithReal,
        ),
      );
    } catch (e) {
      print('Error sending message as admin: $e');
      // Remove optimistic message on failure
      final messagesWithoutOptimistic = state.messages
          .where((msg) => msg.id != optimisticMessage.id)
          .toList();

      emit(
        state.copyWith(
          status: ChatDetailStatus.failure,
          message: e.toString(),
          messages: messagesWithoutOptimistic,
        ),
      );
    }
  }

  Future<void> markAsRead(List<Message> messages, String currentUser) async {
    try {
      final List<Message> messagesToMark = messages
          .where((msg) => msg.senderType != currentUser && msg.isRead == false)
          .toList();

      if (messagesToMark.isEmpty) {
        return;
      }

      // Optimistically update the UI
      final updatedMessages = state.messages.map((msg) {
        if (messagesToMark.any((m) => m.id == msg.id)) {
          return msg;
        }
        return msg;
      }).toList();

      emit(state.copyWith(messages: updatedMessages));

      // Call repository for each unread message
      for (final message in messagesToMark) {
        await _repository.markAsRead(message.id.toString());
      }
    } catch (e) {
      // Silently fail for mark as read - not critical
      // Could log the error if needed
    }
  }
}
