import 'package:flutter/material.dart';
import '../../data/models/onboarding_model.dart';
import 'onboarding_image_widget.dart';
import 'onboarding_title_widget.dart';
import 'onboarding_description_widget.dart';
import '../../../../core/utils/app_spacing.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingModel page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(flex: 2),
          OnboardingImageWidget(imagePath: page.imagePath),
          SizedBox(height: AppSpacing.height(60)),
          OnboardingTitleWidget(
            titleKey: page.titleKey,
            highlightedTitleKey: page.highlightedTitleKey,
          ),
          SizedBox(height: AppSpacing.md),
          OnboardingDescriptionWidget(descriptionKey: page.descriptionKey),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
