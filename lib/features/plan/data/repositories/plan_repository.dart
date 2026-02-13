import 'package:crypto_app/core/networking/api_constant.dart';
import 'package:crypto_app/core/networking/http_services.dart';
import 'package:crypto_app/core/services/cache_service.dart';
import 'package:crypto_app/features/plan/data/models/plans_response.dart';
import 'package:crypto_app/features/plan/data/models/active_plans_response.dart';
import 'package:crypto_app/features/plan/data/models/subscription_response.dart';
import 'package:injectable/injectable.dart';

@injectable
class PlanRepository {
  final HttpServices httpServices;
  PlanRepository(this.httpServices);

  Future<PlansResponse> getAllPlans() async {
    final response = await httpServices.get(ApiConstant.plansEndPoint);
    return PlansResponse.fromMap(response);
  }

  Future<OffersResponse> getAllOffers() async {
    final response = await httpServices.get(ApiConstant.offersEndPoint);
    return OffersResponse.fromMap(response);
  }

  Future<ActivePlansResponse> getUserActivePlans() async {
    final token = await CacheService.getAccessToken();
    final response = await httpServices.post(
      ApiConstant.usersPlanEndPoint,
      body: {"token": token},
    );
    return ActivePlansResponse.fromMap(response);
  }

  Future<SubscriptionResponse> subscribePlan(int planId) async {
    final token = await CacheService.getAccessToken();
    final response = await httpServices.post(
      ApiConstant.subscribePlanEndPoint,
      body: {"token": token, "plan_id": planId},
    );
    return SubscriptionResponse.fromMap(response);
  }

  Future<ActivePlan> getPlanResult(String planId) async {
    final token = await CacheService.getAccessToken();
    final response = await httpServices.post(
      ApiConstant.planResultEndPoint,
      body: {"token": token, "plan_id": planId},
    );
    return ActivePlan.fromMap(response);
  }
}
