class UserWalletModel {
  final int userId;
  final String userName;
  final double usdBalance;
  final List<WalletCryptocurrency> cryptocurrencies;
  final int totalWallets;

  UserWalletModel({
    required this.userId,
    required this.userName,
    required this.usdBalance,
    required this.cryptocurrencies,
    required this.totalWallets,
  });

  factory UserWalletModel.fromJson(Map<String, dynamic> json) {
    return UserWalletModel(
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      usdBalance: (json['usd_balance'] as num).toDouble(),
      cryptocurrencies: (json['cryptocurrencies'] as List)
          .map((e) => WalletCryptocurrency.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalWallets: json['total_wallets'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'usd_balance': usdBalance,
      'cryptocurrencies': cryptocurrencies.map((e) => e.toJson()).toList(),
      'total_wallets': totalWallets,
    };
  }

  // Calculate total portfolio value in USD
  double get totalPortfolioValue {
    // This would need current market prices to calculate accurately
    // For now, just return USD balance
    return usdBalance;
  }
}

class WalletCryptocurrency {
  final int id;
  final int currencyId;
  final String currencyName;
  final String currencySymbol;
  final String currencyApiId;
  final String balance;

  WalletCryptocurrency({
    required this.id,
    required this.currencyId,
    required this.currencyName,
    required this.currencySymbol,
    required this.currencyApiId,
    required this.balance,
  });

  factory WalletCryptocurrency.fromJson(Map<String, dynamic> json) {
    return WalletCryptocurrency(
      id: json['id'] as int,
      currencyId: json['currency_id'] as int,
      currencyName: json['currency_name'] as String,
      currencySymbol: json['currency_symbol'] as String,
      currencyApiId: json['currency_api_id'] as String,
      balance: json['balance'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency_id': currencyId,
      'currency_name': currencyName,
      'currency_symbol': currencySymbol,
      'currency_api_id': currencyApiId,
      'balance': balance,
    };
  }

  double get balanceValue => double.tryParse(balance) ?? 0.0;

  String get formattedBalance {
    final value = balanceValue;
    if (value >= 1) {
      return value.toStringAsFixed(2);
    } else {
      return value.toStringAsFixed(8);
    }
  }
}
