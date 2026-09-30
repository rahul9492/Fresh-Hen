import 'package:dio/dio.dart';

import '../../../core/network/api_call.dart';
import '../../../core/network/endpoints.dart';
import '../models/app_notification.dart';
import 'notification_repository.dart';

/// Assumed API shape (adjust when the contract lands):
/// `GET /notifications` -> `{ "data": [ { id, type, title, body, createdAt, isRead, route } ] }`
class RemoteNotificationRepository implements NotificationRepository {
  RemoteNotificationRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<AppNotification>> fetch() => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>(Endpoints.notifications);
        final items = (res.data?['data'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });

  @override
  Future<void> markRead(String id) => apiCall(() async {
        await _dio.post<void>(Endpoints.notificationRead(id));
      });

  @override
  Future<void> markAllRead() => apiCall(() async {
        await _dio.post<void>(Endpoints.notificationsReadAll);
      });

  @override
  Future<void> delete(String id) => apiCall(() async {
        await _dio.delete<void>('${Endpoints.notifications}/$id');
      });
}
