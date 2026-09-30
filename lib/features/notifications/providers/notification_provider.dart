import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/app_notification.dart';
import 'notification_repository_provider.dart';

part 'notification_provider.g.dart';

/// How long a swiped-away notification can be restored before it is deleted for real.
const notificationUndoWindow = Duration(seconds: 4);

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  final _pendingDeletes = <String, Timer>{};

  @override
  Future<List<AppNotification>> build() async {
    ref.onDispose(() {
      for (final t in _pendingDeletes.values) {
        t.cancel();
      }
    });
    // A different user (or logout) means a different feed.
    if (ref.watch(authSessionProvider) == null) return const [];
    return ref.watch(notificationRepositoryProvider).fetch();
  }

  List<AppNotification> get _current => state.value ?? const [];

  /// Applies [change] to the list immediately, then syncs with the server.
  /// If the server call fails the list is reloaded so the UI never lies.
  Future<void> _optimistic(
    List<AppNotification> Function(List<AppNotification>) change,
    Future<void> Function() sync,
  ) async {
    state = AsyncData(change(_current));
    try {
      await sync();
    } catch (_) {
      ref.invalidateSelf();
    }
  }

  Future<void> markRead(String id) {
    final target = _current.where((n) => n.id == id).firstOrNull;
    if (target == null || target.isRead) return Future.value();
    return _optimistic(
      (list) => [for (final n in list) n.id == id ? n.copyWith(isRead: true) : n],
      () => ref.read(notificationRepositoryProvider).markRead(id),
    );
  }

  Future<void> markAllRead() => _optimistic(
        (list) => [for (final n in list) n.copyWith(isRead: true)],
        () => ref.read(notificationRepositoryProvider).markAllRead(),
      );

  /// Removes [notification] from the list now and deletes it on the server once
  /// the undo window passes. Call [undoRemove] to bring it back.
  void remove(AppNotification notification) {
    state = AsyncData([
      for (final n in _current)
        if (n.id != notification.id) n,
    ]);
    _pendingDeletes[notification.id]?.cancel();
    _pendingDeletes[notification.id] = Timer(notificationUndoWindow, () async {
      _pendingDeletes.remove(notification.id);
      try {
        await ref.read(notificationRepositoryProvider).delete(notification.id);
      } catch (_) {
        ref.invalidateSelf();
      }
    });
  }

  void undoRemove(AppNotification notification) {
    final timer = _pendingDeletes.remove(notification.id);
    if (timer == null) return; // already deleted for real
    timer.cancel();
    state = AsyncData([..._current, notification]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }
}

@riverpod
int unreadNotificationCount(Ref ref) =>
    ref.watch(notificationsProvider).value?.where((n) => !n.isRead).length ?? 0;
