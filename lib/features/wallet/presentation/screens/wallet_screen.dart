import 'package:crypto_app/core/di/di.dart';
import 'package:crypto_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../widgets/wallet_balance_widget.dart';
import '../widgets/wallet_action_button_widget.dart';
import '../widgets/holdings_list_widget.dart';
import '../widgets/deposit_bottom_sheet.dart';
import '../widgets/withdraw_bottom_sheet.dart';
import '../../../home/presentation/widgets/home_header_widget.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WalletCubit>()..fetchUserWallet(),
      child: const _WalletScreenContent(),
    );
  }
}

class _WalletScreenContent extends StatelessWidget {
  const _WalletScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeaderWidget(),
            Expanded(
              child: BlocBuilder<WalletCubit, WalletState>(
                builder: (context, state) {
                  if (state.status == WalletStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == WalletStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'wallet.error'.tr(),
                            style: AppTextStyles.h3.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            state.errorMessage ?? 'Unknown error',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () {
                              context.read<WalletCubit>().refreshWallet();
                            },
                            child: Text('wallet.retry'.tr()),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.walletData == null) {
                    return Center(
                      child: Text(
                        'wallet.no_data'.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<WalletCubit>().refreshWallet(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        children: [
                          WalletBalanceWidget(
                            walletData: state.walletData!,
                            totalBalanceUsd: state.totalBalanceUsd,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              WalletActionButtonWidget(
                                icon: Icons.add,
                                label: 'wallet.buy'.tr(),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom,
                                      ),
                                      child: BlocProvider.value(
                                        value: context.read<WalletCubit>(),
                                        child: const DepositBottomSheet(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              WalletActionButtonWidget(
                                icon: Icons.remove,
                                label: 'wallet.sell'.tr(),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom,
                                      ),
                                      child: BlocProvider.value(
                                        value: context.read<WalletCubit>(),
                                        child: const WithdrawBottomSheet(),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              WalletActionButtonWidget(
                                icon: Icons.swap_horiz,
                                label: 'wallet.exchange'.tr(),
                                onTap: () {
                                  // Find the parent DashboardScreen and switch to Trade tab (index 2)
                                  final dashboardState = context
                                      .findAncestorStateOfType<
                                        State<DashboardScreen>
                                      >();
                                  if (dashboardState != null &&
                                      dashboardState.mounted) {
                                    (dashboardState as dynamic).changeTab(2);
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.xl),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              'wallet.holdings'.tr(),
                              style: AppTextStyles.h3.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),
                          HoldingsListWidget(
                            cryptocurrencies:
                                state.walletData!.cryptocurrencies,
                            marketPrices: state.marketPrices,
                          ),
                          SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
