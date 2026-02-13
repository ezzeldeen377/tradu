import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Show a snackbar with custom styling
void showSnackBar(
  BuildContext context,
  String content, {
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor ?? AppColors.error,
        content: Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: action,
      ),
    );
}

/// Show a success snackbar
void showSuccessSnackBar(BuildContext context, String content) {
  showSnackBar(context, content, backgroundColor: AppColors.success);
}

/// Show an error snackbar
void showErrorSnackBar(BuildContext context, String content) {
  showSnackBar(context, content, backgroundColor: AppColors.error);
}

/// Show a warning snackbar
void showWarningSnackBar(BuildContext context, String content) {
  showSnackBar(context, content, backgroundColor: AppColors.warning);
}

/// Show an info snackbar
void showInfoSnackBar(BuildContext context, String content) {
  showSnackBar(context, content, backgroundColor: AppColors.info);
}

/// Show a custom dialog with title and content
Future<void> showCustomDialog(
  BuildContext context,
  String content,
  String title,
  VoidCallback onPressed, {
  String? confirmText,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(
              confirmText ?? 'common.ok'.tr(),
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      );
    },
  );
}

/// Show a confirmation dialog with Yes/No options
Future<bool> showConfirmDialog(
  BuildContext context,
  String title,
  String content, {
  String? confirmText,
  String? cancelText,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          ),
          content: Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText ?? 'common.cancel'.tr(),
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                confirmText ?? 'common.confirm'.tr(),
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ) ??
      false;
}

/// Show exit app confirmation dialog
Future<bool> onWillPop(BuildContext context) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'common.exit_app'.tr(),
            style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          ),
          content: Text(
            'common.exit_app_message'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'common.no'.tr(),
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => exit(0), // Exit the app completely
              child: Text(
                'common.yes'.tr(),
                style: AppTextStyles.button.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ) ??
      false;
}
