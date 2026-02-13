import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import 'notification_item_widget.dart';

class NotificationListWidget extends StatelessWidget {
  const NotificationListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        // Loading state
        if (state.status == NotificationStatus.loading) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        // Error state
        if (state.status == NotificationStatus.failure) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'notifications.error'.tr(),
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      state.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationCubit>().fetchNotifications();
                    },
                    child: Text('notifications.retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (state.status == NotificationStatus.empty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'notifications.empty'.tr(),
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'notifications.empty_description'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Success state - display notifications
        return RefreshIndicator(
          onRefresh: () =>
              context.read<NotificationCubit>().refreshNotifications(),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: state.notifications.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              return NotificationItemWidget(notification: notification);
            },
          ),
        );
      },
    );
  }
}
