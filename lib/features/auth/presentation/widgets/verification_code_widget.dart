import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';

class VerificationCodeWidget extends StatelessWidget {
  final Function(String)? onChanged;
  final Function(String)? onCompleted;
  final int length;

  const VerificationCodeWidget({
    super.key,
    this.onChanged,
    this.onCompleted,
    this.length = 6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default theme for pinput
    final defaultPinTheme = PinTheme(
      width: AppSpacing.height(56),
      height: AppSpacing.height(64),
      textStyle: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
    );

    // Focused theme
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
    );

    // Submitted theme (when filled)
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
    );

    // Error theme
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: theme.colorScheme.error, width: 2),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr, // Force LTR for OTP input
      child: Pinput(
        length: length,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        errorPinTheme: errorPinTheme,
        onChanged: onChanged,
        onCompleted: onCompleted,
        autofocus: true,
        keyboardType: TextInputType.number,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 24,
              height: 2,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        showCursor: true,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}
