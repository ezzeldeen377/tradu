import 'package:crypto_app/features/auth/data/models/currency_model.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'currency_dropdown_widget.dart';

class CurrencySelectorWidget extends StatefulWidget {
  final String label;
  final String currency;
  final double amount;
  final bool isSwapped;
  final double? availableBalance;
  final VoidCallback onCurrencyTap;
  final Function(CurrencyModel) onCurrencyChanged;
  final VoidCallback? onMaxTap;
  final Function(double)? onAmountChanged;

  const CurrencySelectorWidget({
    super.key,
    required this.label,
    required this.currency,
    required this.amount,
    required this.isSwapped,
    this.availableBalance,
    required this.onCurrencyTap,
    required this.onCurrencyChanged,
    this.onMaxTap,
    this.onAmountChanged,
  });

  @override
  State<CurrencySelectorWidget> createState() => _CurrencySelectorWidgetState();
}

class _CurrencySelectorWidgetState extends State<CurrencySelectorWidget> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatAmount(widget.amount));
  }

  @override
  void didUpdateWidget(CurrencySelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isFocused && widget.amount != oldWidget.amount) {
      _controller.text = _formatAmount(widget.amount);
    }
  }

  String _formatAmount(double amount) {
    if (amount == 0) return "";
    return amount
        .toStringAsFixed(widget.currency == 'USDT' ? 2 : 6)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: (widget.availableBalance != null && widget.isSwapped)
                    ? 1.0
                    : 0.0,
                child: (widget.availableBalance != null)
                    ? Row(
                        children: [
                          Text(
                            'Available: ${widget.availableBalance!.toStringAsFixed(3)} ${widget.currency}',
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          GestureDetector(
                            onTap: widget.onMaxTap,
                            child: Text(
                              'MAX',
                              style: AppTextStyles.caption.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return CurrencyDropdownWidget(
                    selectedCurrency: widget.currency,
                    currencies: state.currencies ?? [],
                    onSelected: widget.onCurrencyChanged,
                  );
                },
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: Focus(
                    onFocusChange: (focused) {
                      setState(() {
                        _isFocused = focused;
                      });
                    },
                    child: TextField(
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: context.locale.languageCode == 'ar'
                          ? TextAlign.left
                          : TextAlign.right,
                      style: AppTextStyles.h1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "0.00",
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      onChanged: (value) {
                        final amount = double.tryParse(value) ?? 0.0;
                        widget.onAmountChanged?.call(amount);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
