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

/// Amber for "waiting on the store", between the pending blue and the busy orange.
const _waitingColor = Color(0xFFB7791F);

extension OrderDisplay on Order {
  /// "Awaiting confirmation" while a UPI payment is being checked, "Payment
  /// issue" if it was rejected, "Scheduled" for a confirmed order with a slot,
  /// else the status label.
  String get statusLabel {
    if (paymentIssue) return 'Payment issue';
    if (awaitingConfirmation) return 'Awaiting confirmation';
    return status == OrderStatus.confirmed && slot != null ? 'Scheduled' : status.label;
  }

  IconData get statusIcon {
    if (paymentIssue) return Icons.error_outline_rounded;
    if (awaitingConfirmation) return Icons.hourglass_top_rounded;
    return status == OrderStatus.confirmed && slot != null ? Icons.event_available_rounded : status.icon;
  }

  /// The status colour, accounting for a payment being checked or rejected.
  Color get statusColor {
    if (paymentIssue) return AppColors.accent;
    if (awaitingConfirmation) return _waitingColor;
    return status.color;
  }

  /// One line under the status, e.g. "Delivered today at 4:37 PM".
  String statusDetail({required String eta}) {
    if (paymentIssue) return "We couldn't verify your payment. Please contact us.";
    // No ETA yet: the clock starts once the store accepts the order.
    if (awaitingConfirmation) return "We're checking your payment and will confirm your order shortly";
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
