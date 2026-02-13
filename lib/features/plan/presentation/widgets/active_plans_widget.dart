import 'package:flutter/material.dart';
import '../../data/models/active_plans_response.dart';
import 'package:crypto_app/core/utils/app_spacing.dart';
import 'active_plan_card.dart';

class ActivePlansWidget extends StatelessWidget {
  final List<ActivePlan> activePlans;

  const ActivePlansWidget({super.key, required this.activePlans});

  @override
  Widget build(BuildContext context) {
    if (activePlans.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activePlans.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) =>
          ActivePlanCard(activePlan: activePlans[index]),
    );
  }
}
