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

class ResetPasswordScreen extends StatelessWidget {
  final String code;
  const ResetPasswordScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.resetPasswordSuccess) {
            showSuccessSnackBar(context, 'auth.password_reset_success'.tr());
            context.go(AppRoutes.login);
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
                  Text('auth.reset_password'.tr(), style: AppTextStyles.h2),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'auth.reset_password_subtitle'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  AuthTextFieldWidget(
                    controller: newPasswordController,
                    label: 'auth.new_password'.tr(),
                    hint: 'auth.password_hint'.tr(),
                    isPassword: true,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AuthTextFieldWidget(
                    controller: confirmPasswordController,
                    label: 'auth.confirm_new_password'.tr(),
                    hint: 'auth.password_hint'.tr(),
                    isPassword: true,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  AuthButtonWidget(
                    text: 'auth.set_new_password'.tr(),
                    isLoading: state.isLoading,
                    onPressed: () {
                      if (newPasswordController.text ==
                          confirmPasswordController.text) {
                        context.read<AuthCubit>().resetPassword(
                          code: code,
                          newPassword: newPasswordController.text,
                        );
                      } else {
                        showErrorSnackBar(
                          context,
                          'validation.passwords_dont_match'.tr(),
                        );
                      }
                    },
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
