import 'package:crypto_app/features/history/data/models/history_model.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/networking/http_services.dart';

@injectable
class HistoryRepository {
  final HttpServices httpServices;

  HistoryRepository(this.httpServices);

  /// Fetch history by type
  Future<List<HistoryItemModel>> fetchHistory(String type) async {
    try {
      final response = await httpServices.get('api/history?type=$type');

      final historyResponse = HistoryResponseModel.fromJson(response);
      return historyResponse.data;
    } catch (e) {
      rethrow;
    }
  }
}
