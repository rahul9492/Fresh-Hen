import '../../cart/models/cart_models.dart';
import '../../catalog/data/mock_catalog_data.dart';
import '../../checkout/data/mock_checkout_data.dart';
import '../models/order_models.dart';

const _home = 'Tower C, Flat 503, 5th Floor, iThum Tower, Sector 62, Near Fortis Hospital, Noida - 201301';
const _work = 'Kasper Infotech, 3rd Floor, Logix Cyber Park, Sector 62, Noida - 201309';

/// Sample order history, newest first, generated relative to [now] so dates
/// always look recent. Lines come from the catalog so "Repeat order" adds real items.
List<Order> mockOrders(DateTime now) {
  CartLine item(String productId, String variantLabel, {int quantity = 1}) {
    final product = mockProducts.firstWhere((p) => p.id == productId);
    final variant = product.variants.firstWhere((v) => v.label == variantLabel);
    return CartLine.fromVariant(product, variant).copyWith(quantity: quantity);
  }

  CartLine addon(String id) {
    final accompaniment = mockProducts
        .expand((p) => p.accompaniments)
        .firstWhere((a) => a.id == id);
    return CartLine.fromAccompaniment(accompaniment);
  }

  OrderBill bill(List<CartLine> lines, {String? coupon, int discount = 0}) {
    final base = OrderBill.forLines(lines, deliveryFee: 0);
    return base.copyWith(
      deliveryFee: mockStoreSettings.deliveryFeeFor(base.itemTotal),
      taxes: mockStoreSettings.taxesFor(lines),
      discount: discount,
      couponCode: coupon,
    );
  }

  final active = [item('chicken-curry-cut', '1 kg'), addon('acc-mdh-masala')];
  final yesterday = [item('chicken-breast', '1 kg')];
  final bulk = [
    item('chicken-boneless', '500 g'),
    item('classic-eggs', '12 pieces'),
    addon('acc-ginger-garlic'),
    addon('acc-lemon'),
  ];
  final cancelled = [item('mutton-keema', '250 g', quantity: 2)];

  /// Confirmed at [placed], then each later status [step] minutes apart.
  List<OrderEvent> events(DateTime placed, List<OrderStatus> statuses, {int step = 8}) => [
        for (var i = 0; i < statuses.length; i++)
          OrderEvent(status: statuses[i], at: placed.add(Duration(minutes: step * i))),
      ];
  const toDoor = [
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];
  final activeAt = now.subtract(const Duration(minutes: 24));
  final yesterdayAt = now.subtract(const Duration(days: 1, hours: 3));
  final bulkAt = now.subtract(const Duration(days: 3, hours: 5));
  final cancelledAt = now.subtract(const Duration(days: 9, hours: 2));

  return [
    Order(
      id: 'FH284519',
      placedAt: activeAt,
      events: events(activeAt, toDoor.take(3).toList()),
      rider: const DeliveryRider(name: 'Ravi Kumar', phone: '9811122233'),
      lines: active,
      bill: bill(active),
      address: _home,
      status: OrderStatus.outForDelivery,
      paymentMethod: PaymentMethod.upi,
      paymentStatus: PaymentStatus.paid,
      paymentReference: '427816390521',
      instructions: 'Please ring the bell once.',
    ),
    Order(
      id: 'FH284487',
      placedAt: yesterdayAt,
      events: events(yesterdayAt, toDoor, step: 19),
      lines: yesterday,
      bill: bill(yesterday, coupon: 'CHICKEN50', discount: 50),
      address: _work,
      addressLabel: 'Work',
      status: OrderStatus.delivered,
      deliveredAt: now.subtract(const Duration(days: 1, hours: 2, minutes: 4)),
      paymentStatus: PaymentStatus.paid,
    ),
    Order(
      id: 'FH284431',
      placedAt: bulkAt,
      events: events(bulkAt, toDoor, step: 24),
      lines: bulk,
      bill: bill(bulk, coupon: 'FRESH20', discount: 100),
      address: _home,
      status: OrderStatus.delivered,
      deliveredAt: now.subtract(const Duration(days: 3, hours: 3, minutes: 48)),
      paymentMethod: PaymentMethod.upi,
      paymentStatus: PaymentStatus.paid,
      paymentReference: '427512094418',
      rating: 5,
      review: 'Super fresh and neatly packed. Delivery partner was polite.',
    ),
    Order(
      id: 'FH284390',
      placedAt: cancelledAt,
      events: events(cancelledAt, const [OrderStatus.confirmed, OrderStatus.cancelled], step: 5),
      cancelReason: 'Ordered by mistake',
      lines: cancelled,
      bill: bill(cancelled),
      address: _home,
      status: OrderStatus.cancelled,
    ),
  ];
}
