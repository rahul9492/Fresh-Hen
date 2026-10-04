import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/env.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/media/image_picking.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/push/push_route.dart';
import '../../../core/push/push_service.dart';
import '../../address/providers/address_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_providers.dart';
import '../../checkout/models/checkout_models.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../models/order_models.dart';
import '../repositories/order_repository.dart';

part 'order_providers.g.dart';

/// The only place that decides mock vs remote for orders.
@Riverpod(keepAlive: true)
OrderRepository orderRepository(Ref ref) {
  if (Env.useMock) return MockOrderRepository();
  return RemoteOrderRepository(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
class Orders extends _$Orders {
  @override
  Future<List<Order>> build() async {
    // A different user (or logout) means a different order history.
    if (ref.watch(authSessionProvider) == null) return const [];

    // An order or payment push while the app is open: show the new status now.
    final pushes = ref.watch(pushServiceProvider).received.listen((data) {
      final type = data['type'];
      if (type == PushType.order.name || type == PushType.payment.name) {
        unawaited(refreshQuietly());
      }
    });
    ref.onDispose(pushes.cancel);

    return ref.watch(orderRepositoryProvider).fetch();
  }

  List<Order> get _current => state.value ?? const [];

  /// Reloads without a loading state, so open screens just update in place.
  /// Offline, the current list stays.
  Future<void> refreshQuietly() async {
    if (ref.read(authSessionProvider) == null) return;
    try {
      final fresh = await ref.read(orderRepositoryProvider).fetch();
      if (ref.mounted) state = AsyncData(fresh);
    } catch (_) {}
  }

  /// Not optimistic: the store may have just started preparing it.
  Future<void> cancel(String orderId, {required String reason}) async {
    final updated = await ref.read(orderRepositoryProvider).cancel(orderId, reason: reason);
    if (!ref.mounted) return;
    state = AsyncData([
      for (final o in _current) o.id == orderId ? updated : o,
    ]);
  }

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
      if (!settings.deliversTo(address.pincode)) {
        throw AppException(
          "We don't deliver to ${address.pincode} yet. Please choose another address.",
        );
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
        addressId: address.id,
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
