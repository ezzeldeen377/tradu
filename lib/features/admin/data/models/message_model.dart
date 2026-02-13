class MessagesResponse {
  final List<Message> messages;

  MessagesResponse({required this.messages});

  factory MessagesResponse.fromMap(Map<String, dynamic> json) {
    return MessagesResponse(
      messages: (json['messages'] as List)
          .map((message) => Message.fromJson(message))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'messages': messages.map((message) => message.toJson()).toList()};
  }
}

class Message {
  final int id;
  final int chatId;
  final int senderId;
  final String senderType;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderType,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      chatId: json['chat_id'] as int,
      senderId: json['sender_id'] ?? 0,
      senderType: json['sender_type'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isRead: json['is_read'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_name': senderType,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
    };
  }

  Message copyWith({
    int? id,
    int? chatId,
    int? senderId,
    String? senderName,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderType: senderName ?? senderType,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
