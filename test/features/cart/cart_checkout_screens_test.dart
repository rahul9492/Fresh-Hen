import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/cart/screens/cart_screen.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart' show Product;
import 'package:fresh_hen/features/cart/widgets/empty_cart_view.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';
import 'package:fresh_hen/features/checkout/models/checkout_models.dart';
import 'package:fresh_hen/features/checkout/providers/checkout_providers.dart';
import 'package:fresh_hen/features/checkout/screens/coupons_screen.dart';
import 'package:fresh_hen/features/checkout/screens/payment_screen.dart';
import 'package:fresh_hen/features/checkout/widgets/payment_unavailable.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/providers/order_providers.dart';
import 'package:go_router/go_router.dart';

import '../../support/feature_harness.dart';
import '../../support/fixtures.dart';
import '../../support/pump.dart';

final _hen = product(
  'hen',
  variants: [variant('v1', 200, mrp: 250, label: '500 g')],
).copyWith(name: 'Whole Chicken');

CartLine _hen1({int quantity = 1}) =>
    CartLine.fromVariant(_hen, _hen.variants.first).copyWith(quantity: quantity);

const _coupons = [
  Coupon(
    code: 'SAVE50',
    title: 'Flat ₹50 off',
    description: 'On orders above ₹300',
    flatOff: 50,
    minOrder: 300,
  ),
  Coupon(
    code: 'BIG',
    title: 'Big saver',
    description: 'Big orders only',
    flatOff: 200,
    minOrder: 5000,
  ),
  Coupon(
    code: 'WELCOME',
    title: 'Welcome',
    description: 'First order',
    flatOff: 30,
    firstOrderOnly: true,
  ),
];

Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  setUpWidgetTests();

  group('cart screen', () {
    Future<Harness> open(
      WidgetTester t, {
      List<CartLine> lines = const [],
      StoreSettings? settings,
      List<Product>? products,
    }) async {
      final h = await pumpFeature(
        t,
        const CartScreen(),
        scaffold: false,
        products: products ?? [_hen],
        settings: settings ?? mockStoreSettings.copyWith(scheduleEnabled: false),
        coupons: _coupons,
        size: const Size(1080, 9000),
        routes: [
          stubRoute(Routes.home, label: 'HOME'),
          stubRoute(Routes.payment, label: 'PAYMENT PAGE'),
          stubRoute(Routes.orderSuccess, label: 'ORDER SUCCESS'),
          stubRoute(Routes.coupons, label: 'COUPONS PAGE'),
        ],
      );
      if (lines.isNotEmpty) h.container.read(cartProvider.notifier).addAll(lines);
      await _settle(t);
      return h;
    }

    testWidgets('an empty cart invites browsing and Browse Products goes Home', (t) async {
      await open(t);
      expect(find.byType(EmptyCartView), findsOneWidget);
      expect(find.text('Your cart is empty'), findsOneWidget);
      await t.tap(find.text('Browse Products'));
      await t.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('a cart shows its items, bill and the call to action', (t) async {
      await open(t, lines: [_hen1(quantity: 2)]);
      expect(find.text('Your cart'), findsOneWidget);
      expect(find.text('Items in cart (2)'), findsOneWidget);
      expect(find.text('Whole Chicken'), findsOneWidget);
      expect(find.text('Special Instructions'), findsOneWidget);
      expect(find.text('Use Coupons'), findsOneWidget);
      expect(find.text('Bill Summary'), findsOneWidget);
      expect(find.text('Item Subtotal'), findsOneWidget);
      expect(find.text('Proceed to Payment'), findsOneWidget);
    });

    testWidgets('the bill follows the cart as items change', (t) async {
      final h = await open(t, lines: [_hen1()]);
      expect(find.text('₹240'), findsWidgets); // 200 + 40 delivery
      h.container.read(cartProvider.notifier).increment('hen:v1');
      await t.pump(); // the amounts count up from the next frame on
      await t.pump(const Duration(milliseconds: 800));
      expect(find.text('₹440'), findsWidgets);
    });

    testWidgets('the free-delivery hint shows under the bill', (t) async {
      await open(t, lines: [_hen1()]);
      expect(find.textContaining('more for FREE delivery'), findsOneWidget);
    });

    testWidgets('removing the last item shows the empty cart', (t) async {
      final h = await open(t, lines: [_hen1()]);
      await t.tap(find.byIcon(Icons.remove_rounded));
      await t.pump(const Duration(milliseconds: 600));
      await t.pump(const Duration(milliseconds: 600));
      expect(h.container.read(cartProvider), isEmpty);
      expect(find.byType(EmptyCartView), findsOneWidget);
    });

    testWidgets('Clear asks first, then empties the cart with an Undo', (t) async {
      final h = await open(t, lines: [_hen1(quantity: 2)]);
      await t.tap(find.text('Clear'));
      await t.pumpAndSettle();
      expect(find.text('Clear your cart?'), findsOneWidget);
      expect(find.text('This removes all 2 items from your cart.'), findsOneWidget);

      await t.tap(find.text('Clear cart'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(h.container.read(cartProvider), isEmpty);
      expect(find.text('Cart cleared'), findsOneWidget);

      await t.tap(find.text('Undo'));
      await t.pump(const Duration(milliseconds: 600));
      expect(h.container.read(cartProvider).single.quantity, 2);
    });

    testWidgets('one item is described in the singular, and Cancel keeps the cart', (t) async {
      final h = await open(t, lines: [_hen1()]);
      await t.tap(find.text('Clear'));
      await t.pumpAndSettle();
      expect(find.text('This removes all 1 item from your cart.'), findsOneWidget);
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(h.container.read(cartProvider), isNotEmpty);
    });

    testWidgets('sold-out items show a banner, and Proceed is replaced by removing them', (
      t,
    ) async {
      final soldOut = product(
        'hen',
        variants: [variant('v1', 200, inStock: false, label: '500 g')],
      ).copyWith(name: 'Whole Chicken');
      final h = await open(t, lines: [_hen1()], products: [soldOut]);
      await t.pump(const Duration(seconds: 1));
      expect(find.text('1 item is sold out. Remove it to continue.'), findsOneWidget);
      expect(find.text('Proceed to Payment'), findsNothing);
      expect(find.text('Remove sold-out items'), findsOneWidget);

      await t.tap(find.text('Remove sold-out items'));
      await t.pump(const Duration(milliseconds: 600));
      expect(h.container.read(cartProvider), isEmpty);
    });

    testWidgets('Use Coupons opens the coupons page', (t) async {
      await open(t, lines: [_hen1()]);
      await t.tap(find.text('Use Coupons'));
      await t.pumpAndSettle();
      expect(find.text('COUPONS PAGE'), findsOneWidget);
    });

    testWidgets('instructions typed are kept for the order', (t) async {
      final h = await open(t, lines: [_hen1()]);
      await t.enterText(find.byType(TextField).first, 'Ring twice');
      expect(h.container.read(checkoutProvider).instructions, 'Ring twice');
    });

    testWidgets('with scheduling on, both timing choices show', (t) async {
      await open(t, lines: [_hen1()], settings: mockStoreSettings.copyWith(scheduleEnabled: true));
      expect(find.text('Schedule for later'), findsOneWidget);
    });

    testWidgets(
      'Proceed with UPI offered opens the payment method sheet, UPI goes to the payment page',
      (t) async {
        await open(t, lines: [_hen1()]);
        await t.tap(find.text('Proceed to Payment'));
        await t.pumpAndSettle();
        expect(find.text('Choose payment method'), findsOneWidget);

        await t.tap(find.textContaining('Continue to Pay'));
        await t.pumpAndSettle();
        expect(find.text('PAYMENT PAGE'), findsOneWidget);
      },
    );

    testWidgets('paying cash places the order, empties the cart and opens the success page', (
      t,
    ) async {
      final h = await open(t, lines: [_hen1()]);
      await t.tap(find.text('Proceed to Payment'));
      await t.pumpAndSettle();
      await t.tap(find.text('Cash on Delivery'));
      await t.pump();
      await t.tap(find.textContaining('Place Order'));
      await t.pumpAndSettle();

      expect(h.orders.placed.single.paymentMethod, PaymentMethod.cash);
      expect(h.container.read(cartProvider), isEmpty);
      expect(find.text('ORDER SUCCESS'), findsOneWidget);
    });

    testWidgets('closing the payment sheet leaves the cart as it was', (t) async {
      final h = await open(t, lines: [_hen1()]);
      await t.tap(find.text('Proceed to Payment'));
      await t.pumpAndSettle();
      await t.tapAt(const Offset(5, 5));
      await t.pumpAndSettle();
      expect(h.orders.placed, isEmpty);
      expect(h.container.read(cartProvider), isNotEmpty);
    });

    testWidgets('an address outside the delivery area is refused with the address list', (t) async {
      await open(
        t,
        lines: [_hen1()],
        settings: mockStoreSettings.copyWith(scheduleEnabled: false, deliveryPincodes: ['110001']),
      );
      await t.tap(find.text('Proceed to Payment'));
      await t.pumpAndSettle();
      expect(
        find.text("We don't deliver to 201301 yet. Please choose another address."),
        findsWidgets,
      );
      expect(find.text('Select delivery address'), findsOneWidget);
    });

    testWidgets('a failed order shows the error and keeps the cart', (t) async {
      final h = await open(t, lines: [_hen1()]);
      h.orders.failPlace = true;
      await t.tap(find.text('Proceed to Payment'));
      await t.pumpAndSettle();
      await t.tap(find.text('Cash on Delivery'));
      await t.pump();
      await t.tap(find.textContaining('Place Order'));
      await t.pumpAndSettle();
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
      expect(h.container.read(cartProvider), isNotEmpty);
    });

    testWidgets('a scheduled order without a slot asks for one first', (t) async {
      final h = await open(
        t,
        lines: [_hen1()],
        settings: mockStoreSettings.copyWith(scheduleEnabled: true),
      );
      h.container
          .read(checkoutProvider.notifier)
          .schedule(
            DeliverySlot(
              id: 'old',
              start: DateTime.now().subtract(const Duration(hours: 1)),
              end: DateTime.now(),
            ),
          );
      await t.pump(const Duration(milliseconds: 300));
      await t.tap(find.text('Proceed to Payment'));
      await t.pump();
      await t.pump(const Duration(seconds: 2));
      expect(find.text('Please pick a delivery slot'), findsOneWidget);
      expect(find.text('Select delivery slot'), findsOneWidget);
    });
  });

  group('coupons screen', () {
    Future<Harness> open(
      WidgetTester t, {
      List<CartLine> lines = const [],
      List<Coupon>? coupons,
      void Function(Coupon?)? onResult,
    }) async {
      final h = await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(
            onPressed: () async {
              final result = await c.push<Coupon>('/coupons-page');
              onResult?.call(result);
            },
            child: const Text('open'),
          ),
        ),
        coupons: coupons ?? _coupons,
        routes: [GoRoute(path: '/coupons-page', builder: (_, _) => const CouponsScreen())],
        size: const Size(1080, 3000),
      );
      if (lines.isNotEmpty) h.container.read(cartProvider.notifier).addAll(lines);
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await _settle(t);
      return h;
    }

    testWidgets('lists the available coupons', (t) async {
      await open(t, lines: [_hen1(quantity: 2)]);
      expect(find.text('Apply Coupon'), findsOneWidget);
      expect(find.text('Available Coupons'), findsOneWidget);
      expect(find.text('SAVE50'), findsOneWidget);
      expect(find.text('BIG'), findsOneWidget);
    });

    testWidgets('a coupon the cart qualifies for can be applied from its card', (t) async {
      Coupon? result;
      final h = await open(t, lines: [_hen1(quantity: 2)], onResult: (c) => result = c);
      await t.tap(find.text('Apply').at(1)); // SAVE50's card
      await t.pumpAndSettle();
      expect(result?.code, 'SAVE50');
      expect(h.container.read(checkoutProvider).coupon?.code, 'SAVE50');
    });

    testWidgets('a coupon the cart does not qualify for says why and cannot be applied', (t) async {
      await open(t, lines: [_hen1()]);
      expect(find.textContaining('more to use this coupon'), findsWidgets);
    });

    testWidgets('typing a valid code applies it', (t) async {
      Coupon? result;
      final h = await open(t, lines: [_hen1(quantity: 2)], onResult: (c) => result = c);
      await t.enterText(find.byType(TextField), 'save50');
      await t.tap(find.widgetWithText(FilledButton, 'Apply').first);
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(result?.code, 'SAVE50');
      expect(h.container.read(checkoutProvider).coupon?.code, 'SAVE50');
    });

    testWidgets('an empty code asks for one', (t) async {
      await open(t, lines: [_hen1()]);
      await t.tap(find.widgetWithText(FilledButton, 'Apply').first);
      await t.pump();
      expect(find.text('Enter a coupon code'), findsOneWidget);
    });

    testWidgets('an unknown code says it is not valid, and typing clears the message', (t) async {
      await open(t, lines: [_hen1()], coupons: _coupons);
      await t.enterText(find.byType(TextField), 'NOPE');
      await t.tap(find.widgetWithText(FilledButton, 'Apply').first);
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(find.textContaining('not valid'), findsOneWidget);

      await t.enterText(find.byType(TextField), 'NOPE2');
      await t.pump();
      expect(find.textContaining('not valid'), findsNothing);
    });

    testWidgets('a real code the cart does not qualify for shows the reason', (t) async {
      await open(t, lines: [_hen1()]);
      await t.enterText(find.byType(TextField), 'BIG');
      await t.tap(find.widgetWithText(FilledButton, 'Apply').first);
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(find.textContaining('more to use this coupon'), findsWidgets);
    });

    testWidgets('only letters and digits can be typed, in capitals, up to 20', (t) async {
      await open(t, lines: [_hen1()]);
      await t.enterText(find.byType(TextField), 'ab-c d!1234567890123456789012');
      await t.pump();
      final text = t.widget<TextField>(find.byType(TextField)).controller!.text;
      expect(text.length, 20);
      expect(RegExp(r'^[A-Za-z0-9]+$').hasMatch(text), isTrue);
    });

    testWidgets('an applied coupon is marked Applied', (t) async {
      final h = await open(t, lines: [_hen1(quantity: 2)]);
      h.container.read(checkoutProvider.notifier).applyCoupon(_coupons.first);
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Applied'), findsOneWidget);
    });

    testWidgets('with no coupons it says so', (t) async {
      await open(t, coupons: const []);
      expect(find.text('No coupons right now'), findsOneWidget);
    });

    testWidgets('a first-order coupon is refused to a customer who has ordered before', (t) async {
      final h = await pumpFeature(
        t,
        Builder(
          builder: (c) =>
              TextButton(onPressed: () => c.push('/coupons-page'), child: const Text('open')),
        ),
        coupons: _coupons,
        orders: [
          Order(
            id: 'old',
            placedAt: DateTime(2026, 9, 1),
            lines: [_hen1()],
            bill: const OrderBill(itemTotal: 200, mrpTotal: 250, deliveryFee: 40),
            address: 'x',
            status: OrderStatus.delivered,
          ),
        ],
        routes: [GoRoute(path: '/coupons-page', builder: (_, _) => const CouponsScreen())],
        size: const Size(1080, 3000),
      );
      h.container.read(cartProvider.notifier).add(_hen1(quantity: 3));
      await h.container.read(ordersProvider.future);
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await _settle(t);
      expect(find.text('Valid on your first order only'), findsOneWidget);
    });
  });

  group('payment screen', () {
    Future<Harness> open(
      WidgetTester t, {
      StoreSettings? settings,
      List<CartLine> lines = const [],
    }) async {
      final h = await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(onPressed: () => c.push('/pay'), child: const Text('open')),
        ),
        settings: settings ?? mockStoreSettings,
        routes: [
          GoRoute(path: '/pay', builder: (_, _) => const PaymentScreen()),
          stubRoute(Routes.orderSuccess, label: 'ORDER SUCCESS'),
        ],
        size: const Size(1080, 9000),
      );
      h.container.read(cartProvider.notifier).addAll(lines.isEmpty ? [_hen1(quantity: 2)] : lines);
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await _settle(t);
      return h;
    }

    testWidgets('shows the QR card, the steps, the reference box and the bill', (t) async {
      await open(t);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Scan & Pay via Any UPI App'), findsOneWidget);
      expect(find.text('How to pay'), findsOneWidget);
      expect(find.textContaining('UPI Transaction ID', findRichText: true), findsOneWidget);
      expect(find.text('Bill Summary'), findsOneWidget);
      expect(find.text('Upload Screenshot'), findsOneWidget);
    });

    testWidgets('the amount to pay is the bill total', (t) async {
      await open(t);
      expect(find.textContaining('₹440', findRichText: true), findsWidgets); // 2 x 200 + 40
    });

    testWidgets('without a UPI QR it says UPI is unavailable', (t) async {
      await open(t, settings: mockStoreSettings.copyWith(upiQrImage: null));
      expect(find.byType(PaymentUnavailable), findsOneWidget);
    });

    testWidgets('a typed reference must have exactly 12 digits before uploading', (t) async {
      await open(t);
      await t.enterText(find.byType(TextField).last, '12345');
      await t.tap(find.text('Upload Screenshot'));
      await t.pump();
      expect(
        find.text('The UPI transaction ID has 12 digits. Check it or leave it empty.'),
        findsOneWidget,
      );
    });

    testWidgets('going back asks first, and Stay keeps the page', (t) async {
      await open(t);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.text('Leave payment?'), findsOneWidget);
      expect(find.text('Your cart is saved'), findsOneWidget);

      await t.tap(find.text('Stay & upload screenshot'));
      await t.pumpAndSettle();
      expect(find.text('Payment'), findsOneWidget);
    });

    testWidgets('Leave anyway goes back to the cart page', (t) async {
      await open(t);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      await t.tap(find.text('Leave anyway'));
      await t.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('the upload bar is hidden when the cart is empty', (t) async {
      final h = await open(t);
      h.container.read(cartProvider.notifier).clear();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Upload Screenshot'), findsNothing);
    });
  });
}
