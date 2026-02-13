class SubscriptedPlan {
  final int userId;
  final int planId;
  final DateTime expiratoryDate;
  final DateTime updatedAt;
  final DateTime createdAt;
  final int id;

  SubscriptedPlan({
    required this.userId,
    required this.planId,
    required this.expiratoryDate,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory SubscriptedPlan.fromMap(Map<String, dynamic> map) {
    return SubscriptedPlan(
      userId: map['user_id'] ?? 0,
      planId: map['plan_id'] ?? 0,
      expiratoryDate:
          DateTime.tryParse(map['expiratory_date'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      id: map['id'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'plan_id': planId,
      'expiratory_date': expiratoryDate.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'id': id,
    };
  }
}

class SubscriptionResponse {
  final String? message;
  final SubscriptedPlan? userPlan;

  SubscriptionResponse({this.message, this.userPlan});

  factory SubscriptionResponse.fromMap(Map<String, dynamic> map) {
    return SubscriptionResponse(
      message: map['message'],
      userPlan: map['user_plan'] != null
          ? SubscriptedPlan.fromMap(map['user_plan'])
          : null,
    );
  }
}
