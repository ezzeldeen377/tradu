import 'package:flutter/material.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../data/models/user_wallet_model.dart';
import 'holding_item_widget.dart';

class HoldingsListWidget extends StatelessWidget {
  final List<WalletCryptocurrency> cryptocurrencies;
  final Map<String, double> marketPrices;

  const HoldingsListWidget({
    super.key,
    required this.cryptocurrencies,
    required this.marketPrices,
  });

  Color _getCoinColor(String symbol) {
    // Map common crypto symbols to their brand colors
    final colorMap = {
      'BTC': const Color(0xFFF7931A),
      'ETH': const Color(0xFF627EEA),
      'BNB': const Color(0xFFF3BA2F),
      'SOL': const Color(0xFF9945FF),
      'USDT': const Color(0xFF26A17B),
      'USDC': const Color(0xFF2775CA),
      'XRP': const Color(0xFF23292F),
      'ADA': const Color(0xFF0033AD),
      'DOGE': const Color(0xFFC2A633),
      'DOT': const Color(0xFFE6007A),
    };
    return colorMap[symbol.toUpperCase()] ?? const Color(0xFF6366F1);
  }

  String _calculateUsdValue(WalletCryptocurrency crypto) {
    final symbol = crypto.currencySymbol.toUpperCase();
    final price = marketPrices[symbol] ?? 0.0;
    final balance = crypto.balanceValue;
    final usdValue = balance * price;

    if (usdValue >= 1000) {
      return '\$${usdValue.toStringAsFixed(2)}';
    } else if (usdValue >= 1) {
      return '\$${usdValue.toStringAsFixed(2)}';
    } else {
      return '\$${usdValue.toStringAsFixed(4)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cryptocurrencies.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'No cryptocurrencies in wallet',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    // Filter out cryptocurrencies with zero balance
    final nonZeroCryptos = cryptocurrencies
        .where((crypto) => crypto.balanceValue > 0)
        .toList();

    if (nonZeroCryptos.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'No cryptocurrencies with balance',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Column(
      children: nonZeroCryptos.map((crypto) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: HoldingItemWidget(
            name: crypto.currencySymbol,
            fullName: crypto.currencyName,
            price: _calculateUsdValue(crypto),
            amount: '${crypto.formattedBalance} ${crypto.currencySymbol}',
            color: _getCoinColor(crypto.currencySymbol),
          ),
        );
      }).toList(),
    );
  }
}
