import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/plans_response.dart';
import 'package:crypto_app/core/theme/app_colors.dart';
import 'package:crypto_app/core/theme/app_text_styles.dart';
import 'package:crypto_app/core/utils/app_spacing.dart';
import 'package:crypto_app/features/plan/presentation/cubit/plans_cubit.dart';
import 'package:crypto_app/features/plan/presentation/cubit/plans_state.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:easy_localization/easy_localization.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;

  const PlanCard({super.key, required this.plan});

  void _showSubscriptionDialog(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final userBalance = (authState.user?.user?.balance ?? 0).toDouble();
    final planPrice = double.tryParse(plan.price) ?? 0.0;

    if (userBalance < planPrice) {
      _showInsufficientBalanceDialog(context);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'plans.confirm_subscription'.tr(),
          style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'plans.subscription_message'.tr(
            namedArgs: {'name': plan.name, 'price': plan.price},
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'common.cancel'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PlansCubit>().subscribePlan(plan.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              'plans.subscribe'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInsufficientBalanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'plans.insufficient_balance'.tr(),
          style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'plans.insufficient_balance_message'.tr(
            namedArgs: {'price': plan.price},
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'common.ok'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSpecial = plan.special == 1;

    if (isSpecial) {
      return _buildSpecialPlanCard(context);
    }
    return _buildNormalPlanCard(context);
  }

  Widget _buildNormalPlanCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Stack(
          children: [
            Positioned(
              top: -15,
              right: -15,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${plan.profitMargin}%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    plan.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                  const Divider(color: AppColors.border, thickness: 0.5),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'plans.price'.tr(),
                          '\$${plan.price}',
                          Icons.payments_outlined,
                          AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'plans.duration'.tr(),
                          '${plan.durationDays} ${'common.days'.tr()}',
                          Icons.timer_outlined,
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  BlocBuilder<PlansCubit, PlansState>(
                    builder: (context, state) {
                      final isAlreadySubscribed = state.activePlans.any(
                        (activePlan) => activePlan.plan.id == plan.id,
                      );

                      return SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: isAlreadySubscribed
                              ? null
                              : () => _showSubscriptionDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAlreadySubscribed
                                ? AppColors.border
                                : AppColors.primary,
                            foregroundColor: isAlreadySubscribed
                                ? AppColors.textTertiary
                                : Colors.white,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            disabledBackgroundColor: AppColors.border,
                            disabledForegroundColor: AppColors.textTertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                          ),
                          child: Text(
                            isAlreadySubscribed
                                ? 'plans.already_subscribed'.tr()
                                : 'plans.select'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialPlanCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'HOT'.tr(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${plan.profitMargin}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    plan.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    plan.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _buildInfoItem(
                        'plans.price'.tr(),
                        '\$${plan.price}',
                        Icons.payments_outlined,
                        Colors.white,
                      ),
                      const Spacer(),
                      _buildInfoItem(
                        'plans.duration'.tr(),
                        '${plan.durationDays} ${'common.days'.tr()}',
                        Icons.timer_outlined,
                        Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  BlocBuilder<PlansCubit, PlansState>(
                    builder: (context, state) {
                      final isAlreadySubscribed = state.activePlans.any(
                        (activePlan) => activePlan.plan.id == plan.id,
                      );

                      return SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: isAlreadySubscribed
                              ? null
                              : () => _showSubscriptionDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAlreadySubscribed
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.white,
                            foregroundColor: isAlreadySubscribed
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppColors.primary,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            disabledForegroundColor: Colors.white.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          child: Text(
                            isAlreadySubscribed
                                ? 'plans.already_subscribed'.tr()
                                : 'plans.subscribe_now'.tr(),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isAlreadySubscribed
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color == Colors.white
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
