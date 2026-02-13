import 'package:crypto_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:crypto_app/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:crypto_app/features/home/presentation/cubit/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/crypto_currency.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import 'currency_selector_overlay.dart';

class BalanceCardWidget extends StatefulWidget {
  const BalanceCardWidget({super.key});

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  final GlobalKey _currencyButtonKey = GlobalKey();

  void _showCurrencySelector(
    BuildContext context,
    String selectedCurrencyCode,
  ) {
    final RenderBox? renderBox =
        _currencyButtonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    CurrencySelectorOverlay.show(
      context: context,
      selectedCurrency: selectedCurrencyCode,
      onCurrencySelected: (currency) {
        context.read<HomeCubit>().updateCurrency(currency);
      },
      position: Offset(
        position.dx + size.width - size.width,
        position.dy + size.height,
      ),
    );
  }

  double _calculateLiveBalance(
    double baseBalanceUSD,
    Map<String, dynamic> tickers,
    CryptoCurrency selectedCurrency,
  ) {
    // If USD is selected, return the base balance
    if (selectedCurrency == CryptoCurrency.usd) {
      return baseBalanceUSD;
    }

    // Get the trading pair symbol for the selected currency
    // For example: BTCUSDT, ETHUSDT, etc.
    final symbol = '${selectedCurrency.code.toUpperCase()}USDT';

    // Check if we have live price data for this currency
    if (tickers.containsKey(symbol)) {
      final ticker = tickers[symbol];
      final livePrice = double.tryParse(ticker.price) ?? 0;

      // If we have a valid live price, use it to calculate the balance
      if (livePrice > 0) {
        // Convert USD balance to the selected cryptocurrency
        // balance in crypto = USD balance / live price
        final balanceInCrypto = baseBalanceUSD / livePrice;
        return balanceInCrypto;
      }
    }

    // Fallback to static conversion rate if no live data available
    return selectedCurrency.convertFromUSD(baseBalanceUSD);
  }

  String _formatBalance(
    double baseBalanceUSD,
    Map<String, dynamic> tickers,
    CryptoCurrency selectedCurrency,
  ) {
    final balance = _calculateLiveBalance(
      baseBalanceUSD,
      tickers,
      selectedCurrency,
    );

    final formattedAmount = selectedCurrency.formatAmount(balance);
    return '${selectedCurrency.symbol}$formattedAmount';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        final selectedCurrency = CryptoCurrency.fromCode(
          homeState.selectedCurrency,
        );
        print(homeState.selectedCurrency);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency Selector Row
            Row(
              children: [
                Text(
                  '${'home.total_balance'.tr()} (${selectedCurrency.code})',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.visibility_outlined,
                  size: AppSpacing.iconSm,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const Spacer(),
                // Currency selector button
                GestureDetector(
                  key: _currencyButtonKey,
                  onTap: () =>
                      _showCurrencySelector(context, selectedCurrency.code),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedCurrency.code,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: AppSpacing.iconSm,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final balanceUSD = (authState.user?.user?.balance ?? 0)
                    .toDouble();

                return Text(
                  _formatBalance(
                    balanceUSD,
                    homeState.tickers,
                    selectedCurrency,
                  ),
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.sm),
          ],
        );
      },
    );
  }
}
