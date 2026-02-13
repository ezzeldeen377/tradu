import '../../data/models/user_wallet_model.dart';

enum WalletStatus { initial, loading, success, failure }

class WalletState {
  final WalletStatus status;
  final UserWalletModel? walletData;
  final double totalBalanceUsd;
  final Map<String, double> marketPrices;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.walletData,
    this.totalBalanceUsd = 0.0,
    this.marketPrices = const {},
    this.errorMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    UserWalletModel? walletData,
    double? totalBalanceUsd,
    Map<String, double>? marketPrices,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      walletData: walletData ?? this.walletData,
      totalBalanceUsd: totalBalanceUsd ?? this.totalBalanceUsd,
      marketPrices: marketPrices ?? this.marketPrices,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
