import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/notification_repository.dart';
import 'notification_state.dart';

@injectable
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(const NotificationState());

  /// Fetch all notifications
  Future<void> fetchNotifications() async {
    emit(state.copyWith(status: NotificationStatus.loading));

    try {
      final notifications = await _repository.fetchNotifications();

      if (notifications.isEmpty) {
        emit(
          state.copyWith(status: NotificationStatus.empty, notifications: []),
        );
      } else {
        emit(
          state.copyWith(
            status: NotificationStatus.success,
            notifications: notifications,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }
}
