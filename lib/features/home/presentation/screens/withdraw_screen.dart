import 'package:crypto_app/core/utils/show_snack_bar.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:crypto_app/features/home/presentation/cubit/withdraw/withdraw_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _westernUnionNameController =
      TextEditingController();
  final TextEditingController _westernUnionPhoneController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _walletAddressController =
      TextEditingController();
  String _selectedPaymentMethod = '';

  @override
  void dispose() {
    _amountController.dispose();
    _westernUnionNameController.dispose();
    _westernUnionPhoneController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _cardNumberController.dispose();
    _walletAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WithdrawCubit, WithdrawState>(
      listener: (context, state) {
        if (state.status == WithdrawStatus.success) {
          _showSuccessDialog(context);
        } else if (state.status == WithdrawStatus.failure) {
          showErrorSnackBar(
            context,
            state.message ?? 'withdraw.validation.invalid_amount'.tr(),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.sm),
                _buildWithdrawForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'withdraw.title'.tr(),
        style: AppTextStyles.h3.copyWith(color: AppColors.primary),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      actions: [
        Padding(
          padding: EdgeInsetsDirectional.only(end: AppSpacing.md),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                    size: AppSpacing.iconMd,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '\$${state.user?.user?.balance ?? 0}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'withdraw.withdraw_amount'.tr(),
          style: AppTextStyles.h4.copyWith(color: AppColors.primary),
        ),
        SizedBox(height: AppSpacing.md),
        _buildAmountField(),
        SizedBox(height: AppSpacing.lg),
        _buildPaymentMethod(
          'withdraw.payment_methods.bank_transfer'.tr(),
          Icons.account_balance,
          'withdraw.payment_methods.bank_transfer_desc'.tr(),
        ),
        _buildPaymentMethod(
          'withdraw.payment_methods.local_payment'.tr(),
          Icons.credit_card,
          'withdraw.payment_methods.local_payment_desc'.tr(),
        ),
        _buildPaymentMethod(
          'withdraw.payment_methods.western_union'.tr(),
          Icons.account_balance_wallet,
          'withdraw.payment_methods.western_union_desc'.tr(),
        ),
        _buildPaymentMethod(
          'withdraw.payment_methods.cryptocurrency'.tr(),
          Icons.currency_bitcoin,
          'withdraw.payment_methods.cryptocurrency_desc'.tr(),
        ),
        SizedBox(height: AppSpacing.xl),
        _buildWithdrawButton(),
      ],
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'withdraw.enter_amount'.tr(),
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.attach_money,
            color: AppColors.primary,
            size: AppSpacing.iconMd,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, IconData icon, String subtitle) {
    bool isSelected = _selectedPaymentMethod == title;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _selectedPaymentMethod = isSelected ? '' : title;
              });
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: AppSpacing.iconLg),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: AppSpacing.iconLg,
                  ),
                ],
              ),
            ),
          ),
          if (isSelected) _buildPaymentFields(title),
        ],
      ),
    );
  }

  Widget _buildPaymentFields(String paymentMethod) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryWithAlpha(0.05),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusLg),
          bottomRight: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        children: [
          if (paymentMethod ==
              'withdraw.payment_methods.western_union'.tr()) ...[
            _buildTextField(
              controller: _westernUnionNameController,
              hint: 'withdraw.form_fields.full_name'.tr(),
              icon: Icons.person,
            ),
            SizedBox(height: AppSpacing.sm),
            _buildTextField(
              controller: _westernUnionPhoneController,
              hint: 'withdraw.form_fields.phone_number'.tr(),
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
          ] else if (paymentMethod ==
              'withdraw.payment_methods.bank_transfer'.tr()) ...[
            _buildTextField(
              controller: _accountNumberController,
              hint: 'withdraw.form_fields.account_number'.tr(),
              icon: Icons.numbers,
            ),
            SizedBox(height: AppSpacing.sm),
            _buildTextField(
              controller: _bankNameController,
              hint: 'withdraw.form_fields.bank_name'.tr(),
              icon: Icons.account_balance,
            ),
          ] else if (paymentMethod ==
              'withdraw.payment_methods.local_payment'.tr()) ...[
            _buildTextField(
              controller: _cardNumberController,
              hint: 'withdraw.form_fields.wallet_account'.tr(),
              icon: Icons.credit_card,
            ),
          ] else if (paymentMethod ==
              'withdraw.payment_methods.cryptocurrency'.tr()) ...[
            _buildTextField(
              controller: _walletAddressController,
              hint: 'withdraw.form_fields.wallet_address'.tr(),
              icon: Icons.wallet,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
            size: AppSpacing.iconMd,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.sm),
        ),
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return BlocBuilder<WithdrawCubit, WithdrawState>(
      builder: (context, state) {
        final isLoading = state.status == WithdrawStatus.loading;
        return SizedBox(
          width: double.infinity,
          height: AppSpacing.height(56),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleWithdraw,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primaryWithAlpha(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: AppSpacing.iconLg,
                    height: AppSpacing.iconLg,
                    child: CircularProgressIndicator(
                      color: AppColors.textPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'withdraw.button_withdraw'.tr(),
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _handleWithdraw() {
    // Validation
    if (_selectedPaymentMethod.isEmpty) {
      showErrorSnackBar(context, 'withdraw.validation.select_payment'.tr());
      return;
    }

    if (_amountController.text.isEmpty) {
      showErrorSnackBar(context, 'withdraw.validation.enter_amount'.tr());
      return;
    }

    if (_amountController.text.contains('.') ||
        _amountController.text.contains(',')) {
      showErrorSnackBar(context, 'withdraw.validation.integer_only'.tr());
      return;
    }

    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null) {
      showErrorSnackBar(context, 'withdraw.validation.invalid_amount'.tr());
      return;
    }

    final balance = context.read<AuthCubit>().state.user?.user?.balance ?? 0;
    if (amount > balance) {
      showErrorSnackBar(
        context,
        'withdraw.validation.insufficient_balance'.tr(),
      );
      return;
    }

    // Prepare withdraw data
    Map<String, dynamic> withdrawData = {
      'amount': _amountController.text,
      'token': context.read<AuthCubit>().state.user?.token,
    };

    // Add payment method specific data
    if (_selectedPaymentMethod ==
        'withdraw.payment_methods.western_union'.tr()) {
      if (_westernUnionNameController.text.isEmpty ||
          _westernUnionPhoneController.text.isEmpty) {
        showErrorSnackBar(
          context,
          'withdraw.validation.fill_western_union'.tr(),
        );
        return;
      }
      withdrawData['western'] =
          "${_westernUnionNameController.text} - ${_westernUnionPhoneController.text}";
    } else if (_selectedPaymentMethod ==
        'withdraw.payment_methods.bank_transfer'.tr()) {
      if (_accountNumberController.text.isEmpty ||
          _bankNameController.text.isEmpty) {
        showErrorSnackBar(
          context,
          'withdraw.validation.fill_bank_transfer'.tr(),
        );
        return;
      }
      withdrawData['bank'] =
          "${_accountNumberController.text} - ${_bankNameController.text}";
    } else if (_selectedPaymentMethod ==
        'withdraw.payment_methods.local_payment'.tr()) {
      if (_cardNumberController.text.isEmpty) {
        showErrorSnackBar(
          context,
          'withdraw.validation.fill_account_info'.tr(),
        );
        return;
      }
      withdrawData['money_office'] = _cardNumberController.text;
    } else if (_selectedPaymentMethod ==
        'withdraw.payment_methods.cryptocurrency'.tr()) {
      if (_walletAddressController.text.isEmpty) {
        showErrorSnackBar(
          context,
          'withdraw.validation.fill_wallet_address'.tr(),
        );
        return;
      }
      withdrawData['usdt'] = _walletAddressController.text;
    }

    // Call withdraw
    context.read<WithdrawCubit>().withdraw(withdrawData);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: BorderSide(color: AppColors.primary, width: 1),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: AppSpacing.height(64),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'withdraw.success_title'.tr(),
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'withdraw.success_message'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _clearAllFields();
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: Text(
                    'withdraw.button_done'.tr(),
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearAllFields() {
    _amountController.clear();
    _westernUnionNameController.clear();
    _westernUnionPhoneController.clear();
    _accountNumberController.clear();
    _bankNameController.clear();
    _cardNumberController.clear();
    _walletAddressController.clear();
    setState(() {
      _selectedPaymentMethod = '';
    });
  }
}
