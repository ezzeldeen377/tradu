import 'package:crypto_app/core/services/mounted_mixin.dart';
import 'package:crypto_app/features/admin/data/models/chat_model.dart';
import 'package:crypto_app/features/admin/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'chats_state.dart';

@singleton
class ChatsCubit extends Cubit<ChatsState> with MountedCubit<ChatsState> {
  final ChatRepository _repository;

  ChatsCubit(this._repository) : super(ChatsState(status: ChatsStatus.initial));

  Future<void> fetchChats() async {
    try {
      emit(state.copyWith(status: ChatsStatus.loading));

      final chatsResponse = await _repository.getAllChats();

      emit(
        state.copyWith(status: ChatsStatus.success, chats: chatsResponse.chats),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatsStatus.failure,
          message: e.toString(),
          chats: [],
        ),
      );
    }
  }

  Future<void> fetchChatsWithoutLoading() async {
    try {
      final chatsResponse = await _repository.getAllChats();

      emit(
        state.copyWith(status: ChatsStatus.success, chats: chatsResponse.chats),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatsStatus.failure,
          message: e.toString(),
          chats: [],
        ),
      );
    }
  }

  Future<void> refreshChats() async {
    try {
      // Don't show loading state for refresh
      final chatsResponse = await _repository.getAllChats();

      emit(
        state.copyWith(status: ChatsStatus.success, chats: chatsResponse.chats),
      );
    } catch (e) {
      emit(state.copyWith(status: ChatsStatus.failure, message: e.toString()));
    }
  }

  Future<void> changeUserChatStatus(int userId, int isBannedChat) async {
    try {
      await _repository.changeUserChatStatus(userId, isBannedChat);

      // Update the user's ban status in the local chat list
      final updatedChats = state.chats.map((chat) {
        if (chat.userId == userId) {
          return chat.copyWith(
            user: chat.user.copyWith(isBannedChat: isBannedChat),
          );
        }
        return chat;
      }).toList();

      emit(state.copyWith(status: ChatsStatus.success, chats: updatedChats));
    } catch (e) {
      emit(state.copyWith(status: ChatsStatus.failure, message: e.toString()));
    }
  }
}
