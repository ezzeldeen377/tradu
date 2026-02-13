import 'dart:async';
import 'package:crypto_app/core/theme/app_colors.dart';
import 'package:crypto_app/core/theme/app_text_styles.dart';
import 'package:crypto_app/core/utils/app_spacing.dart';
import 'package:crypto_app/features/admin/data/models/chat_model.dart';
import 'package:crypto_app/features/admin/presentation/cubits/chat_detail_cubit/chat_detail_cubit.dart';
import 'package:crypto_app/features/admin/presentation/widgets/message_bubble.dart';
import 'package:crypto_app/features/admin/presentation/widgets/message_input.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;
  final bool isAdmin;

  const ChatDetailScreen({
    super.key,
    required this.chat,
    required this.isAdmin,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _initialScrollDone = false;
  StreamSubscription<RemoteMessage>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _setupMessageListener();
    // Fetch messages when screen loads
  }

  void _setupMessageListener() {
    _messageSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      if (message.data['action'] == 'new_message' &&
          message.data['chat_id'] == widget.chat.id.toString()) {
        if (mounted) {
          context.read<ChatDetailCubit>().fetchMessagesAuto(
            widget.chat.id.toString(),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: AppSpacing.height(20),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person,
                    size: AppSpacing.iconSm,
                    color: AppColors.primary,
                  ),
                ),
                // Online indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: AppSpacing.width(10),
                    height: AppSpacing.height(10),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isAdmin
                        ? (widget.chat.user.name ?? 'admin.unknown_user'.tr())
                        : 'admin.support'.tr(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'admin.online_now'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (widget.isAdmin)
            InkWell(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(
                    text: widget.chat.user.userIdentifier.toString(),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('admin.id_copied'.tr()),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: AppSpacing.md),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "${'admin.id'.tr()}: ${widget.chat.user.userIdentifier}",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.copy,
                      color: AppColors.primary,
                      size: AppSpacing.iconSm,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: BlocConsumer<ChatDetailCubit, ChatDetailState>(
        listener: (context, state) {
          if (state.status == ChatDetailStatus.success ||
              state.status == ChatDetailStatus.sending) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state.status == ChatDetailStatus.loading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == ChatDetailStatus.failure &&
              state.messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    state.message ?? 'admin.error_occurred'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatDetailCubit>().fetchMessages(
                        widget.chat.id.toString(),
                        widget.isAdmin ? 'admin' : 'user',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: Text(
                      'admin.retry'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'admin.no_messages'.tr(),
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'admin.start_conversation'.tr(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final isMe = widget.isAdmin
                              ? message.senderType == 'admin'
                              : message.senderType == 'user';

                          // Trigger initial scroll if not done
                          if (!_initialScrollDone) {
                            _initialScrollDone = true;
                            _scrollToBottom();
                          }

                          return MessageBubble(message: message, isMe: isMe);
                        },
                      ),
              ),
              MessageInput(
                onSend: (content) {
                  if (widget.isAdmin) {
                    context.read<ChatDetailCubit>().sendMessageAsAdmin(
                      widget.chat.userId.toString(),
                      content,
                    );
                  } else {
                    context.read<ChatDetailCubit>().sendMessage(
                      widget.chat.id.toString(),
                      content,
                    );
                  }
                },
                isSending: state.status == ChatDetailStatus.sending,
              ),
            ],
          );
        },
      ),
    );
  }
}
