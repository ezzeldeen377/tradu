import '../../../auth/data/models/currency_model.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../../core/di/di.dart';
import '../../../../core/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../home/presentation/widgets/home_header_widget.dart';
import '../cubit/trade_cubit.dart';
import '../cubit/trade_state.dart';
import '../widgets/currency_selector_widget.dart';
import '../widgets/conversion_info_widget.dart';

class TradeScreen extends StatelessWidget {
  const TradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tradeCubit = getIt<TradeCubit>();

    // Fetch wallet data when screen is built
    tradeCubit.fetchWalletData();

    // Initial check/update when screen is built
    final authState = context.read<AuthCubit>().state;
    if (authState.user?.user?.balance != null) {
      tradeCubit.updateAvailableBalance(
        authState.user!.user!.balance!.toDouble(),
      );
    }

    if (authState.currencies != null && authState.currencies!.isNotEmpty) {
      final symbols = authState.currencies!.map((e) => e.symbol).toList();
      tradeCubit.startMarketStream(symbols);
    }

    return BlocProvider.value(value: tradeCubit, child: const TradeView());
  }
}

class TradeView extends StatefulWidget {
  const TradeView({super.key});

  @override
  State<TradeView> createState() => _TradeViewState();
}

class _TradeViewState extends State<TradeView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectorHeight = AppSpacing.height(160);
    final spacing = AppSpacing.md;
    final totalTransitionHeight = (selectorHeight * 2) + spacing;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.user?.user?.balance != null) {
          context.read<TradeCubit>().updateAvailableBalance(
            state.user!.user!.balance!.toDouble(),
          );
        }
        if (state.currencies != null && state.currencies!.isNotEmpty) {
          final symbols = state.currencies!.map((e) => e.symbol).toList();
          context.read<TradeCubit>().startMarketStream(symbols);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const HomeHeaderWidget(),
              Expanded(
                child: BlocBuilder<TradeCubit, TradeState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: totalTransitionHeight,
                            child: Stack(
                              children: [
                                // Identity Widget 1 (Initially at Top, moves to Bottom on swap)
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutBack,
                                  top: state.isSwapped
                                      ? (selectorHeight + spacing)
                                      : 0,
                                  left: 0,
                                  right: 0,
                                  child: CurrencySelectorWidget(
                                    label: state.isSwapped
                                        ? 'trade.to'.tr()
                                        : 'trade.from'.tr(),
                                    currency: state.isSwapped
                                        ? state.toCurrency
                                        : state.fromCurrency,
                                    amount: state.isSwapped
                                        ? state.toAmount
                                        : state.fromAmount,
                                    availableBalance: state.isSwapped
                                        ? null
                                        : context
                                              .read<TradeCubit>()
                                              .getAvailableBalance(
                                                state.fromCurrency,
                                              ),
                                    isSwapped: !state.isAnimating,
                                    onCurrencyTap: () {},
                                    onCurrencyChanged:
                                        (CurrencyModel? currency) {
                                          if (currency == null) return;
                                          if (state.isSwapped) {
                                            context
                                                .read<TradeCubit>()
                                                .updateToCurrency(
                                                  currency.symbol,
                                                );
                                          } else {
                                            context
                                                .read<TradeCubit>()
                                                .updateFromCurrency(
                                                  currency.symbol,
                                                );
                                          }
                                        },
                                    onMaxTap: state.isSwapped
                                        ? null
                                        : () {
                                            final balance = context
                                                .read<TradeCubit>()
                                                .getAvailableBalance(
                                                  state.fromCurrency,
                                                );
                                            context
                                                .read<TradeCubit>()
                                                .updateFromAmount(balance);
                                          },
                                    onAmountChanged: (value) {
                                      if (state.isSwapped) {
                                        context
                                            .read<TradeCubit>()
                                            .updateToAmount(value);
                                      } else {
                                        context
                                            .read<TradeCubit>()
                                            .updateFromAmount(value);
                                      }
                                    },
                                  ),
                                ),

                                // Identity Widget 2 (Initially at Bottom, moves to Top on swap)
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutBack,
                                  top: state.isSwapped
                                      ? 0
                                      : (selectorHeight + spacing),
                                  left: 0,
                                  right: 0,
                                  child: CurrencySelectorWidget(
                                    label: state.isSwapped
                                        ? 'trade.from'.tr()
                                        : 'trade.to'.tr(),
                                    currency: state.isSwapped
                                        ? state.fromCurrency
                                        : state.toCurrency,
                                    amount: state.isSwapped
                                        ? state.fromAmount
                                        : state.toAmount,
                                    availableBalance: state.isSwapped
                                        ? context
                                              .read<TradeCubit>()
                                              .getAvailableBalance(
                                                state.fromCurrency,
                                              )
                                        : null,
                                    onCurrencyTap: () {},
                                    isSwapped: !state.isAnimating,
                                    onCurrencyChanged:
                                        (CurrencyModel? currency) {
                                          if (currency == null) return;
                                          if (state.isSwapped) {
                                            context
                                                .read<TradeCubit>()
                                                .updateFromCurrency(
                                                  currency.symbol,
                                                );
                                          } else {
                                            context
                                                .read<TradeCubit>()
                                                .updateToCurrency(
                                                  currency.symbol,
                                                );
                                          }
                                        },
                                    onMaxTap: state.isSwapped
                                        ? () {
                                            final balance = context
                                                .read<TradeCubit>()
                                                .getAvailableBalance(
                                                  state.fromCurrency,
                                                );
                                            context
                                                .read<TradeCubit>()
                                                .updateFromAmount(balance);
                                          }
                                        : null,
                                    onAmountChanged: (value) {
                                      if (state.isSwapped) {
                                        context
                                            .read<TradeCubit>()
                                            .updateFromAmount(value);
                                      } else {
                                        context
                                            .read<TradeCubit>()
                                            .updateToAmount(value);
                                      }
                                    },
                                  ),
                                ),

                                // Swap Button
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutBack,
                                  top:
                                      selectorHeight -
                                      (AppSpacing.height(100) / 2) +
                                      (spacing / 2),
                                  left:
                                      (MediaQuery.of(context).size.width -
                                              AppSpacing.lg * 2) /
                                          2 -
                                      (AppSpacing.height(48) / 2),
                                  child: GestureDetector(
                                    onTap: () => context
                                        .read<TradeCubit>()
                                        .swapCurrencies(),
                                    child: Container(
                                      width: AppSpacing.height(48),
                                      height: AppSpacing.height(48),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: AnimatedRotation(
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        turns: state.isSwapped ? 0.5 : 0,
                                        child: Icon(
                                          Icons.swap_vert,
                                          color: theme.colorScheme.primary,
                                          size: AppSpacing.iconMd,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.fromAmount > 0) ...[
                            SizedBox(height: AppSpacing.xl),
                            ConversionInfoWidget(
                              rate:
                                  '1 ${state.fromCurrency} ≈ ${state.rate.toStringAsFixed(6)} ${state.toCurrency}',
                              inverseRate:
                                  '1 ${state.toCurrency} ≈ ${(1 / (state.rate > 0 ? state.rate : 1)).toStringAsFixed(6)} ${state.fromCurrency}',
                              fees: 'trade.no_fees'.tr(),
                            ),
                          ],
                          SizedBox(height: AppSpacing.xxxl),
                          ElevatedButton(
                            onPressed: state.status == TradeStatus.loading
                                ? null
                                : () async {
                                    final tradeCubit = context
                                        .read<TradeCubit>();
                                    final fromBalance = tradeCubit
                                        .getAvailableBalance(
                                          state.fromCurrency,
                                        );
                                    if (state.fromAmount <= 0) return;
                                    if (state.fromAmount > fromBalance) {
                                      showErrorSnackBar(
                                        context,
                                        'trade.insufficient_balance'.tr(),
                                      );
                                      return;
                                    }
                                    final toCurrency = context
                                        .read<AuthCubit>()
                                        .state
                                        .currencies
                                        ?.firstWhere(
                                          (c) =>
                                              c.symbol.toUpperCase() ==
                                              state.toCurrency.toUpperCase(),
                                          orElse: () => throw Exception(
                                            'To currency not found',
                                          ),
                                        );
                                    final success = await tradeCubit
                                        .exchangeCryptoToCrypto(toCurrency!);

                                    if (!context.mounted) return;

                                    if (success) {
                                      showSuccessSnackBar(
                                        context,
                                        'trade.exchange_success'.tr(),
                                      );

                                      // Navigate to wallet tab
                                      final dashboardState = context
                                          .findAncestorStateOfType<
                                            State<DashboardScreen>
                                          >();
                                      if (dashboardState != null &&
                                          dashboardState.mounted) {
                                        (dashboardState as dynamic).changeTab(
                                          4,
                                        );
                                      }
                                    } else {
                                      // Show error message from cubit state
                                      final errorMessage =
                                          tradeCubit.state.errorMessage ??
                                          'trade.exchange_failed'.tr();
                                      showErrorSnackBar(context, errorMessage);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                              ),
                            ),
                            child: state.status == TradeStatus.loading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'trade.preview_conversion'.tr(),
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      const Icon(Icons.arrow_forward, size: 24),
                                    ],
                                  ),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: 'trade.by_clicking_preview'.tr(),
                                style: AppTextStyles.caption.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                children: [
                                  TextSpan(
                                    text: ' ${'trade.terms_of_use'.tr()}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: theme.colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
