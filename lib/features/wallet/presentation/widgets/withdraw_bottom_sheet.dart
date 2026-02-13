import 'package:crypto_app/core/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/user_wallet_model.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';

class WithdrawBottomSheet extends StatefulWidget {
  const WithdrawBottomSheet({super.key});

  @override
  State<WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<WithdrawBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  WalletCryptocurrency? _selectedCrypto;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setMaxAmount() {
    if (_selectedCrypto != null) {
      _amountController.text = _selectedCrypto!.balance;
      setState(() {});
    }
  }

  Future<void> _handleWithdraw() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrypto == null) {
      setState(() => _errorMessage = 'wallet.select_currency'.tr());
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final amount = double.tryParse(_amountController.text) ?? 0;
    final success = await context.read<WalletCubit>().withdrawCryptoToUsd(
      currencyApiId: _selectedCrypto!.currencyApiId,
      cryptoAmount: amount,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Close bottom sheet first
      Navigator.pop(context);
      // Then show success message on the parent context
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          showSuccessSnackBar(context, 'wallet.withdraw_success'.tr());
        }
      });
    } else {
      setState(() => _errorMessage = 'wallet.withdraw_failed'.tr());
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
            'wallet.withdraw'.tr(),
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

          // Current Balance Display
          BlocBuilder<WalletCubit, WalletState>(
            builder: (context, state) {
              final totalBalance = state.totalBalanceUsd;
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
                      'wallet.total_balance'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    Text(
                      '\$${totalBalance.toStringAsFixed(2)}',
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
                // Crypto Selector
                Text(
                  'wallet.select_crypto'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                BlocBuilder<WalletCubit, WalletState>(
                  builder: (context, state) {
                    final cryptocurrencies =
                        state.walletData?.cryptocurrencies ?? [];

                    // Validate that selected crypto still exists in the list
                    if (_selectedCrypto != null &&
                        !cryptocurrencies.any(
                          (c) =>
                              c.currencyApiId == _selectedCrypto!.currencyApiId,
                        )) {
                      // Reset selection if crypto no longer exists
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _selectedCrypto = null;
                            _amountController.clear();
                          });
                        }
                      });
                    }

                    if (cryptocurrencies.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                        child: Text(
                          'wallet.no_crypto_holdings'.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      );
                    }

                    // Find the selected crypto in the current list
                    final currentSelectedCrypto = _selectedCrypto != null
                        ? cryptocurrencies.firstWhere(
                            (c) =>
                                c.currencyApiId ==
                                _selectedCrypto!.currencyApiId,
                            orElse: () => cryptocurrencies.first,
                          )
                        : null;

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
                        child: DropdownButton<WalletCryptocurrency>(
                          isExpanded: true,
                          value: currentSelectedCrypto,
                          hint: Text('wallet.choose_crypto'.tr()),
                          items: cryptocurrencies.map((crypto) {
                            return DropdownMenuItem(
                              value: crypto,
                              child: Row(
                                children: [
                                  Text(
                                    crypto.currencySymbol,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      crypto.currencyName,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    crypto.formattedBalance,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCrypto = value;
                              _amountController.clear();
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: AppSpacing.lg),

                // Amount Input with Max Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'wallet.amount'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_selectedCrypto != null)
                      TextButton(
                        onPressed: _setMaxAmount,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'wallet.max'.tr(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled: _selectedCrypto != null,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    suffixText: _selectedCrypto?.currencySymbol ?? '',
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

                    if (_selectedCrypto != null) {
                      final balance = _selectedCrypto!.balanceValue;
                      if (amount > balance) {
                        return 'wallet.insufficient_crypto_balance'.tr();
                      }
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // Withdraw Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleWithdraw,
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
                    'wallet.confirm_withdraw'.tr(),
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
