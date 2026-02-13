# Investment Plans System - Complete Documentation

## Overview
This document provides a comprehensive guide to the investment plans/subscription system implementation. Use this as a reference to recreate the same logic in other projects.

---

## 1. Data Models

### 1.1 Plan Model
**File**: `lib/features/home/data/models/plans_response.dart`

```dart
class Plan {
  final int id;
  final String name;
  final String description;
  final String profitMargin;        // Percentage return
  final int durationDays;           // Plan duration in days
  final String price;               // Investment amount
  final int special;                // 1 = special offer, 0 = regular
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Key Points**:
- `special` field distinguishes between regular plans and special offers
- `profitMargin` is stored as String but represents percentage
- `price` is the investment amount required

### 1.2 PlansResponse Model
```dart
class PlansResponse {
  final String? message;
  final List<Plan>? plans;
}
```

### 1.3 OffersResponse Model
```dart
class OffersResponse {
  final String? message;
  final List<Plan>? offers;  // Uses same Plan model
}
```

### 1.4 ActivePlan Model
**File**: `lib/features/home/data/models/active_plans_response.dart`

```dart
class ActivePlan {
  final Plan plan;              // The plan details
  final String status;          // "active", "inactive", "expired"
  final double profit;          // Current profit earned
  final String expiryDate;      // When plan expires
  final String? startDate;      // When plan started
}
```

### 1.5 ActivePlansResponse Model
```dart
class ActivePlansResponse {
  final String message;
  final List<ActivePlan>? plans;
  final double balance;         // User's current balance
  final double totalProfit;     // Total profit from all plans
}
```

### 1.6 SubscriptionResponse Model
**File**: `lib/features/home/data/models/subscription_response.dart`

```dart
class SubscriptionResponse {
  final String? message;
  final SubscriptedPlan? userPlan;
}

class SubscriptedPlan {
  final int userId;
  final int planId;
  final DateTime expiratoryDate;
  final DateTime updatedAt;
  final DateTime createdAt;
  final int id;
}
```

---

## 2. API Endpoints

### 2.1 API Constants
**File**: `lib/core/networking/api_constant.dart`

```dart
static const String plansEndPoint = 'api/plans';
static const String offersEndPoint = 'api/getoffers';
static const String usersPlanEndPoint = 'api/users-plan';
static const String subscribePlanEndPoint = 'api/subscribe';
static const String checkplanEndPoint = 'api/checkplan';
static const String planResultEndPoint = 'api/plan-result';
```

### 2.2 Data Source Methods
**File**: `lib/features/home/data/datasources/main_remote_data_source.dart`

#### Get All Plans
```dart
Future<Map<String, dynamic>> getAllPlans() {
  return HttpServices.instance.get(ApiConstant.plansEndPoint);
}
```
- **Method**: GET
- **Returns**: List of all available plans

#### Get All Offers
```dart
Future<Map<String, dynamic>> getAllOffers() {
  return HttpServices.instance.get(ApiConstant.offersEndPoint);
}
```
- **Method**: GET
- **Returns**: List of special offer plans

#### Get User Active Plans
```dart
Future<Map<String, dynamic>> getUserActivePlan(String token) {
  return HttpServices.instance.post(ApiConstant.usersPlanEndPoint, body: {
    "token": token,
  });
}
```
- **Method**: POST
- **Body**: `{ "token": "user_token" }`
- **Returns**: User's active plans with balance and total profit

#### Subscribe to Plan
```dart
Future<Map<String, dynamic>> subscribePlan(String token, int planId) {
  return HttpServices.instance.post(ApiConstant.subscribePlanEndPoint, body: {
    "token": token,
    "plan_id": planId,
  });
}
```
- **Method**: POST
- **Body**: `{ "token": "user_token", "plan_id": 123 }`
- **Returns**: Subscription confirmation with user plan details

#### Check Plans Status
```dart
Future<Map<String, dynamic>> checkPlans(String token) {
  return HttpServices.instance.post(ApiConstant.checkplanEndPoint, body: {
    "token": token,
  });
}
```
- **Method**: POST
- **Body**: `{ "token": "user_token" }`
- **Returns**: Status of user's plans

#### Get Plan Result/Details
```dart
Future<Map<String, dynamic>> getPlanReuslt(String token, String planId) {
  return HttpServices.instance.post(ApiConstant.planResultEndPoint, body: {
    "token": token,
    "plan_id": planId,
  });
}
```
- **Method**: POST
- **Body**: `{ "token": "user_token", "plan_id": "123" }`
- **Returns**: Detailed plan result with current profit

---

## 3. Repository Layer

**File**: `lib/features/home/data/repositories/main_repository.dart`

### Repository Interface
```dart
abstract class MainRepository {
  Future<Either<Failure, PlansResponse>> getAllPlans();
  Future<Either<Failure, OffersResponse>> getAllOffers();
  Future<Either<Failure, ActivePlansResponse>> getUserActivePlan(String token);
  Future<Either<Failure, SubscriptionResponse>> subscribePlan(String token, int planId);
  Future<Either<Failure, Map<String, dynamic>>> checkPlans(String token);
  Future<Either<Failure, ActivePlan>> getPlanReuslt(String token, String planId);
}
```

### Repository Implementation
```dart
@Injectable(as: MainRepository)
class MainRepositoryImpl implements MainRepository {
  final MainRemoteDataSource dataSource;

