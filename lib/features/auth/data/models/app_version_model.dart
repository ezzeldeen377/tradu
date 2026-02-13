import 'currency_model.dart';

class AppVersionModel {
  final String version;
  final List<CurrencyModel> currencies;

  AppVersionModel({required this.version, required this.currencies});

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      version: json['version'] as String,
      currencies: (json['currencies'] as List<dynamic>)
          .map(
            (currency) =>
                CurrencyModel.fromJson(currency as Map<String, dynamic>),
          )
          .where(
            (currency) =>
                currency.symbol != 'USDT' && currency.apiId != 'tether',
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'currencies': currencies.map((currency) => currency.toJson()).toList(),
    };
  }

  AppVersionModel copyWith({String? version, List<CurrencyModel>? currencies}) {
    return AppVersionModel(
      version: version ?? this.version,
      currencies: currencies ?? this.currencies,
    );
  }
}
