import '../../data/models/plans_response.dart';
import '../../data/models/active_plans_response.dart';
import '../../data/models/subscription_response.dart';

enum PlansStatus {
  initial,
  loading,
  success,
  empty,
  failure,
  subscribing,
  subscribed,
}

class PlansState {
  final PlansStatus status;
  final List<Plan> plans;
  final List<Plan> offers;
  final List<ActivePlan> activePlans;
  final double balance;
  final double totalProfit;
  final String? errorMessage;
  final SubscriptedPlan? subscriptedPlan;

  const PlansState({
    this.status = PlansStatus.initial,
    this.plans = const [],
    this.offers = const [],
    this.activePlans = const [],
    this.balance = 0.0,
    this.totalProfit = 0.0,
    this.errorMessage,
    this.subscriptedPlan,
  });

  PlansState copyWith({
    PlansStatus? status,
    List<Plan>? plans,
    List<Plan>? offers,
    List<ActivePlan>? activePlans,
    double? balance,
    double? totalProfit,
    String? errorMessage,
    SubscriptedPlan? subscriptedPlan,
  }) {
    return PlansState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      offers: offers ?? this.offers,
      activePlans: activePlans ?? this.activePlans,
      balance: balance ?? this.balance,
      totalProfit: totalProfit ?? this.totalProfit,
      errorMessage: errorMessage ?? this.errorMessage,
      subscriptedPlan: subscriptedPlan ?? this.subscriptedPlan,
    );
  }
}
