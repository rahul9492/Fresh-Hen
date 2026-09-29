import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../cart/providers/cart_providers.dart';
import '../models/order_models.dart';
import '../repositories/order_repository.dart';

part 'order_providers.g.dart';

const defaultDeliveryAddress = 'Home • Koramangala, Bengaluru 560034';

@Riverpod(keepAlive: true)
OrderRepository orderRepository(Ref ref) => MockOrderRepository();

@Riverpod(keepAlive: true)
class Orders extends _$Orders {
  @override
  List<Order> build() => const [];

  void add(Order order) => state = [order, ...state];
}

@riverpod
class PlaceOrder extends _$PlaceOrder {
  @override
  FutureOr<Order?> build() => null;

  Future<Order?> submit() async {
    final lines = ref.read(cartProvider);
    final summary = ref.read(cartSummaryProvider);
    if (lines.isEmpty) return null;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(orderRepositoryProvider).place(
            lines: lines,
            total: summary.grandTotal,
            address: defaultDeliveryAddress,
          ),
    );
    final order = state.value;
    if (order != null) {
      ref.read(ordersProvider.notifier).add(order);
      ref.read(cartProvider.notifier).clear();
    }
    return order;
  }
}
