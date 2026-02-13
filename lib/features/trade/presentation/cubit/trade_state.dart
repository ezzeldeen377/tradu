import 'package:equatable/equatable.dart';
import '../../../wallet/data/models/user_wallet_model.dart';

enum TradeStatus { initial, loading, success, failure }

class TradeState extends Equatable {
  final TradeStatus status;
  final String fromCurrency;
  final String toCurrency;
  final double fromAmount;
  final double toAmount;
  final bool isSwapped;
  final bool isAnimating;
  final double rate;
  final double availableBalance;
  final String? errorMessage;
  final UserWalletModel? walletData;

  const TradeState({
    this.status = TradeStatus.initial,
    this.fromCurrency = 'BTC',
    this.toCurrency = 'ETH',
    this.fromAmount = 0.0,
    this.toAmount = 0.0,
    this.isSwapped = false,
    this.isAnimating = false,
    this.rate = 1.0,
    this.availableBalance = 0.0,
    this.errorMessage,
    this.walletData,
  });

  TradeState copyWith({
    TradeStatus? status,
    String? fromCurrency,
    String? toCurrency,
    double? fromAmount,
    double? toAmount,
    bool? isSwapped,
    bool? isAnimating,
    double? rate,
    double? availableBalance,
    String? errorMessage,
    UserWalletModel? walletData,
  }) {
    return TradeState(
      status: status ?? this.status,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      fromAmount: fromAmount ?? this.fromAmount,
      toAmount: toAmount ?? this.toAmount,
      isSwapped: isSwapped ?? this.isSwapped,
      isAnimating: isAnimating ?? this.isAnimating,
      rate: rate ?? this.rate,
      availableBalance: availableBalance ?? this.availableBalance,
      errorMessage: errorMessage ?? this.errorMessage,
      walletData: walletData ?? this.walletData,
    );
  }

  @override
  List<Object?> get props => [
    status,
    fromCurrency,
    toCurrency,
    fromAmount,
    toAmount,
    isSwapped,
    isAnimating,
    rate,
    availableBalance,
    errorMessage,
    walletData,
  ];
}
