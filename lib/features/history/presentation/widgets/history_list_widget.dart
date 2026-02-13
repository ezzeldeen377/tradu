import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import 'history_item_widget.dart';

class HistoryListWidget extends StatelessWidget {
  const HistoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        // Loading state
        if (state.status == HistoryStatus.loading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }

        // Error state
        if (state.status == HistoryStatus.failure) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'history.error'.tr(),
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      state.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HistoryCubit>().fetchHistory(
                        state.selectedType,
                      );
                    },
                    child: Text('history.retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (state.status == HistoryStatus.empty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'history.empty'.tr(),
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'history.empty_description'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Success state - display items
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: state.items.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: HistoryItemWidget(item: item),
            );
          }).toList(),
        );
      },
    );
  }
}
