import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/bottom_action_bar.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../models/order_models.dart';
import '../providers/order_providers.dart';

class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  void _viewOrder(BuildContext context) {
    context.go(Routes.orders);
    context.push(Routes.orderFor(orderId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider(orderId)).value;
    final eta = ref.watch(currentStoreSettingsProvider).etaLabel;

    return PopScope(
      // The checkout is done: back goes home, never to the payment screen.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.home);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2CC46B), Color(0xFF1E9E55)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, size: 46, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Order Placed!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "You'll receive updates soon.",
                    style: TextStyle(color: AppColors.muted, fontSize: 13.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Order #$orderId',
                    style: const TextStyle(color: AppColors.body, fontWeight: FontWeight.w600),
                  ),
                  if (order != null) ...[
                    const SizedBox(height: 26),
                    _Details(order: order, eta: eta),
                  ],
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomActionBar(
          button: AppButton(label: 'View Order', onPressed: () => _viewOrder(context)),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.order, required this.eta});

  final Order order;
  final String eta;

  @override
  Widget build(BuildContext context) {
    final slot = order.slot;
    final verifying = order.paymentStatus == PaymentStatus.verifying;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          _Line(
            icon: slot == null ? Icons.bolt_rounded : Icons.schedule_rounded,
            label: slot == null ? 'Arriving in' : 'Delivery slot',
            value: slot == null ? eta : slot.label,
          ),
          const SizedBox(height: 10),
          _Line(
            icon: order.paymentMethod == PaymentMethod.upi
                ? Icons.qr_code_2_rounded
                : Icons.payments_outlined,
            label: order.paymentMethod == PaymentMethod.upi ? 'UPI payment' : 'Cash on Delivery',
            value: rupees(order.total),
          ),
          if (verifying) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.hourglass_top_rounded, size: 18, color: Color(0xFFB7791F)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "We're verifying your payment screenshot. You'll be notified once it's confirmed.",
                      style: TextStyle(color: Color(0xFF8A5A12), fontSize: 12.5, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.body, fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
