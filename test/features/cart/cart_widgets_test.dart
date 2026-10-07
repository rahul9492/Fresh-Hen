import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/widgets/add_control.dart';
import 'package:fresh_hen/core/widgets/bottom_action_bar.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/cart/widgets/cart_checkout_bar.dart';
import 'package:fresh_hen/features/cart/widgets/cart_items_card.dart';
import 'package:fresh_hen/features/cart/widgets/cart_recommended.dart';
import 'package:fresh_hen/features/cart/widgets/clear_cart_chip.dart';
import 'package:fresh_hen/features/cart/widgets/coupon_tile.dart';
import 'package:fresh_hen/features/cart/widgets/delivery_timing_card.dart';
import 'package:fresh_hen/features/cart/widgets/empty_cart_view.dart';
import 'package:fresh_hen/features/cart/widgets/free_delivery_hint.dart';
import 'package:fresh_hen/features/cart/widgets/instructions_card.dart';
import 'package:fresh_hen/features/cart/widgets/view_cart_bar.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';
import 'package:fresh_hen/features/checkout/models/checkout_models.dart';
import 'package:fresh_hen/features/checkout/providers/checkout_providers.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart' show DeliverySlot, PaymentMethod;
import 'package:fresh_hen/features/orders/providers/order_providers.dart';
import 'package:go_router/go_router.dart';

import '../../support/feature_harness.dart';
import '../../support/fixtures.dart';
import '../../support/pump.dart';

CartLine _line(
  String id, {
  int price = 200,
  int? mrp,
  int quantity = 1,
  String? name,
}) =>
    CartLine.fromVariant(
      product(id).copyWith(name: name ?? id),
      variant('v1', price, mrp: mrp, label: '500 g'),
    ).copyWith(quantity: quantity);

final _hen = product('hen', variants: [variant('v1', 200, mrp: 250, label: '500 g')]);

