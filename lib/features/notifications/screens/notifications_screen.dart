import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/choice_chip_group.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/small_widgets.dart';
import '../models/app_notification.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  var _filter = NotificationFilter.all;

  Future<void> _refresh() => ref.refresh(notificationsProvider.future);

  void _open(AppNotification n) {
    ref.read(notificationsProvider.notifier).markRead(n.id);
    final route = n.route;
    if (route != null) context.push(route);
  }

  void _dismiss(AppNotification n) {
    final controller = ref.read(notificationsProvider.notifier)..remove(n);
    AppSnackbar.info(
      context,
      'Notification removed',
      duration: notificationUndoWindow,
      actionLabel: 'Undo',
      onAction: () => controller.undoRemove(n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: unread == 0
                ? null
                : () => ref.read(notificationsProvider.notifier).markAllRead(),
            child: const Text('Mark all read'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: ChoiceChipGroup<NotificationFilter>(
              values: NotificationFilter.values,
              selected: _filter,
              label: (f) => f.label,
              onSelected: (f) => setState(() => _filter = f),
            ),
          ),
          Expanded(
            child: AsyncView(
              value: notifications,
              onRetry: () => ref.invalidate(notificationsProvider),
              loading: const ShimmerList(itemHeight: 96),
              data: (all) => _List(
                items: all.where(_filter.matches).toList(),
                filter: _filter,
                onRefresh: _refresh,
                onOpen: _open,
                onDismiss: _dismiss,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.items,
    required this.filter,
    required this.onRefresh,
    required this.onOpen,
    required this.onDismiss,
  });

  final List<AppNotification> items;
  final NotificationFilter filter;
  final Future<void> Function() onRefresh;
  final ValueChanged<AppNotification> onOpen;
  final ValueChanged<AppNotification> onDismiss;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 420,
              child: EmptyState(
                icon: Icons.notifications_none_rounded,
                title: filter == NotificationFilter.all
                    ? "You're all caught up"
                    : 'No ${filter.label.toLowerCase()} notifications',
                message: 'We will let you know when something new arrives.',
              ),
            ),
          ],
        ),
      );
    }

    final rows = _rows(items);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: rows.length,
        itemBuilder: (context, i) {
          final row = rows[i];
          if (row is String) return _GroupHeader(row);
          final n = row as AppNotification;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Dismissible(
              key: ValueKey(n.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => onDismiss(n),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 22),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
              ),
              child: NotificationTile(notification: n, onTap: () => onOpen(n)),
            ),
          );
        },
      ),
    );
  }

  /// Interleaves "Today" / "Yesterday" / "Earlier" headers with the items.
  static List<Object> _rows(List<AppNotification> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    String group(DateTime d) {
      final day = DateTime(d.year, d.month, d.day);
      final diff = today.difference(day).inDays;
      return diff <= 0 ? 'Today' : (diff == 1 ? 'Yesterday' : 'Earlier');
    }

    final rows = <Object>[];
    String? current;
    for (final n in items) {
      final g = group(n.createdAt);
      if (g != current) {
        rows.add(g);
        current = g;
      }
      rows.add(n);
    }
    return rows;
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 0, 10),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.body,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
