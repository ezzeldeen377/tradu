import 'dart:math';
import 'package:crypto_app/features/plan/data/models/plans_response.dart';
import 'package:flutter/material.dart';
import 'package:crypto_app/core/utils/app_spacing.dart';
import 'plan_card.dart';

class PlansListWidget extends StatefulWidget {
  final List<Plan> plans;

  const PlansListWidget({super.key, required this.plans});

  @override
  State<PlansListWidget> createState() => _PlansListWidgetState();
}

class _PlansListWidgetState extends State<PlansListWidget> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plans.isEmpty) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: PageView.builder(
        itemCount: widget.plans.length,
        allowImplicitScrolling: true,
        physics: const ClampingScrollPhysics(),
        controller: _pageController,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0.0;
              if (_pageController.position.haveDimensions) {
                value = index.toDouble() - (_pageController.page ?? 0);
                value = (value * 0.038).clamp(-1, 1);
              }
              return Transform.rotate(
                angle:
                    (Directionality.of(context) == TextDirection.rtl ? -1 : 1) *
                    pi *
                    value,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Hero(
                    tag: "plan_${widget.plans[index].id}",
                    child: PlanCard(plan: widget.plans[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