  @override
  Future<Either<Failure, PlansResponse>> getAllPlans() {
    return executeTryAndCatchForRepository(() async {
      final response = await dataSource.getAllPlans();
      return PlansResponse.fromMap(response);
    });
  }

  @override
  Future<Either<Failure, SubscriptionResponse>> subscribePlan(
      String token, int planId) {
    return executeTryAndCatchForRepository(() async {
      final response = await dataSource.subscribePlan(token, planId);
      return SubscriptionResponse.fromMap(response);
    });
  }
  
  // Similar pattern for other methods...
}
```

---

## 4. State Management (BLoC)

### 4.1 MyPlansCubit (User's Active Plans)
**File**: `lib/features/home/presentation/bloc/my_plans/my_plans_cubit.dart`

```dart
@injectable
class MyPlansCubit extends Cubit<MyPlansState> with MountedCubit<MyPlansState> {
  final MainRepository repository;

  Future<void> getUserActivePlan(String token) async {
    emit(state.copyWith(status: MyPlansStatus.loading));
    final response = await repository.getUserActivePlan(token);
    response.fold(
      (failure) => emit(state.copyWith(
        status: MyPlansStatus.error, 
        errorMessage: failure.message
      )),
      (success) => emit(state.copyWith(
        status: MyPlansStatus.success, 
        activePlans: success.plans
      )),
    );
  }

  void getPlanReuslt(String token, String planId) async {
    emit(state.copyWith(status: MyPlansStatus.loading));
    final result = await repository.getPlanReuslt(token, planId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: MyPlansStatus.error,
        errorMessage: failure.message,
      )),
      (plan) => emit(state.copyWith(
        status: MyPlansStatus.successGetPlanDetails,
        userActivePlan: plan,
      )),
    );
  }
}
```

### 4.2 OfferCubit (Special Offers)
**File**: `lib/features/home/presentation/bloc/offer/offer_cubit.dart`

```dart
@injectable
class OfferCubit extends Cubit<OfferState> with MountedCubit<OfferState> {
  final MainRepository repository;

  Future<void> getOffers() async {
    emit(state.copyWith(status: OfferStatus.loading));
    final result = await repository.getAllOffers();
    result.fold(
      (failure) => emit(state.copyWith(
        status: OfferStatus.failure, 
        message: failure.message
      )),
      (success) => emit(state.copyWith(
        status: OfferStatus.successGetOffer, 
        offers: success.offers
      ))
    );
  }

  void subscribePlan(String token, int planId) async {
    emit(state.copyWith(status: OfferStatus.loading));
    final response = await repository.subscribePlan(token, planId);
    response.fold(
      (failure) => emit(state.copyWith(
        status: OfferStatus.failure, 
        message: failure.message
      )),
      (success) => emit(state.copyWith(
        status: OfferStatus.subscribePlan,
        message: success.message,
        subscriptedPlan: success.userPlan
      )),
    );
  }

