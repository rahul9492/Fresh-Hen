import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/tab_close_button.dart';
import '../../../core/widgets/brand_refresh.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../cart/providers/cart_providers.dart';
import '../models/order_models.dart';
import '../providers/order_providers.dart';
import '../widgets/empty_orders.dart';
import '../widgets/order_card.dart';
import '../widgets/live_order_refresh.dart';
import '../widgets/order_actions.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  static const _background = AppColors.page;

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
        // Same soft down-arrow as the Categories tab: closes this tab back to Home.
        leading: const TabCloseButton(),
        leadingWidth: TabCloseButton.width,
        titleSpacing: 12,
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
              return EmptyOrders(onShop: () => context.go(Routes.home));
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