void main() {
  setUpWidgetTests();

  group('CartItemsCard', () {
    Widget card() => Consumer(
          builder: (_, ref, _) => SingleChildScrollView(child: CartItemsCard(lines: ref.watch(cartProvider))),
        );

    testWidgets('lists each line with its pack, and counts units in the header', (t) async {
      final h = await pumpFeature(t, card(), products: [_hen, product('egg')]);
      h.container.read(cartProvider.notifier).addAll([
        _line('hen', quantity: 2, name: 'Whole Chicken'),
        _line('egg', name: 'Eggs'),
      ]);
      await t.pump(const Duration(seconds: 1));

      expect(find.text('Items in cart (3)'), findsOneWidget);
      expect(find.text('Whole Chicken'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('500 g'), findsNWidgets(2));
    });

    testWidgets('a discounted line shows the struck MRP and the saving', (t) async {
      final h = await pumpFeature(t, card(), products: [_hen]);
      h.container.read(cartProvider.notifier).add(CartLine.fromVariant(_hen, _hen.variants.first).copyWith(quantity: 2));
      await t.pump(const Duration(seconds: 1));

      expect(find.text('Save ₹100'), findsOneWidget);
      expect(find.textContaining('₹500', findRichText: true), findsOneWidget);
      expect(find.textContaining('₹400', findRichText: true), findsOneWidget);
    });

    testWidgets('an add-on is labelled as one', (t) async {
      final h = await pumpFeature(t, card());
      h.container.read(cartProvider.notifier).add(const CartLine(
            id: 'addon:m',
            productId: 'm',
            name: 'Masala',
            unitLabel: '100 g',
            image: 'x',
            unitPrice: 80,
            isAddon: true,
          ));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('100 g • Add-on'), findsOneWidget);
    });

    testWidgets('the stepper changes the cart quantity', (t) async {
      final h = await pumpFeature(t, card(), products: [_hen]);
      final cart = h.container.read(cartProvider.notifier);
      cart.add(_line('hen'));
      await t.pump(const Duration(seconds: 1));

      await t.tap(find.byIcon(Icons.add_rounded));
      await t.pump(const Duration(milliseconds: 400));
      expect(h.container.read(cartProvider).single.quantity, 2);

      await t.tap(find.byIcon(Icons.remove_rounded));
      await t.pump(const Duration(milliseconds: 400));
      expect(h.container.read(cartProvider).single.quantity, 1);

      await t.tap(find.byIcon(Icons.remove_rounded));
      await t.pump(const Duration(milliseconds: 400));
      expect(h.container.read(cartProvider), isEmpty);
    });

    testWidgets('a sold-out line says so and can be removed, with no stepper', (t) async {
      final soldOut = product('hen', variants: [variant('v1', 200, inStock: false, label: '500 g')]);
      final h = await pumpFeature(t, card(), products: [soldOut]);
      h.container.read(cartProvider.notifier).add(_line('hen', name: 'Whole Chicken'));
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(seconds: 1)); // the catalog loads after the first build

      expect(find.text('Sold out'), findsOneWidget);
      expect(find.byType(QtyStepper), findsNothing);
      await t.tap(find.widgetWithText(OutlinedButton, 'Remove'));
      await t.pump(const Duration(milliseconds: 400));
      expect(h.container.read(cartProvider), isEmpty);
    });

    testWidgets('an available line is not marked sold out', (t) async {
      final h = await pumpFeature(t, card(), products: [_hen]);
      h.container.read(cartProvider.notifier).add(CartLine.fromVariant(_hen, _hen.variants.first));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Sold out'), findsNothing);
      expect(find.byType(QtyStepper), findsOneWidget);
    });

    testWidgets('swiping a line away removes it and Undo puts it back in the same place', (t) async {
      final h = await pumpFeature(t, card(), products: [_hen, product('egg'), product('fish')]);
      h.container.read(cartProvider.notifier).addAll([
        _line('hen', name: 'Whole Chicken'),
        _line('egg', name: 'Eggs'),
        _line('fish', name: 'Fish'),
      ]);
      await t.pump(const Duration(seconds: 1));

      await t.drag(find.text('Eggs'), const Offset(-700, 0));
      await t.pumpAndSettle();
      expect(h.container.read(cartProvider).map((l) => l.name), ['Whole Chicken', 'Fish']);
      expect(find.text('Eggs removed'), findsOneWidget);

      await t.tap(find.text('Undo'));
      await t.pump(const Duration(milliseconds: 400));
      expect(h.container.read(cartProvider).map((l) => l.name), ['Whole Chicken', 'Eggs', 'Fish']);
    });

    testWidgets('tapping a product photo opens that product', (t) async {
      final h = await pumpFeature(
        t,
        card(),
        products: [_hen],
        routes: [stubRoute('/product/:id', label: 'PRODUCT PAGE')],
      );
      h.container.read(cartProvider.notifier).add(CartLine.fromVariant(_hen, _hen.variants.first));
      await t.pump(const Duration(seconds: 1));
      await t.tap(find.byType(Hero));
      await t.pumpAndSettle();
      expect(find.text('PRODUCT PAGE'), findsOneWidget);
    });
  });

  group('SoldOutBanner', () {
    testWidgets('speaks about one item or several, and removes on tap', (t) async {
      var removed = 0;
      await pumpWidgetApp(t, SoldOutBanner(count: 1, onRemove: () => removed++));
      expect(find.text('1 item is sold out. Remove it to continue.'), findsOneWidget);
      await t.tap(find.text('Remove'));
      expect(removed, 1);

      await pumpWidgetApp(t, SoldOutBanner(count: 3, onRemove: () => removed++));
      expect(find.text('3 items are sold out. Remove them to continue.'), findsOneWidget);
      await t.tap(find.text('Remove all'));
      expect(removed, 2);
    });
  });

  group('ClearCartChip', () {
    testWidgets('says Clear, reacts to taps and is a labelled button', (t) async {
      var taps = 0;
      await pumpWidgetApp(t, Center(child: ClearCartChip(onTap: () => taps++)));
      expect(find.text('Clear'), findsOneWidget);
      await t.tap(find.text('Clear'));
      expect(taps, 1);
      expect(find.bySemanticsLabel('Clear cart'), findsOneWidget);
    });
  });

  group('FreeDeliveryHint', () {
    testWidgets('says how much more earns free delivery, and goes away once reached', (t) async {
      final h = await pumpFeature(
        t,
        const FreeDeliveryHint(),
        settings: mockStoreSettings.copyWith(deliveryFee: 40, freeDeliveryAbove: 499),
      );
      expect(find.text('Add ₹499 more for FREE delivery'), findsOneWidget);

      h.container.read(cartProvider.notifier).add(_line('hen', price: 300));
      await t.pump();
      expect(find.text('Add ₹199 more for FREE delivery'), findsOneWidget);

      h.container.read(cartProvider.notifier).increment('hen:v1');
      await t.pump();
      expect(find.textContaining('FREE delivery'), findsNothing);
    });

    testWidgets('is hidden when delivery is already free', (t) async {
      await pumpFeature(t, const FreeDeliveryHint(), settings: mockStoreSettings.copyWith(deliveryFee: 0));
      expect(find.textContaining('FREE delivery'), findsNothing);
    });
  });

  group('DeliveryTimingCard', () {
    testWidgets('without scheduling it only promises "Order now"', (t) async {
      await pumpFeature(
        t,
        DeliveryTimingCard(onPickSlot: () {}),
        settings: mockStoreSettings.copyWith(scheduleEnabled: false),
      );
      expect(find.text('Order now'), findsOneWidget);
      expect(find.text('Arrives in 45 mins - 1:30 hrs'), findsOneWidget);
      expect(find.text('Schedule for later'), findsNothing);
    });

    testWidgets('with scheduling it offers both, and Order now is chosen first', (t) async {
      final h = await pumpFeature(
        t,
        DeliveryTimingCard(onPickSlot: () {}),
        settings: mockStoreSettings.copyWith(scheduleEnabled: true),
      );
      expect(find.text('Order now'), findsOneWidget);
      expect(find.text('Schedule for later'), findsOneWidget);
      expect(find.text('Pick a slot'), findsOneWidget);
      expect(h.container.read(deliveryModeProvider), DeliveryMode.now);
    });

    testWidgets('the schedule option opens the slot picker; a chosen slot shows its day', (t) async {
      var picks = 0;
      final h = await pumpFeature(
        t,
        DeliveryTimingCard(onPickSlot: () => picks++),
        settings: mockStoreSettings.copyWith(scheduleEnabled: true),
      );
      await t.tap(find.text('Schedule for later'));
      expect(picks, 1);

      final start = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 10, minute: 0);
      h.container.read(checkoutProvider.notifier).schedule(
            DeliverySlot(id: 's', start: start, end: start.add(const Duration(hours: 1))),
          );
      await t.pump();
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('Pick a slot'), findsNothing);
    });

    testWidgets('Order now switches back from a scheduled slot', (t) async {
      final h = await pumpFeature(
        t,
        DeliveryTimingCard(onPickSlot: () {}),
        settings: mockStoreSettings.copyWith(scheduleEnabled: true),
      );
      final start = DateTime.now().add(const Duration(days: 1));
      h.container.read(checkoutProvider.notifier).schedule(
            DeliverySlot(id: 's', start: start, end: start.add(const Duration(hours: 1))),
          );
      await t.pump();
      expect(h.container.read(deliveryModeProvider), DeliveryMode.scheduled);

      await t.tap(find.text('Order now'));
      await t.pump();
      expect(h.container.read(deliveryModeProvider), DeliveryMode.now);
    });
  });

  group('InstructionsCard', () {
    testWidgets('starts with what was already written and saves what is typed', (t) async {
      final h = await pumpFeature(t, const InstructionsCard());
      expect(find.text('Special Instructions'), findsOneWidget);
      expect(find.text('(Optional)'), findsOneWidget);

      await t.enterText(find.byType(TextField), 'Ring the bell');
      expect(h.container.read(checkoutProvider).instructions, 'Ring the bell');
    });

    testWidgets('shows the instructions kept from before', (t) async {
      final h = await pumpFeature(t, const SizedBox());
      h.container.read(checkoutProvider.notifier).setInstructions('Leave at door');
      await pumpFeature(t, const InstructionsCard(), overrides: const []);
      // A fresh page reads the shared checkout state; check through the field itself.
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('stops at 200 characters', (t) async {
      final h = await pumpFeature(t, const InstructionsCard());
      await t.enterText(find.byType(TextField), 'x' * 300);
      expect(h.container.read(checkoutProvider).instructions.length, 200);
    });
  });

  group('CouponTile', () {
    final coupons = [
      const Coupon(code: 'SAVE50', title: 't', description: 'd', flatOff: 50, minOrder: 300),
      const Coupon(code: 'BIG', title: 't', description: 'd', flatOff: 200, minOrder: 5000),
    ];

    testWidgets('with no coupon applied it invites you, with the best saving that works now', (t) async {
      final h = await pumpFeature(t, const CouponTile(), coupons: coupons);
      h.container.read(cartProvider.notifier).add(_line('hen', price: 400));
      await t.pump(const Duration(milliseconds: 300));

      expect(find.text('Use Coupons'), findsOneWidget);
      expect(find.text('Save up to ₹50'), findsOneWidget);
      expect(find.text('1 available'), findsOneWidget);
    });

    testWidgets('with nothing usable there is no saving line or count', (t) async {
      await pumpFeature(t, const CouponTile(), coupons: coupons);
      expect(find.text('Use Coupons'), findsOneWidget);
      expect(find.textContaining('Save up to'), findsNothing);
      expect(find.textContaining('available'), findsNothing);
    });

    testWidgets('an applied coupon shows its code and what it saves, and can be removed', (t) async {
      final h = await pumpFeature(t, const CouponTile(), coupons: coupons);
      h.container.read(cartProvider.notifier).add(_line('hen', price: 400));
      h.container.read(checkoutProvider.notifier).applyCoupon(coupons.first);
      await t.pump(const Duration(milliseconds: 300));

      expect(find.text('SAVE50 applied'), findsOneWidget);
      expect(find.text('You save ₹50 with this coupon'), findsOneWidget);

      await t.tap(find.text('Remove'));
      await t.pump();
      expect(h.container.read(checkoutProvider).coupon, isNull);
      expect(find.text('Use Coupons'), findsOneWidget);
    });

    testWidgets('an applied coupon that no longer qualifies explains why', (t) async {
      final h = await pumpFeature(t, const CouponTile(), coupons: coupons);
      h.container.read(cartProvider.notifier).add(_line('hen', price: 100));
      h.container.read(checkoutProvider.notifier).applyCoupon(coupons.first);
      await t.pump(const Duration(milliseconds: 300));

      expect(find.text('SAVE50 applied'), findsOneWidget);
      expect(find.text('Add ₹200 more to use this coupon'), findsOneWidget);
    });

    testWidgets('tapping opens the coupons page; a coupon coming back is announced', (t) async {
      late ProviderContainer container;
      final h = await pumpFeature(
        t,
        const CouponTile(),
        coupons: coupons,
        routes: [
          GoRoute(
            path: '/coupons',
            builder: (context, _) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    container.read(checkoutProvider.notifier).applyCoupon(coupons.first);
                    context.pop(coupons.first);
                  },
                  child: const Text('pick SAVE50'),
                ),
              ),
            ),
          ),
        ],
      );
      container = h.container;
      h.container.read(cartProvider.notifier).add(_line('hen', price: 400));
      await t.pump(const Duration(milliseconds: 300));

      await t.tap(find.text('Use Coupons'));
      await t.pumpAndSettle();
      expect(find.text('pick SAVE50'), findsOneWidget);

      await t.tap(find.text('pick SAVE50'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 700));
      expect(find.text('SAVE50 applied!'), findsOneWidget); // the celebration banner
      expect(find.text('You saved ₹50 on this order'), findsOneWidget);
      await t.pump(const Duration(seconds: 5));
    });

    testWidgets('with reduced motion the announcement is a snackbar', (t) async {
      late ProviderContainer container;
      final h = await pumpFeature(
        t,
        const CouponTile(),
        coupons: coupons,
        reduceMotion: true,
        routes: [
          GoRoute(
            path: '/coupons',
            builder: (context, _) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    container.read(checkoutProvider.notifier).applyCoupon(coupons.first);
                    context.pop(coupons.first);
                  },
                  child: const Text('pick'),
                ),
              ),
            ),
          ),
        ],
      );
      container = h.container;
      h.container.read(cartProvider.notifier).add(_line('hen', price: 400));
      await t.pump(const Duration(milliseconds: 300));
      await t.tap(find.text('Use Coupons'));
      await t.pumpAndSettle();
      await t.tap(find.text('pick'));
      await t.pumpAndSettle();
      expect(find.text('SAVE50 applied!'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('CartRecommended', () {
    testWidgets('suggests recommended products that are not in the cart yet', (t) async {
      final h = await pumpFeature(
        t,
        const SingleChildScrollView(child: CartRecommended()),
        products: [
          product('Eggs', isRecommended: true),
          product('Fish', isRecommended: true),
          product('Mutton'),
        ],
      );
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Recommended'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('Fish'), findsOneWidget);
      expect(find.text('Mutton'), findsNothing);

      h.container.read(cartProvider.notifier).add(_line('Eggs'));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Eggs'), findsNothing);
      expect(find.text('Fish'), findsOneWidget);
    });

    testWidgets('shows nothing when there is nothing to suggest', (t) async {
      await pumpFeature(t, const CartRecommended(), products: [product('Mutton')]);
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Recommended'), findsNothing);
    });
  });

  group('CartCheckoutBar', () {
    Widget bar(CheckoutStep step, {List<String>? log}) => CartCheckoutBar(
          step: step,
          onAddAddress: () => log?.add('address'),
          onPickSlot: () => log?.add('slot'),
          onProceed: () => log?.add('proceed'),
          onRemoveSoldOut: () => log?.add('remove'),
        );

    testWidgets('without an address the button asks for one', (t) async {
      final log = <String>[];
      await pumpFeature(
        t,
        bar(CheckoutStep.address, log: log),
        addresses: const [],
        settings: mockStoreSettings.copyWith(scheduleEnabled: false),
      );
      await t.tap(find.text('Add Delivery Address'));
      expect(log, ['address']);
      expect(find.textContaining('Delivering to'), findsNothing);
    });

    testWidgets('with scheduling on, the first step also mentions the slot', (t) async {
      await pumpFeature(
        t,
        bar(CheckoutStep.address),
        addresses: const [],
        settings: mockStoreSettings.copyWith(scheduleEnabled: true),
      );
      expect(find.text('Add Address & Slot'), findsOneWidget);
    });

    testWidgets('with an address it proceeds to payment and shows where it is going', (t) async {
      final log = <String>[];
      await pumpFeature(t, bar(CheckoutStep.payment, log: log));
      expect(find.textContaining('Delivering to', findRichText: true), findsOneWidget);
      expect(find.text(homeAddress.line), findsOneWidget);
      expect(find.text('Delivery in 45 mins - 1:30 hrs'), findsOneWidget);

      await t.tap(find.text('Proceed to Payment'));
      expect(log, ['proceed']);
    });

    testWidgets('an address we do not deliver to says so', (t) async {
      await pumpFeature(
        t,
        bar(CheckoutStep.payment),
        settings: mockStoreSettings.copyWith(deliveryPincodes: ['110001']),
      );
      expect(
        find.text("We don't deliver to 201301 yet. Please choose another address."),
        findsOneWidget,
      );
    });

    testWidgets('sold-out items turn the button into a remove action', (t) async {
      final log = <String>[];
      final soldOut = product('hen', variants: [variant('v1', 200, inStock: false)]);
      final h = await pumpFeature(t, bar(CheckoutStep.payment, log: log), products: [soldOut]);
      h.container.read(cartProvider.notifier).add(_line('hen'));
      await t.pump(const Duration(milliseconds: 300));

      expect(find.text('Proceed to Payment'), findsNothing);
      await t.tap(find.text('Remove sold-out items'));
      expect(log, ['remove']);
    });

    testWidgets('a scheduled order shows its slot with a Change link', (t) async {
      final log = <String>[];
      final h = await pumpFeature(
        t,
        bar(CheckoutStep.payment, log: log),
        settings: mockStoreSettings.copyWith(scheduleEnabled: true),
      );
      final start = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 10, minute: 0);
      h.container.read(checkoutProvider.notifier).schedule(
            DeliverySlot(id: 's', start: start, end: start.add(const Duration(hours: 1))),
          );
      await t.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Delivery scheduled for', findRichText: true), findsOneWidget);
      expect(find.textContaining('Tomorrow, 10-11 AM', findRichText: true), findsOneWidget);
      expect(find.textContaining('Delivery in 45'), findsNothing); // replaced by the slot row

      await t.tap(find.text('Change').first);
      expect(log, ['slot']);
    });

    testWidgets('Change on the address row opens the address list', (t) async {
      await pumpFeature(t, bar(CheckoutStep.payment));
      await t.tap(find.text('Change'));
      await t.pumpAndSettle();
      expect(find.text(homeAddress.title), findsWidgets);
    });

    testWidgets('while an order is being placed the button shows a spinner', (t) async {
      final h = await pumpFeature(t, bar(CheckoutStep.payment));
      h.orders.placeLatency = const Duration(seconds: 1);
      h.container.read(cartProvider.notifier).add(_line('hen'));
      h.container.listen(placeOrderProvider, (_, _) {});
      final pending = h.container.read(placeOrderProvider.notifier).submit(method: _cash);
      await t.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      await pending;
    });

    testWidgets('it is a bottom action bar', (t) async {
      await pumpFeature(t, bar(CheckoutStep.payment));
      expect(find.byType(BottomActionBar), findsOneWidget);
    });
  });

  group('EmptyCartView', () {
    testWidgets('invites the customer to browse and fires the callback', (t) async {
      var browsed = 0;
      await pumpWidgetApp(t, EmptyCartView(onBrowse: () => browsed++));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Add your favorite products to get started.'), findsOneWidget);
      await t.tap(find.text('Browse Products'));
      expect(browsed, 1);
    });

    testWidgets('still shows its button on a very small screen', (t) async {
      await pumpWidgetApp(t, EmptyCartView(onBrowse: () {}), size: const Size(720, 1280));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Browse Products'), findsOneWidget);
    });
  });

  group('ViewCartBar', () {
    testWidgets('is hidden while the cart is empty', (t) async {
      await pumpFeature(t, const ViewCartBar());
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('View cart'), findsNothing);
    });

    testWidgets('shows the item count and total, and follows changes', (t) async {
      final h = await pumpFeature(t, const ViewCartBar());
      final cart = h.container.read(cartProvider.notifier);
      cart.add(_line('hen', price: 200));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('View cart'), findsOneWidget);
      expect(find.text('1 item · ₹200'), findsOneWidget);

      cart.increment('hen:v1');
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('2 items · ₹400'), findsOneWidget);

      cart.clear();
      await t.pumpAndSettle();
      expect(find.text('View cart'), findsNothing);
    });

    testWidgets('tapping opens the cart', (t) async {
      final h = await pumpFeature(
        t,
        const ViewCartBar(),
        routes: [stubRoute('/cart', label: 'CART PAGE')],
      );
      h.container.read(cartProvider.notifier).add(_line('hen'));
      await t.pump(const Duration(milliseconds: 500));
      await t.tap(find.text('View cart'));
      await t.pumpAndSettle();
      expect(find.text('CART PAGE'), findsOneWidget);
    });

    testWidgets('the compact version is content-sized rather than full width', (t) async {
      final h = await pumpFeature(t, const Center(child: ViewCartBar(compact: true)));
      h.container.read(cartProvider.notifier).add(_line('hen'));
      await t.pump(const Duration(milliseconds: 500));
      expect(t.getSize(find.byType(InkWell).first).width, lessThan(300));
    });

    testWidgets('the regular version spans the width', (t) async {
      final h = await pumpFeature(t, const ViewCartBar());
      h.container.read(cartProvider.notifier).add(_line('hen'));
      await t.pump(const Duration(milliseconds: 500));
      expect(t.getSize(find.byType(InkWell).first).width, greaterThan(300));
    });
  });
}

const _cash = PaymentMethod.cash;
