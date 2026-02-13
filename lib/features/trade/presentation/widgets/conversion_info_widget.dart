import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ConversionInfoWidget extends StatelessWidget {
  final String rate;
  final String inverseRate;
  final String fees;

  const ConversionInfoWidget({
    super.key,
    required this.rate,
    required this.inverseRate,
    required this.fees,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _InfoRow(label: 'trade.rate'.tr(), value: rate, theme: theme),
        SizedBox(height: AppSpacing.sm),
        _InfoRow(
          label: 'trade.inverse_rate'.tr(),
          value: inverseRate,
          theme: theme,
        ),
        SizedBox(height: AppSpacing.sm),
        _InfoRow(
          label: 'trade.transaction_fees'.tr(),
          value: fees,
          theme: theme,
          valueColor: Colors.green,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (label == 'trade.rate'.tr()) ...[
              SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.info_outline,
                size: AppSpacing.iconSm,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
