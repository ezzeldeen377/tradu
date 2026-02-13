import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';

class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'verification_status.title'.tr(),
          style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shield Icon with Processing Badge
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: AppSpacing.height(200),
                          height: AppSpacing.height(200),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            size: AppSpacing.height(120),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Positioned(
                          bottom: AppSpacing.lg,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.hourglass_empty,
                                  size: AppSpacing.iconSm,
                                  color: Colors.white,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  'verification_status.processing'.tr(),
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xl * 2),
                    // Title
                    Text(
                      'verification_status.under_review'.tr(),
                      style: AppTextStyles.h1.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    // Status Steps
                    _buildStatusStep(
                      context,
                      icon: Icons.check_circle,
                      iconColor: const Color(0xFF10B981),
                      title: 'verification_status.documents_received'.tr(),
                      subtitle: 'verification_status.info_stored'.tr(),
                      isCompleted: true,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildStatusStep(
                      context,
                      icon: Icons.search,
                      iconColor: theme.colorScheme.primary,
                      title: 'verification_status.reviewing_details'.tr(),
                      subtitle: 'verification_status.verifying_id'.tr(),
                      isCompleted: false,
                      isActive: true,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildStatusStep(
                      context,
                      icon: Icons.notifications_outlined,
                      iconColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.3,
                      ),
                      title: 'verification_status.final_notification'.tr(),
                      subtitle: 'verification_status.alert_complete'.tr(),
                      isCompleted: false,
                    ),
                    SizedBox(height: AppSpacing.xl * 2),
                    // Estimated Time
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: AppSpacing.iconMd,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'verification_status.estimated_time'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            '< 24 hours',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRoutes.dashboard),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'verification_status.go_home'.tr(),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Implement contact support
                    },
                    icon: Icon(
                      Icons.support_agent,
                      size: AppSpacing.iconMd,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    label: Text(
                      'verification_status.contact_support'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusStep(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.dividerColor.withValues(alpha: 0.1),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.height(40),
            height: AppSpacing.height(40),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppSpacing.iconMd, color: iconColor),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs / 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
