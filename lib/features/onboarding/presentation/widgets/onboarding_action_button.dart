import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'onboarding_button_widget.dart';

class OnboardingActionButton extends StatelessWidget {
  final PageController pageController;
  final ValueNotifier<int> currentPageNotifier;
  final int totalPages;
  final VoidCallback onComplete;

  const OnboardingActionButton({
    super.key,
    required this.pageController,
    required this.currentPageNotifier,
    required this.totalPages,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ValueListenableBuilder<int>(
        valueListenable: currentPageNotifier,
        builder: (context, currentPage, _) {
          final isLastPage = currentPage == totalPages - 1;

          return OnboardingButtonWidget(
            text: isLastPage
                ? 'onboarding.get_started'.tr()
                : 'onboarding.next'.tr(),
            isNext: true,
            onPressed: () {
              if (isLastPage) {
                onComplete();
              } else {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          );
        },
      ),
    );
  }
}
