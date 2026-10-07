import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../models/order_models.dart';
import 'awaiting_payment_card.dart';
import 'payment_issue_card.dart';
import 'stage_card.dart';
import 'on_the_way_card.dart';

/// Animated header for an order in progress: an hourglass while a UPI payment
/// is being checked, a cleaver chopping while it is being prepared, a scooter
/// riding from the store to your home while it is on its way, and a tick once
/// it is delivered. A rejected payment shows a help card instead. Nothing for
/// other statuses.
///
/// Purely visual: there is no live rider tracking, so the scooter just loops
/// along the route rather than showing real progress or an ETA.
class OrderStatusScene extends StatelessWidget {
  const OrderStatusScene({super.key, required this.order});

  final Order order;

  static const _preparing = 'assets/lottie/order_preparing.json';
  static const _delivered = 'assets/lottie/order_delivered.json';

  @override
  Widget build(BuildContext context) {
    final scene = switch (order.status) {
      // Payment problems come first: nothing else moves until they are sorted.
      _ when order.paymentIssue => const PaymentIssueCard(key: ValueKey('paymentIssue')),
      _ when order.awaitingConfirmation => const AwaitingPaymentCard(key: ValueKey('awaiting')),
      OrderStatus.preparing => const StageCard(
        key: ValueKey('preparing'),
        lottie: _preparing,
        fallbackIcon: Icons.restaurant_rounded,
        title: 'Your order is being prepared',
        subtitle: 'Cleaning, cutting and packing it fresh',
      ),
      OrderStatus.outForDelivery => OnTheWayCard(
        key: const ValueKey('onTheWay'),
        rider: order.rider,
      ),
      OrderStatus.delivered => const StageCard(
        key: ValueKey('delivered'),
        lottie: _delivered,
        fallbackIcon: Icons.check_circle_rounded,
        title: 'Order delivered',
        subtitle: 'Enjoy your fresh meal!',
        playOnce: true,
        tint: AppColors.success,
      ),
      _ => null,
    };

    // Grows, shrinks and cross-fades as the order moves from one stage to the next.
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: scene == null
            ? const SizedBox(width: double.infinity, key: ValueKey('none'))
            : Padding(key: scene.key, padding: const EdgeInsets.only(bottom: 16), child: scene),
      ),
    );
  }
}
