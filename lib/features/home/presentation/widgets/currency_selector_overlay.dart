import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class CurrencySelectorOverlay extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencySelected;
  final VoidCallback onDismiss;

  const CurrencySelectorOverlay({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencies = context.read<AuthCubit>().state.currencies ?? [];

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.currency_exchange,
                      size: AppSpacing.iconSm,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'home.select_currency'.tr(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Currency List
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
                    final isSelected = currency.symbol == selectedCurrency;

                    return InkWell(
                      onTap: () {
                        onCurrencySelected(currency.symbol);
                        onDismiss();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Currency Icon
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  currency.symbol.substring(0, 1),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: AppSpacing.sm),

                            // Currency Symbol and Name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currency.symbol,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    currency.name,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Selected Indicator
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                size: AppSpacing.iconSm,
                                color: theme.colorScheme.primary,
                              ),
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
      ),
    );
  }

  static void show({
    required BuildContext context,
    required String selectedCurrency,
    required Function(String) onCurrencySelected,
    required Offset position,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent barrier to close overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: () => overlayEntry.remove(),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Currency selector positioned near the tap
          Positioned(
            left: position.dx,
            top: position.dy + 10,
            child: CurrencySelectorOverlay(
              selectedCurrency: selectedCurrency,
              onCurrencySelected: onCurrencySelected,
              onDismiss: () => overlayEntry.remove(),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);
  }
}
