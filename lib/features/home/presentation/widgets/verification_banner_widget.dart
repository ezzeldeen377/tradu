import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class VerificationBannerWidget extends StatelessWidget {
  const VerificationBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user?.user;
        final isVerified = user?.isVerified ?? false;

        // Don't show banner if user is verified
        if (isVerified) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home.complete_verification'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'home.unlock_features'.tr(),
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              ElevatedButton(
                onPressed: () => _handleVerificationTap(context, user),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                child: Text(
                  'home.verify_now'.tr(),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleVerificationTap(BuildContext context, dynamic user) {
    // TODO: Check user verification status from backend
    // For now, using a simple logic:
    // - If user has submitted documents (assuming some field indicates this), show status screen
    // - Otherwise, show identity verification screen

    // You can add a field like 'verificationStatus' to User model
    // For now, checking if user has any data (simplified logic)
    final hasSubmittedDocuments = user?.userIdentifier != null;

    if (hasSubmittedDocuments) {
      // Documents submitted, show status screen
      context.push(AppRoutes.verificationStatus);
    } else {
      // No documents submitted, show identity verification screen
      context.push(AppRoutes.identityVerification);
    }
  }
}
