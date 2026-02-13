import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/utils/app_spacing.dart';

class PageIndicatorWidget extends StatelessWidget {
  final PageController controller;
  final int count;

  const PageIndicatorWidget({
    super.key,
    required this.controller,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: ExpandingDotsEffect(
        activeDotColor: theme.colorScheme.primary,
        dotColor: theme.colorScheme.surface,
        dotHeight: AppSpacing.sm,
        dotWidth: AppSpacing.sm,
        expansionFactor: 4,
        spacing: AppSpacing.sm,
      ),
    );
  }
}
