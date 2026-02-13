import 'models/onboarding_model.dart';

class OnboardingData {
  static const List<OnboardingModel> pages = [
    OnboardingModel(
      imagePath: 'assets/images/onboarding_1.png',
      titleKey: 'onboarding.page1.title',
      highlightedTitleKey: '',
      descriptionKey: 'onboarding.page1.description',
    ),
    OnboardingModel(
      imagePath: 'assets/images/onboarding_2.png',
      titleKey: 'onboarding.page2.title',
      highlightedTitleKey: 'onboarding.page2.highlighted_title',
      descriptionKey: 'onboarding.page2.description',
    ),
    OnboardingModel(
      imagePath: 'assets/images/onboarding_3.png',
      titleKey: 'onboarding.page3.title',
      highlightedTitleKey: 'onboarding.page3.highlighted_title',
      descriptionKey: 'onboarding.page3.description',
    ),
  ];
}
