import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/errors/app_exception.dart';
import 'package:fresh_hen/core/media/image_picking.dart';
import 'package:fresh_hen/core/push/push_service.dart';
import 'package:fresh_hen/features/address/models/address.dart';
import 'package:fresh_hen/features/address/providers/address_providers.dart';
import 'package:fresh_hen/features/address/repositories/address_repository.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';
import 'package:fresh_hen/features/checkout/models/checkout_models.dart';
import 'package:fresh_hen/features/checkout/providers/checkout_providers.dart';
import 'package:fresh_hen/features/checkout/repositories/checkout_repository.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/providers/order_providers.dart';
import 'package:fresh_hen/features/orders/repositories/order_repository.dart';

import '../../support/fixtures.dart';

// --- fakes --------------------------------------------------------------

class _FakePush extends PushService {
  _FakePush(super.ref);

  @override
  Stream<Map<String, dynamic>> get received => const Stream.empty();

  @override
  Future<void> unregister() async {}
}

class _Settings extends MockCheckoutRepository {
  _Settings(this.value);

  final StoreSettings value;

  @override
  Future<StoreSettings> settings() async => value;
}

class _Orders extends MockOrderRepository {
  bool failRate = false;
  int rated = 0;

  @override
  Future<void> rate(String orderId, {required int stars, String? comment}) async {
    if (failRate) throw const AppException('Could not save your rating.');
    rated++;
    return super.rate(orderId, stars: stars, comment: comment);
  }
}

class _Addresses implements AddressRepository {
  _Addresses(this.list);

  final List<Address> list;

  @override
  Future<List<Address>> fetch() async => list;

  @override
  Future<Address> create(Address address) async => address;

  @override
  Future<Address> update(Address address) async => address;

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> makeDefault(String id) async {}
}

// --- fixtures -----------------------------------------------------------

const _home = Address(
  id: 'a1',
  label: AddressLabel.home,
  house: 'Flat 503',
  area: 'Sector 62',
  city: 'Noida',
  pincode: '201301',
  name: 'Rahul',
  phone: '9876543210',
  isDefault: true,
);

final _hen = product('hen', variants: [variant('500', 200, mrp: 250)]);

CartLine _henLine({int quantity = 1}) =>
    CartLine.fromVariant(_hen, _hen.variants.first).copyWith(quantity: quantity);

Order _order(String id, OrderStatus status, {int? rating}) => Order(
      id: id,
      placedAt: DateTime(2026, 10, 1),
      lines: [_henLine()],
      bill: const OrderBill(itemTotal: 200, mrpTotal: 250, deliveryFee: 40),
      address: 'x',
      status: status,
      rating: rating,
    );

Future<ProviderContainer> _container({
  StoreSettings? settings,
  _Orders? orders,
  List<Address> addresses = const [_home],
  bool signedIn = true,
}) async {
  final (c, _) = await makeContainer(signedIn: signedIn, overrides: [
    pushServiceProvider.overrideWith(_FakePush.new),
    checkoutRepositoryProvider.overrideWithValue(_Settings(settings ?? mockStoreSettings)),
    orderRepositoryProvider.overrideWithValue(orders ?? _Orders()),
    addressRepositoryProvider.overrideWithValue(_Addresses(addresses)),
  ]);
  addTearDown(c.dispose);
  c.listen(addressesProvider, (_, _) {});
  c.listen(selectedAddressIdProvider, (_, _) {});
  c.listen(placeOrderProvider, (_, _) {});
  c.listen(checkoutBillProvider, (_, _) {});
  c.listen(deliveryModeProvider, (_, _) {});
  c.listen(couponIssueProvider, (_, _) {});
  c.listen(checkoutStepProvider, (_, _) {});
  c.listen(isFirstOrderProvider, (_, _) {});
  await c.read(storeSettingsProvider.future);
  await c.read(ordersProvider.future);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  return c;
}

DeliverySlot _slot({Duration from = const Duration(hours: 5)}) {
  final start = DateTime.now().add(from);
  return DeliverySlot(id: 's1', start: start, end: start.add(const Duration(hours: 1)));
}

