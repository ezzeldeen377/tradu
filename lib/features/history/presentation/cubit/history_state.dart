import '../../data/models/history_model.dart';
import '../../domain/history_type.dart';

enum HistoryStatus { initial, loading, success, failure, empty }

class HistoryState {
  final HistoryStatus status;
  final List<HistoryItemModel> items;
  final HistoryType selectedType;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.items = const [],
    this.selectedType = HistoryType.deposits,
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryItemModel>? items,
    HistoryType? selectedType,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedType: selectedType ?? this.selectedType,
      errorMessage: errorMessage,
    );
  }
}
