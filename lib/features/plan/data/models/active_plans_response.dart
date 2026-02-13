import 'plans_response.dart';

class ActivePlan {
  final Plan plan;
  final String status;
  final double profit;
  final String expiryDate;
  final String? startDate;

  ActivePlan({
    required this.plan,
    required this.status,
    required this.profit,
    required this.expiryDate,
    this.startDate,
  });

  factory ActivePlan.fromMap(Map<String, dynamic> map) {
    return ActivePlan(
      plan: Plan.fromMap(map['plan'] ?? {}),
      status: map['status'] ?? 'inactive',
      profit: (map['profit'] as num?)?.toDouble() ?? 0.0,
      expiryDate: map['expiry_date'] ?? '',
      startDate: map['start_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan': plan.toMap(),
      'status': status,
      'profit': profit,
      'expiry_date': expiryDate,
      'start_at': startDate,
    };
  }
}

class ActivePlansResponse {
  final String message;
  final List<ActivePlan> plans;
  final double balance;
  final double totalProfit;

  ActivePlansResponse({
    required this.message,
    required this.plans,
    required this.balance,
    required this.totalProfit,
  });

  factory ActivePlansResponse.fromMap(Map<String, dynamic> map) {
    return ActivePlansResponse(
      message: map['message'] ?? '',
      plans: List<ActivePlan>.from(
        (map['plans'] as List? ?? []).map((x) => ActivePlan.fromMap(x)),
      ),
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (map['total_profit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
