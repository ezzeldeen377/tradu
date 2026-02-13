import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../data/models/plans_response.dart';
import 'package:crypto_app/core/theme/app_colors.dart';
import 'package:crypto_app/core/utils/app_spacing.dart';
import 'plan_card.dart';

class OffersCarouselWidget extends StatefulWidget {
  final List<Plan> offers;

  const OffersCarouselWidget({super.key, required this.offers});

  @override
  State<OffersCarouselWidget> createState() => _OffersCarouselWidgetState();
}

class _OffersCarouselWidgetState extends State<OffersCarouselWidget> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: AppSpacing.height(200),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.offers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: PlanCard(plan: widget.offers[index]),
              );
            },
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SmoothPageIndicator(
          controller: _pageController,
          count: widget.offers.length,
          effect: ExpandingDotsEffect(
            activeDotColor: AppColors.primary,
            dotColor: AppColors.border.withValues(alpha: 0.2),
            dotHeight: 8,
            dotWidth: 8,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }
}
