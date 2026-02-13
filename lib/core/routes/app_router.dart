import 'package:crypto_app/core/di/di.dart';
import 'package:crypto_app/features/auth/presentation/screens/identity_verification_screen.dart';
import 'package:crypto_app/features/auth/presentation/screens/verification_status_screen.dart';
import 'package:crypto_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:crypto_app/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:crypto_app/features/home/presentation/cubit/withdraw/withdraw_cubit.dart';
import 'package:crypto_app/features/home/presentation/screens/deposite_screen.dart';
import 'package:crypto_app/features/home/presentation/screens/withdraw_screen.dart';
import 'package:crypto_app/features/notifications/presentation/screens/notification_screen.dart';
import 'package:crypto_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:crypto_app/features/profile/presentation/screens/policy_screen.dart';
import 'package:crypto_app/features/profile/presentation/screens/refer_and_earn_screen.dart';
import 'package:crypto_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:crypto_app/features/trade/presentation/screens/trade_screen.dart';
import 'package:crypto_app/features/admin/presentation/screens/chats_screen.dart';
import 'package:crypto_app/features/admin/presentation/screens/chat_detail_screen.dart';
import 'package:crypto_app/features/admin/presentation/cubits/chats_cubit/chats_cubit.dart';
import 'package:crypto_app/features/admin/presentation/cubits/chat_detail_cubit/chat_detail_cubit.dart';
import 'package:crypto_app/features/admin/data/models/chat_model.dart';
import 'package:crypto_app/features/home/presentation/screens/coin_details_screen.dart';
import 'package:crypto_app/features/home/data/models/market_ticker_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/language/presentation/screens/language_selection_screen.dart';
import '../../features/language/presentation/cubit/language_cubit.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/verify_account_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import 'app_routes.dart';

class AppRouter {
  static bool _hasRedirected = false;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    restorationScopeId: 'app',
    redirect: (context, state) {
      // Only redirect on first navigation (app start), not on hot reload
      if (_hasRedirected) {
        return null;
      }

      // Only redirect if we're on the splash screen
      if (state.matchedLocation != AppRoutes.splash) {
        return null;
      }

      _hasRedirected = true;

      final languageState = context.read<LanguageCubit>().state;

      // If first time, show language selection
      if (languageState.isFirstTime) {
        return AppRoutes.languageSelection;
      }

      // Check auth status
      final authState = context.read<AuthCubit>().state;
      if (authState.isAuthenticated) {
        // Check if user is admin
        final userRole = authState.user?.user?.role;
        if (userRole != null && userRole.toLowerCase() == 'admin') {
          return AppRoutes.adminChats; // Admin users go to chats
        }
        return AppRoutes.dashboard; // Regular users go to dashboard
      }

      // Check if onboarding was completed
      final onboardingState = context.read<OnboardingCubit>().state;
      if (onboardingState.status == OnboardingStatus.completed) {
        return AppRoutes.login;
      }

      // Show onboarding for first time users
      return AppRoutes.onboarding;
    },
    routes: [
      GoRoute(
        name: AppRoutes.splash,
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.languageSelection,
        path: AppRoutes.languageSelection,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        name: AppRoutes.onboarding,
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.login,
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: AppRoutes.signup,
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        name: AppRoutes.forgotPassword,
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: AppRoutes.verifyAccount,
        path: AppRoutes.verifyAccount,
        builder: (context, state) {
          final screenType = state.extra as ScreenType?;
          return VerifyAccountScreen(
            screenType: screenType ?? ScreenType.verifyAccount,
          );
        },
      ),
      GoRoute(
        name: AppRoutes.resetPassword,
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final code = state.extra as String?;
          return ResetPasswordScreen(code: code ?? '');
        },
      ),
      GoRoute(
        name: AppRoutes.dashboard,
        path: AppRoutes.dashboard,
        builder: (context, state) {
          // Get optional index parameter from query params
          final indexParam = state.uri.queryParameters['index'];
          final index = indexParam != null ? int.tryParse(indexParam) : null;
          return DashboardScreen(index: index);
        },
      ),
      GoRoute(
        name: AppRoutes.notifications,
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        name: AppRoutes.profile,
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        name: AppRoutes.identityVerification,
        path: AppRoutes.identityVerification,
        builder: (context, state) => const IdentityVerificationScreen(),
      ),
      GoRoute(
        name: AppRoutes.verificationStatus,
        path: AppRoutes.verificationStatus,
        builder: (context, state) => const VerificationStatusScreen(),
      ),
      GoRoute(
        name: AppRoutes.deposit,
        path: AppRoutes.deposit,
        builder: (context, state) => const DepositScreen(),
      ),
      GoRoute(
        name: AppRoutes.withdraw,
        path: AppRoutes.withdraw,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<WithdrawCubit>(),
          child: const WithdrawScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.trade,
        path: AppRoutes.trade,
        builder: (context, state) => const TradeScreen(),
      ),
      GoRoute(
        name: AppRoutes.adminChats,
        path: AppRoutes.adminChats,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<ChatsCubit>(),
          child: const ChatsScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.chatDetail,
        path: AppRoutes.chatDetail,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final chat = args['chat'] as Chat;
          final isAdmin = args['isAdmin'] as bool;

          return BlocProvider(
            create: (context) {
              final cubit = getIt<ChatDetailCubit>();
              if (chat.id != -1) {
                cubit.fetchMessages(
                  chat.id.toString(),
                  isAdmin ? 'admin' : 'user',
                );
              }
              return cubit;
            },
            child: ChatDetailScreen(chat: chat, isAdmin: isAdmin),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.coinDetails,
        path: AppRoutes.coinDetails,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final ticker = extras['ticker'] as MarketTickerModel;
          final coinColor = extras['coinColor'] as Color;

          return BlocProvider.value(
            value: getIt<HomeCubit>(),
            child: CoinDetailsScreen(ticker: ticker, coinColor: coinColor),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.privacyPolicy,
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => PolicyScreen(
          title: 'policies.privacy_title'.tr(),
          content: 'policies.privacy_content'.tr(),
        ),
      ),
      GoRoute(
        name: AppRoutes.termsConditions,
        path: AppRoutes.termsConditions,
        builder: (context, state) => PolicyScreen(
          title: 'policies.terms_title'.tr(),
          content: 'policies.terms_content'.tr(),
        ),
      ),
      GoRoute(
        name: AppRoutes.referAndEarn,
        path: AppRoutes.referAndEarn,
        builder: (context, state) => const ReferAndEarnScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page not found'))),
  );

  static GoRouter get router => _router;
}
