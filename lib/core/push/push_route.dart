import '../../app/router/routes.dart';

/// What a push is about. The backend sends it as `data.type`.
enum PushType { order, payment, offer }

/// Turns a push's `data` into the screen to open when it is tapped.
///
/// Contract with the backend (every value is a string, as FCM requires):
///
/// | type      | other keys                          | opens              |
/// |-----------|-------------------------------------|--------------------|
/// | `order`   | `orderId`                           | order details      |
/// | `payment` | `orderId`                           | order details      |
/// | `offer`   | `productId` or `categoryId`+`title` | product / category |
///
/// Unknown types or missing ids open Home, so a new push type sent before the
/// app knows it still lands somewhere sensible. To add a type: add it to
/// [PushType] and a case below.
String pushRoute(Map<String, dynamic> data) {
  String? value(String key) {
    final v = data[key];
    return v is String && v.isNotEmpty ? v : null;
  }

  final type = PushType.values.asNameMap()[value('type')];
  final orderId = value('orderId');
  final productId = value('productId');
  final categoryId = value('categoryId');

  return switch (type) {
    PushType.order || PushType.payment when orderId != null => Routes.orderFor(orderId),
    PushType.offer when productId != null => Routes.productFor(productId),
    PushType.offer when categoryId != null =>
      Routes.productsFor(title: value('title') ?? 'Offers', category: categoryId),
    _ => Routes.home,
  };
}

/// Android notification channel a push belongs to, so customers can mute
/// offers but keep order updates. The backend sets the same id as
/// `android.notification.channel_id`; without it Android uses order updates
/// (see the default channel in AndroidManifest.xml).
enum PushChannel {
  orderUpdates('order_updates', 'Order updates', 'Order status and payment updates'),
  offers('offers', 'Offers', 'Deals and new products');

  const PushChannel(this.id, this.label, this.description);

  final String id;
  final String label;
  final String description;

  static PushChannel forData(Map<String, dynamic> data) =>
      data['type'] == PushType.offer.name ? offers : orderUpdates;
}
