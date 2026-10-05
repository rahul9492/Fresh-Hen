import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/media/image_picking.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:fresh_hen/core/utils/formatters.dart';
import 'package:fresh_hen/features/address/models/address.dart';
import 'package:fresh_hen/features/address/providers/address_providers.dart';
import 'package:fresh_hen/features/auth/models/app_user.dart';
import 'package:fresh_hen/features/auth/providers/auth_provider.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/catalog/data/mock_catalog_data.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';
import 'package:fresh_hen/features/checkout/models/checkout_models.dart';
import 'package:fresh_hen/features/checkout/providers/checkout_providers.dart';
import 'package:fresh_hen/features/checkout/repositories/checkout_repository.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/providers/order_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SignedIn extends AuthSession {
  @override
  AppUser? build() => const AppUser(phone: '9876543210', name: 'Rahul Kumar');
}

/// Mock store with the admin's "Schedule for later" switch turned off.
class _ScheduleOff extends MockCheckoutRepository {
  @override
  Future<StoreSettings> settings() async => mockStoreSettings.copyWith(scheduleEnabled: false);
}

CartLine _line(String productId, String label, {int quantity = 1}) {
  final p = mockProducts.firstWhere((p) => p.id == productId);
  return CartLine.fromVariant(p, p.variants.firstWhere((v) => v.label == label))
      .copyWith(quantity: quantity);
}

const _address = Address(
  id: 'a1',
  label: AddressLabel.home,
  house: 'Flat 503, Tower C',
  area: 'Sector 62',
  city: 'Noida',
  pincode: '201301',
  name: 'Rahul Kumar',
  phone: '9876543210',
);

Future<ProviderContainer> _container({CheckoutRepository? checkout}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      authSessionProvider.overrideWith(_SignedIn.new),
      if (checkout != null) checkoutRepositoryProvider.overrideWithValue(checkout),
    ],
  );
  addTearDown(c.dispose);
  // Keep auto-dispose providers alive for the whole test.
  c.listen(checkoutBillProvider, (_, _) {});
  c.listen(checkoutStepProvider, (_, _) {});
  c.listen(placeOrderProvider, (_, _) {});
  await c.read(storeSettingsProvider.future);
  await c.read(ordersProvider.future);
  return c;
}

