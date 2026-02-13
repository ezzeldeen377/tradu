import 'dart:async';
import 'package:crypto_app/features/auth/data/models/currency_model.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:crypto_app/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as context;
import 'package:injectable/injectable.dart';
import '../../../home/data/home_repository.dart';
import '../../../home/data/models/market_ticker_model.dart';
import '../../../wallet/data/wallet_repository.dart';
import '../../../wallet/data/models/user_wallet_model.dart';
import 'trade_state.dart';

@lazySingleton
class TradeCubit extends Cubit<TradeState> {
  final HomeRepository _homeRepository;
  final WalletRepository _walletRepository;
  StreamSubscription? _marketSubscription;
  Map<String, MarketTickerModel> _latestTickers = {};

  TradeCubit(this._homeRepository, this._walletRepository)
    : super(const TradeState());

  /// Fetch user wallet data
  Future<void> fetchWalletData() async {
    try {
      final walletData = await _walletRepository.getUserWallet();
      emit(state.copyWith(walletData: walletData));
    } catch (e) {
      emit(
        state.copyWith(status: TradeStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  /// Get available balance for a specific cryptocurrency
  double getAvailableBalance(String currencySymbol) {
    if (state.walletData == null) return 0.0;

    final crypto = state.walletData!.cryptocurrencies.firstWhere(
      (c) => c.currencySymbol.toUpperCase() == currencySymbol.toUpperCase(),
      orElse: () => WalletCryptocurrency(
        id: 0,
        currencyId: 0,
        currencyName: '',
        currencySymbol: '',
        currencyApiId: '',
        balance: '0',
      ),
    );

    return crypto.balanceValue;
  }

  void startMarketStream(List<String> currencies) {
    if (currencies.isEmpty) return;

    _marketSubscription?.cancel();
    _marketSubscription = _homeRepository
        .getMarketStream(currencies)
        .listen(
          (tickers) {
            _latestTickers = tickers;
            _calculateTargetAmount();
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: TradeStatus.failure,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  void updateFromAmount(double amount) {
    emit(state.copyWith(fromAmount: amount));
    _calculateTargetAmount();
  }

  void updateToAmount(double amount) {
    emit(state.copyWith(toAmount: amount));
    _calculateSourceAmount();
  }

  void updateFromCurrency(String currency) {
    emit(state.copyWith(fromCurrency: currency));
    _calculateTargetAmount();
  }

  void updateToCurrency(String currency) {
    emit(state.copyWith(toCurrency: currency));
    _calculateTargetAmount();
  }

  void swapCurrencies() {
    if (state.isAnimating) return;

    final newIsSwapped = !state.isSwapped;

    // Swap currencies and amounts
    final currentFromCurrency = state.fromCurrency;
    final currentToCurrency = state.toCurrency;
    final currentFromAmount = state.fromAmount;
    final currentToAmount = state.toAmount;

    emit(
      state.copyWith(
        isAnimating: true,
        isSwapped: newIsSwapped,
        fromCurrency: currentToCurrency,
        toCurrency: currentFromCurrency,
        fromAmount: currentToAmount,
        toAmount: currentFromAmount,
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!isClosed) {
        emit(state.copyWith(isAnimating: false));
      }
    });
  }

  void updateAvailableBalance(double balance) {
    emit(state.copyWith(availableBalance: balance));
  }

  /// Exchange crypto to crypto
  Future<bool> exchangeCryptoToCrypto(CurrencyModel toCurrency) async {
    try {
      emit(state.copyWith(status: TradeStatus.loading));

      // Get currency API IDs from wallet data
      final fromCrypto = state.walletData?.cryptocurrencies.firstWhere(
        (c) =>
            c.currencySymbol.toUpperCase() == state.fromCurrency.toUpperCase(),
        orElse: () => throw Exception('From currency not found in wallet'),
      );

      await _walletRepository.exchangeCryptoToCrypto(
        fromCurrencyApiId: fromCrypto!.currencyApiId,
        toCurrencyApiId: toCurrency.apiId,
        cryptoAmount: state.fromAmount,
      );

      // Refresh wallet data after successful exchange
      await fetchWalletData();

      emit(state.copyWith(status: TradeStatus.success));
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: TradeStatus.failure, errorMessage: e.toString()),
      );
      return false;
    }
  }

  double _getPriceInUSDT(String symbol) {
    if (symbol.toUpperCase() == 'USDT' || symbol.toUpperCase() == 'USD') {
      return 1.0;
    }

    // Binance symbols are usually SYMBOLUSDT
    final tickerKey = '${symbol.toUpperCase()}USDT';
    if (_latestTickers.containsKey(tickerKey)) {
      return double.tryParse(_latestTickers[tickerKey]!.price) ?? 0.0;
    }
    return 0.0;
  }

  void _calculateTargetAmount() {
    final fromPrice = _getPriceInUSDT(state.fromCurrency);
    final toPrice = _getPriceInUSDT(state.toCurrency);

    if (fromPrice > 0 && toPrice > 0) {
      final rate = fromPrice / toPrice;
      final targetAmount = state.fromAmount * rate;
      emit(
        state.copyWith(
          status: TradeStatus.success,
          toAmount: targetAmount,
          rate: rate,
        ),
      );
    }
  }

  void _calculateSourceAmount() {
    final fromPrice = _getPriceInUSDT(state.fromCurrency);
    final toPrice = _getPriceInUSDT(state.toCurrency);

    if (fromPrice > 0 && toPrice > 0) {
      final rate = fromPrice / toPrice;
      final sourceAmount = state.toAmount / rate;
      emit(
        state.copyWith(
          status: TradeStatus.success,
          fromAmount: sourceAmount,
          rate: rate,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _marketSubscription?.cancel();
    return super.close();
  }
}
