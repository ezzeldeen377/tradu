import '../../../data/models/market_ticker_model.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState {
  final HomeStatus status;
  final Map<String, MarketTickerModel> tickers;
  final List<String> sortedSymbols; // Maintains consistent order
  final List<double> priceHistory;
  final int selectedTab;
  final String selectedTimeframe;
  final String? activeSymbol;
  final String selectedCurrency;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.tickers = const {},
    this.sortedSymbols = const [],
    this.priceHistory = const [],
    this.selectedTab = 0,
    this.selectedTimeframe = '1D',
    this.activeSymbol,
    this.selectedCurrency = 'USD',
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    Map<String, MarketTickerModel>? tickers,
    List<String>? sortedSymbols,
    List<double>? priceHistory,
    int? selectedTab,
    String? selectedTimeframe,
    String? activeSymbol,
    String? selectedCurrency,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      tickers: tickers ?? this.tickers,
      sortedSymbols: sortedSymbols ?? this.sortedSymbols,
      priceHistory: priceHistory ?? this.priceHistory,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      activeSymbol: activeSymbol ?? this.activeSymbol,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
