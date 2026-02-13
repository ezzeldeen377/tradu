import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';

class OnboardingButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isNext;

  const OnboardingButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.height(56),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: AppTextStyles.button),
            if (isNext) ...[
              SizedBox(width: AppSpacing.sm),
              Icon(Icons.arrow_forward, size: AppSpacing.iconMd),
            ],
          ],
        ),
      ),
    );
  }
}
