import 'package:crypto_app/core/di/di.dart';
import 'package:crypto_app/features/history/presentation/cubit/history_cubit.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/history_type.dart';
import '../widgets/history_search_widget.dart';
import '../widgets/history_tabs_widget.dart';
import '../widgets/history_list_widget.dart';
import '../../../home/presentation/widgets/home_header_widget.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<HistoryCubit>()..fetchHistory(HistoryType.deposits),
      child: const _HistoryScreenContent(),
    );
  }
}

class _HistoryScreenContent extends StatelessWidget {
  const _HistoryScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeaderWidget(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HistoryTabsWidget(),
                    SizedBox(height: AppSpacing.lg),
                    const HistoryListWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
