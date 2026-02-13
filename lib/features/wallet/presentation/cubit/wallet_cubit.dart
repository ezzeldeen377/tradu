import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../home/data/home_repository.dart';
import '../../data/wallet_repository.dart';
import 'wallet_state.dart';

@injectable
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;
  final HomeRepository _homeRepository;
  StreamSubscription? _marketSubscription;

  WalletCubit(this._repository, this._homeRepository)
    : super(const WalletState());

  /// Fetch user wallet data
  Future<void> fetchUserWallet() async {
    emit(state.copyWith(status: WalletStatus.loading));

    try {
      final walletData = await _repository.getUserWallet();
      emit(
        state.copyWith(status: WalletStatus.success, walletData: walletData),
      );

      // Start listening to market prices for all cryptocurrencies in wallet
      if (walletData.cryptocurrencies.isNotEmpty) {
        _startMarketPriceStream(
          walletData.cryptocurrencies.map((c) => c.currencySymbol).toList(),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: WalletStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Start listening to market prices for wallet cryptocurrencies
  void _startMarketPriceStream(List<String> currencySymbols) {
    // Cancel existing subscription
    _marketSubscription?.cancel();

    // Subscribe to market stream
    _marketSubscription = _homeRepository
        .getMarketStream(currencySymbols)
        .listen(
          (tickers) {
            // Only proceed if we have actual ticker data
            if (tickers.isEmpty) return;

            // Extract prices from tickers and match with currency symbols
            final Map<String, double> prices = {};
            tickers.forEach((symbol, ticker) {
              final price = double.tryParse(ticker.price) ?? 0.0;

              // Remove 'USDT' suffix from symbol to get the base currency
              // e.g., "BNBUSDT" -> "BNB"
              final cleanSymbol = symbol.replaceAll('USDT', '').toUpperCase();
              prices[cleanSymbol] = price;

              print('Price for $cleanSymbol: \$$price');
            });

            // Only calculate and update if we have valid prices
            if (prices.isNotEmpty) {
              // Calculate total balance with actual market prices
              final totalBalance = _calculateTotalBalance(prices);

              // Update state with new prices and total balance
              emit(
                state.copyWith(
                  marketPrices: prices,
                  totalBalanceUsd: totalBalance,
                ),
              );
            }
          },
          onError: (error) {
            // Silently handle market price stream errors
          },
        );
  }

  /// Calculate total balance in USD
  double _calculateTotalBalance(Map<String, double> prices) {
    if (state.walletData == null) return 0.0;

    // Start with USD balance
    double total = 0;

    print('\n=== Calculating Total Balance ===');
    print('USD Balance: \$${state.walletData!.usdBalance.toStringAsFixed(2)}');

    // Add value of each cryptocurrency
    for (final crypto in state.walletData!.cryptocurrencies) {
      final symbol = crypto.currencySymbol.toUpperCase();
      final price = prices[symbol] ?? 0.0;
      final balance = crypto.balanceValue;
      final cryptoValueInUsd = balance * price;

      print(
        '${crypto.currencySymbol}: $balance × \$$price = \$${cryptoValueInUsd.toStringAsFixed(2)}',
      );

      total += cryptoValueInUsd;
    }

    print('Total Balance: \$${total.toStringAsFixed(2)}');
    print('================================\n');

    return total;
  }

  /// Refresh wallet data
  Future<void> refreshWallet() async {
    await fetchUserWallet();
  }

  /// Deposit USD to crypto
  Future<bool> depositUsdToCrypto({
    required String currencyApiId,
    required double usdAmount,
  }) async {
    try {
      await _repository.depositUsdToCrypto(
        currencyApiId: currencyApiId,
        usdAmount: usdAmount,
      );

      // Refresh wallet data after successful deposit
      await fetchUserWallet();

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: WalletStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  /// Withdraw crypto to USD
  Future<bool> withdrawCryptoToUsd({
    required String currencyApiId,
    required double cryptoAmount,
  }) async {
    try {
      await _repository.withdrawCryptoToUsd(
        currencyApiId: currencyApiId,
        cryptoAmount: cryptoAmount,
      );

      // Refresh wallet data after successful withdrawal
      await fetchUserWallet();

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: WalletStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  @override
  Future<void> close() {
    _marketSubscription?.cancel();
    return super.close();
  }
}
