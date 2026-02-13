import 'package:crypto_app/core/networking/api_constant.dart';
import 'package:crypto_app/core/networking/http_services.dart';
import 'package:crypto_app/features/admin/data/models/chat_model.dart';
import 'package:crypto_app/features/admin/data/models/message_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChatRepository {
  final HttpServices httpServices;
  ChatRepository(this.httpServices);

  Future<ChatsResponse> getAllChats() async {
    final res = await httpServices.get(ApiConstant.getAllChats);
    return ChatsResponse.fromMap(res);
  }

  Future<MessagesResponse> getChatMessages(String chatId) async {
    final res = await httpServices.get(
      "${ApiConstant.getChatMessages}/$chatId",
    );

    return MessagesResponse.fromMap(res);
  }

  Future<Message> sendMessage(Map<String, dynamic> messageData) async {
    final res = await httpServices.post(
      ApiConstant.sendMessage,
      body: messageData,
    );

    // Create new message
    return Message.fromJson(res['data']);
  }

  Future<Map<String, dynamic>> markAsRead(String message) async {
    final res = await httpServices.get("${ApiConstant.markAsRead}/$message");

    return res;
  }

  Future<Message> sendMessageAsAdmin(Map<String, dynamic> messageData) async {
    final res = await httpServices.post(
      ApiConstant.sendMessageAsAdmin,
      body: messageData,
    );
    return Message.fromJson(res['data']);
  }

  Future<Map<String, dynamic>> changeUserChatStatus(
    int userId,
    int isBannedChat,
  ) async {
    final res = await httpServices.get(
      "${ApiConstant.changeUserChatStatus}/$userId?is_banned_chat=$isBannedChat",
    );
    return res;
  }
}
