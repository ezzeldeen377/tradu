import 'package:crypto_app/core/routes/app_routes.dart';
import 'package:crypto_app/core/services/notification_helper.dart';
import 'package:crypto_app/core/theme/app_colors.dart';
import 'package:crypto_app/core/theme/app_text_styles.dart';
import 'package:crypto_app/core/utils/app_spacing.dart';
import 'package:crypto_app/features/admin/presentation/cubits/chats_cubit/chats_cubit.dart';
import 'package:crypto_app/features/admin/presentation/widgets/chat_list_item.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch chats when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<ChatsCubit>().fetchChats();

      // Update FCM token for admin
      final token = await NotificationHelper.getFCMToken();
      if (token != null && mounted) {
        context.read<AuthCubit>().updateFCMToken(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!state.isAuthenticated) {
          // User logged out, navigate to login
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          title: Text(
            'admin.chats_title'.tr(),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                // Show logout confirmation
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    title: Text(
                      'admin.logout_confirm'.tr(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'admin.logout_message'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'admin.cancel'.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.read<AuthCubit>().logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                        ),
                        child: Text(
                          'admin.logout'.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout, color: AppColors.error),
            ),
          ],
        ),
        body: BlocBuilder<ChatsCubit, ChatsState>(
          builder: (context, state) {
            if (state.status == ChatsStatus.loading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.status == ChatsStatus.failure) {
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
                        context.read<ChatsCubit>().fetchChats();
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

            if (state.status == ChatsStatus.success && state.chats.isEmpty) {
              return Center(
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
                      'admin.no_chats'.tr(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<ChatsCubit>().refreshChats();
              },
              color: AppColors.primary,
              backgroundColor: theme.colorScheme.surface,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: state.chats.length,
                itemBuilder: (context, index) {
                  final chat = state.chats[index];
                  final isAdmin =
                      context.read<AuthCubit>().state.user?.user?.role ==
                      'admin';

                  return ChatListItem(
                    chat: chat,
                    onTap: () {
                      // Navigate to chat detail screen
                      // TODO: Add navigation using GoRouter
                      context.pushNamed(
                        AppRoutes.chatDetail,
                        extra: {'chat': chat, 'isAdmin': isAdmin},
                      );
                    },
                    onBanToggle: isAdmin
                        ? (userId, isBannedChat) {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                backgroundColor: theme.colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                                title: Text(
                                  isBannedChat == 1
                                      ? 'admin.ban_user'.tr()
                                      : 'admin.unban_user'.tr(),
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  isBannedChat == 1
                                      ? 'admin.ban_confirm'.tr()
                                      : 'admin.unban_confirm'.tr(),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: Text(
                                      'admin.cancel'.tr(),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                      context
                                          .read<ChatsCubit>()
                                          .changeUserChatStatus(
                                            userId,
                                            isBannedChat,
                                          );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isBannedChat == 1
                                                ? 'admin.user_banned'.tr()
                                                : 'admin.user_unbanned'.tr(),
                                          ),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isBannedChat == 1
                                          ? AppColors.error
                                          : AppColors.success,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'admin.confirm'.tr(),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
