import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_app/core/utils/app_spacing.dart';
import 'package:crypto_app/core/theme/app_colors.dart';
import 'package:crypto_app/core/theme/app_text_styles.dart';
import 'package:crypto_app/features/plan/presentation/cubit/plans_cubit.dart';
import 'package:crypto_app/features/plan/presentation/cubit/plans_state.dart';
import 'package:crypto_app/features/plan/presentation/widgets/plans_list_widget.dart';
import 'package:crypto_app/features/plan/presentation/widgets/active_plans_widget.dart';
import 'package:crypto_app/features/plan/presentation/widgets/offers_carousel_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../home/presentation/widgets/home_header_widget.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    context.read<PlansCubit>().fetchAllPlansData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E2A40), AppColors.background],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const HomeHeaderWidget(),
              Expanded(
                child: BlocBuilder<PlansCubit, PlansState>(
                  builder: (context, state) {
                    if (state.status == PlansStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == PlansStatus.failure) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppColors.error,
                                ),
                              ),
                              SizedBox(height: AppSpacing.lg),
                              Text(
                                state.errorMessage ??
                                    'plans.error_loading'.tr(),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                              ElevatedButton(
                                onPressed: _fetchData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xl,
                                    vertical: AppSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd,
                                    ),
                                  ),
                                ),
                                child: Text('plans.retry'.tr()),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _fetchData(),
                      color: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (state.offers.isNotEmpty) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                    ),
                                    child: _buildSectionHeader(
                                      'plans.special_offers'.tr(),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  OffersCarouselWidget(offers: state.offers),
                                  SizedBox(height: AppSpacing.xl),
                                ],
                                if (state.activePlans.isNotEmpty) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                    ),
                                    child: _buildSectionHeader(
                                      'plans.active_plans'.tr(),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                    ),
                                    child: ActivePlansWidget(
                                      activePlans: state.activePlans,
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.xl),
                                ],
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                  ),
                                  child: _buildSectionHeader(
                                    'plans.available_plans'.tr(),
                                  ),
                                ),
                                SizedBox(height: AppSpacing.md),
                                PlansListWidget(plans: state.plans),
                                SizedBox(height: AppSpacing.xl),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