  Future<void> getUserActivePlan(String token) async {
    emit(state.copyWith(status: OfferStatus.loading));
    final response = await repository.getUserActivePlan(token);
    response.fold(
      (failure) => emit(state.copyWith(
        status: OfferStatus.failure, 
        message: null
      )),
      (success) => emit(state.copyWith(
        status: OfferStatus.successGetActiveUserPlans, 
        userActivePlans: success.plans
      )),
    );
  }
}
```

---

## 5. UI Components

### 5.1 Investment Card Widget
**File**: `lib/features/home/presentation/widgets/home/investment_card.dart`

**Purpose**: Displays a single plan/offer card with subscription functionality

**Key Features**:
- Shows plan details (name, description, profit margin, duration, price)
- Special badge for special offers (`plan.special == 1`)
- Different button states: "Choose Plan" vs "View Details"
- Confirmation bottom sheet before subscription

**Usage**:
```dart
InvestmentCard(
  activePlan: activePlan,
  isActive: isPlanActive(plan.id, activeUserPlans),
)
```

**Subscription Flow**:
```dart
void _showConfirmationBottomSheet(BuildContext context) {
  showModalBottomSheet(
    // Show plan details for confirmation
    // On confirm:
    activePlan.plan.special == 1
      ? context.read<OfferCubit>().subscribePlan(token, planId)
      : context.read<HomeCubit>().subscribePlan(token, planId);
  );
}
```

### 5.2 Investment Plans Carousel
**File**: `lib/features/home/presentation/widgets/home/investment_plans_carousel.dart`

**Purpose**: Displays plans in a carousel slider on home screen

**Key Features**:
- Uses `carousel_slider` package
- Auto-play with 3-second intervals
- Shows gift card as first item if enabled and not redeemed
- Pagination dots indicator
- Checks if plan is active for current user

**Helper Function**:
```dart
bool isPlanActive(int planId, List<ActivePlan> activeUserPlans) {
  return activeUserPlans.any((activePlan) => activePlan.plan.id == planId);
}
```

### 5.3 Plans Page (My Plans)
**File**: `lib/features/home/presentation/pages/plans_page.dart`

**Purpose**: Shows user's active investment plans

**Features**:
- Lists all active plans
- Shows plan status (active/inactive)
- Displays profit margin, duration, investment amount
- Tap to view plan details
- Empty state when no active plans

**Navigation**:
```dart
Navigator.pushNamed(
  context,
  RouteNames.planDetails,
  arguments: activePlan
);
```

### 5.4 Plan Details Screen
**File**: `lib/features/home/presentation/pages/plan_details_screen.dart`

**Purpose**: Detailed view of a specific active plan

**Features**:
- Plan information (ID, status, investment, returns, duration)
- Start and expiry dates
- Progress tracking:
  - Linear progress bar
  - Days spent vs days remaining
  - Percentage completion
- Countdown timer widget
- Current profit display
- Plan description with animation

**Progress Calculation**:
```dart
void _calculateProgress() {
  startTime = DateTime.parse(activePlan.startDate ?? DateTime.now().toString());
  endTime = DateTime.parse(activePlan.expiryDate);
  final now = DateTime.now();
  final totalDays = activePlan.plan.durationDays;
  
  final differenceInHours = now.difference(startTime).inHours;
  final completeDays = (differenceInHours / 24).floor();

  daysSpent = completeDays.clamp(0, totalDays);
  daysRemaining = (totalDays - daysSpent).clamp(0, totalDays);
  progress = (daysSpent / totalDays).clamp(0.0, 1.0);
}
```

### 5.5 Offers Page
**File**: `lib/features/home/presentation/pages/offer_page.dart`

**Purpose**: Displays special offer plans

**Features**:
- Carousel of special offers
- Benefits section explaining why choose offers
- "How It Works" section with step-by-step guide
- Auto-play carousel
- Subscription flow with success dialog

**Subscription Success Flow**:
```dart
BlocListener<OfferCubit, OfferState>(
  listener: (context, state) {
    if (state.isSubscribePlan) {
      // Refresh active plans
      context.read<OfferCubit>().getUserActivePlan(token);
      // Get plan details
      context.read<OfferCubit>().getPlanReuslt(token, planId);
    }
    if (state.isSuccessPlanDetails) {
      // Show success dialog
      // Navigate to plan details
      Navigator.popAndPushNamed(
        context,
        RouteNames.planDetails,
        arguments: state.userActivePlan
      );
    }
  },
)
```

---

## 6. Complete Flow Diagrams

### 6.1 View Plans Flow
```
1. User opens app
   ↓
