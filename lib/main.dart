import 'package:crypto_app/core/di/di.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/version_gate.dart';
import 'features/language/presentation/cubit/language_cubit.dart';
import 'features/language/presentation/cubit/language_state.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';

import 'package:crypto_app/core/services/notification_helper.dart';
import 'core/widgets/exit_app_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  final token = await FirebaseMessaging.instance.getToken();
  print(token);
  configureDependencies();
  await NotificationHelper.init();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<LanguageCubit>()..loadSavedLanguage(),
        ),
        BlocProvider(
          create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider(
          create: (context) => OnboardingCubit()..checkOnboardingStatus(),
        ),
      ],
      child: const _AppContent(),
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, languageState) {
        return BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, onboardingState) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                // Show loading while checking language, onboarding, or auth status
                if (languageState.status == LanguageStatus.loading ||
                    onboardingState.status == OnboardingStatus.loading ||
                    authState.status == AuthStatus.initial) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.darkTheme,
                    home: Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                return BlocListener<LanguageCubit, LanguageState>(
                  listenWhen: (previous, current) =>
                      previous.selectedLocale != current.selectedLocale,
                  listener: (context, state) {
                    context.setLocale(state.selectedLocale);
                  },
                  child: ScreenUtilInit(
                    designSize: const Size(375, 812),
                    minTextAdapt: true,
                    splitScreenMode: true,
                    builder: (context, child) {
                      return VersionGate(
                        serverVersion: authState.appVersion ?? '0.0.0',
                        child: MaterialApp.router(
                          title: 'Tradu',
                          debugShowCheckedModeBanner: false,
                          localizationsDelegates: context.localizationDelegates,
                          supportedLocales: context.supportedLocales,
                          locale: languageState.selectedLocale,
                          theme: AppTheme.darkTheme,
                          routerConfig: AppRouter.router,
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
