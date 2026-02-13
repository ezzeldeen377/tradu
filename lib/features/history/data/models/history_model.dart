class HistoryItemModel {
  final int id;
  final int userId;
  final String message;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;

  HistoryItemModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      message: json['message'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class HistoryResponseModel {
  final String status;
  final List<HistoryItemModel> data;

  HistoryResponseModel({required this.status, required this.data});

  factory HistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return HistoryResponseModel(
      status: json['status'] as String,
      data: (json['data'] as List<dynamic>)
          .map(
            (item) => HistoryItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
