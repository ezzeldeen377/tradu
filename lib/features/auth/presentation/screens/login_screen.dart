import 'package:crypto_app/core/routes/app_routes.dart';
import 'package:crypto_app/features/auth/presentation/widgets/auth_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/show_snack_bar.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field_widget.dart';
import '../widgets/auth_button_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            // Check user role and redirect accordingly
            final userRole = state.user?.user?.role;
            if (userRole != null && userRole.toLowerCase() == 'admin') {
              context.go(AppRoutes.adminChats); // Admin goes to chats
            } else {
              context.go(AppRoutes.dashboard); // Regular user goes to dashboard
            }
          } else if (state.status == AuthStatus.error) {
            showErrorSnackBar(context, state.errorMessage ?? 'Error');
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthImageWidget(
                        imagePath: 'assets/images/logo.png',
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text('auth.welcome_back'.tr(), style: AppTextStyles.h2),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'auth.login_subtitle'.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      AuthTextFieldWidget(
                        controller: emailController,
                        label: 'auth.email'.tr(),
                        hint: 'auth.email_hint'.tr(),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      AuthTextFieldWidget(
                        controller: passwordController,
                        label: 'auth.password'.tr(),
                        hint: 'auth.password_hint'.tr(),
                        isPassword: true,
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.forgotPassword),
                          child: Text(
                            'auth.forgot_password'.tr(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      AuthButtonWidget(
                        text: 'auth.login'.tr(),
                        isLoading: state.isLoading,
                        onPressed: () {
                          context.read<AuthCubit>().login(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                        },
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.dont_have_account'.tr(),
                            style: AppTextStyles.bodySmall,
                          ),
                          TextButton(
                            onPressed: () => context.push('/signup'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                            ),
                            child: Text(
                              'auth.sign_up'.tr(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
              // Full-screen loading overlay when saving token
              if (state.isSavingToken)
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'auth.saving_credentials'.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
