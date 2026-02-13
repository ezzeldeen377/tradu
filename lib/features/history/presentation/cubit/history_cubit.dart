import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/history_repository.dart';
import '../../domain/history_type.dart';
import 'history_state.dart';

@injectable
class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _repository;

  HistoryCubit(this._repository) : super(const HistoryState());

  /// Fetch history for the selected type
  Future<void> fetchHistory(HistoryType type) async {
    emit(state.copyWith(status: HistoryStatus.loading, selectedType: type));

    try {
      final items = await _repository.fetchHistory(type.value);

      if (items.isEmpty) {
        emit(state.copyWith(status: HistoryStatus.empty, items: []));
      } else {
        emit(state.copyWith(status: HistoryStatus.success, items: items));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: HistoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Change selected type and fetch data
  void changeType(HistoryType type) {
    if (state.selectedType == type) return;
    fetchHistory(type);
  }
}
