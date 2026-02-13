import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/home_repository.dart';
import '../../../data/models/market_ticker_model.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;
  StreamSubscription? _marketSubscription;

  HomeCubit(this._repository) : super(const HomeState()) {
    // Load cached data on initialization
    loadCachedData();
  }

  /// Load cached market data and display immediately
  void loadCachedData() {
    final cachedTickers = _repository.loadCachedTickers();
    if (cachedTickers != null && cachedTickers.isNotEmpty) {
      // Create sorted symbols list (alphabetically)
      final sortedSymbols = cachedTickers.keys.toList()..sort();

      emit(
        state.copyWith(
          status: HomeStatus.success,
          tickers: cachedTickers,
          sortedSymbols: sortedSymbols,
        ),
      );
    }
  }

  /// Start streaming market data for given currencies
  void startMarketStream(List<String> currencies) {
    if (currencies.isEmpty) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: 'No currencies provided',
        ),
      );
      return;
    }

    // Load cached data first if available
    final cachedTickers = _repository.loadCachedTickers();
    if (cachedTickers != null && cachedTickers.isNotEmpty) {
      // Create sorted symbols list if not already set
      final sortedSymbols = state.sortedSymbols.isEmpty
          ? (cachedTickers.keys.toList()..sort())
          : state.sortedSymbols;

      emit(
        state.copyWith(
          status: HomeStatus.success,
          tickers: cachedTickers,
          sortedSymbols: sortedSymbols,
        ),
      );
    } else {
      emit(state.copyWith(status: HomeStatus.loading));
    }

    try {
      // Cancel existing subscription
      _marketSubscription?.cancel();

      // Subscribe to market stream
      _marketSubscription = _repository
          .getMarketStream(currencies)
          .listen(
            (tickers) {
              List<double> updatedHistory = List.from(state.priceHistory);

              // Update history if we have an active symbol and its price changed
              if (state.activeSymbol != null &&
                  tickers.containsKey(state.activeSymbol)) {
                final currentTicker = tickers[state.activeSymbol]!;
                final newPrice = double.parse(currentTicker.price);

                if (updatedHistory.isEmpty || updatedHistory.last != newPrice) {
                  updatedHistory.add(newPrice);
                  // Keep last 60 points
                  if (updatedHistory.length > 60) {
                    updatedHistory.removeAt(0);
                  }
                }
              }

              // Initialize sorted symbols on first data
              List<String> sortedSymbols = state.sortedSymbols;
              Map<String, MarketTickerModel> updatedTickers = Map.from(
                state.tickers,
              );

              if (sortedSymbols.isEmpty) {
                // First time - initialize everything
                sortedSymbols = tickers.keys.toList()..sort();
                updatedTickers = tickers;
              } else {
                // Update only the ticker values, keep the same map reference structure
                tickers.forEach((symbol, newTicker) {
                  updatedTickers[symbol] = newTicker;
                });
              }

              emit(
                state.copyWith(
                  status: HomeStatus.success,
                  tickers: updatedTickers,
                  sortedSymbols: sortedSymbols,
                  priceHistory: updatedHistory,
                ),
              );
            },
            onError: (error) {
              emit(
                state.copyWith(
                  status: HomeStatus.failure,
                  errorMessage: error.toString(),
                ),
              );
            },
          );
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  /// Set the active coin for details view
  void setActiveCoin(String symbol) {
    if (state.activeSymbol == symbol) return;

    // Clear history and set new active symbol
    emit(
      state.copyWith(
        activeSymbol: symbol,
        priceHistory: [],
        selectedTab: 0,
        selectedTimeframe: '1D',
      ),
    );
  }

  /// Update selected tab for details screen
  void updateTab(int index) {
    emit(state.copyWith(selectedTab: index));
  }

  /// Update selected timeframe
  void updateTimeframe(String timeframe) {
    emit(state.copyWith(selectedTimeframe: timeframe));
  }

  /// Update selected currency
  void updateCurrency(String currency) {
    emit(state.copyWith(selectedCurrency: currency));
  }

  /// Refresh market data
  Future<void> refreshMarketData(List<String> currencies) async {
    // Restart the market stream
    startMarketStream(currencies);
    // Wait a bit to ensure data is loaded
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Stop market stream
  void stopMarketStream() {
    _marketSubscription?.cancel();
    _marketSubscription = null;
  }

  @override
  Future<void> close() {
    _marketSubscription?.cancel();
    _repository.dispose();
    return super.close();
  }
}
