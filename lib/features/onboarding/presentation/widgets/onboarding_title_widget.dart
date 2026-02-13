import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingTitleWidget extends StatelessWidget {
  final String titleKey;
  final String highlightedTitleKey;

  const OnboardingTitleWidget({
    super.key,
    required this.titleKey,
    required this.highlightedTitleKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.h2,
        children: [
          TextSpan(text: titleKey.tr()),
          if (highlightedTitleKey.isNotEmpty)
            TextSpan(
              text: highlightedTitleKey.tr(),
              style: AppTextStyles.h2.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