void main() {
  group('order models', () {
    test('only confirmed, preparing and on-the-way orders are active', () {
      expect(OrderStatus.confirmed.isActive, isTrue);
      expect(OrderStatus.preparing.isActive, isTrue);
      expect(OrderStatus.outForDelivery.isActive, isTrue);
      expect(OrderStatus.delivered.isActive, isFalse);
      expect(OrderStatus.cancelled.isActive, isFalse);
    });

    test('every status, payment method and payment state has a label', () {
      for (final l in [
        ...OrderStatus.values.map((e) => e.label),
        ...PaymentMethod.values.map((e) => e.label),
        ...PaymentStatus.values.map((e) => e.label),
      ]) {
        expect(l, isNotEmpty);
      }
    });

    test('the bill totals items, fees and taxes, less the discount', () {
      const bill = OrderBill(
        itemTotal: 500,
        mrpTotal: 600,
        deliveryFee: 40,
        taxes: 10,
        discount: 50,
      );
      expect(bill.total, 500);
      expect(bill.savings, 150); // 100 off the MRPs plus the 50 coupon
    });

    test('a bill built from lines sums price and MRP, and takes the given fee', () {
      final bill = OrderBill.forLines([_henLine(quantity: 2)], deliveryFee: 40);
      expect(bill.itemTotal, 400);
      expect(bill.mrpTotal, 500);
      expect(bill.deliveryFee, 40);
      expect(bill.total, 440);
      expect(bill.savings, 100);
      expect(OrderBill.forLines(const [], deliveryFee: 0).total, 0);
    });

    test('an order counts units and takes its total from the bill', () {
      final o = _order('1', OrderStatus.confirmed).copyWith(lines: [_henLine(quantity: 3)]);
      expect(o.itemCount, 3);
      expect(o.total, o.bill.total);
    });

    test('reachedAt prefers recorded events, then placed and delivered times', () {
      final at = DateTime(2026, 10, 2, 9);
      final withEvents = _order('1', OrderStatus.preparing).copyWith(
        events: [OrderEvent(status: OrderStatus.preparing, at: at)],
      );
      expect(withEvents.reachedAt(OrderStatus.preparing), at);

      final old = _order('2', OrderStatus.delivered).copyWith(deliveredAt: DateTime(2026, 10, 3));
      expect(old.reachedAt(OrderStatus.confirmed), old.placedAt);
      expect(old.reachedAt(OrderStatus.delivered), DateTime(2026, 10, 3));
      expect(old.reachedAt(OrderStatus.preparing), isNull);
      expect(old.reachedAt(OrderStatus.outForDelivery), isNull);
    });

    test('can be cancelled only while confirmed', () {
      for (final s in OrderStatus.values) {
        expect(_order('1', s).canCancel, s == OrderStatus.confirmed, reason: s.name);
      }
    });

    test('an invoice exists once delivered, or when paid and not cancelled', () {
      expect(_order('1', OrderStatus.delivered).hasInvoice, isTrue);
      expect(_order('1', OrderStatus.preparing).hasInvoice, isFalse);
      expect(
        _order('1', OrderStatus.preparing).copyWith(paymentStatus: PaymentStatus.paid).hasInvoice,
        isTrue,
      );
      expect(
        _order('1', OrderStatus.cancelled).copyWith(paymentStatus: PaymentStatus.paid).hasInvoice,
        isFalse,
      );
    });

    test('slot labels', () {
      final start = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 10, minute: 0);
      final slot = DeliverySlot(id: 's', start: start, end: start.add(const Duration(hours: 1)));
      expect(slot.timeLabel, '10:00 AM - 11:00 AM');
      expect(slot.label, 'Tomorrow, 10:00 AM - 11:00 AM');
      expect(slot.shortLabel, 'Tomorrow, 10-11 AM');
    });

    test('a day is open unless closed or fully booked', () {
      final open = _slot();
      final full = open.copyWith(available: false);
      final date = DateTime(2026, 10, 8);
      expect(DeliveryDay(date: date, slots: [open]).isOpen, isTrue);
      expect(DeliveryDay(date: date, slots: [full, open]).isOpen, isTrue);
      expect(DeliveryDay(date: date, slots: [full]).isOpen, isFalse);
      expect(DeliveryDay(date: date, slots: const []).isOpen, isFalse);
      expect(DeliveryDay(date: date, slots: [open], closedReason: 'Holiday').isOpen, isFalse);
    });
  });

  group('store settings', () {
    test('UPI is offered only while a QR is set', () {
      expect(const StoreSettings().upiEnabled, isFalse);
      expect(const StoreSettings(upiQrImage: '').upiEnabled, isFalse);
      expect(const StoreSettings(upiQrImage: 'qr.png').upiEnabled, isTrue);
    });

    test('delivery fee: nothing on an empty cart, free from the threshold', () {
      const s = StoreSettings(deliveryFee: 40, freeDeliveryAbove: 499);
      expect(s.deliveryFeeFor(0), 0);
      expect(s.deliveryFeeFor(498), 40);
      expect(s.deliveryFeeFor(499), 0);
      expect(s.deliveryFeeFor(2000), 0);
    });

    test('taxes: packaging plus rounded percentage, nothing on an empty cart', () {
      const s = StoreSettings(packagingFee: 5, taxPercent: 5);
      expect(s.taxesFor(0), 0);
      expect(s.taxesFor(100), 10);
      expect(s.taxesFor(130), 12); // 5 + 6.5 rounds up to 7 -> 12
      expect(const StoreSettings().taxesFor(500), 0);
    });

    test('pincodes: an empty list serves everyone, a list only its entries', () {
      expect(const StoreSettings().deliversTo('999999'), isTrue);
      const s = StoreSettings(deliveryPincodes: ['201301']);
      expect(s.deliversTo('201301'), isTrue);
      expect(s.deliversTo(' 201301 '), isTrue);
      expect(s.deliversTo('201302'), isFalse);
      expect(s.deliversTo(''), isFalse);
    });

    test('the ETA reads as a range', () {
      expect(const StoreSettings().etaLabel, '45 mins - 1:30 hrs');
    });
  });

  group('coupon messages', () {
    const flat = Coupon(code: 'F', title: 't', description: 'd', flatOff: 50, minOrder: 300);
    final now = DateTime(2026, 10, 7);

    test('usable when all rules pass', () {
      expect(flat.issueFor(itemTotal: 300, isFirstOrder: false, now: now), isNull);
    });

    test('below the minimum says how much more to add', () {
      expect(
        flat.issueFor(itemTotal: 250, isFirstOrder: false, now: now),
        'Add ₹50 more to use this coupon',
      );
    });

    test('expired, and first-order rules', () {
      final old = flat.copyWith(expiresAt: DateTime(2026, 10, 1));
      expect(old.issueFor(itemTotal: 500, isFirstOrder: true, now: now), 'This coupon has expired');
      final first = flat.copyWith(firstOrderOnly: true);
      expect(
        first.issueFor(itemTotal: 500, isFirstOrder: false, now: now),
        'Valid on your first order only',
      );
      expect(first.issueFor(itemTotal: 500, isFirstOrder: true, now: now), isNull);
    });

    test('expiry is checked before the other rules', () {
      final c = flat.copyWith(expiresAt: DateTime(2026, 10, 1), firstOrderOnly: true);
      expect(c.issueFor(itemTotal: 1, isFirstOrder: false, now: now), 'This coupon has expired');
    });

    test('a flat coupon never exceeds the items cost; percent respects its cap', () {
      expect(flat.discountFor(30), 30);
      const pct = Coupon(code: 'P', title: 't', description: 'd', percentOff: 20, maxDiscount: 100);
      expect(pct.discountFor(200), 40);
      expect(pct.discountFor(1000), 100);
      const uncapped = Coupon(code: 'U', title: 't', description: 'd', percentOff: 50);
      expect(uncapped.discountFor(1000), 500);
    });
  });

  group('checkout choices', () {
    test('instructions, coupon and slot are remembered, and reset clears them', () async {
      final c = await _container();
      final checkout = c.read(checkoutProvider.notifier);
      final coupon = mockCoupons(DateTime.now()).first;

      checkout.setInstructions('Ring the bell');
      checkout.applyCoupon(coupon);
      checkout.schedule(_slot());
      var state = c.read(checkoutProvider);
      expect(state.instructions, 'Ring the bell');
      expect(state.coupon, coupon);
      expect(state.mode, DeliveryMode.scheduled);
      expect(state.slot, isNotNull);

      checkout.removeCoupon();
      expect(c.read(checkoutProvider).coupon, isNull);
      checkout.orderNow();
      expect(c.read(checkoutProvider).mode, DeliveryMode.now);

      checkout.reset();
      state = c.read(checkoutProvider);
      expect(state.instructions, '');
      expect(state.slot, isNull);
      expect(state.mode, DeliveryMode.now);
    });

    test('a scheduled slot is used only while the admin allows scheduling', () async {
      final on = await _container(settings: mockStoreSettings.copyWith(scheduleEnabled: true));
      on.read(checkoutProvider.notifier).schedule(_slot());
      expect(on.read(deliveryModeProvider), DeliveryMode.scheduled);

      final off = await _container(settings: mockStoreSettings.copyWith(scheduleEnabled: false));
      off.read(checkoutProvider.notifier).schedule(_slot());
      expect(off.read(deliveryModeProvider), DeliveryMode.now);
    });

    test('the step is address until one exists, then payment', () async {
      final none = await _container(addresses: const []);
      expect(none.read(checkoutStepProvider), CheckoutStep.address);
      final some = await _container();
      expect(some.read(checkoutStepProvider), CheckoutStep.payment);
    });

    test('the bill follows the cart, fees and coupon', () async {
      final c = await _container(
        settings: mockStoreSettings.copyWith(deliveryFee: 40, freeDeliveryAbove: 1000),
      );
      expect(c.read(checkoutBillProvider).total, 0);

      c.read(cartProvider.notifier).add(_henLine(quantity: 2)); // 400
      var bill = c.read(checkoutBillProvider);
      expect(bill.itemTotal, 400);
      expect(bill.deliveryFee, 40);
      expect(bill.total, 440);
      expect(bill.couponCode, isNull);

      c.read(checkoutProvider.notifier).applyCoupon(
            const Coupon(code: 'C50', title: 't', description: 'd', flatOff: 50, minOrder: 300),
          );
      bill = c.read(checkoutBillProvider);
      expect(bill.discount, 50);
      expect(bill.couponCode, 'C50');
      expect(bill.total, 390);
    });

    test('a first-order coupon is refused once an order has been delivered', () async {
      final c = await _container();
      c.read(cartProvider.notifier).add(_henLine(quantity: 3));
      c.read(checkoutProvider.notifier).applyCoupon(
            const Coupon(
              code: 'NEW',
              title: 't',
              description: 'd',
              flatOff: 50,
              firstOrderOnly: true,
            ),
          );
      expect(c.read(couponIssueProvider), isNotNull);
      expect(c.read(checkoutBillProvider).discount, 0);
    });
  });

  group('order history', () {
    test('is empty when signed out', () async {
      final c = await _container(signedIn: false);
      expect(await c.read(ordersProvider.future), isEmpty);
    });

    test('a new order goes to the top and replaces a copy of the same id', () async {
      final c = await _container();
      final orders = c.read(ordersProvider.notifier);
      final before = c.read(ordersProvider).requireValue.length;

      orders.add(_order('NEW1', OrderStatus.confirmed));
      expect(c.read(ordersProvider).requireValue.first.id, 'NEW1');
      expect(c.read(ordersProvider).requireValue.length, before + 1);

      orders.add(_order('NEW1', OrderStatus.preparing));
      expect(c.read(ordersProvider).requireValue.length, before + 1);
      expect(c.read(ordersProvider).requireValue.first.status, OrderStatus.preparing);
    });

    test('an order is found by id, or null', () async {
      final c = await _container();
      c.read(ordersProvider.notifier).add(_order('FIND', OrderStatus.confirmed));
      expect((await c.read(orderProvider('FIND').future))?.id, 'FIND');
      expect(await c.read(orderProvider('nope').future), isNull);
    });

    test('a rating shows at once and is saved, with a blank comment dropped', () async {
      final repo = _Orders();
      final c = await _container(orders: repo);
      final id = c.read(ordersProvider).requireValue.firstWhere((o) => o.rating == null).id;

      await c.read(ordersProvider.notifier).rate(id, stars: 4, comment: '   ');

      final o = c.read(ordersProvider).requireValue.firstWhere((o) => o.id == id);
      expect(o.rating, 4);
      expect(o.review, isNull);
      expect(repo.rated, 1);

      await c.read(ordersProvider.notifier).rate(id, stars: 5, comment: '  Great  ');
      expect(c.read(ordersProvider).requireValue.firstWhere((o) => o.id == id).review, 'Great');
    });

    test('a rating the server rejects is undone by reloading, and the error surfaces', () async {
      final repo = _Orders()..failRate = true;
      final c = await _container(orders: repo);
      final id = c.read(ordersProvider).requireValue.firstWhere((o) => o.rating == null).id;

      await expectLater(
        c.read(ordersProvider.notifier).rate(id, stars: 5),
        throwsA(isA<AppException>()),
      );
      await c.read(ordersProvider.future);
      expect(c.read(ordersProvider).requireValue.firstWhere((o) => o.id == id).rating, isNull);
    });

    test('cancelling updates the order; a late cancel is refused', () async {
      final c = await _container();
      final orders = c.read(ordersProvider.notifier);
      final repo = c.read(orderRepositoryProvider);
      final placed = await repo.place(
        OrderRequest(
          lines: [_henLine()],
          bill: const OrderBill(itemTotal: 200, mrpTotal: 250, deliveryFee: 40),
          addressId: 'a1',
          address: 'x',
          addressLabel: 'Home',
          paymentMethod: PaymentMethod.cash,
        ),
      );
      orders.add(placed);

      await orders.cancel(placed.id, reason: 'Changed my mind');
      final after = c.read(ordersProvider).requireValue.firstWhere((o) => o.id == placed.id);
      expect(after.status, OrderStatus.cancelled);
      expect(after.cancelReason, 'Changed my mind');

      // A second cancel is too late: only a confirmed order can be cancelled.
      await expectLater(
        orders.cancel(placed.id, reason: 'again'),
        throwsA(isA<AppException>().having((e) => e.message, 'm', tooLateToCancel)),
      );
    });

    test('first order: unknown while loading, true with none delivered, false after one', () async {
      final c = await _container();
      final past = c.read(ordersProvider).requireValue;
      expect(
        c.read(isFirstOrderProvider),
        past.every((o) => o.status == OrderStatus.cancelled),
      );
      c.read(ordersProvider.notifier).add(_order('D', OrderStatus.delivered));
      expect(c.read(isFirstOrderProvider), isFalse);
    });
  });

  group('placing an order', () {
    PickedImage proof() => PickedImage(bytes: Uint8List(8), name: 'pay.png');

    Future<ProviderContainer> ready({StoreSettings? settings, List<Address>? addresses}) async {
      final c = await _container(settings: settings, addresses: addresses ?? const [_home]);
      c.read(cartProvider.notifier).add(_henLine(quantity: 2));
      return c;
    }

    Future<String?> errorOf(ProviderContainer c, Future<Order?> run) async {
      final result = await run;
      expect(result, isNull);
      final error = c.read(placeOrderProvider).error;
      return error is AppException ? error.message : error?.toString();
    }

    test('an empty cart places nothing', () async {
      final c = await _container();
      expect(await c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash), isNull);
      expect(c.read(placeOrderProvider).hasError, isFalse);
    });

    test('without an address the customer is asked for one', () async {
      final c = await ready(addresses: const []);
      final msg = await errorOf(
        c,
        c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash),
      );
      expect(msg, 'Please add a delivery address.');
      expect(c.read(cartProvider), isNotEmpty); // nothing lost
    });

    test('an address outside the delivery area is refused, naming the pincode', () async {
      final c = await ready(settings: mockStoreSettings.copyWith(deliveryPincodes: ['110001']));
      final msg = await errorOf(
        c,
        c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash),
      );
      expect(msg, "We don't deliver to 201301 yet. Please choose another address.");
      expect(c.read(cartProvider), isNotEmpty);
    });

    test('UPI is refused while the store has no QR', () async {
      final c = await ready(settings: mockStoreSettings.copyWith(upiQrImage: null));
      final msg = await errorOf(
        c,
        c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.upi, proof: proof()),
      );
      expect(msg, contains('UPI payments are unavailable'));
    });

    test('cash is refused while the store has switched it off', () async {
      final c = await ready(settings: mockStoreSettings.copyWith(cashOnDeliveryEnabled: false));
      final msg = await errorOf(
        c,
        c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash),
      );
      expect(msg, contains('Cash on delivery is unavailable'));
    });

    test('UPI needs the payment screenshot', () async {
      final c = await ready();
      final msg = await errorOf(
        c,
        c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.upi),
      );
      expect(msg, 'Please upload your payment screenshot.');
    });

    test('a cash order carries trimmed instructions, then empties the cart and checkout', () async {
      final c = await ready();
      c.read(checkoutProvider.notifier).setInstructions('  Leave at the door  ');

      final order = await c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash);

      expect(order, isNotNull);
      expect(order!.instructions, 'Leave at the door');
      expect(order.paymentStatus, PaymentStatus.due);
      expect(order.itemCount, 2);
      expect(order.address, _home.line);
      expect(order.addressLabel, 'Home');
      expect(c.read(cartProvider), isEmpty);
      expect(c.read(checkoutProvider).instructions, '');
      expect(c.read(ordersProvider).requireValue.first.id, order.id);
    });

    test('blank instructions and reference are sent as nothing', () async {
      final c = await ready();
      c.read(checkoutProvider.notifier).setInstructions('   ');
      final order = await c
          .read(placeOrderProvider.notifier)
          .submit(method: PaymentMethod.upi, proof: proof(), paymentReference: '  ');
      expect(order!.instructions, isNull);
      expect(order.paymentReference, isNull);
    });

    test('a UPI order keeps the screenshot key and trimmed reference, awaiting verification', () async {
      final c = await ready();
      final order = await c.read(placeOrderProvider.notifier).submit(
            method: PaymentMethod.upi,
            proof: proof(),
            paymentReference: ' 123456789012 ',
          );
      expect(order!.paymentProof, startsWith('payment-proofs/'));
      expect(order.paymentReference, '123456789012');
      expect(order.paymentStatus, PaymentStatus.verifying);
      expect(order.awaitingConfirmation, isTrue);
    });

    test('a scheduled order carries its slot, and is refused if the slot has gone', () async {
      final c = await ready(settings: mockStoreSettings.copyWith(scheduleEnabled: true));
      final slot = _slot();
      c.read(checkoutProvider.notifier).schedule(slot);
      final order = await c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash);
      expect(order!.slot?.id, slot.id);

      final late = await ready(settings: mockStoreSettings.copyWith(scheduleEnabled: true));
      late.read(checkoutProvider.notifier).schedule(_slot(from: const Duration(minutes: 5)));
      final msg = await errorOf(
        late,
        late.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash),
      );
      expect(msg, contains('no longer available'));
      expect(late.read(cartProvider), isNotEmpty);
    });

    test('a second tap while one order is being placed is ignored', () async {
      final c = await ready();
      final before = c.read(ordersProvider).requireValue.length;
      final notifier = c.read(placeOrderProvider.notifier);
      final first = notifier.submit(method: PaymentMethod.cash);
      final second = await notifier.submit(method: PaymentMethod.cash);
      expect(second, isNull);
      expect(await first, isNotNull);
      expect(c.read(ordersProvider).requireValue.length, before + 1);
    });
  });
}
