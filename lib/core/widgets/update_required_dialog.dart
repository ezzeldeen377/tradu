import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_spacing.dart';

class UpdateRequiredDialog extends StatelessWidget {
  final String currentVersion;
  final String newVersion;
  final bool isMandatory;

  const UpdateRequiredDialog({
    super.key,
    required this.currentVersion,
    required this.newVersion,
    this.isMandatory = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !isMandatory,
      child: AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: theme.colorScheme.primary,
              size: AppSpacing.iconLg,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'update.title'.tr(),
              style: AppTextStyles.h3.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMandatory
                  ? 'update.mandatory_message'.tr()
                  : 'update.optional_message'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                children: [
                  _buildVersionRow(
                    context,
                    'update.current_version'.tr(),
                    currentVersion,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  _buildVersionRow(
                    context,
                    'update.new_version'.tr(),
                    newVersion,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!isMandatory)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'update.later'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => _launchStore(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Text(
              'update.update_now'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow(BuildContext context, String label, String version) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          version,
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _launchStore() async {
    // TODO: Replace with your actual app store URLs
    const androidUrl =
        'https://play.google.com/store/apps/details?id=com.example.crypto_app';
    const iosUrl = 'https://apps.apple.com/app/idYOUR_APP_ID';

    // Use Android URL by default, you can add platform detection if needed
    const url = androidUrl;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
