import 'package:crypto_app/core/routes/app_routes.dart';
import 'package:crypto_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:crypto_app/features/home/presentation/widgets/market_list_widget.dart';
import 'package:crypto_app/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_spacing.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/action_button_widget.dart';
import '../widgets/home_header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Start market stream when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currencies = context.read<AuthCubit>().state.currencies;

      if (currencies != null && currencies.isNotEmpty) {
        final currencyApiIds = currencies.map((c) => c.symbol).toList();
        context.read<HomeCubit>().startMarketStream(currencyApiIds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.user?.user?.isBannedChat == 1) {
          context.read<AuthCubit>().logout();
        }
        if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const HomeHeaderWidget(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<AuthCubit>().fetchUserData();
                    final currencies = context
                        .read<AuthCubit>()
                        .state
                        .currencies;
                    if (currencies != null && currencies.isNotEmpty) {
                      final currencyApiIds = currencies
                          .map((c) => c.symbol)
                          .toList();
                      await context.read<HomeCubit>().refreshMarketData(
                        currencyApiIds,
                      );
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BalanceCardWidget(),
                        SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ActionButtonWidget(
                              icon: Icons.download,
                              label: 'home.deposit'.tr(),
                              onTap: () async {
                                await context.pushNamed(AppRoutes.deposit);
                                // Fetch user data after returning from deposit screen
                                if (context.mounted) {
                                  context.read<AuthCubit>().fetchUserData();
                                }
                              },
                            ),
                            ActionButtonWidget(
                              icon: Icons.upload,
                              label: 'home.withdraw'.tr(),
                              onTap: () async {
                                await context.pushNamed(AppRoutes.withdraw);
                                // Fetch user data after returning from withdraw screen
                                if (context.mounted) {
                                  context.read<AuthCubit>().fetchUserData();
                                }
                              },
                            ),
                            ActionButtonWidget(
                              icon: Icons.swap_vert,
                              label: 'home.convert'.tr(),
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

                        SizedBox(height: AppSpacing.lg),
                        const MarketListWidget(),
                        SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
