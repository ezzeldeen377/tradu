import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';

class ProfileSettingItemWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? trailing;
  final Color? trailingColor;
  final bool hasSwitch;
  final bool switchValue;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSwitchChanged;

  const ProfileSettingItemWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    this.trailingColor,
    this.hasSwitch = false,
    this.switchValue = false,
    this.onTap,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: hasSwitch ? null : onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.height(40),
              height: AppSpacing.height(40),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: AppSpacing.iconMd),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: theme.colorScheme.primary,
              )
            else if (trailing != null)
              Row(
                children: [
                  Text(
                    trailing!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          trailingColor ??
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: trailingColor != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: AppSpacing.iconMd,
                  ),
                ],
              )
            else
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: AppSpacing.iconMd,
              ),
          ],
        ),
      ),
    );
  }
}