void main() {
  group('rules', () {
    test('coupon discount respects cap, minimum and first-order rule', () {
      final now = DateTime(2026, 10, 3);
      final fresh20 = mockCoupons(now).firstWhere((c) => c.code == 'FRESH20');
      expect(fresh20.discountFor(600), 100); // 20% = 120, capped at 100
      expect(fresh20.issueFor(itemTotal: 400, isFirstOrder: false, now: now),
          'Add ₹99 more to use this coupon');
      expect(fresh20.issueFor(itemTotal: 600, isFirstOrder: false, now: now), isNull);
      expect(fresh20.issueFor(itemTotal: 600, isFirstOrder: false, now: now.add(const Duration(days: 30))),
          'This coupon has expired');

      final welcome = mockCoupons(DateTime(2026)).firstWhere((c) => c.code == 'WELCOME15');
      expect(welcome.issueFor(itemTotal: 300, isFirstOrder: false), 'Valid on your first order only');
      expect(welcome.issueFor(itemTotal: 300, isFirstOrder: true), isNull);
    });

    test('delivery is free from the threshold up', () {
      expect(mockStoreSettings.deliveryFeeFor(498), 40);
      expect(mockStoreSettings.deliveryFeeFor(499), 0);
      expect(mockStoreSettings.deliveryFeeFor(0), 0);
    });

    test('formatters', () {
      expect(rupees(125000), '₹1,25,000');
      expect(formatEta(45, 90), '45 mins - 1:30 hrs');
    });

    test('slots before the lead time and on the weekly off are unavailable', () {
      final monday = DateTime(2026, 10, 5, 9, 15); // a Monday
      final days = mockDeliveryDays(monday);
      expect(days[0].slots.where((s) => s.start.hour <= 10).every((s) => !s.available), isTrue);
      expect(days[1].isOpen, isFalse); // Tuesday: weekly off
      expect(days[1].closedReason, 'Weekly off');
    });
  });

  group('checkout', () {
    test('steps: address, then payment', () async {
      final c = await _container();
      c.read(cartProvider.notifier).add(_line('chicken-curry-cut', '500 g'));
      expect(c.read(checkoutStepProvider), CheckoutStep.address);

      await c.read(addressesProvider.notifier).save(_address);
      expect(c.read(selectedAddressProvider)?.isDefault, isTrue); // first address
      expect(c.read(checkoutStepProvider), CheckoutStep.payment);
    });

    test('coupon applies only once the cart reaches its minimum', () async {
      final c = await _container();
      c.read(cartProvider.notifier).add(_line('chicken-curry-cut', '500 g', quantity: 2));
      final coupon = mockCoupons(DateTime.now()).firstWhere((c) => c.code == 'CHICKEN50');
      c.read(checkoutProvider.notifier).applyCoupon(coupon);

      expect(c.read(couponIssueProvider), 'Add ₹59 more to use this coupon');
      expect(c.read(checkoutBillProvider).discount, 0);
      expect(c.read(checkoutBillProvider).total, 240 + 40);

      c.read(cartProvider.notifier).add(_line('chicken-breast', '500 g'));
      final bill = c.read(checkoutBillProvider);
      expect(c.read(couponIssueProvider), isNull);
      expect((bill.itemTotal, bill.deliveryFee, bill.discount, bill.total), (460, 40, 50, 450));
      expect(bill.savings, 60 + 50); // MRP savings on the curry cut + coupon
    });

    test('cash order is placed, then cart and checkout reset', () async {
      final c = await _container();
      c.read(cartProvider.notifier).add(_line('chicken-boneless', '500 g'));
      await c.read(addressesProvider.notifier).save(_address);
      c.read(checkoutProvider.notifier).setInstructions('  Ring once  ');

      final order = await c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash);

      expect(order, isNotNull);
      expect(order!.paymentStatus, PaymentStatus.due);
      expect(order.instructions, 'Ring once');
      expect(order.addressLabel, 'Home');
      expect(order.total, 250 + 40);
      expect(c.read(ordersProvider).value!.first.id, order.id);
      expect(c.read(cartProvider), isEmpty);
      expect(c.read(checkoutProvider), const CheckoutState());
    });

    test('only delivers to the pincodes set in the admin app', () async {
      expect(const StoreSettings().deliversTo('110001'), isTrue); // no list = no limit
      expect(mockStoreSettings.deliversTo('201301'), isTrue);
      expect(mockStoreSettings.deliversTo(' 201301 '), isTrue);
      expect(mockStoreSettings.deliversTo('110001'), isFalse);
      expect(
        StoreSettings.fromJson({
          'deliveryPincodes': ['201301'],
        }).deliveryPincodes,
        ['201301'],
      );

      final c = await _container();
      c.read(cartProvider.notifier).add(_line('chicken-boneless', '500 g'));
      await c.read(addressesProvider.notifier).save(_address.copyWith(pincode: '110001'));
      final order = await c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash);
      expect(order, isNull);
      expect(c.read(placeOrderProvider).error.toString(), contains("don't deliver to 110001"));
      expect(c.read(cartProvider), isNotEmpty);
    });

    test('UPI order needs the payment screenshot', () async {
      final c = await _container();
      c.read(cartProvider.notifier).add(_line('chicken-boneless', '500 g'));
      await c.read(addressesProvider.notifier).save(_address);

      final missing = await c.read(placeOrderProvider.notifier).submit(method: PaymentMethod.upi);
      expect(missing, isNull);
      expect(c.read(placeOrderProvider).error.toString(), contains('upload your payment screenshot'));
      expect(c.read(cartProvider), isNotEmpty);

      final order = await c.read(placeOrderProvider.notifier).submit(
            method: PaymentMethod.upi,
            proof: PickedImage(bytes: Uint8List(64), name: 'paid.png'),
            paymentReference: '427816390521',
          );
      expect(order!.paymentStatus, PaymentStatus.verifying);
      expect(order.paymentProof, contains('paid.png'));
      expect(order.paymentReference, '427816390521');
    });

    test('scheduled slot is used, unless the admin switched scheduling off', () async {
      final slot = DeliverySlot(
        id: 's1',
        start: DateTime.now().add(const Duration(days: 1)),
        end: DateTime.now().add(const Duration(days: 1, hours: 1)),
      );

      final on = await _container();
      on.read(cartProvider.notifier).add(_line('chicken-boneless', '500 g'));
      await on.read(addressesProvider.notifier).save(_address);
      on.read(checkoutProvider.notifier).schedule(slot);
      expect(on.read(deliveryModeProvider), DeliveryMode.scheduled);
      final scheduled = await on.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash);
      expect(scheduled!.slot?.id, 's1');

      final off = await _container(checkout: _ScheduleOff());
      off.read(cartProvider.notifier).add(_line('chicken-boneless', '500 g'));
      await off.read(addressesProvider.notifier).save(_address);
      off.read(checkoutProvider.notifier).schedule(slot);
      expect(off.read(deliveryModeProvider), DeliveryMode.now);
      final now = await off.read(placeOrderProvider.notifier).submit(method: PaymentMethod.cash);
      expect(now!.slot, isNull);
    });

    test('addresses persist per user and keep exactly one default', () async {
      final c = await _container();
      final notifier = c.read(addressesProvider.notifier);
      await notifier.save(_address);
      await notifier.save(_address.copyWith(id: 'a2', label: AddressLabel.work, isDefault: true));
      expect(c.read(addressesProvider).where((a) => a.isDefault).map((a) => a.id), ['a2']);

      await notifier.remove('a2');
      expect(c.read(addressesProvider).single.isDefault, isTrue);

      // A fresh container reads the same saved list back.
      final prefs = c.read(sharedPrefsProvider);
      final again = ProviderContainer(overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        authSessionProvider.overrideWith(_SignedIn.new),
      ]);
      addTearDown(again.dispose);
      expect(again.read(addressesProvider).single.id, 'a1');
    });

    test('cart survives a restart and is removed once emptied', () async {
      final c = await _container();
      c.read(cartProvider.notifier).add(_line('chicken-curry-cut', '500 g', quantity: 2));

      final prefs = c.read(sharedPrefsProvider);
      ProviderContainer restart() {
        final next = ProviderContainer(overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          authSessionProvider.overrideWith(_SignedIn.new),
        ]);
        addTearDown(next.dispose);
        return next;
      }

      final again = restart();
      expect(again.read(cartProvider).single.quantity, 2);

      again.read(cartProvider.notifier).clear();
      expect(restart().read(cartProvider), isEmpty);
    });
  });
}
