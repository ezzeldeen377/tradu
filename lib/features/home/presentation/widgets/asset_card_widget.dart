import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import 'dart:math' as math;

class AssetCardWidget extends StatelessWidget {
  final String name;
  final String price;
  final String change;
  final bool isPositive;
  final Color color;

  const AssetCardWidget({
    super.key,
    required this.name,
    required this.price,
    required this.change,
    required this.isPositive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSpacing.height(32),
                height: AppSpacing.height(32),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          CustomPaint(
            size: Size(double.infinity, AppSpacing.height(40)),
            painter: _ChartPainter(
              isPositive: isPositive,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            price,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.xsW),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: AppSpacing.iconSm,
                color: isPositive ? Colors.green : Colors.red,
              ),
              SizedBox(width: AppSpacing.xsW),
              Text(
                change,
                style: AppTextStyles.caption.copyWith(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final bool isPositive;
  final Color color;

  _ChartPainter({required this.isPositive, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = 20;

    for (int i = 0; i < points; i++) {
      final x = (size.width / points) * i;
      final y =
          size.height / 2 +
          math.sin((i / points) * math.pi * 2 + (isPositive ? 0 : math.pi)) *
              size.height /
              3;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
