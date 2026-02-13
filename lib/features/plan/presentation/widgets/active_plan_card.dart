import 'package:flutter/material.dart';
import '../../data/models/active_plans_response.dart';
import 'package:crypto_app/core/theme/app_colors.dart';
import 'package:crypto_app/core/theme/app_text_styles.dart';
import 'package:crypto_app/core/utils/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivePlanCard extends StatelessWidget {
  final ActivePlan activePlan;

  const ActivePlanCard({super.key, required this.activePlan});

  @override
  Widget build(BuildContext context) {
    final progressInfo = _calculateProgress();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      activePlan.plan.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(activePlan.status),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniInfo(
                        'plans.current_profit'.tr(),
                        '\$${activePlan.profit.toStringAsFixed(2)}',
                        AppColors.success,
                      ),
                      _buildMiniInfo(
                        'plans.duration'.tr(),
                        '${progressInfo.daysSpent} / ${activePlan.plan.durationDays} ${'common.days'.tr()}',
                        AppColors.textSecondary,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.border.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 8,
                        width:
                            MediaQuery.of(context).size.width *
                            0.7 *
                            progressInfo.progress,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF4C8CFF)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(progressInfo.progress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.error).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        'plans.${status.toLowerCase()}'.tr(),
        style: AppTextStyles.bodySmall.copyWith(
          color: isActive ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  _ProgressInfo _calculateProgress() {
    final startTime =
        DateTime.tryParse(activePlan.startDate ?? '') ?? DateTime.now();
    final endTime = DateTime.tryParse(activePlan.expiryDate) ?? DateTime.now();
    final now = DateTime.now();
    final totalDays = activePlan.plan.durationDays;

    if (now.isBefore(startTime)) {
      return _ProgressInfo(progress: 0.0, daysSpent: 0);
    }
    if (now.isAfter(endTime)) {
      return _ProgressInfo(progress: 1.0, daysSpent: totalDays);
    }

    final totalDuration = endTime.difference(startTime).inSeconds;
    final currentDuration = now.difference(startTime).inSeconds;

    final progress = (currentDuration / totalDuration).clamp(0.0, 1.0);
    final daysSpent = (now.difference(startTime).inHours / 24).floor().clamp(
      0,
      totalDays,
    );

    return _ProgressInfo(progress: progress, daysSpent: daysSpent);
  }
}

class _ProgressInfo {
  final double progress;
  final int daysSpent;

  _ProgressInfo({required this.progress, required this.daysSpent});
}