2. HomeCubit.getAllPlans() called
   ↓
3. MainRepository.getAllPlans()
   ↓
4. MainRemoteDataSource.getAllPlans()
   ↓
5. HTTP GET to api/plans
   ↓
6. Parse PlansResponse
   ↓
7. Update HomeCubit state with plans
   ↓
8. InvestmentPlansCarousel displays plans
```

### 6.2 Subscribe to Plan Flow
```
1. User taps "Choose Plan" on InvestmentCard
   ↓
2. Show confirmation bottom sheet
   ↓
3. User confirms subscription
   ↓
4. Check if special offer:
   - Yes: OfferCubit.subscribePlan(token, planId)
   - No: HomeCubit.subscribePlan(token, planId)
   ↓
5. MainRepository.subscribePlan(token, planId)
   ↓
6. MainRemoteDataSource.subscribePlan(token, planId)
   ↓
7. HTTP POST to api/subscribe with {token, plan_id}
   ↓
8. Parse SubscriptionResponse
   ↓
9. Update cubit state (status: subscribePlan)
   ↓
10. Listener triggers:
    - getUserActivePlan(token)
    - getPlanReuslt(token, planId)
   ↓
11. Show success dialog
   ↓
12. Navigate to PlanDetailsScreen
```

### 6.3 View Active Plans Flow
```
1. User navigates to PlansPage
   ↓
2. MyPlansCubit.getUserActivePlan(token) called
   ↓
3. MainRepository.getUserActivePlan(token)
   ↓
4. MainRemoteDataSource.getUserActivePlan(token)
   ↓
5. HTTP POST to api/users-plan with {token}
   ↓
6. Parse ActivePlansResponse
   ↓
7. Update MyPlansCubit state with:
   - activePlans: List<ActivePlan>
   - balance: double
   - totalProfit: double
   ↓
8. PlansPage displays list of active plans
   ↓
9. User taps on a plan
   ↓
10. Navigate to PlanDetailsScreen with activePlan
```

### 6.4 View Plan Details Flow
```
1. User taps on active plan
   ↓
2. Navigate to PlanDetailsScreen(activePlan)
   ↓
3. Screen calculates progress:
   - Parse start and expiry dates
   - Calculate days spent and remaining
   - Calculate progress percentage
   ↓
4. Display:
   - Plan information
   - Progress bar and metrics
   - Countdown timer
   - Current profit (from state.userActivePlan)
   ↓
5. Optional: Refresh plan details
   MyPlansCubit.getPlanReuslt(token, planId)
```

---

## 7. State Status Enums

### MyPlansStatus
```dart
enum MyPlansStatus {
  initial,
  loading,
  success,
  error,
  successGetPlanDetails,
}
```

### OfferStatus
```dart
enum OfferStatus {
  initial,
  loading,
  successGetOffer,
  successGetActiveUserPlans,
  subscribePlan,
  successGetPlanDetails,
  failure,
}
```

---

## 8. Key Implementation Notes

### 8.1 Plan vs Offer Distinction
- **Plans**: Regular investment plans (special = 0)
- **Offers**: Special promotional plans (special = 1)
- Both use the same `Plan` model
- Different endpoints: `api/plans` vs `api/getoffers`
- Different cubits: `HomeCubit` vs `OfferCubit`

### 8.2 Active Plan Checking
```dart
bool isPlanActive(int planId, List<ActivePlan> activeUserPlans) {
  return activeUserPlans.any((activePlan) => activePlan.plan.id == planId);
}
```
- Used to determine button state in InvestmentCard
- Prevents duplicate subscriptions
- Changes button from "Choose Plan" to "View Details"

### 8.3 Progress Calculation
- Uses hours difference converted to complete days
- Clamps values to prevent overflow
- Formula: `progress = daysSpent / totalDays`
- Displayed as percentage and linear progress bar

### 8.4 Error Handling
- Uses `Either<Failure, Success>` pattern (dartz package)
- Repository layer wraps data source calls in try-catch
- Cubit emits error states with messages
- UI shows error messages via SnackBar or dialogs

### 8.5 Token Management
- User token required for all authenticated endpoints
- Retrieved from `AppUserCubit().state.accessToken`
- Passed to all plan-related API calls

---

## 9. Dependencies Used

```yaml
dependencies:
  flutter_bloc: ^8.x.x
  injectable: ^2.x.x
  get_it: ^7.x.x
  dartz: ^0.10.x
  carousel_slider: ^4.x.x
  flutter_screenutil: ^5.x.x
  lottie: ^2.x.x
