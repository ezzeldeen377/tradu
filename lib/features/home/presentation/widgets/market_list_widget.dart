import 'package:crypto_app/core/di/di.dart';
import 'package:crypto_app/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:crypto_app/features/home/presentation/cubit/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_app/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../screens/coin_details_screen.dart';
import 'market_coin_item_widget.dart';
import 'market_coin_shimmer.dart';

class MarketListWidget extends StatelessWidget {
  const MarketListWidget({super.key});

  // Coin color mapping
  Color _getCoinColor(String symbol) {
    final colors = {
      'BTCUSDT': const Color(0xFFF7931A),
      'ETHUSDT': const Color(0xFF627EEA),
      'BNBUSDT': const Color(0xFFF3BA2F),
      'SOLUSDT': const Color(0xFF9945FF),
      'XRPUSDT': const Color(0xFF23292F),
      'ADAUSDT': const Color(0xFF0033AD),
      'DOGEUSDT': const Color(0xFFC2A633),
      'TRXUSDT': const Color(0xFFFF0013),
      'MATICUSDT': const Color(0xFF8247E5),
    };
    return colors[symbol] ?? const Color(0xFF1F68F9);
  }

  // Map ticker symbol to currency api_id
  String _getApiIdFromSymbol(String symbol) {
    final symbolMap = {
      'BTCUSDT': 'bitcoin',
      'ETHUSDT': 'ethereum',
      'BNBUSDT': 'binancecoin',
      'SOLUSDT': 'solana',
      'XRPUSDT': 'ripple',
      'ADAUSDT': 'cardano',
      'DOGEUSDT': 'dogecoin',
      'TRXUSDT': 'tron',
      'MATICUSDT': 'matic-network',
    };
    return symbolMap[symbol] ?? symbol.toLowerCase().replaceAll('usdt', '');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // Loading state - show shimmer
        if (state.status == HomeStatus.loading || state.tickers.isEmpty) {
          final currencies = context.read<AuthCubit>().state.currencies ?? [];
          final itemCount = currencies.isNotEmpty ? currencies.length : 6;

          return Column(
            children: List.generate(
              itemCount,
              (index) => Column(
                children: [
                  const MarketCoinShimmer(),
                  if (index < itemCount - 1) SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          );
        }

        // Error state
        if (state.status == HomeStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.withValues(alpha: 0.7),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Failed to load market data',
                  style: TextStyle(color: Colors.red.withValues(alpha: 0.7)),
                ),
                if (state.errorMessage != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    state.errorMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        // Success state - show market data
        final sortedSymbols = state.sortedSymbols;
        final currencies = context.read<AuthCubit>().state.currencies ?? [];

        return Column(
          children: List.generate(sortedSymbols.length, (index) {
            final symbol = sortedSymbols[index];
            final ticker = state.tickers[symbol];

            // Skip if ticker not found (shouldn't happen)
            if (ticker == null) return const SizedBox.shrink();

            final isLast = index == sortedSymbols.length - 1;

            // Find matching currency by api_id
            final apiId = _getApiIdFromSymbol(ticker.symbol);
            final currency = currencies.firstWhere(
              (c) => c.apiId == apiId,
              orElse: () => currencies.first,
            );

            return Column(
              children: [
                MarketCoinItemWidget(
                  name: ticker.symbol.replaceAll('USDT', ''),
                  volume: ticker.formattedVolume,
                  price: ticker.formattedPrice,
                  change: ticker.formattedChange,
                  isPositive: ticker.isPositive,
                  image: currency.link,
                  color: _getCoinColor(ticker.symbol),
                  onTap: () {
                    context.push(
                      AppRoutes.coinDetails,
                      extra: {
                        'ticker': ticker,
                        'coinColor': _getCoinColor(ticker.symbol),
                      },
                    );
                  },
                ),
                if (!isLast) SizedBox(height: AppSpacing.sm),
              ],
            );
          }),
        );
      },
    );
  }
}
