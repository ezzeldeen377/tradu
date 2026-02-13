import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../data/models/notification_model.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItemWidget({super.key, required this.notification});

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'price_alert':
        return Icons.trending_up;
      case 'security':
        return Icons.shield_outlined;
      case 'promotion':
        return Icons.card_giftcard;
      case 'system':
        return Icons.build_outlined;
      case 'transaction':
        return Icons.swap_horiz;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'price_alert':
        return Colors.green;
      case 'security':
        return Colors.red;
      case 'promotion':
        return Colors.amber;
      case 'system':
        return Colors.blue;
      case 'transaction':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'notifications.just_now'.tr();
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${'notifications.minutes_ago'.tr()}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${'notifications.hours_ago'.tr()}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${'notifications.days_ago'.tr()}';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _getColorForType(notification.type);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: notification.isRead
            ? null
            : Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.height(48),
            height: AppSpacing.height(48),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              _getIconForType(notification.type),
              color: iconColor,
              size: AppSpacing.iconMd,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    if (!notification.isRead) ...[
                      SizedBox(width: AppSpacing.xs),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  notification.body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
