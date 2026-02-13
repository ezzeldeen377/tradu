import 'package:flutter/material.dart';
import '../../../../core/utils/app_spacing.dart';

class OnboardingImageWidget extends StatelessWidget {
  final String imagePath;

  const OnboardingImageWidget({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.height(280),
      child: Image.asset(imagePath, fit: BoxFit.contain),
    );
  }
}
