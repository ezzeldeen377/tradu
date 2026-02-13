import 'dart:developer';

import 'package:crypto_app/features/auth/data/models/user_model.dart';

class ChatsResponse {
  final List<Chat> chats;

  ChatsResponse({required this.chats});

  factory ChatsResponse.fromMap(Map<String, dynamic> json) {
    log("@@@@@@@@@@@@@@@@@@$json");

    return ChatsResponse(
      chats: (json['chats'] as List)
          .map((chat) => Chat.fromJson(chat))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'chats': chats.map((chat) => chat.toJson()).toList()};
  }
}

class Chat {
  final int id;
  final int userId;
  final int adminId;
  final String lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadMessagesCount;
  final User user;

  Chat({
    required this.id,
    required this.userId,
    required this.adminId,
    required this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadMessagesCount,
    required this.user,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      adminId: json['admin_id'] as int,
      lastMessage: json['last_message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      unreadMessagesCount: json['unread_messages_count'] as int,
      user: User.fromMap(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'admin_id': adminId,
      'last_message': lastMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'unread_messages_count': unreadMessagesCount,
      'user': user.toMap(),
    };
  }

  Chat copyWith({
    int? id,
    int? userId,
    int? adminId,
    String? lastMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? unreadMessagesCount,
    User? user,
  }) {
    return Chat(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      adminId: adminId ?? this.adminId,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'Chat(id: $id, userId: $userId, adminId: $adminId, lastMessage: $lastMessage, createdAt: $createdAt, updatedAt: $updatedAt, user: $user)';
  }
}
