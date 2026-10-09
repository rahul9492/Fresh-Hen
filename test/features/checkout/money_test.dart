import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:fresh_hen/features/auth/models/app_user.dart';
import 'package:fresh_hen/features/auth/providers/auth_provider.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/catalog/data/mock_catalog_data.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';
import 'package:fresh_hen/features/checkout/models/checkout_models.dart';
import 'package:fresh_hen/features/checkout/providers/checkout_providers.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/providers/order_providers.dart';
import 'package:fresh_hen/features/orders/services/invoice_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every rupee the customer sees or pays: bill math, the cart, the invoice.

class _SignedIn extends AuthSession {
  @override
  AppUser? build() => const AppUser(phone: '9876543210', name: 'Rahul Kumar');
}

final _curry = mockProducts.firstWhere((p) => p.id == 'chicken-curry-cut');
final _masala = _curry.accompaniments.firstWhere((a) => a.id == 'acc-mdh-masala');

ProductVariant _pack(String label) => _curry.variants.firstWhere((v) => v.label == label);

CartLine _curryLine(String label, {int quantity = 1}) =>
    CartLine.fromVariant(_curry, _pack(label)).copyWith(quantity: quantity);

Coupon _coupon(String code) => mockCoupons(DateTime.now()).firstWhere((c) => c.code == code);

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [
    sharedPrefsProvider.overrideWithValue(prefs),
    authSessionProvider.overrideWith(_SignedIn.new),
  ]);
  addTearDown(c.dispose);
  c.listen(checkoutBillProvider, (_, _) {});
  c.listen(couponIssueProvider, (_, _) {});
  await c.read(storeSettingsProvider.future);
  await c.read(ordersProvider.future); // sample history: not a first order
  return c;
}

CartLine _taxed(int price, int taxPercent, {int quantity = 1}) => CartLine(
      id: 'p$price',
      productId: 'p$price',
      name: 'Item',
      unitLabel: '500 g',
      image: '',
      unitPrice: price,
      quantity: quantity,
      taxPercent: taxPercent,
    );

