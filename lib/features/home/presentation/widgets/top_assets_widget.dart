import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import 'asset_card_widget.dart';

class TopAssetsWidget extends StatelessWidget {
  const TopAssetsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('home.top_assets'.tr(), style: AppTextStyles.h3),
            Icon(
              Icons.tune,
              size: AppSpacing.iconMd,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Expanded(
              child: AssetCardWidget(
                name: 'BTC',
                price: '\$64,200',
                change: '+1.2%',
                isPositive: true,
                color: Color(0xFFF7931A),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            const Expanded(
              child: AssetCardWidget(
                name: 'ETH',
                price: '\$3,450',
                change: '-0.5%',
                isPositive: false,
                color: Color(0xFF627EEA),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
