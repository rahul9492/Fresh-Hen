import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/env.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/prefs_provider.dart';
import '../repositories/mock_notification_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/remote_notification_repository.dart';

part 'notification_repository_provider.g.dart';

/// The only place that decides mock vs remote for notifications.
@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) {
  if (Env.useMock) return MockNotificationRepository(ref.watch(sharedPrefsProvider));
  return RemoteNotificationRepository(ref.watch(dioProvider));
}
