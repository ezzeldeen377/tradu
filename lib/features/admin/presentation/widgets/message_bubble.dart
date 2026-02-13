import 'package:crypto_app/core/theme/app_colors.dart';
import 'package:crypto_app/core/theme/app_text_styles.dart';
import 'package:crypto_app/core/utils/app_spacing.dart';
import 'package:crypto_app/features/admin/data/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(
      Uri.parse(link.url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: message.message));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم نسخ النص')));
        },
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.primary
                      : AppColors.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusMd),
                    topRight: Radius.circular(AppSpacing.radiusMd),
                    bottomLeft: isMe
                        ? Radius.circular(AppSpacing.radiusMd)
                        : Radius.zero,
                    bottomRight: isMe
                        ? Radius.zero
                        : Radius.circular(AppSpacing.radiusMd),
                  ),
                  border: Border.all(
                    color: isMe
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Linkify(
                      onOpen: _onOpen,
                      text: message.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                      linkStyle: AppTextStyles.bodyMedium.copyWith(
                        color: isMe ? AppColors.background : AppColors.primary,
                        height: 1.4,
                        decoration: TextDecoration.underline,
                        decorationColor: isMe
                            ? AppColors.background
                            : AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isMe
                                ? Colors.black.withValues(alpha: 0.6)
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                        ),
                        if (isMe) ...[
                          SizedBox(width: AppSpacing.xs),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.isRead
                                ? Colors.blue
                                : Colors.black.withValues(alpha: 0.6),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
