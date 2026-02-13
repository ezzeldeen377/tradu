import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/market_ticker_model.dart';
import '../cubit/home/home_cubit.dart';
import '../cubit/home/home_state.dart';
import 'package:crypto_app/core/di/di.dart';
import 'package:crypto_app/features/trade/presentation/cubit/trade_cubit.dart';
import 'package:crypto_app/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class CoinDetailsScreen extends StatelessWidget {
  final MarketTickerModel ticker;
  final Color coinColor;

  const CoinDetailsScreen({
    super.key,
    required this.ticker,
    required this.coinColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coinName = ticker.symbol.replaceAll('USDT', '');

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) {
        // Only rebuild if the ticker for this coin changed or global UI state changed
        return previous.tickers[ticker.symbol] !=
                current.tickers[ticker.symbol] ||
            previous.selectedTab != current.selectedTab ||
            previous.selectedTimeframe != current.selectedTimeframe ||
            previous.priceHistory.length != current.priceHistory.length;
      },
      builder: (context, state) {
        final currentTicker = state.tickers[ticker.symbol] ?? ticker;

        // Ensure active coin is set in Cubit
        if (state.activeSymbol != ticker.symbol) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<HomeCubit>().setActiveCoin(ticker.symbol);
            // Also restart stream to ensure updates for this coin
            final coinSymbol = ticker.symbol.replaceAll('USDT', '');
            context.read<HomeCubit>().startMarketStream([coinSymbol]);
          });
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, theme, coinName),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppSpacing.lg),

                        // Price Section
                        _buildPriceSection(theme, currentTicker),

                        SizedBox(height: AppSpacing.xl),

                        // Chart section with real spots from history
                        _buildChartSection(theme, state.priceHistory),

                        SizedBox(height: AppSpacing.lg),

                        // Tabs
                        _buildTabs(context, theme, state.selectedTab),

                        SizedBox(height: AppSpacing.lg),

                        // Market Stats
                        if (state.selectedTab == 0)
                          _buildMarketStats(theme, currentTicker),

                        SizedBox(height: AppSpacing.xl),

                        // Action Buttons
                        _buildActionButtons(context, theme, coinName),

                        SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, String coinName) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          ),

          const Spacer(),

          // Coin Name
          Column(
            children: [
              Text(
                coinName,
                style: AppTextStyles.h3.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$coinName/USD',
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Favorite Button
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.star_border, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(ThemeData theme, MarketTickerModel ticker) {
    return Column(
      children: [
        // Price
        Text(
          ticker.formattedPrice,
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        SizedBox(height: AppSpacing.xs),

        // Change
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ticker.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: ticker.isPositive ? Colors.green : Colors.red,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              ticker.formattedChange,
              style: AppTextStyles.bodyMedium.copyWith(
                color: ticker.isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              'coin_details.past_24_hours'.tr(),
              style: AppTextStyles.caption.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection(ThemeData theme, List<double> history) {
    if (history.length < 2) {
      return Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: coinColor.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    final spots = List.generate(
      history.length,
      (index) => FlSpot(index.toDouble(), history[index]),
    );

    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: coinColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    coinColor.withValues(alpha: 0.3),
                    coinColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, ThemeData theme, int selectedTab) {
    final tabs = ['coin_details.overview'.tr()];

    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = selectedTab == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<HomeCubit>().updateTab(index);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[index],
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMarketStats(ThemeData theme, MarketTickerModel ticker) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'coin_details.market_stats'.tr(),
          style: AppTextStyles.h3.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: AppSpacing.md),

        // Stats Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              theme,
              Icons.account_balance_wallet,
              'coin_details.market_cap'.tr(),
              '\$828.5B',
            ),
            _buildStatCard(
              theme,
              Icons.bar_chart,
              'coin_details.volume_24h'.tr(),
              ticker.formattedVolume,
            ),
            _buildStatCard(
              theme,
              Icons.sync_alt,
              'coin_details.circulating_supply'.tr(),
              '19.5M ${ticker.symbol.replaceAll('USDT', '')}',
            ),
            _buildStatCard(
              theme,
              Icons.trending_up,
              'coin_details.all_time_high'.tr(),
              ticker.formattedPrice,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    String coinName,
  ) {
    return Row(
      children: [
        // Sell Button
        Expanded(
          child: Container(
            height: AppSpacing.height(54),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              color: Colors.red,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final tradeCubit = getIt<TradeCubit>();
                  tradeCubit.updateFromCurrency(coinName);
                  tradeCubit.updateToCurrency('USDT');
                  tradeCubit.updateFromAmount(0);
                  context.go('${AppRoutes.dashboard}?index=2');
                },
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'coin_details.sell'.tr(),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: AppSpacing.md),

        // Buy Button
        Expanded(
          flex: 2,
          child: Container(
            height: AppSpacing.height(54),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final tradeCubit = getIt<TradeCubit>();
                  tradeCubit.updateFromCurrency('USDT');
                  tradeCubit.updateToCurrency(coinName);
                  tradeCubit.updateFromAmount(0);
                  context.go('${AppRoutes.dashboard}?index=2');
                },
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_shopping_cart,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'coin_details.buy'.tr(args: [coinName]),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
