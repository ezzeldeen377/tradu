import 'package:crypto_app/core/errors/app_exception.dart';
import 'package:crypto_app/features/home/data/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'withdraw_state.dart';

@injectable
class WithdrawCubit extends Cubit<WithdrawState> {
  final HomeRepository _repository;

  WithdrawCubit(this._repository)
    : super(WithdrawState(status: WithdrawStatus.initial));

  Future<void> getBalance({required String token}) async {
    emit(state.copyWith(status: WithdrawStatus.loading));
    try {
      final result = await _repository.getUserProfile(token);
      emit(
        state.copyWith(
          status: WithdrawStatus.getBalance,
          balance: result.balance,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: WithdrawStatus.failure, message: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: WithdrawStatus.failure,
          message: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> withdraw(Map<String, dynamic> data) async {
    emit(state.copyWith(status: WithdrawStatus.loading));
    try {
      final result = await _repository.withdraw(data);
      emit(
        state.copyWith(
          status: WithdrawStatus.success,
          message: result.message,
          balance: result.user?.balance,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: WithdrawStatus.failure, message: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: WithdrawStatus.failure,
          message: _extractErrorMessage(e),
        ),
      );
    }
  }

  String _extractErrorMessage(dynamic error) {
    String errorMessage = error.toString();
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }
    return errorMessage.isNotEmpty
        ? errorMessage
        : 'An unexpected error occurred. Please try again.';
  }
}
