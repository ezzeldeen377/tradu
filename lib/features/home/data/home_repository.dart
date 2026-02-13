import 'dart:async';
import 'dart:convert';
import 'package:crypto_app/core/cache/cache_service.dart';
import 'package:crypto_app/core/networking/api_constant.dart';
import 'package:crypto_app/core/networking/http_services.dart';
import 'package:crypto_app/features/auth/data/models/user_model.dart';
import 'package:crypto_app/features/home/data/models/market_ticker_model.dart';
import 'package:crypto_app/features/home/data/models/withdraw_response.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

@injectable
class HomeRepository {
  WebSocketChannel? _channel;
  StreamController<Map<String, MarketTickerModel>>? _controller;
  final HttpServices httpServices;
  final CacheService _cacheService;

  HomeRepository(this.httpServices, this._cacheService);

  /// Create WebSocket connection for given currency symbols
  Stream<Map<String, MarketTickerModel>> getMarketStream(
    List<String> currencies,
  ) {
    // Close existing connection if any
    _closeConnection();

    // Create new stream controller
    _controller = StreamController<Map<String, MarketTickerModel>>.broadcast();

    // Build streams string for Binance WebSocket
    // Using api_id from currency model which is already clean
    print(currencies);
    final streams = currencies
        .map((currency) => '${currency.toLowerCase()}usdt@miniTicker')
        .join('/');

    // Connect to Binance WebSocket
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/stream?streams=$streams'),
    );

    // Store latest ticker data for each symbol
    final Map<String, MarketTickerModel> tickerMap = {};

    // Listen to WebSocket stream
    _channel!.stream.listen(
      (message) {
        try {
          final json = jsonDecode(message as String) as Map<String, dynamic>;
          final ticker = MarketTickerModel.fromJson(json);

          // Update ticker map
          tickerMap[ticker.symbol] = ticker;

          // Save to cache
          _cacheService.saveMarketTickers(tickerMap);

          // Emit updated map
          _controller?.add(Map.from(tickerMap));
        } catch (e) {
          // Silently ignore parsing errors
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _controller?.addError(error);
      },
      onDone: () {
        print('WebSocket connection closed');
        _controller?.close();
      },
    );

    return _controller!.stream;
  }

  /// Get real-time stream for a specific coin
  Stream<MarketTickerModel> getSingleMarketStream(String currency) {
    final streamController = StreamController<MarketTickerModel>.broadcast();

    // Using api_id from currency model which is already clean
    final streamName = '${currency.toLowerCase()}usdt@miniTicker';

    final channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/stream?streams=$streamName'),
    );

    channel.stream.listen(
      (message) {
        try {
          final json = jsonDecode(message as String) as Map<String, dynamic>;
          final ticker = MarketTickerModel.fromJson(json);
          streamController.add(ticker);
        } catch (e) {
          // ignore error
        }
      },
      onError: (error) => streamController.addError(error),
      onDone: () {
        channel.sink.close();
        streamController.close();
      },
    );

    // Handle closing
    streamController.onCancel = () {
      channel.sink.close();
    };

    return streamController.stream;
  }

  /// Load cached market tickers
  Map<String, MarketTickerModel>? loadCachedTickers() {
    return _cacheService.loadMarketTickers();
  }

  Future<User> getUserProfile(String token) async {
    final response = await httpServices.post(
      ApiConstant.meEndPoint,
      body: {'token': token},
    );
    return User.fromMap(response);
  }

  Future<WithdrawResponse> withdraw(Map<String, dynamic> withdrawData) async {
    final response = await httpServices.post(
      ApiConstant.withdrawEndPoint,
      body: withdrawData,
    );
    return WithdrawResponse.fromMap(response);
  }

  /// Close WebSocket connection
  void _closeConnection() {
    _channel?.sink.close();
    _channel = null;
    _controller?.close();
    _controller = null;
  }

  /// Dispose resources
  void dispose() {
    _closeConnection();
  }
}
