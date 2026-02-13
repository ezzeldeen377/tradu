import 'package:crypto_app/core/di/di.dart';
import 'package:crypto_app/core/utils/app_spacing.dart';
import 'package:crypto_app/core/widgets/exit_app_wrapper.dart';
import 'package:crypto_app/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:crypto_app/features/home/presentation/screens/home_screen.dart';
import 'package:crypto_app/features/trade/presentation/screens/trade_screen.dart';
import 'package:crypto_app/features/history/presentation/screens/history_screen.dart';
import 'package:crypto_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:crypto_app/features/admin/data/models/chat_model.dart';
import 'package:crypto_app/core/routes/app_routes.dart';
import 'package:crypto_app/features/plan/presentation/cubit/plans_cubit.dart';
import 'package:crypto_app/features/plan/presentation/screens/plans_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/notification_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.index});
  final int? index;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int currentIndex;
  late List<Widget> _screens;
  late PageController _pageController;

  void _initScreens() {
    _screens = [
      BlocProvider(
        create: (context) => getIt<HomeCubit>(),
        child: const HomeScreen(),
      ),
      BlocProvider(
        create: (context) => getIt<PlansCubit>(),
        child: const PlansScreen(),
      ),
      const TradeScreen(),
      const HistoryScreen(),
      const WalletScreen(),
    ];
  }

  @override
  void initState() {
    super.initState();
    // Initialize current index from widget parameter or default to 0
    currentIndex = widget.index ?? 0;
    _pageController = PageController(initialPage: currentIndex);
    _initScreens();

    // Fetch user data and update FCM token when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AuthCubit>().fetchUserData();
      final token = await NotificationHelper.getFCMToken();
      if (token != null && mounted) {
        context.read<AuthCubit>().updateFCMToken(token);
      }
      context.read<AuthCubit>().createSupportChat();
    });
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != null && widget.index != currentIndex) {
      setState(() {
        currentIndex = widget.index!;
        _pageController.jumpToPage(currentIndex);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void changeTab(int index) {
    if (index == currentIndex) return;
    setState(() {
      currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Wait for currencies to be loaded
        if (authState.currencies == null || authState.currencies!.isEmpty) {
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Screens are initialized in initState or via _initScreens
        // This ensures they persist across tab switches

        return ExitAppWrapper(
          child: Scaffold(
            body: Stack(
              children: [
                // Main content with swipeable pages
                PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  children: _screens,
                ),

                // Floating support button
                PositionedDirectional(
                  end: AppSpacing.md,
                  bottom: AppSpacing.height(AppSpacing.md), // Above bottom nav
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      final unreadCount = authState.unreadMessagesCount ?? 0;
                      final supportChat = authState.supportChat;
                      final user = authState.user?.user;

                      return FloatingActionButton(
                        heroTag: 'support_button',
                        backgroundColor: theme.colorScheme.secondary,
                        onPressed: () {
                          print(supportChat);
                          if (!mounted) return;

                          if (user != null) {
                            // Use existing chat or create placeholder
                            final chat =
                                supportChat ??
                                Chat(
                                  id: supportChat?.id ?? -1,
                                  userId: user.id ?? -1,
                                  adminId: 0,
                                  lastMessage: '',
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  unreadMessagesCount: 0,
                                  user: user,
                                );

                            context.push(
                              AppRoutes.chatDetail,
                              extra: {'chat': chat, 'isAdmin': false},
                            );
                          }
                        },
                        child: unreadCount > 0
                            ? Badge.count(
                                count: unreadCount,
                                alignment: Alignment.topRight,
                                offset: const Offset(10, -15),
                                child: Icon(
                                  Icons.support_agent,
                                  color: theme.colorScheme.onSecondary,
                                  size: AppSpacing.iconXl,
                                ),
                              )
                            : Icon(
                                Icons.support_agent,
                                color: theme.colorScheme.onSecondary,
                                size: AppSpacing.iconXl,
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'trade_button', // Unique tag
              shape: const CircleBorder(),
              onPressed: () {
                setState(() => currentIndex = 2);
                _pageController.animateToPage(
                  2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.swap_horiz,
                color: theme.colorScheme.onPrimary,
                size: AppSpacing.iconLg,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              elevation: 0,
              notchMargin: 8.0,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              height: AppSpacing.height(55),
              shape: const CircularNotchedRectangle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavItem(
                    icon: Icons.home,
                    label: 'navigation.home'.tr(),
                    isSelected: currentIndex == 0,
                    onTap: () {
                      // Fetch user data when navigating to home
                      context.read<AuthCubit>().fetchUserData();
                      setState(() => currentIndex = 0);
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  _NavItem(
                    icon: Icons.bar_chart,
                    label: 'navigation.plans'.tr(),
                    isSelected: currentIndex == 1,
                    onTap: () {
                      setState(() => currentIndex = 1);
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  SizedBox(width: AppSpacing.height(56)),
                  _NavItem(
                    icon: Icons.history,
                    label: 'navigation.history'.tr(),
                    isSelected: currentIndex == 3,
                    onTap: () {
                      setState(() => currentIndex = 3);
                      _pageController.animateToPage(
                        3,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  _NavItem(
                    icon: Icons.account_balance_wallet,
                    label: 'navigation.wallet'.tr(),
                    isSelected: currentIndex == 4,
                    onTap: () {
                      setState(() => currentIndex = 4);
                      _pageController.animateToPage(
                        4,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: AppSpacing.iconMd,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
