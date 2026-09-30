import '../../../app/router/routes.dart';
import '../models/app_notification.dart';

/// Sample feed, generated relative to [now] so the grouping (Today, Yesterday,
/// Earlier) always looks realistic. Read/deleted state is applied by the repository.
List<AppNotification> mockNotifications(DateTime now) {
  AppNotification n(
    String id,
    NotificationType type,
    String title,
    String body,
    Duration ago, {
    String? route,
  }) =>
      AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: now.subtract(ago),
        route: route,
      );

  final popular = Routes.productsFor(title: 'Popular Picks', section: 'popular');

  return [
    n(
      'n1',
      NotificationType.delivery,
      'Your order is out for delivery',
      'Ravi is on the way with your fresh order and should reach you in about 15 minutes.',
      const Duration(minutes: 6),
      route: Routes.orders,
    ),
    n(
      'n2',
      NotificationType.offer,
      'Flat 20% off on Country Hen',
      'Fresh, free-range country hen cut your way. Use code HEN20 on orders above ₹499.',
      const Duration(minutes: 52),
      route: popular,
    ),
    n(
      'n3',
      NotificationType.order,
      'Order confirmed',
      'We have received your order and our butchers are getting it ready.',
      const Duration(hours: 2, minutes: 10),
      route: Routes.orders,
    ),
    n(
      'n4',
      NotificationType.offer,
      'Free delivery this weekend',
      'No delivery fee on every order above ₹299, Saturday and Sunday only.',
      const Duration(hours: 5),
      route: popular,
    ),
    n(
      'n5',
      NotificationType.delivery,
      'Order delivered',
      'Your order was delivered. Enjoy your fresh cuts and do rate your experience!',
      const Duration(days: 1, hours: 1),
      route: Routes.orders,
    ),
    n(
      'n6',
      NotificationType.order,
      'Order is being prepared',
      'Your chicken curry cut is being freshly cleaned and packed.',
      const Duration(days: 1, hours: 2),
      route: Routes.orders,
    ),
    n(
      'n7',
      NotificationType.system,
      'Add your delivery address',
      'Save your home and work addresses to check out faster next time.',
      const Duration(days: 1, hours: 6),
      route: Routes.addresses,
    ),
    n(
      'n8',
      NotificationType.offer,
      'Eggs at a special price',
      'Farm eggs, tray of 30 at just ₹179 for the next 48 hours.',
      const Duration(days: 3),
      route: popular,
    ),
    n(
      'n9',
      NotificationType.order,
      'Order delivered',
      'Thanks for shopping with Fresh Hen. Your invoice is available in My Orders.',
      const Duration(days: 4, hours: 3),
      route: Routes.orders,
    ),
    n(
      'n10',
      NotificationType.system,
      'Welcome to Fresh Hen',
      'Farm fresh, handpicked and hygienically cut. Start with your first order today.',
      const Duration(days: 6),
    ),
  ];
}
