import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';

class MarketTabsWidget extends StatefulWidget {
  const MarketTabsWidget({super.key});

  @override
  State<MarketTabsWidget> createState() => _MarketTabsWidgetState();
}

class _MarketTabsWidgetState extends State<MarketTabsWidget> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'market.favorites', 'icon': Icons.star},
    {'label': 'market.hot', 'icon': null},
    {'label': 'market.gainers', 'icon': null},
    {'label': 'market.losers', 'icon': null},
    {'label': 'market.new', 'icon': null},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedIndex == index;
          final tab = _tabs[index];

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected && index == 0
                      ? Colors.amber.withValues(alpha: 0.2)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    if (tab['icon'] != null) ...[
                      Icon(
                        tab['icon'],
                        size: AppSpacing.iconSm,
                        color: isSelected && index == 0
                            ? Colors.amber
                            : _getTabColor(index, isSelected, theme),
                      ),
                      SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      tab['label'].toString().tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _getTabColor(index, isSelected, theme),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Color _getTabColor(int index, bool isSelected, ThemeData theme) {
    if (index == 0 && isSelected) return Colors.amber;
    if (index == 2) return Colors.green;
    if (index == 3) return Colors.red;
    return isSelected
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
  }
}
