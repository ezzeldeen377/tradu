import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../data/models/user_wallet_model.dart';

class WalletBalanceWidget extends StatelessWidget {
  final UserWalletModel walletData;
  final double totalBalanceUsd;

  const WalletBalanceWidget({
    super.key,
    required this.walletData,
    required this.totalBalanceUsd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Count only cryptocurrencies with non-zero balance
    final assetsWithBalance = walletData.cryptocurrencies
        .where((crypto) => crypto.balanceValue > 0)
        .length;

    return Column(
      children: [
        Text(
          '\$${totalBalanceUsd.toStringAsFixed(2)}',
          style: AppTextStyles.h1.copyWith(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          '$assetsWithBalance ${assetsWithBalance == 1 ? 'wallet.asset'.tr() : 'wallet.assets'.tr()}',
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
