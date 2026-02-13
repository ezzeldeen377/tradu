import 'package:flutter/material.dart';
import '../../../auth/data/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';

class CurrencyDropdownWidget extends StatelessWidget {
  final String selectedCurrency;
  final List<CurrencyModel> currencies;
  final Function(CurrencyModel) onSelected;

  const CurrencyDropdownWidget({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onSelected,
  });

  Color _getCurrencyColor(String currency) {
    switch (currency.toUpperCase()) {
      case 'BTC':
        return const Color(0xFFF7931A);
      case 'ETH':
        return const Color(0xFF627EEA);
      case 'USDT':
        return const Color(0xFF26A17B);
      case 'BNB':
        return const Color(0xFFF3BA2F);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<CurrencyModel>(
        onSelected: onSelected,
        offset: const Offset(0, 45),
        color: AppColors.surfaceLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColors.border),
        ),
        itemBuilder: (context) {
          return currencies.map((currency) {
            final isSelected = currency.symbol == selectedCurrency;
            return PopupMenuItem<CurrencyModel>(
              value: currency,
              padding: EdgeInsets.zero,
              child: Container(
                width: 150,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getCurrencyColor(currency.symbol),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          currency.symbol.isNotEmpty ? currency.symbol[0] : '?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        currency.symbol,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.primary,
                      ),
                  ],
                ),
              ),
            );
          }).toList();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getCurrencyColor(selectedCurrency),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    selectedCurrency.isNotEmpty ? selectedCurrency[0] : '?',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                selectedCurrency,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
