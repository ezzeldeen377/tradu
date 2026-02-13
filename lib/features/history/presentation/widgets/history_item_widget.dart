import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/history_model.dart';

class HistoryItemWidget extends StatelessWidget {
  final HistoryItemModel item;

  const HistoryItemWidget({super.key, required this.item});

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return Icons.shopping_cart;
      case 'sell':
        return Icons.sell;
      case 'deposits':
        return Icons.arrow_downward;
      case 'withdrawls':
        return Icons.arrow_upward;
      case 'plans':
        return Icons.card_membership;
      case 'alt':
        return Icons.swap_horiz;
      default:
        return Icons.history;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return const Color(0xFF4CAF50); // Green
      case 'sell':
        return const Color(0xFFF44336); // Red
      case 'deposits':
        return const Color(0xFF2196F3); // Blue
      case 'withdrawls':
        return const Color(0xFFFF9800); // Orange
      case 'plans':
        return const Color(0xFF9C27B0); // Purple
      case 'alt':
        return const Color(0xFF00BCD4); // Cyan
      default:
        return const Color(0xFF607D8B); // Grey
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'history.yesterday'.tr();
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${'history.days_ago'.tr()}';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return 'history.buy'.tr();
      case 'sell':
        return 'history.sell'.tr();
      case 'deposits':
        return 'history.deposits'.tr();
      case 'withdrawls':
        return 'history.withdrawals'.tr();
      case 'plans':
        return 'history.tabs.plans'.tr();
      case 'alt':
        return 'history.tabs.alt'.tr();
      default:
        return type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _getColorForType(item.type);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: AppSpacing.height(48),
            height: AppSpacing.height(48),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              _getIconForType(item.type),
              color: iconColor,
              size: AppSpacing.iconMd,
            ),
          ),
          SizedBox(width: AppSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatDate(item.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Text(
                        _getTypeLabel(item.type),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arrow icon
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: AppSpacing.iconMd,
          ),
        ],
      ),
    );
  }
}
