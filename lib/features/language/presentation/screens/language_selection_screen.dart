import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import '../cubit/language_cubit.dart';
import '../cubit/language_state.dart';
import '../widgets/language_option_widget.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.xl),
                  Text(
                    'language_selection.title'.tr(),
                    style: AppTextStyles.h2,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'language_selection.subtitle'.tr(),
                    style: AppTextStyles.bodyMedium,
                  ),
                  SizedBox(height: AppSpacing.xxxl),
                  LanguageOptionWidget(
                    languageCode: 'en',
                    languageName: 'language_selection.default'.tr(),
                    nativeName: 'language_selection.english'.tr(),
                    isSelected: state.selectedLocale.languageCode == 'en',
                    onTap: () {
                      print('English selected');
                      context.read<LanguageCubit>().selectLanguage(
                        const Locale('en'),
                      );
                    },
                  ),
                  LanguageOptionWidget(
                    languageCode: 'ع',
                    languageName: 'Arabic',
                    nativeName: 'language_selection.arabic'.tr(),
                    isSelected: state.selectedLocale.languageCode == 'ar',
                    isDefault: true,
                    onTap: () {
                      context.read<LanguageCubit>().selectLanguage(
                        const Locale('ar'),
                      );
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.height(56),
                    child: ElevatedButton(
                      onPressed: () async {
                        await context
                            .read<LanguageCubit>()
                            .confirmLanguageSelection();

                        if (context.mounted) {
                          context.go('/onboarding');
                        }
                      },
                      child: Text(
                        'language_selection.continue'.tr(),
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
