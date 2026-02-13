class MarketTickerModel {
  final String symbol;
  final String price;
  final String openPrice;
  final String highPrice;
  final String lowPrice;
  final String volume;

  MarketTickerModel({
    required this.symbol,
    required this.price,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });

  factory MarketTickerModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return MarketTickerModel(
      symbol: data['s'] as String,
      price: data['c'] as String,
      openPrice: data['o'] as String,
      highPrice: data['h'] as String,
      lowPrice: data['l'] as String,
      volume: data['v'] as String,
    );
  }

  /// Create from cached map (different structure than WebSocket)
  factory MarketTickerModel.fromMap(Map<String, dynamic> map) {
    return MarketTickerModel(
      symbol: map['symbol'] as String,
      price: map['price'] as String,
      openPrice: map['openPrice'] as String,
      highPrice: map['highPrice'] as String,
      lowPrice: map['lowPrice'] as String,
      volume: map['volume'] as String,
    );
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'price': price,
      'openPrice': openPrice,
      'highPrice': highPrice,
      'lowPrice': lowPrice,
      'volume': volume,
    };
  }

  // Calculate price change
  double get priceChangeValue {
    final current = double.tryParse(price) ?? 0;
    final open = double.tryParse(openPrice) ?? 0;
    return current - open;
  }

  // Calculate price change percentage
  double get priceChangePercent {
    final open = double.tryParse(openPrice) ?? 0;
    if (open == 0) return 0;
    return (priceChangeValue / open) * 100;
  }

  bool get isPositive => priceChangeValue >= 0;

  String get formattedPrice {
    final value = double.tryParse(price) ?? 0;
    if (value >= 1000) {
      return '\$${value.toStringAsFixed(2)}';
    } else if (value >= 1) {
      return '\$${value.toStringAsFixed(2)}';
    } else {
      return '\$${value.toStringAsFixed(4)}';
    }
  }

  String get formattedVolume {
    final value = double.tryParse(volume) ?? 0;
    if (value >= 1000000000) {
      return '\$${(value / 1000000000).toStringAsFixed(1)}B Vol';
    } else if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M Vol';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K Vol';
    } else {
      return '\$${value.toStringAsFixed(0)} Vol';
    }
  }

  String get formattedChange {
    final percent = priceChangePercent;
    final sign = isPositive ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }
}
