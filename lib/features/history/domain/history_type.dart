enum HistoryType {
  deposits('deposits'),
  withdrawals('withdrawls'),
  plans('plans'),
  buy('buy'),
  sell('sell'),
  alt('alt'),
  referrals('referral_bonus');

  final String value;
  const HistoryType(this.value);

  String get displayName {
    switch (this) {
      case HistoryType.deposits:
        return 'history.tabs.deposits';
      case HistoryType.withdrawals:
        return 'history.tabs.withdrawals';
      case HistoryType.plans:
        return 'history.tabs.plans';
      case HistoryType.buy:
        return 'history.tabs.buy';
      case HistoryType.sell:
        return 'history.tabs.sell';
      case HistoryType.alt:
        return 'history.tabs.alt';
      case HistoryType.referrals:
        return 'history.tabs.referral_bonus';
    }
  }
}
