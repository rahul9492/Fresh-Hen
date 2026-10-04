import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/bottom_action_bar.dart';
import '../../../core/widgets/product_image.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../cart/models/cart_models.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../../checkout/widgets/bill_summary.dart';
import '../models/order_models.dart';
import '../providers/order_providers.dart';
import '../widgets/order_actions.dart';
import '../widgets/order_timeline.dart';
import '../widgets/order_status_style.dart';

class OrderSummaryScreen extends ConsumerStatefulWidget {
  const OrderSummaryScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends ConsumerState<OrderSummaryScreen> {
  String get orderId => widget.orderId;

  @override
  void initState() {
    super.initState();
    // Opened from a push or the list: show the latest status, not a stale one.
    Future.microtask(() => ref.read(ordersProvider.notifier).refreshQuietly());
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderProvider(orderId));
    final current = order.value;
    final canRepeat = current?.status.isActive == false;

    return Scaffold(
      backgroundColor: AppColors.page,
      appBar: AppBar(title: const Text('Order Summary')),
      body: AsyncView(
        value: order,
        onRetry: () => ref.invalidate(ordersProvider),
        loading: const ShimmerList(itemCount: 4, itemHeight: 140),
        data: (order) => order == null
            ? EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Order not found',
                message: 'We could not find order #$orderId.',
                action: OutlinedButton(
                  onPressed: () => context.go(Routes.orders),
                  child: const Text('See all orders'),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(ordersProvider.future),
                child: _Body(order: order),
              ),
      ),
      bottomNavigationBar: canRepeat
          ? BottomActionBar(
              button: AppButton(
                label: 'Repeat Order',
                onPressed: () => repeatOrder(context, ref, current!),
              ),
            )
          : current != null && current.canCancel
              ? BottomActionBar(
                  button: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => cancelOrder(context, ref, current),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Cancel order'),
                    ),
                  ),
                )
              : null,
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eta = ref.watch(currentStoreSettingsProvider).etaLabel;
    final paid = order.paymentStatus == PaymentStatus.paid;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 9,
                    backgroundColor: order.status.color,
                    child: Icon(order.statusIcon, size: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.statusDetail(eta: eta),
                      style: const TextStyle(color: AppColors.body, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
              if (order.hasInvoice) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => context.push(Routes.invoiceFor(order.id)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Download Tax Invoice',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.download_rounded, size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(child: OrderTimeline(order: order)),
        if (order.status == OrderStatus.outForDelivery && order.rider != null) ...[
          const SizedBox(height: 14),
          RiderCard(rider: order.rider!),
        ],
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} in this order',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              for (var i = 0; i < order.lines.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.hairline),
                _ItemRow(line: order.lines[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: BillSummary(
            bill: order.bill,
            title: 'Bill Details',
            totalLabel: paid ? 'Total Paid' : 'Total Amount',
            highlightTotal: !paid,
          ),
        ),
        const SizedBox(height: 14),
        _DetailsCard(order: order),
        if (order.status == OrderStatus.delivered) ...[
          const SizedBox(height: 14),
          _RatingCard(order: order),
        ],
        const SizedBox(height: 14),
        const _HelpCard(),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          ProductImage(asset: line.image, size: 60, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 3),
                Text(
                  '${line.unitLabel} x ${line.quantity}${line.isAddon ? ' • Add-on' : ''}',
                  style: const TextStyle(color: AppColors.body, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                if (line.isDiscounted)
                  TextSpan(
                    text: '${rupees(line.mrpTotal)}  ',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                TextSpan(text: rupees(line.total)),
              ],
            ),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final payment = switch (order.paymentMethod) {
      PaymentMethod.cash => order.paymentStatus == PaymentStatus.paid
          ? 'Paid in cash on delivery'
          : 'Cash on Delivery',
      PaymentMethod.upi => order.paymentStatus == PaymentStatus.paid
          ? 'Paid online via UPI'
          : 'UPI • ${order.paymentStatus.label}',
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          _Detail(
            label: 'Order ID',
            child: Row(
              children: [
                Text(order.id, style: _Detail.valueStyle),
                const SizedBox(width: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: order.id));
                    context.showSuccess('Order ID copied');
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.copy_rounded, size: 16, color: AppColors.body),
                  ),
                ),
              ],
            ),
          ),
          _Detail(label: 'Placed on', value: formatOrderDate(order.placedAt)),
          _Detail(label: 'Payment Mode', value: payment),
          if (order.paymentReference != null)
            _Detail(label: 'UPI Reference', value: order.paymentReference!),
          if (order.slot != null) _Detail(label: 'Delivery Slot', value: order.slot!.label),
          if (order.instructions != null)
            _Detail(label: 'Special Instructions', value: order.instructions!),
          _Detail(
            label: order.status == OrderStatus.delivered ? 'Delivered To' : 'Delivering To',
            value: '${order.addressLabel}\n${order.address}',
          ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, this.value, this.child});

  final String label;
  final String? value;
  final Widget? child;

  static const valueStyle = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.35);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.body, fontSize: 12.5)),
          const SizedBox(height: 3),
          child ?? Text(value!, style: valueStyle),
        ],
      ),
    );
  }
}

class _RatingCard extends ConsumerWidget {
  const _RatingCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = order.rating;
    return AppCard(
      onTap: () => rateOrder(context, ref, order),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rating == null ? 'How was your order?' : 'Your rating',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      Icon(
                        i <= (rating ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 24,
                        color: i <= (rating ?? 0) ? AppColors.star : AppColors.muted,
                      ),
                  ],
                ),
                if (order.review != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '“${order.review}”',
                    style: const TextStyle(color: AppColors.body, fontSize: 13, height: 1.35),
                  ),
                ],
              ],
            ),
          ),
          Text(
            rating == null ? 'Rate now' : 'Edit',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Need help with your order?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Material(
            color: const Color(0xFFF1F2FD),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => context.push(Routes.help),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.accentSoft,
                      child: Icon(Icons.support_agent_rounded, color: AppColors.primary),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Fresh Hen',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Cut quality, weight, or refund queries',
                            style: TextStyle(color: AppColors.body, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.body),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
