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
import '../widgets/auth_button_widget.dart';
import '../widgets/verification_code_widget.dart';

enum ScreenType { verifyAccount, resetPassword }

class VerifyAccountScreen extends StatelessWidget {
  const VerifyAccountScreen({super.key, required this.screenType});
  final ScreenType screenType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final codeNotifier = ValueNotifier<String>('');

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.forgotPasswordOtpVerified) {
            context.push(AppRoutes.resetPassword, extra: codeNotifier.value);
          } else if (state.status == AuthStatus.authenticated) {
            context.go(AppRoutes.dashboard);
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
                  Text('auth.verify_account'.tr(), style: AppTextStyles.h2),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '${'auth.verify_subtitle'.tr()} ${state.email ?? state.phone ?? ''}. ${'auth.verify_enter_code'.tr()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Center(
                    child: VerificationCodeWidget(
                      onChanged: (code) => codeNotifier.value = code,
                      onCompleted: (code) {
                        codeNotifier.value = code;
                        if (screenType == ScreenType.resetPassword) {
                          context.read<AuthCubit>().verifyForgotPasswordOtp(
                            code: code,
                          );
                        } else {
                          context.read<AuthCubit>().verifyOtp(code: code);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Center(
                    child: TextButton(
                      onPressed: state.isLoading
                          ? null
                          : () => context.read<AuthCubit>().resendOtp(),
                      child: Text(
                        'auth.didnt_receive_code'.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  ValueListenableBuilder<String>(
                    valueListenable: codeNotifier,
                    builder: (context, code, child) {
                      return AuthButtonWidget(
                        text: 'auth.verify_now'.tr(),
                        isLoading: state.isLoading,
                        onPressed: code.length == 6
                            ? () {
                                if (screenType == ScreenType.resetPassword) {
                                  context
                                      .read<AuthCubit>()
                                      .verifyForgotPasswordOtp(code: code);
                                } else {
                                  context.read<AuthCubit>().verifyOtp(
                                    code: code,
                                  );
                                }
                              }
                            : null,
                      );
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
