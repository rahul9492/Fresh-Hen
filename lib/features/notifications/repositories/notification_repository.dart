import '../models/app_notification.dart';

abstract interface class NotificationRepository {
  /// Newest first.
  Future<List<AppNotification>> fetch();

  Future<void> markRead(String id);

  Future<void> markAllRead();

  Future<void> delete(String id);
}
