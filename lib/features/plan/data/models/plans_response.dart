class Plan {
  final int id;
  final String name;
  final String description;
  final String profitMargin;
  final int durationDays;
  final String price;
  final int special;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.profitMargin,
    required this.durationDays,
    required this.price,
    required this.special,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      profitMargin: map['profit_margin']?.toString() ?? '0',
      durationDays: map['duration_days'] ?? 0,
      price: map['price']?.toString() ?? '0',
      special: map['special'] ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'profit_margin': profitMargin,
      'duration_days': durationDays,
      'price': price,
      'special': special,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PlansResponse {
  final String? message;
  final List<Plan> plans;

  PlansResponse({this.message, required this.plans});

  factory PlansResponse.fromMap(Map<String, dynamic> map) {
    return PlansResponse(
      message: map['message'],
      plans: List<Plan>.from(
        (map['plans'] as List? ?? []).map((x) => Plan.fromMap(x)),
      ),
    );
  }
}

class OffersResponse {
  final String? message;
  final List<Plan> offers;

  OffersResponse({this.message, required this.offers});

  factory OffersResponse.fromMap(Map<String, dynamic> map) {
    return OffersResponse(
      message: map['message'],
      offers: List<Plan>.from(
        (map['offers'] as List? ?? []).map((x) => Plan.fromMap(x)),
      ),
    );
  }
}
