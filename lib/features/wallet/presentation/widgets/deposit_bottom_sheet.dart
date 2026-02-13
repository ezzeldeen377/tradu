import 'package:crypto_app/core/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/data/models/currency_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';

class DepositBottomSheet extends StatefulWidget {
  const DepositBottomSheet({super.key});

  @override
  State<DepositBottomSheet> createState() => _DepositBottomSheetState();
}

class _DepositBottomSheetState extends State<DepositBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  CurrencyModel? _selectedCurrency;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleDeposit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCurrency == null) {
      setState(() => _errorMessage = 'wallet.select_currency'.tr());
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final amount = double.tryParse(_amountController.text) ?? 0;
    final success = await context.read<WalletCubit>().depositUsdToCrypto(
      currencyApiId: _selectedCurrency!.apiId,
      usdAmount: amount,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Close bottom sheet first
      Navigator.pop(context);
      // Then show success message on the parent context
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          showSuccessSnackBar(context, 'wallet.deposit_success'.tr());
        }
      });
    } else {
      setState(() => _errorMessage = 'wallet.deposit_failed'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'wallet.deposit'.tr(),
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),

          // Error Message
          if (_errorMessage != null)
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Current USD Balance
          BlocBuilder<WalletCubit, WalletState>(
            builder: (context, state) {
              final usdBalance = state.walletData?.usdBalance ?? 0;
              return Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'wallet.available_balance'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    Text(
                      '\$${usdBalance.toStringAsFixed(2)}',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: AppSpacing.lg),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Currency Selector
                Text(
                  'wallet.select_currency'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    final currencies = authState.currencies ?? [];

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CurrencyModel>(
                          isExpanded: true,
                          value: _selectedCurrency,
                          hint: Text('wallet.choose_currency'.tr()),
                          items: currencies.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Row(
                                children: [
                                  Text(
                                    currency.symbol,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(
                                    currency.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCurrency = value);
                          },
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: AppSpacing.lg),

                // Amount Input
                Text(
                  'wallet.amount_usd'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'wallet.enter_amount'.tr();
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'wallet.invalid_amount'.tr();
                    }

                    final walletState = context.read<WalletCubit>().state;
                    final usdBalance = walletState.walletData?.usdBalance ?? 0;
                    if (amount > usdBalance) {
                      return 'wallet.insufficient_balance'.tr();
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // Deposit Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleDeposit,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'wallet.confirm_deposit'.tr(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
