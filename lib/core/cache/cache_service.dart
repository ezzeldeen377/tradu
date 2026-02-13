import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/data/models/market_ticker_model.dart';

@injectable
class CacheService {
  static const String _marketTickersKey = 'market_tickers';

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Save market tickers to cache
  Future<void> saveMarketTickers(Map<String, MarketTickerModel> tickers) async {
    try {
      final Map<String, dynamic> tickersJson = {};
      tickers.forEach((key, value) {
        tickersJson[key] = value.toJson();
      });
      final jsonString = jsonEncode(tickersJson);
      await _prefs.setString(_marketTickersKey, jsonString);
    } catch (e) {
      // Silently fail - caching is not critical
    }
  }

  /// Load market tickers from cache
  Map<String, MarketTickerModel>? loadMarketTickers() {
    try {
      final jsonString = _prefs.getString(_marketTickersKey);
      if (jsonString == null) return null;

      final Map<String, dynamic> tickersJson =
          jsonDecode(jsonString) as Map<String, dynamic>;

      final Map<String, MarketTickerModel> tickers = {};
      tickersJson.forEach((key, value) {
        tickers[key] = MarketTickerModel.fromMap(value as Map<String, dynamic>);
      });

      return tickers;
    } catch (e) {
      // Return null if cache is corrupted
      return null;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _prefs.remove(_marketTickersKey);
  }
}
