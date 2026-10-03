import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/media/image_picking.dart';
import '../../address/providers/address_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_providers.dart';
import '../../checkout/models/checkout_models.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../models/order_models.dart';
import '../repositories/order_repository.dart';

part 'order_providers.g.dart';

@Riverpod(keepAlive: true)
OrderRepository orderRepository(Ref ref) => MockOrderRepository();

@Riverpod(keepAlive: true)
class Orders extends _$Orders {
  @override
  Future<List<Order>> build() async {
    // A different user (or logout) means a different order history.
    if (ref.watch(authSessionProvider) == null) return const [];
    return ref.watch(orderRepositoryProvider).fetch();
  }

  List<Order> get _current => state.value ?? const [];

  void add(Order order) => state = AsyncData([
        order,
        for (final o in _current)
          if (o.id != order.id) o,
      ]);

  /// Shows the rating at once; reloads from the server if saving fails.
  Future<void> rate(String orderId, {required int stars, String? comment}) async {
    final review = (comment ?? '').trim();
    state = AsyncData([
      for (final o in _current)
        o.id == orderId ? o.copyWith(rating: stars, review: review.isEmpty ? null : review) : o,
    ]);
    try {
      await ref
          .read(orderRepositoryProvider)
          .rate(orderId, stars: stars, comment: review.isEmpty ? null : review);
    } catch (_) {
      ref.invalidateSelf();
      rethrow;
    }
  }
}

/// One order by id, from the loaded history.
@riverpod
Future<Order?> order(Ref ref, String id) async {
  final orders = await ref.watch(ordersProvider.future);
  return orders.where((o) => o.id == id).firstOrNull;
}

@riverpod
class PlaceOrder extends _$PlaceOrder {
  @override
  FutureOr<Order?> build() => null;

  /// Places the cart as an order. UPI orders must include the payment screenshot.
  Future<Order?> submit({
    required PaymentMethod method,
    PickedImage? proof,
    String? paymentReference,
  }) async {
    final lines = ref.read(cartProvider);
    if (lines.isEmpty || state.isLoading) return null;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final address = ref.read(selectedAddressProvider);
      if (address == null) throw const AppException('Please add a delivery address.');

      // Always check against the latest admin settings, not what the cart showed.
      ref.invalidate(storeSettingsProvider);
      final settings = await ref.read(storeSettingsProvider.future);
      if (method == PaymentMethod.upi && !settings.upiEnabled) {
        throw const AppException('UPI payments are unavailable right now. Please choose cash.');
      }
      if (method == PaymentMethod.cash && !settings.cashOnDeliveryEnabled) {
        throw const AppException('Cash on delivery is unavailable right now. Please pay by UPI.');
      }

      final checkout = ref.read(checkoutProvider);
      final scheduled = ref.read(deliveryModeProvider) == DeliveryMode.scheduled;
      final repo = ref.read(orderRepositoryProvider);

      String? proofKey;
      if (method == PaymentMethod.upi) {
        if (proof == null) throw const AppException('Please upload your payment screenshot.');
        proofKey = await repo.uploadPaymentProof(proof.bytes, proof.name);
      }

      final instructions = checkout.instructions.trim();
      final reference = paymentReference?.trim() ?? '';
      return repo.place(OrderRequest(
        lines: lines,
        bill: ref.read(checkoutBillProvider),
        address: address.line,
        addressLabel: address.title,
        paymentMethod: method,
        slot: scheduled ? checkout.slot : null,
        instructions: instructions.isEmpty ? null : instructions,
        paymentProof: proofKey,
        paymentReference: reference.isEmpty ? null : reference,
      ));
    });

    final order = state.value;
    if (order != null) {
      ref.read(ordersProvider.notifier).add(order);
      ref.read(cartProvider.notifier).clear();
      ref.read(checkoutProvider.notifier).reset();
    }
    return order;
  }
}
