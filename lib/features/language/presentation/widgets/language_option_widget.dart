import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';

class LanguageOptionWidget extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final String nativeName;
  final bool isSelected;
  final bool isDefault;
  final VoidCallback onTap;

  const LanguageOptionWidget({
    super.key,
    required this.languageCode,
    required this.languageName,
    required this.nativeName,
    required this.isSelected,
    required this.onTap,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final borderColor = theme.dividerColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.height(20)),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.6)
                : borderColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.height(48),
              height: AppSpacing.height(48),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.1)
                    : borderColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  languageCode.toUpperCase(),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? primaryColor : onSurfaceColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: onSurfaceColor,
                    ),
                  ),
                  if (isDefault) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      languageName,
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF5D6F8F),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: AppSpacing.height(24),
              height: AppSpacing.height(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : borderColor,
                  width: 2,
                ),
                color: Colors.transparent,
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
