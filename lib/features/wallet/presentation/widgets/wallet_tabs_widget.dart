import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';

class WalletTabsWidget extends StatefulWidget {
  const WalletTabsWidget({super.key});

  @override
  State<WalletTabsWidget> createState() => _WalletTabsWidgetState();
}

class _WalletTabsWidgetState extends State<WalletTabsWidget> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'wallet.holdings',
    'wallet.favorites',
    'wallet.gainers',
    'wallet.losers',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: List.generate(_tabs.length, (index) {
        final isSelected = _selectedIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _tabs[index].tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
