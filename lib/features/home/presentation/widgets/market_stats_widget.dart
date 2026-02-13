import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class MarketStatsWidget extends StatelessWidget {
  const MarketStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'market.live_market'.tr(),
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text.rich(
                  TextSpan(
                    text: 'market.market_is_up'.tr(),
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: ' 2.4%',
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'market.global_cap'.tr() + ' \$2.34T',
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: AppSpacing.height(80),
            height: AppSpacing.height(80),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: CustomPaint(painter: _MiniChartPainter()),
          ),
        ],
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final barWidth = size.width / 7;
    final heights = [0.3, 0.5, 0.4, 0.6, 0.7, 0.8, 0.9];

    for (int i = 0; i < heights.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final barHeight = size.height * heights[i];
      final y = size.height - barHeight;

      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, y),
        paint..strokeWidth = 4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
