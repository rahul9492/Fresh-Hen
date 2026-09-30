import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/add_control.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/product_image.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../address/providers/address_providers.dart';
import '../../orders/providers/order_providers.dart';
import '../models/cart_models.dart';
import '../providers/cart_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _placeOrder(BuildContext context, WidgetRef ref) async {
    final order = await ref.read(placeOrderProvider.notifier).submit();
    if (order != null && context.mounted) context.go(Routes.orderSuccessFor(order.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(placeOrderProvider, (_, s) {
      if (s.hasError) context.showError(s.error!);
    });
    final lines = ref.watch(cartProvider);
    final summary = ref.watch(cartSummaryProvider);
    final placing = ref.watch(placeOrderProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: lines.isEmpty
          ? EmptyState(
              icon: Icons.shopping_basket_outlined,
              title: 'Your cart is empty',
              message: 'Add some fresh cuts to get started.',
              action: OutlinedButton(
                onPressed: () => context.go(Routes.home),
                child: const Text('Browse items'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Card(
                  child: Column(
                    children: [for (final line in lines) _LineTile(line: line)],
                  ),
                ),
                const SizedBox(height: 16),
                _Card(child: _Bill(summary: summary)),
                const SizedBox(height: 16),
                _Card(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ref.watch(selectedAddressProvider).fullText,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(Routes.addresses),
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: lines.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  label: 'Place Order • ${rupees(summary.grandTotal)}',
                  loading: placing,
                  onPressed: () => _placeOrder(context, ref),
                ),
              ),
            ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _LineTile extends ConsumerWidget {
  const _LineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ProductImage(asset: line.image, size: 56, radius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${line.unitLabel} • ${rupees(line.unitPrice)}',
                  style: const TextStyle(color: AppColors.body, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              QtyStepper(
                quantity: line.quantity,
                onIncrement: () => cart.increment(line.id),
                onDecrement: () => cart.decrement(line.id),
              ),
              const SizedBox(height: 4),
              Text(rupees(line.total), style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bill extends StatelessWidget {
  const _Bill({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {bool bold = false, Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
              Text(
                value,
                style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: color),
              ),
            ],
          ),
        );

    final remaining = AppConstants.freeDeliveryThreshold - summary.itemTotal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bill details', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        row('Item total', rupees(summary.itemTotal)),
        row(
          'Delivery fee',
          summary.deliveryFee == 0 ? 'FREE' : rupees(summary.deliveryFee),
          color: summary.deliveryFee == 0 ? AppColors.success : null,
        ),
        const Divider(height: 20),
        row('To pay', rupees(summary.grandTotal), bold: true),
        if (remaining > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Add ${rupees(remaining)} more for free delivery',
              style: const TextStyle(color: AppColors.primary, fontSize: 12.5),
            ),
          ),
      ],
    );
  }
}
