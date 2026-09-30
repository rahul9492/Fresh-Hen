import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../data/mock_notification_data.dart';
import '../models/app_notification.dart';
import 'notification_repository.dart';

/// Serves the sample feed and remembers read / deleted items across launches.
class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _readKey = 'notifications.read';
  static const _deletedKey = 'notifications.deleted';

  Set<String> _ids(String key) => (_prefs.getStringList(key) ?? const []).toSet();

  Future<void> _add(String key, Iterable<String> ids) =>
      _prefs.setStringList(key, {..._ids(key), ...ids}.toList());

  @override
  Future<List<AppNotification>> fetch() async {
    await Future<void>.delayed(AppConstants.mockLatency);
    final read = _ids(_readKey);
    final deleted = _ids(_deletedKey);
    return [
      for (final n in mockNotifications(DateTime.now()))
        if (!deleted.contains(n.id)) n.copyWith(isRead: read.contains(n.id)),
    ];
  }

  @override
  Future<void> markRead(String id) => _add(_readKey, [id]);

  @override
  Future<void> markAllRead() =>
      _add(_readKey, mockNotifications(DateTime.now()).map((n) => n.id));

  @override
  Future<void> delete(String id) => _add(_deletedKey, [id]);
}
