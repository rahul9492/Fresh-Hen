import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

enum NotificationType { order, delivery, offer, system }

/// Tabs on the notifications screen.
enum NotificationFilter {
  all('All'),
  orders('Orders'),
  offers('Offers');

  const NotificationFilter(this.label);

  final String label;

  bool matches(AppNotification n) => switch (this) {
        NotificationFilter.all => true,
        NotificationFilter.orders =>
          n.type == NotificationType.order || n.type == NotificationType.delivery,
        NotificationFilter.offers => n.type == NotificationType.offer,
      };
}

@freezed
abstract class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required String id,
    @JsonKey(unknownEnumValue: NotificationType.system) required NotificationType type,
    required String title,
    required String body,
    required DateTime createdAt,
    @Default(false) bool isRead,

    /// In-app route opened when the notification is tapped (optional).
    String? route,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
}
