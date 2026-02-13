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
import 'verify_account_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.forgotPasswordSuccess) {
            context.push(
              AppRoutes.verifyAccount,
              extra: ScreenType.resetPassword,
            );
          } else if (state.status == AuthStatus.error) {
            showErrorSnackBar(context, state.errorMessage ?? 'Error');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                  ),
                  const AuthImageWidget(imagePath: 'assets/images/logo.png'),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'auth.forgot_password_title'.tr(),
                    style: AppTextStyles.h2,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'auth.forgot_password_subtitle'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  AuthTextFieldWidget(
                    controller: emailController,
                    label: 'auth.email'.tr(),
                    hint: 'auth.email_hint'.tr(),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  AuthButtonWidget(
                    text: 'auth.send_reset_link'.tr(),
                    isLoading: state.isLoading,
                    onPressed: () {
                      if (emailController.text.isNotEmpty) {
                        context.read<AuthCubit>().forgotPassword(
                          email: emailController.text,
                        );
                      }
                    },
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'auth.back_to_login'.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