void main() {
  group('bill math', () {
    test('total = items + delivery + taxes - discount', () {
      const bill = OrderBill(itemTotal: 460, mrpTotal: 520, deliveryFee: 40, taxes: 12, discount: 50);
      expect(bill.total, 460 + 40 + 12 - 50);
      expect(bill.savings, (520 - 460) + 50);
    });

    test('items and MRP add up per line and quantity', () {
      final bill = OrderBill.forLines(
        [_curryLine('500 g', quantity: 2), CartLine.fromAccompaniment(_masala)],
        deliveryFee: 40,
      );
      expect(bill.itemTotal, 120 * 2 + 82);
      expect(bill.mrpTotal, 150 * 2 + 82); // no MRP: the price counts as MRP
      expect(bill.total, 120 * 2 + 82 + 40);
    });

    test('a discount can never make the total negative', () {
      const huge = Coupon(code: 'BIG', title: 't', description: 'd', flatOff: 1000);
      expect(huge.discountFor(300), 300);
      final bill = OrderBill(itemTotal: 300, mrpTotal: 300, deliveryFee: 40, discount: huge.discountFor(300));
      expect(bill.total, 40);
      expect(huge.discountFor(0), 0);
    });

    test('percentage coupons round down, then cap', () {
      const pct = Coupon(code: 'P', title: 't', description: 'd', percentOff: 15);
      expect(pct.discountFor(333), 49); // 49.95 rounds down: never over-discount
      const capped = Coupon(code: 'C', title: 't', description: 'd', percentOff: 50, maxDiscount: 120);
      expect(capped.discountFor(1000), 120);
    });

    test('taxes and packaging are nothing on an empty cart, rounded otherwise', () {
      const s = StoreSettings(packagingFee: 10);
      expect(s.taxesFor(const []), 0);
      expect(s.taxesFor([_taxed(301, 5)]), 10 + 15); // 15.05 rounds to 15
    });

    test("each item is taxed at its own product's rate, rounded once for the bill", () {
      const s = StoreSettings();
      // Masala at 5% (2.05 + 2.05) and chicken at 0%: 4.1 rounds to 4.
      expect(s.taxesFor([_taxed(41, 5, quantity: 2), _taxed(300, 0)]), 4);
    });
  });

  group('coupons in the cart', () {
    test('a coupon drops out below its minimum and returns when the cart grows', () async {
      final c = await _container();
      final cart = c.read(cartProvider.notifier)..add(_curryLine('1 kg', quantity: 2)); // 456
      c.read(checkoutProvider.notifier).applyCoupon(_coupon('CHICKEN50')); // ₹50 off from ₹299
      expect(c.read(checkoutBillProvider).discount, 50);

      cart.decrement(_curryLine('1 kg').id); // 228: below the minimum
      var bill = c.read(checkoutBillProvider);
      expect((bill.discount, bill.couponCode), (0, null));
      expect(bill.total, 228 + 40);
      expect(c.read(couponIssueProvider), 'Add ₹71 more to use this coupon');

      cart.add(CartLine.fromAccompaniment(_masala)); // 310
      bill = c.read(checkoutBillProvider);
      expect((bill.discount, bill.couponCode), (50, 'CHICKEN50'));
      expect(bill.total, 310 + 40 - 50);
    });

    test('an expired coupon gives nothing', () async {
      final c = await _container();
      c.read(cartProvider.notifier).add(_curryLine('1 kg', quantity: 3));
      c.read(checkoutProvider.notifier).applyCoupon(Coupon(
            code: 'OLD',
            title: 't',
            description: 'd',
            flatOff: 50,
            expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
          ));
      expect(c.read(couponIssueProvider), 'This coupon has expired');
      expect(c.read(checkoutBillProvider).discount, 0);
    });

    test('a first-order coupon does nothing for a returning customer', () async {
      final c = await _container();
      c.read(cartProvider.notifier).add(_curryLine('1 kg', quantity: 3));
      c.read(checkoutProvider.notifier).applyCoupon(_coupon('WELCOME15'));
      expect(c.read(couponIssueProvider), 'Valid on your first order only');
      expect(c.read(checkoutBillProvider).discount, 0);
    });

    test('free delivery is judged on the item total before the coupon', () async {
      final c = await _container();
      c.read(cartProvider.notifier).add(_curryLine('1 kg', quantity: 3)); // 684
      c.read(checkoutProvider.notifier).applyCoupon(_coupon('FRESH20')); // 20%, max ₹100
      final bill = c.read(checkoutBillProvider);
      expect((bill.itemTotal, bill.discount, bill.deliveryFee), (684, 100, 0));
      expect(bill.total, 584);
    });
  });

  group('cart', () {
    test('adding the same pack again raises its quantity', () async {
      final c = await _container();
      final cart = c.read(cartProvider.notifier)
        ..add(_curryLine('500 g'))
        ..add(_curryLine('500 g'));
      expect(c.read(cartProvider).single.quantity, 2);

      cart
        ..decrement(_curryLine('500 g').id)
        ..decrement(_curryLine('500 g').id);
      expect(c.read(cartProvider), isEmpty);
      expect(c.read(cartSummaryProvider).itemTotal, 0);
    });

    test('totals count every pack and add-on', () async {
      final c = await _container();
      c.read(cartProvider.notifier)
        ..add(_curryLine('500 g', quantity: 2))
        ..add(_curryLine('1 kg'))
        ..add(CartLine.fromAccompaniment(_masala));
      final summary = c.read(cartSummaryProvider);
      expect(summary.itemCount, 4);
      expect(summary.itemTotal, 120 * 2 + 228 + 82);
      expect(c.read(productQuantityProvider(_curry.id)), 3); // add-ons are separate
      expect(c.read(lineQuantityProvider(_curryLine('1 kg').id)), 1);
    });

    test('picking another pack swaps it but keeps add-ons', () async {
      final c = await _container();
      final cart = c.read(cartProvider.notifier)
        ..add(_curryLine('500 g'))
        ..add(CartLine.fromAccompaniment(_masala))
        ..selectVariant(_curry, _pack('1 kg'));
      expect(c.read(cartProvider).map((l) => l.unitLabel), containsAll(['1 kg', '100 g']));
      expect(c.read(cartProvider).length, 2);
      expect(c.read(cartSummaryProvider).itemTotal, 228 + 82);

      cart.selectVariant(_curry, _pack('1 kg')); // already picked: no change
      expect(c.read(cartProvider).length, 2);
    });

    test('Buy again adds the old order on top of what is in the cart', () async {
      final c = await _container();
      final cart = c.read(cartProvider.notifier)..add(_curryLine('500 g'));
      cart.addAll([_curryLine('500 g', quantity: 2), CartLine.fromAccompaniment(_masala)]);
      final lines = c.read(cartProvider);
      expect(lines.firstWhere((l) => l.id == _curryLine('500 g').id).quantity, 3);
      expect(c.read(cartSummaryProvider).itemTotal, 120 * 3 + 82);
    });
  });

  group('invoice', () {
    TestWidgetsFlutterBinding.ensureInitialized(); // fonts load from the asset bundle

    final order = Order(
      id: 'FH1',
      placedAt: DateTime(2026, 10, 4),
      lines: [_curryLine('1 kg', quantity: 3)],
      bill: const OrderBill(
        itemTotal: 684,
        mrpTotal: 684,
        deliveryFee: 0,
        taxes: 12,
        discount: 100,
        couponCode: 'FRESH20',
      ),
      address: 'x',
      paymentStatus: PaymentStatus.paid,
    );

    test('prints the same amounts as the bill', () {
      expect(invoiceTotals(order), [
        ('Item subtotal', '₹684'),
        ('Delivery fee', 'FREE'),
        ('Coupon (FRESH20)', '-₹100'),
        ('Taxes & packaging', '₹12'),
        ('Total paid', '₹596'),
      ]);
      expect(order.total, 596);
    });

    test('no discount row without a discount; unpaid says Total amount', () {
      final unpaid = order.copyWith(
        paymentStatus: PaymentStatus.due,
        bill: const OrderBill(itemTotal: 228, mrpTotal: 228, deliveryFee: 40),
      );
      expect(invoiceTotals(unpaid).map((r) => r.$1), [
        'Item subtotal',
        'Delivery fee',
        'Taxes & packaging',
        'Total amount',
      ]);
      expect(invoiceTotals(unpaid).last.$2, '₹268');
    });

    test('the PDF renders', () async {
      final bytes = await buildInvoicePdf(order, mockStoreSettings);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
