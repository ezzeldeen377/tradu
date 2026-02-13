import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/cache_service.dart';

enum OnboardingStatus { loading, completed, notCompleted }

class OnboardingState {
  final OnboardingStatus status;

  const OnboardingState({this.status = OnboardingStatus.loading});

  OnboardingState copyWith({OnboardingStatus? status}) {
    return OnboardingState(status: status ?? this.status);
  }
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  Future<void> checkOnboardingStatus() async {
    final isCompleted = await CacheService.isOnboardingCompleted();
    emit(
      state.copyWith(
        status: isCompleted
            ? OnboardingStatus.completed
            : OnboardingStatus.notCompleted,
      ),
    );
  }

  Future<void> markAsCompleted() async {
    await CacheService.setOnboardingCompleted();
    emit(state.copyWith(status: OnboardingStatus.completed));
  }
}
