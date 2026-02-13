import 'dart:developer';

import 'package:crypto_app/core/networking/http_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/plan_repository.dart';
import 'plans_state.dart';

@injectable
class PlansCubit extends Cubit<PlansState> {
  final PlanRepository _repository;

  PlansCubit(this._repository) : super(const PlansState());

  Future<void> fetchAllPlansData() async {
    emit(state.copyWith(status: PlansStatus.loading));
    try {
      final plansResp = await _repository.getAllPlans();
      final offersResp = await _repository.getAllOffers();

      emit(state.copyWith(plans: plansResp.plans, offers: offersResp.offers));

      await fetchActivePlans();

      emit(state.copyWith(status: PlansStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: PlansStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> fetchActivePlans() async {
    try {
      final activePlansResp = await _repository.getUserActivePlans();
      emit(
        state.copyWith(
          activePlans: activePlansResp.plans,
          balance: activePlansResp.balance,
          totalProfit: activePlansResp.totalProfit,
        ),
      );
    } on NoDataException catch (e) {
      log('No active plans found: ${e.message}');
      emit(state.copyWith(activePlans: [], balance: 0.0, totalProfit: 0.0));
    } catch (e) {
      log('Error fetching active plans: $e');
    }
  }

  Future<void> subscribePlan(int planId) async {
    emit(state.copyWith(status: PlansStatus.subscribing));
    try {
      final response = await _repository.subscribePlan(planId);

      // Refresh active plans after subscription
      await fetchActivePlans();

      emit(
        state.copyWith(
          status: PlansStatus.subscribed,
          subscriptedPlan: response.userPlan,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: PlansStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
