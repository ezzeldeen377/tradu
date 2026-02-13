/// Enum representing different cryptocurrencies with their conversion rates
enum CryptoCurrency {
  usd('USD', 1.0, '\$'),
  btc('BTC', 0.000010, '₿'),
  eth('ETH', 0.00025, 'Ξ'),
  bnb('BNB', 0.0015, 'BNB'),
  usdt('USDT', 1.0, '₮'),
  xrp('XRP', 1.5, 'XRP'),
  ada('ADA', 2.0, 'ADA'),
  doge('DOGE', 7.5, 'Ð'),
  sol('SOL', 0.005, 'SOL'),
  dot('DOT', 0.12, 'DOT');

  final String code;
  final double conversionRate;
  final String symbol;

  const CryptoCurrency(this.code, this.conversionRate, this.symbol);

  /// Convert USD amount to this currency
  double convertFromUSD(double usdAmount) {
    return usdAmount * conversionRate;
  }

  /// Convert this currency amount to USD
  double convertToUSD(double amount) {
    return amount / conversionRate;
  }

  /// Format the amount with appropriate decimal places
  String formatAmount(double amount) {
    if (conversionRate < 0.0001) {
      return amount.toStringAsFixed(8);
    } else if (conversionRate < 0.01) {
      return amount.toStringAsFixed(6);
    } else if (conversionRate < 1) {
      return amount.toStringAsFixed(4);
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  /// Get currency from code string
  static CryptoCurrency fromCode(String code) {
    return CryptoCurrency.values.firstWhere(
      (currency) => currency.code == code.toUpperCase(),
      orElse: () => CryptoCurrency.usd,
    );
  }
}
