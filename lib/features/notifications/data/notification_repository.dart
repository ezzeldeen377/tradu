import 'package:crypto_app/features/notifications/data/models/notification_model.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/networking/http_services.dart';

@injectable
class NotificationRepository {
  final HttpServices httpServices;

  NotificationRepository(this.httpServices);

  /// Fetch all notifications
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await httpServices.get('api/notifications');

      final notificationResponse = NotificationResponseModel.fromJson(response);
      return notificationResponse.data;
    } catch (e) {
      rethrow;
    }
  }
}
