import '../../../../core/enums/crypto_currency.dart';

class CurrencyModel {
  final int id;
  final String name;
  final String symbol;
  final String apiId;
  final String createdAt;
  final String updatedAt;
  final double? conversionRate;
  final String? link;

  CurrencyModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.apiId,
    required this.createdAt,
    required this.updatedAt,
    this.conversionRate,
    this.link,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] as int,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      apiId: json['api_id'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      conversionRate: json['conversion_rate'] != null
          ? (json['conversion_rate'] as num).toDouble()
          : null,
      link: json['link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'api_id': apiId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (conversionRate != null) 'conversion_rate': conversionRate,
      if (link != null) 'link': link,
    };
  }

  CurrencyModel copyWith({
    int? id,
    String? name,
    String? symbol,
    String? apiId,
    String? createdAt,
    String? updatedAt,
    double? conversionRate,
    String? link,
  }) {
    return CurrencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      apiId: apiId ?? this.apiId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      conversionRate: conversionRate ?? this.conversionRate,
      link: link ?? this.link,
    );
  }

  /// Get the CryptoCurrency enum value for this currency
  CryptoCurrency get cryptoCurrency => CryptoCurrency.fromCode(name);

  /// Get the conversion rate, either from the model or from the enum
  double get effectiveConversionRate =>
      conversionRate ?? cryptoCurrency.conversionRate;
}