```

---

## 10. API Response Examples

### Get All Plans Response
```json
{
  "message": "Plans retrieved successfully",
  "plans": [
    {
      "id": 1,
      "name": "Starter Plan",
      "description": "Perfect for beginners",
      "profit_margin": "10.5",
      "duration_days": 30,
      "price": "100",
      "special": 0,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### Get User Active Plans Response
```json
{
  "message": "Active plans retrieved",
  "plans": [
    {
      "plan": {
        "id": 1,
        "name": "Starter Plan",
        "description": "Perfect for beginners",
        "profit_margin": "10.5",
        "duration_days": 30,
        "price": "100",
        "special": 0,
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z"
      },
      "status": "active",
      "profit": 5.25,
      "expiry_date": "2024-02-01T00:00:00Z",
      "start_at": "2024-01-01T00:00:00Z"
    }
  ],
  "balance": 1000.00,
  "total_profit": 50.75
}
```

### Subscribe Plan Response
```json
{
  "message": "Successfully subscribed to plan",
  "user_plan": {
    "id": 123,
    "user_id": 456,
    "plan_id": 1,
    "expiratory_date": "2024-02-01T00:00:00Z",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

---

## 11. Checklist for Implementation

### Backend Requirements
- [ ] Create plans table with fields: id, name, description, profit_margin, duration_days, price, special
- [ ] Create user_plans table to track subscriptions
- [ ] Implement GET /api/plans endpoint
- [ ] Implement GET /api/getoffers endpoint (filter special=1)
- [ ] Implement POST /api/users-plan endpoint (requires token)
- [ ] Implement POST /api/subscribe endpoint (requires token, plan_id)
- [ ] Implement POST /api/checkplan endpoint
- [ ] Implement POST /api/plan-result endpoint (requires token, plan_id)
- [ ] Add authentication middleware for protected endpoints
- [ ] Calculate and update profit for active plans (cron job or on-demand)

### Frontend Requirements
- [ ] Create all data models (Plan, PlansResponse, ActivePlan, etc.)
- [ ] Implement data source layer with HTTP calls
- [ ] Implement repository layer with Either pattern
- [ ] Create MyPlansCubit for user's active plans
- [ ] Create OfferCubit for special offers
- [ ] Build InvestmentCard widget
- [ ] Build InvestmentPlansCarousel widget
- [ ] Build PlansPage screen
- [ ] Build PlanDetailsScreen
- [ ] Build OfferPage screen
- [ ] Add routes for all screens
- [ ] Implement subscription confirmation flow
- [ ] Add success/error dialogs
- [ ] Test complete flow end-to-end

---

## 12. Testing Scenarios

1. **View Plans**: Verify all plans load correctly
2. **View Offers**: Verify special offers load separately
3. **Subscribe to Plan**: Test successful subscription
4. **Duplicate Subscription**: Verify user can't subscribe to same plan twice
5. **View Active Plans**: Check user's active plans display correctly
6. **Plan Progress**: Verify progress calculation is accurate
7. **Plan Expiry**: Test behavior when plan expires
8. **Profit Calculation**: Verify profit updates correctly
9. **Error Handling**: Test with invalid token, network errors
10. **Navigation**: Test all navigation flows between screens

---

## Summary

This investment plans system provides a complete subscription-based investment platform with:
- Multiple plan types (regular and special offers)
- User subscription management
- Progress tracking and profit calculation
- Beautiful UI with carousels and animations
- Robust error handling and state management
- Clear separation of concerns (data/domain/presentation layers)

Use this documentation as a blueprint to implement similar functionality in other projects. Adjust the models and endpoints according to your specific backend API structure.
