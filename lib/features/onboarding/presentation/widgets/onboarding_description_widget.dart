import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingDescriptionWidget extends StatelessWidget {
  final String descriptionKey;

  const OnboardingDescriptionWidget({super.key, required this.descriptionKey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      descriptionKey.tr(),
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyMedium.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}
