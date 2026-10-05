import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/env.dart';
import '../../../core/network/dio_provider.dart';
import '../../address/providers/address_providers.dart';
import '../../cart/providers/cart_providers.dart';
import '../../orders/models/order_models.dart';
import '../../orders/providers/order_providers.dart';
import '../models/checkout_models.dart';
import '../repositories/checkout_repository.dart';

part 'checkout_providers.g.dart';

/// The only place that decides mock vs remote for checkout data.
@Riverpod(keepAlive: true)
CheckoutRepository checkoutRepository(Ref ref) =>
    Env.useMock ? MockCheckoutRepository() : RemoteCheckoutRepository(ref.watch(dioProvider));

/// Admin-managed checkout rules. The cart refreshes this when it opens, so a
/// change in the admin app (schedule switch, new QR) shows up without a restart.
@Riverpod(keepAlive: true)
Future<StoreSettings> storeSettings(Ref ref) => ref.watch(checkoutRepositoryProvider).settings();

/// Loaded settings, or the defaults while they load so the cart can render.
@riverpod
StoreSettings currentStoreSettings(Ref ref) =>
    ref.watch(storeSettingsProvider).value ?? const StoreSettings();

/// Fetched fresh each time the slot picker opens, so full slots are current.
@riverpod
Future<List<DeliveryDay>> deliveryDays(Ref ref) =>
    ref.watch(checkoutRepositoryProvider).deliveryDays();

@riverpod
Future<List<Coupon>> coupons(Ref ref) => ref.watch(checkoutRepositoryProvider).coupons();

/// True when the customer has never had an order delivered or on its way.
/// Unknown (still loading) counts as false so first-order coupons aren't misused.
@riverpod
bool isFirstOrder(Ref ref) {
  final orders = ref.watch(ordersProvider).value;
  return orders != null && orders.every((o) => o.status == OrderStatus.cancelled);
}

@Riverpod(keepAlive: true)
class Checkout extends _$Checkout {
  @override
  CheckoutState build() => const CheckoutState();

  void setInstructions(String value) => state = state.copyWith(instructions: value);

  void applyCoupon(Coupon coupon) => state = state.copyWith(coupon: coupon);

  void removeCoupon() => state = state.copyWith(coupon: null);

  void orderNow() => state = state.copyWith(mode: DeliveryMode.now);

  void schedule(DeliverySlot slot) =>
      state = state.copyWith(mode: DeliveryMode.scheduled, slot: slot);

  /// After an order is placed, start the next checkout from scratch.
  void reset() => state = const CheckoutState();
}

/// The delivery mode that will actually be used: scheduling falls back to
/// "Order now" if the admin switched it off after the customer picked a slot.
@riverpod
DeliveryMode deliveryMode(Ref ref) {
  final enabled = ref.watch(currentStoreSettingsProvider.select((s) => s.scheduleEnabled));
  final checkout = ref.watch(checkoutProvider);
  return enabled && checkout.mode == DeliveryMode.scheduled && checkout.slot != null
      ? DeliveryMode.scheduled
      : DeliveryMode.now;
}

/// Why the applied coupon doesn't apply right now (e.g. cart dropped below the
/// minimum), or null. The coupon stays applied and kicks in again once valid.
@riverpod
String? couponIssue(Ref ref) {
  final coupon = ref.watch(checkoutProvider.select((s) => s.coupon));
  if (coupon == null) return null;
  return coupon.issueFor(
    itemTotal: ref.watch(cartSummaryProvider).itemTotal,
    isFirstOrder: ref.watch(isFirstOrderProvider),
  );
}

@riverpod
OrderBill checkoutBill(Ref ref) {
  final lines = ref.watch(cartProvider);
  final settings = ref.watch(currentStoreSettingsProvider);
  final coupon = ref.watch(checkoutProvider.select((s) => s.coupon));
  final usable = coupon != null && ref.watch(couponIssueProvider) == null;

  final bill = OrderBill.forLines(lines, deliveryFee: 0);
  return bill.copyWith(
    deliveryFee: settings.deliveryFeeFor(bill.itemTotal),
    taxes: settings.taxesFor(bill.itemTotal),
    discount: usable ? coupon.discountFor(bill.itemTotal) : 0,
    couponCode: usable ? coupon.code : null,
  );
}

@riverpod
CheckoutStep checkoutStep(Ref ref) {
  return ref.watch(selectedAddressProvider) == null ? CheckoutStep.address : CheckoutStep.payment;
}
