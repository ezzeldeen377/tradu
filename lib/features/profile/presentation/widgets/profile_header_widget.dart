import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final User? user;

  const ProfileHeaderWidget({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVerified = user?.isVerified ?? false;
    final userName = user?.name ?? 'User';
    final userId = user?.userIdentifier?.toString() ?? '---';

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: AppSpacing.height(100),
                height: AppSpacing.height(100),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: AppSpacing.height(50),
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              if (isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: AppSpacing.height(32),
                    height: AppSpacing.height(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: AppSpacing.iconSm,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            userName,
            style: AppTextStyles.h2.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user?.role == 'admin')
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: AppSpacing.iconSm,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: AppSpacing.xs / 2),
                      Text(
                        'ADMIN',
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (user?.role == 'admin') SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: userId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('ID copied to clipboard'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      '${"profile.id".tr()}:',
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs / 2),
                    Text(
                      userId,
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs / 2),
                    Icon(
                      Icons.copy,
                      size: AppSpacing.iconSm,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
