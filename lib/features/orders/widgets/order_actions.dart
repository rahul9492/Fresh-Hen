import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/utils/context_x.dart';
import '../../cart/providers/cart_providers.dart';
import '../models/order_models.dart';
import '../providers/order_providers.dart';
import 'cancel_order_sheet.dart';
import 'rate_experience_sheet.dart';

/// Puts every item of [order] back in the cart and opens it.
void repeatOrder(BuildContext context, WidgetRef ref, Order order) {
  ref.read(cartProvider.notifier).addAll(order.lines);
  context.push(Routes.cart);
}

/// Opens the rating sheet and saves the result.
Future<void> rateOrder(BuildContext context, WidgetRef ref, Order order) async {
  final review = await showRateExperienceSheet(context, order: order);
  if (review == null || !context.mounted) return;
  try {
    await ref
        .read(ordersProvider.notifier)
        .rate(order.id, stars: review.stars, comment: review.comment);
    if (context.mounted) context.showSuccess('Thanks for your feedback!');
  } catch (e) {
    if (context.mounted) context.showError(e);
  }
}

/// Asks for a reason and cancels [order]. If the store already started on it,
/// the reloaded status shows why it can't be cancelled.
Future<void> cancelOrder(BuildContext context, WidgetRef ref, Order order) async {
  final reason = await showCancelOrderSheet(context, order: order);
  if (reason == null || !context.mounted) return;
  try {
    await ref.read(ordersProvider.notifier).cancel(order.id, reason: reason);
    if (context.mounted) context.showSuccess('Your order has been cancelled');
  } catch (e) {
    await ref.read(ordersProvider.notifier).refreshQuietly();
    if (context.mounted) context.showError(e);
  }
}
