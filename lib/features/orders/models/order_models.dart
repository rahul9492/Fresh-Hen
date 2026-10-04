import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/formatters.dart';
import '../../cart/models/cart_models.dart';

part 'order_models.freezed.dart';
part 'order_models.g.dart';

enum OrderStatus {
  confirmed('Confirmed'),
  preparing('Being prepared'),
  outForDelivery('Out for delivery'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.label);

  final String label;

  /// Still on its way: the customer can only ask for help, not reorder or rate.
  bool get isActive => this != delivered && this != cancelled;
}

enum PaymentMethod {
  cash('Cash on Delivery'),
  upi('UPI (Scan & Pay)');

  const PaymentMethod(this.label);

  final String label;
}

enum PaymentStatus {
  /// Cash on delivery, collected at the door.
  due('Pay on delivery'),

  /// UPI proof uploaded, waiting for the store to match it with its bank.
  verifying('Verification pending'),
  paid('Paid'),

  /// The store could not match the UPI payment to the uploaded proof.
  rejected('Payment rejected');

  const PaymentStatus(this.label);

  final String label;
}

/// A delivery window, e.g. Sat 4 Oct, 10:00 AM - 11:00 AM.
@freezed
abstract class DeliverySlot with _$DeliverySlot {
  const DeliverySlot._();

  const factory DeliverySlot({
    required String id,
    required DateTime start,
    required DateTime end,

    /// False when the slot is full or too close to start.
    @Default(true) bool available,
  }) = _DeliverySlot;

  factory DeliverySlot.fromJson(Map<String, dynamic> json) => _$DeliverySlotFromJson(json);

  /// "10:00 AM - 11:00 AM"
  String get timeLabel => '${formatClock(start)} - ${formatClock(end)}';

  /// "Today, 10:00 AM - 11:00 AM" / "Sat 4 Oct, 10:00 AM - 11:00 AM"
  String get label => '${formatDayName(start)}, $timeLabel';

  /// "Tomorrow, 7-8 AM" / "Sat 4 Oct, 11 AM-12 PM", for tight spaces.
  String get shortLabel => '${formatDayName(start)}, ${formatTimeRange(start, end)}';
}

@freezed
abstract class OrderBill with _$OrderBill {
  const OrderBill._();

  const factory OrderBill({
    required int itemTotal,

    /// Sum of MRPs, to show what the customer saved on item prices.
    required int mrpTotal,
    required int deliveryFee,
    @Default(0) int discount,
    @Default(0) int taxes,
    String? couponCode,
  }) = _OrderBill;

  factory OrderBill.fromJson(Map<String, dynamic> json) => _$OrderBillFromJson(json);

  int get total => itemTotal + deliveryFee + taxes - discount;

  int get savings => (mrpTotal - itemTotal) + discount;

  static OrderBill forLines(List<CartLine> lines, {required int deliveryFee}) {
    final itemTotal = lines.fold<int>(0, (sum, l) => sum + l.total);
    return OrderBill(
      itemTotal: itemTotal,
      mrpTotal: lines.fold<int>(0, (sum, l) => sum + l.mrpTotal),
      deliveryFee: deliveryFee,
    );
  }
}

/// When the order reached [status]; the order's tracking timeline.
@freezed
abstract class OrderEvent with _$OrderEvent {
  const factory OrderEvent({
    @JsonKey(unknownEnumValue: OrderStatus.confirmed) required OrderStatus status,
    required DateTime at,
  }) = _OrderEvent;

  factory OrderEvent.fromJson(Map<String, dynamic> json) => _$OrderEventFromJson(json);
}

/// Who is bringing the order, shown once it is out for delivery.
@freezed
abstract class DeliveryRider with _$DeliveryRider {
  const factory DeliveryRider({required String name, required String phone}) = _DeliveryRider;

  factory DeliveryRider.fromJson(Map<String, dynamic> json) => _$DeliveryRiderFromJson(json);
}

@freezed
abstract class Order with _$Order {
  const Order._();

  const factory Order({
    required String id,
    required DateTime placedAt,
    required List<CartLine> lines,
    required OrderBill bill,

    /// Full delivery address as printed on the invoice.
    required String address,
    @Default('Home') String addressLabel,
    // A status this app version doesn't know yet still shows, as the nearest one.
    @JsonKey(unknownEnumValue: OrderStatus.confirmed)
    @Default(OrderStatus.confirmed)
    OrderStatus status,
    @Default(PaymentMethod.cash) PaymentMethod paymentMethod,
    @JsonKey(unknownEnumValue: PaymentStatus.verifying)
    @Default(PaymentStatus.due)
    PaymentStatus paymentStatus,

    /// Null means "order now" (delivered within the store's ETA).
    DeliverySlot? slot,
    String? instructions,
    DateTime? deliveredAt,

    /// UPI transaction reference (UTR) the customer typed, if any.
    String? paymentReference,

    /// Where the uploaded UPI screenshot lives (URL or storage key).
    String? paymentProof,

    /// 1-5 stars and an optional comment once the customer rates the order.
    int? rating,
    String? review,

    /// Why it was cancelled, as the customer or the store put it.
    String? cancelReason,

    /// Each status the order reached and when, oldest first.
    @Default(<OrderEvent>[]) List<OrderEvent> events,
    DeliveryRider? rider,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  int get total => bill.total;

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  /// When the order reached [s], if it has. Older orders without events
  /// still know when they were placed and delivered.
  DateTime? reachedAt(OrderStatus s) =>
      events.where((e) => e.status == s).firstOrNull?.at ??
      switch (s) {
        OrderStatus.confirmed => placedAt,
        OrderStatus.delivered => deliveredAt,
        _ => null,
      };

  /// The customer may cancel only until the store starts preparing it.
  bool get canCancel => status == OrderStatus.confirmed;

  /// A delivered order can be invoiced; so can a paid one still on its way.
  bool get hasInvoice =>
      status == OrderStatus.delivered ||
      (status != OrderStatus.cancelled && paymentStatus == PaymentStatus.paid);
}
