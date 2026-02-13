part of 'withdraw_cubit.dart';

enum WithdrawStatus {
  initial,
  loading,
  success,
  getBalance,
  failure,
}

extension WithdrawStateX on WithdrawState {
  bool get isInitial => status == WithdrawStatus.initial;
  bool get isLoading => status == WithdrawStatus.loading;
  bool get isSuccess => status == WithdrawStatus.success;
  bool get isFailure => status == WithdrawStatus.failure;
  bool get isGetBalance => status == WithdrawStatus.getBalance;
}

class WithdrawState {
  final WithdrawStatus status;
  final String? message;
  final int? balance;

  WithdrawState({
    required this.status,
    this.message,
    this.balance,
  });

  WithdrawState copyWith({
    WithdrawStatus? status,
    String? message,
    int? balance,
  }) {
    return WithdrawState(
      status: status ?? this.status,
      message: message ?? this.message,
      balance: balance ?? this.balance,
    );
  }

  @override
  String toString() {
    return 'WithdrawState(status: $status, message: $message, balance: $balance)';
  }
}