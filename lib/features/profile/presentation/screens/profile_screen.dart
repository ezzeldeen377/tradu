import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/dialogs/logout_dialog.dart';
import '../../../../core/utils/dialogs/delete_account_dialog.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../language/presentation/cubit/language_cubit.dart';
import '../../../language/presentation/cubit/language_state.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_balance_widget.dart';
import '../widgets/profile_setting_item_widget.dart';
import '../widgets/profile_section_header_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isNotificationOpen = true;

  void _toggleNotification(bool value) {
    setState(() {
      _isNotificationOpen = value;
    });
  }

  void _changeLanguage(BuildContext context) {
    final currentLocale = context.locale;
    final newLocale = currentLocale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');

    context.read<LanguageCubit>().changeLanguage(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'profile.title'.tr(),
          style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null) ProfileHeaderWidget(user: user.user),
                SizedBox(height: AppSpacing.lg),
                if (user != null) ProfileBalanceWidget(user: user.user),
                SizedBox(height: AppSpacing.xl),
                ProfileSectionHeaderWidget(title: 'profile.app_settings'.tr()),
                SizedBox(height: AppSpacing.sm),
                BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, languageState) {
                    final isEnglish = languageState.locale.languageCode == 'en';
                    return ProfileSettingItemWidget(
                      icon: Icons.language,
                      iconColor: const Color(0xFFEC4899),
                      title: 'profile.language'.tr(),
                      trailing: isEnglish
                          ? 'profile.english'.tr()
                          : 'profile.arabic'.tr(),
                      onTap: () => _changeLanguage(context),
                    );
                  },
                ),
                ProfileSettingItemWidget(
                  icon: Icons.card_giftcard,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'profile.refer_and_earn'.tr(),
                  onTap: () => context.push(AppRoutes.referAndEarn),
                ),
                SizedBox(height: AppSpacing.lg),
                ProfileSectionHeaderWidget(title: 'profile.notifications'.tr()),
                SizedBox(height: AppSpacing.sm),
                ProfileSettingItemWidget(
                  icon: Icons.notifications_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'profile.push_notifications'.tr(),
                  hasSwitch: true,
                  switchValue: _isNotificationOpen,
                  onSwitchChanged: _toggleNotification,
                ),
                SizedBox(height: AppSpacing.lg),
                ProfileSectionHeaderWidget(title: 'profile.security'.tr()),
                SizedBox(height: AppSpacing.sm),
                ProfileSettingItemWidget(
                  icon: Icons.verified_user_outlined,
                  iconColor: const Color(0xFF10B981),
                  title: 'profile.identity_verification'.tr(),
                  trailing: 'profile.verified'.tr(),
                  onTap: () {},
                ),
                ProfileSettingItemWidget(
                  icon: Icons.security_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'profile.privacy_policy'.tr(),
                  onTap: () => context.push(AppRoutes.privacyPolicy),
                ),
                ProfileSettingItemWidget(
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'profile.terms_conditions'.tr(),
                  onTap: () => context.push(AppRoutes.termsConditions),
                ),
                SizedBox(height: AppSpacing.xl),
                ProfileSettingItemWidget(
                  icon: Icons.logout,
                  iconColor: const Color(0xFFEF4444),
                  title: 'profile.logout'.tr(),
                  onTap: () => showLogoutDialog(context),
                ),
                SizedBox(height: AppSpacing.sm),
                ProfileSettingItemWidget(
                  icon: Icons.delete_forever,
                  iconColor: const Color(0xFFEF4444),
                  title: 'profile.delete_account'.tr(),
                  onTap: () => showDeleteAccountDialog(context),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}
