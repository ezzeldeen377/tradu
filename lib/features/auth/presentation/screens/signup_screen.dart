import 'package:crypto_app/core/routes/app_routes.dart';
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
import '../widgets/phone_field_widget.dart';
import 'verify_account_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final referralCodeController = TextEditingController();
  String completePhoneNumber = '';
  bool agreedToTerms = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralCodeController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.full_name_required'.tr();
    }
    if (value.trim().length < 3) {
      return 'validation.full_name_too_short'.tr();
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.email_required'.tr();
    }
    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'validation.email_invalid'.tr();
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (completePhoneNumber.isEmpty) {
      return 'validation.phone_required'.tr();
    }
    if (completePhoneNumber.length < 10) {
      return 'validation.phone_invalid'.tr();
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation.password_required'.tr();
    }
    if (value.length < 8) {
      return 'validation.password_too_short'.tr();
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'validation.password_number'.tr();
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation.confirm_password_required'.tr();
    }
    if (value != passwordController.text) {
      return 'validation.passwords_dont_match'.tr();
    }
    return null;
  }

  void _handleSignUp() {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Manual phone validation
    if (completePhoneNumber.isEmpty) {
      showErrorSnackBar(context, 'validation.phone_required'.tr());
      return;
    }
    if (completePhoneNumber.length < 10) {
      showErrorSnackBar(context, 'validation.phone_invalid'.tr());
      return;
    }

    // Check terms agreement
    if (!agreedToTerms) {
      showWarningSnackBar(context, 'validation.agree_to_terms'.tr());
      return;
    }

    // All validations passed, proceed with signup
    context.read<AuthCubit>().signUp(
      fullName: fullNameController.text.trim(),
      email: emailController.text.trim(),
      phone: completePhoneNumber,
      password: passwordController.text,
      referralCode: referralCodeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              print(state.status);
              if (state.status == AuthStatus.authenticated) {
                context.go(AppRoutes.dashboard);
              } else if (state.status == AuthStatus.awaitingVerification) {
                // Navigate to OTP verification screen
                context.push(
                  AppRoutes.verifyAccount,
                  extra: ScreenType.verifyAccount,
                );
              } else if (state.status == AuthStatus.error) {
                showErrorSnackBar(context, state.errorMessage ?? 'Error');
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: AppSpacing.xl),
                    Text('auth.create_account'.tr(), style: AppTextStyles.h2),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'auth.signup_subtitle'.tr(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    AuthTextFieldWidget(
                      controller: fullNameController,
                      label: 'auth.full_name'.tr(),
                      hint: 'auth.full_name_hint'.tr(),
                      validator: _validateFullName,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AuthTextFieldWidget(
                      controller: emailController,
                      label: 'auth.email'.tr(),
                      hint: 'auth.email_hint'.tr(),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    PhoneFieldWidget(
                      controller: phoneController,
                      label: 'auth.phone'.tr(),
                      hint: 'auth.phone_hint'.tr(),
                      onChanged: (phone) {
                        setState(() {
                          completePhoneNumber = phone;
                        });
                      },
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AuthTextFieldWidget(
                      controller: passwordController,
                      label: 'auth.password'.tr(),
                      hint: 'auth.password_hint'.tr(),
                      isPassword: true,
                      validator: _validatePassword,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AuthTextFieldWidget(
                      controller: confirmPasswordController,
                      label: 'auth.confirm_password'.tr(),
                      hint: 'auth.confirm_password_hint'.tr(),
                      isPassword: true,
                      validator: _validateConfirmPassword,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AuthTextFieldWidget(
                      controller: referralCodeController,
                      label: 'auth.referral_code'.tr(),
                      hint: 'auth.referral_code_hint'.tr(),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        SizedBox(
                          height: AppSpacing.height(20),
                          width: AppSpacing.height(20),
                          child: Checkbox(
                            value: agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                agreedToTerms = value ?? false;
                              });
                            },
                            fillColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return theme.colorScheme.primary;
                              }
                              return theme.colorScheme.outline;
                            }),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'auth.agree_to'.tr(),
                              style: AppTextStyles.caption,
                              children: [
                                TextSpan(
                                  text: ' ${'auth.terms'.tr()}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    AuthButtonWidget(
                      text: 'auth.sign_up'.tr(),
                      isLoading: state.isLoading,
                      onPressed: state.isLoading ? null : _handleSignUp,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auth.already_have_account'.tr(),
                          style: AppTextStyles.bodySmall,
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                          ),
                          child: Text(
                            'auth.log_in'.tr(),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
