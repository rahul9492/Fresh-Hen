import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/brand_refresh.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../cart/providers/cart_providers.dart';
import '../models/order_models.dart';
import '../providers/order_providers.dart';
import '../widgets/order_card.dart';
import '../widgets/live_order_refresh.dart';
import '../widgets/order_actions.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  static const _background = Color(0xFFF8F8F8);

  var _query = '';

  Future<void> _refresh() => ref.refresh(ordersProvider.future);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ordersProvider.notifier).refreshQuietly());
  }

  /// Matches the order ID, the status or any item name.
  bool _matches(Order order) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return order.id.toLowerCase().contains(q) ||
        order.status.label.toLowerCase().contains(q) ||
        order.lines.any((l) => l.name.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final hasCart = !ref.watch(cartSummaryProvider).isEmpty;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          // This is a bottom tab, so there is usually nothing to pop: go Home instead.
          onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
        ),
        titleSpacing: 0,
        title: const Text('My Orders'),
      ),
      // Keeps statuses fresh while any order is still on its way.
      body: LiveOrderRefresh(
        active: ref.watch(ordersProvider).value?.any((o) => o.status.isActive) ?? false,
        child: AsyncView(
          value: ref.watch(ordersProvider),
          onRetry: () => ref.invalidate(ordersProvider),
          loading: const OrderListSkeleton(),
          data: (orders) {
            if (orders.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message: 'Your fresh orders will show up here.',
                action: OutlinedButton(
                  onPressed: () => context.go(Routes.home),
                  child: const Text('Start shopping'),
                ),
              );
            }

            final visible = orders.where(_matches).toList();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: AppSearchBar(
                    hint: 'Search by item or order ID',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? const EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No matching orders',
                          message: 'Try another item name or order ID.',
                        )
                      : BrandRefresh(
                          onRefresh: _refresh,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.fromLTRB(16, 12, 16, hasCart ? 96 : 24),
                            itemCount: visible.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 16),
                            itemBuilder: (_, i) {
                              final order = visible[i];
                              return StaggeredFadeIn(
                                key: ValueKey(order.id),
                                index: i,
                                child: OrderCard(
                                  order: order,
                                  onTap: () => context.push(Routes.orderFor(order.id)),
                                  onReorder: () => repeatOrder(context, ref, order),
                                  onRate: () => rateOrder(context, ref, order),
                                  onHelp: () => context.push(Routes.help),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
