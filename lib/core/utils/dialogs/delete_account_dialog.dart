import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_text_styles.dart';
import '../app_spacing.dart';
import '../../routes/app_routes.dart';
import '../show_snack_bar.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';

/// Show delete account confirmation dialog
void showDeleteAccountDialog(BuildContext context) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'profile.delete_account_title'.tr(),
        style: AppTextStyles.h3.copyWith(color: theme.colorScheme.error),
      ),
      content: Text(
        'profile.delete_account_message'.tr(),
        style: AppTextStyles.bodyMedium.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            'common.cancel'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            await performDeleteAccount(context);
          },
          child: Text(
            'profile.delete'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Perform account deletion with loading overlay
Future<void> performDeleteAccount(BuildContext context) async {
  final theme = Theme.of(context);

  // Show loading overlay
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Material(
      child: PopScope(
        canPop: false,
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                SizedBox(height: AppSpacing.md),
                Text(
                  'profile.deleting_account'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  try {
    // Perform delete account
    await context.read<AuthCubit>().deleteAccount();

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();

      // Navigate to login
      context.go(AppRoutes.login);
    }
  } catch (e) {
    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
      showErrorSnackBar(context, 'profile.delete_account_error'.tr());
    }
  }
}
