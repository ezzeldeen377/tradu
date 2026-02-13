import 'package:crypto_app/core/theme/app_colors.dart';
import 'package:crypto_app/core/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackBar(
      context,
      'home.id_copied'.tr(),
      backgroundColor: AppColors.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user?.user;
        final userName = user?.name ?? 'home.guest'.tr();
        final userIdentifier = user?.userIdentifier?.toString() ?? '';

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.push(AppRoutes.profile),
                child: CircleAvatar(
                  radius: AppSpacing.height(20),
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimary,
                    size: AppSpacing.iconMd,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (userIdentifier.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xs),
                      GestureDetector(
                        onTap: () => _copyToClipboard(context, userIdentifier),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${"profile.id".tr()}: $userIdentifier',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.copy,
                              size: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push(AppRoutes.notifications),
              ),
            ],
          ),
        );
      },
    );
  }
}
