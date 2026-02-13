import 'package:crypto_app/core/routes/app_routes.dart';
import 'package:crypto_app/core/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/onboarding_data.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/skip_button_widget.dart';
import '../widgets/page_indicator_widget.dart';
import '../widgets/onboarding_action_button.dart';
import '../../../../core/utils/app_spacing.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    final ValueNotifier<int> currentPageNotifier = ValueNotifier(0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SkipButtonWidget(
              onPressed: () async {
                await CacheService.setOnboardingCompleted();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  currentPageNotifier.value = index;
                },
                itemCount: OnboardingData.pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    page: OnboardingData.pages[index],
                  );
                },
              ),
            ),
            PageIndicatorWidget(
              controller: pageController,
              count: OnboardingData.pages.length,
            ),
            SizedBox(height: AppSpacing.lg),
            OnboardingActionButton(
              pageController: pageController,
              currentPageNotifier: currentPageNotifier,
              totalPages: OnboardingData.pages.length,
              onComplete: () async {
                await CacheService.setOnboardingCompleted();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
