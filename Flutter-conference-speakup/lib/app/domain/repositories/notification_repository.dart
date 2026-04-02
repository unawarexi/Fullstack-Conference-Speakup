import 'package:video_confrence_app/core/network/api_client.dart';
import 'package:video_confrence_app/core/apis/endpoints.dart';
import 'package:video_confrence_app/app/domain/models/notification_model.dart';

class NotificationRepository {
  final _api = ApiClient.instance;

  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _api.get(ApiEndpoints.notifications, queryParameters: {
      'page': page,
      'limit': limit,
    });
    final list = res.data['data'] as List;
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<int> getUnreadCount() async {
    final res = await _api.get(ApiEndpoints.notificationUnreadCount);
    return res.data['data']['count'] as int;
  }

  Future<void> markAllAsRead() =>
      _api.put(ApiEndpoints.notificationReadAll);

  Future<void> markAsRead(String id) =>
      _api.put(ApiEndpoints.notificationRead(id));

  Future<void> delete(String id) =>
      _api.delete(ApiEndpoints.notificationDelete(id));
}
