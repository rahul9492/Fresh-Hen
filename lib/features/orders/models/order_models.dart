import 'package:freezed_annotation/freezed_annotation.dart';

import '../../cart/models/cart_models.dart';

part 'order_models.freezed.dart';

enum OrderStatus {
  confirmed('Confirmed'),
  preparing('Being prepared'),
  outForDelivery('Out for delivery'),
  delivered('Delivered');

  const OrderStatus(this.label);

  final String label;
}

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required DateTime placedAt,
    required List<CartLine> lines,
    required int total,
    required String address,
    @Default(OrderStatus.confirmed) OrderStatus status,
  }) = _Order;
}
