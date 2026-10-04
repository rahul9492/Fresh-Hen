import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../models/order_models.dart';

extension OrderStatusStyle on OrderStatus {
  IconData get icon => switch (this) {
        OrderStatus.confirmed => Icons.receipt_long_rounded,
        OrderStatus.preparing => Icons.inventory_2_rounded,
        OrderStatus.outForDelivery => Icons.delivery_dining_rounded,
        OrderStatus.delivered => Icons.check_rounded,
        OrderStatus.cancelled => Icons.close_rounded,
      };

  Color get color => switch (this) {
        OrderStatus.confirmed => const Color(0xFF2F6FDF),
        OrderStatus.preparing => const Color(0xFFD98A00),
        OrderStatus.outForDelivery => const Color(0xFFE8710A),
        OrderStatus.delivered => AppColors.success,
        OrderStatus.cancelled => AppColors.accent,
      };
}

extension OrderDisplay on Order {
  /// "Scheduled" for a confirmed order with a slot, else the status label.
  String get statusLabel =>
      status == OrderStatus.confirmed && slot != null ? 'Scheduled' : status.label;

  IconData get statusIcon =>
      status == OrderStatus.confirmed && slot != null ? Icons.event_available_rounded : status.icon;

  /// One line under the status, e.g. "Delivered today at 4:37 PM".
  String statusDetail({required String eta}) {
    final s = slot;
    return switch (status) {
      OrderStatus.delivered =>
        deliveredAt == null ? 'Delivered' : formatDeliveredAt(deliveredAt!),
      OrderStatus.cancelled =>
        cancelReason == null ? 'This order was cancelled' : 'Cancelled: $cancelReason',
      OrderStatus.outForDelivery => 'Your order is on the way',
      _ when s != null => 'Arriving ${s.label}',
      _ => 'Arriving in $eta',
    };
  }
}
