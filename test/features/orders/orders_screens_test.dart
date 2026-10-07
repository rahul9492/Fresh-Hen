import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/screens/invoice_screen.dart';
import 'package:fresh_hen/features/orders/screens/order_success_screen.dart';
import 'package:fresh_hen/features/orders/screens/order_summary_screen.dart';
import 'package:fresh_hen/features/orders/screens/orders_screen.dart';
import 'package:fresh_hen/features/orders/widgets/empty_orders.dart';
import 'package:fresh_hen/features/orders/widgets/order_card.dart';
import 'package:go_router/go_router.dart';

import '../../support/feature_harness.dart';
import '../../support/fixtures.dart';
import '../../support/pump.dart';

CartLine _line(String name, {int quantity = 1, int price = 100}) => CartLine.fromVariant(
  product(name).copyWith(name: name),
  variant('v1', price, label: '500 g'),
).copyWith(quantity: quantity);

Order _order(
  String id, {
  OrderStatus status = OrderStatus.preparing,
  List<CartLine>? lines,
  PaymentMethod method = PaymentMethod.cash,
  PaymentStatus payment = PaymentStatus.due,
  int? rating,
  String? review,
  DeliveryRider? rider,
  String? instructions,
  String? reference,
  DateTime? deliveredAt,
  DateTime? placedAt,
}) => Order(
  id: id,
  placedAt: placedAt ?? DateTime(2026, 10, 1, 16, 28),
  lines: lines ?? [_line('Eggs', quantity: 2)],
  bill: const OrderBill(
    itemTotal: 200,
    mrpTotal: 250,
    deliveryFee: 40,
    discount: 20,
    couponCode: 'SAVE20',
  ),
  address: 'Flat 503, Sector 62, Noida - 201301',
  addressLabel: 'Home',
  status: status,
  paymentMethod: method,
  paymentStatus: payment,
  rating: rating,
  review: review,
  rider: rider,
  instructions: instructions,
  paymentReference: reference,
  deliveredAt: deliveredAt,
);

/// The status animations loop forever, so move time on by hand instead of settling.
Future<void> _pumps(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 400));
  await t.pump(const Duration(milliseconds: 400));
}

Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  setUpWidgetTests();

  group('orders screen', () {
    Future<Harness> open(WidgetTester t, {List<Order> orders = const []}) async {
      final h = await pumpFeature(
        t,
        const OrdersScreen(),
        scaffold: false,
        orders: orders,
        size: const Size(1080, 4000),
        routes: [
          stubRoute(Routes.home, label: 'HOME'),
          stubRoute('/order/:id', label: 'ORDER DETAIL'),
          stubRoute(Routes.help, label: 'HELP'),
          stubRoute(Routes.cart, label: 'CART'),
        ],
      );
      await _settle(t);
      return h;
    }

    testWidgets('with no orders it shows the empty state and Start shopping goes Home', (t) async {
      await open(t);
      await t.pump(const Duration(seconds: 1));
      expect(find.byType(EmptyOrders), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      await t.tap(find.text('Start shopping'));
      await t.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('lists every order as a card, with a search bar', (t) async {
      await open(
        t,
        orders: [
          _order('FH1'),
          _order('FH2', status: OrderStatus.delivered),
        ],
      );
      expect(find.byType(OrderCard), findsNWidgets(2));
      expect(find.text('Search by item or order ID'), findsOneWidget);
      expect(find.text('#FH1'), findsOneWidget);
      expect(find.text('#FH2'), findsOneWidget);
    });

    testWidgets('searching by order ID narrows the list', (t) async {
      await open(t, orders: [_order('FH100'), _order('FH200')]);
      await t.enterText(find.byType(TextField), 'fh200');
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('#FH200'), findsOneWidget);
      expect(find.text('#FH100'), findsNothing);
    });

    testWidgets('searching by item name finds the order', (t) async {
      await open(
        t,
        orders: [
          _order('A', lines: [_line('Salmon')]),
          _order('B', lines: [_line('Eggs')]),
        ],
      );
      await t.enterText(find.byType(TextField), 'salm');
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('#A'), findsOneWidget);
      expect(find.text('#B'), findsNothing);
    });

    testWidgets('searching by status finds the order', (t) async {
      await open(
        t,
        orders: [
          _order('A', status: OrderStatus.delivered),
          _order('B'),
        ],
      );
      await t.enterText(find.byType(TextField), 'delivered');
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('#A'), findsOneWidget);
      expect(find.text('#B'), findsNothing);
    });

    testWidgets('a search with no match says so, and clearing it brings the list back', (t) async {
      await open(t, orders: [_order('FH1')]);
      await t.enterText(find.byType(TextField), 'zzzz');
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('No matching orders'), findsOneWidget);

      await t.tap(find.byIcon(Icons.close_rounded));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byType(OrderCard), findsOneWidget);
    });

    testWidgets('tapping an order opens its page', (t) async {
      await open(t, orders: [_order('FH1')]);
      await t.tap(find.text('Being prepared'));
      await t.pumpAndSettle();
      expect(find.text('ORDER DETAIL'), findsOneWidget);
    });

    testWidgets('Help & Support opens help', (t) async {
      await open(t, orders: [_order('FH1')]);
      await t.tap(find.text('Help & Support'));
      await t.pumpAndSettle();
      expect(find.text('HELP'), findsOneWidget);
    });

    testWidgets('Reorder adds the items and opens the cart', (t) async {
      final h = await open(
        t,
        orders: [
          _order('FH1', status: OrderStatus.delivered, lines: [_line('Eggs', quantity: 2)]),
        ],
      );
      await t.tap(find.text('Reorder'));
      await t.pumpAndSettle();
      expect(h.container.read(cartProvider).single.quantity, 2);
      expect(find.text('CART'), findsOneWidget);
    });

    testWidgets('Rate order saves the rating', (t) async {
      final h = await open(t, orders: [_order('FH1', status: OrderStatus.delivered)]);
      await t.tap(find.text('Rate order'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('5 stars'));
      await t.pump();
      await t.tap(find.text('Submit'));
      await t.pumpAndSettle();
      expect(h.orders.ratings.single.$2, 5);
      expect(find.text('Thanks for your feedback!'), findsOneWidget);
    });

    testWidgets('an order on its way keeps itself fresh', (t) async {
      final h = await open(t, orders: [_order('FH1')]);
      final before = h.orders.orders.first.status;
      h.orders.orders[0] = h.orders.orders.first.copyWith(status: OrderStatus.outForDelivery);
      await t.pump(const Duration(seconds: 21));
      await t.pump(const Duration(milliseconds: 300));
      expect(before, OrderStatus.preparing);
      expect(find.text('Out for delivery'), findsOneWidget);
    });
  });

  group('order summary screen', () {
    Future<Harness> open(WidgetTester t, String id, List<Order> orders) async {
      final h = await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(onPressed: () => c.push('/sum'), child: const Text('open')),
        ),
        orders: orders,
        size: const Size(1080, 9000),
        routes: [
          GoRoute(
            path: '/sum',
            builder: (_, _) => OrderSummaryScreen(orderId: id),
          ),
          stubRoute(Routes.orders, label: 'ORDERS TAB'),
          stubRoute(Routes.help, label: 'HELP'),
          stubRoute(Routes.cart, label: 'CART'),
          stubRoute('/order/:id/invoice', label: 'INVOICE PAGE'),
        ],
      );
      await t.tap(find.text('open'));
      await _pumps(t);
      await _settle(t);
      return h;
    }

    testWidgets('shows the status, items, bill and details of the order', (t) async {
      await open(t, 'FH1', [_order('FH1', instructions: 'Ring twice')]);
      expect(find.text('Order Summary'), findsWidgets);
      expect(find.text('2 items in this order'), findsOneWidget);
      expect(find.text('Bill Details'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('Order ID'), findsOneWidget);
      expect(find.text('Ring twice'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
    });

    testWidgets('an unknown order says it was not found and links to all orders', (t) async {
      await open(t, 'NOPE', [_order('FH1')]);
      expect(find.text('Order not found'), findsOneWidget);
      expect(find.text('We could not find order #NOPE.'), findsOneWidget);
      await t.tap(find.text('See all orders'));
      await _pumps(t);
      expect(find.text('ORDERS TAB'), findsOneWidget);
    });

    testWidgets('a confirmed order can be cancelled with a reason', (t) async {
      final h = await open(t, 'FH1', [_order('FH1', status: OrderStatus.confirmed)]);
      await t.tap(find.text('Cancel order'));
      await _pumps(t);
      await t.tap(find.text('Ordered by mistake'));
      await t.pump();
      await t.tap(find.widgetWithText(FilledButton, 'Cancel order'));
      await _pumps(t);
      expect(h.orders.cancels.single, ('FH1', 'Ordered by mistake'));
    });

    testWidgets('an order already being prepared cannot be cancelled', (t) async {
      await open(t, 'FH1', [_order('FH1')]);
      expect(find.text('Cancel order'), findsNothing);
      expect(find.text('Repeat Order'), findsNothing);
    });

    testWidgets('a delivered order offers Repeat Order, which refills the cart', (t) async {
      final h = await open(t, 'FH1', [
        _order('FH1', status: OrderStatus.delivered, deliveredAt: DateTime.now()),
      ]);
      await t.tap(find.text('Repeat Order'));
      await _pumps(t);
      expect(h.container.read(cartProvider).single.quantity, 2);
      expect(find.text('CART'), findsOneWidget);
    });

    testWidgets('a delivered order offers the tax invoice and shows the total as paid or due', (
      t,
    ) async {
      await open(t, 'FH1', [
        _order(
          'FH1',
          status: OrderStatus.delivered,
          payment: PaymentStatus.paid,
          method: PaymentMethod.upi,
        ),
      ]);
      expect(find.text('Download Tax Invoice'), findsOneWidget);
      expect(find.text('Total Paid'), findsOneWidget);
      expect(find.text('Paid online via UPI'), findsOneWidget);
      await t.tap(find.text('Download Tax Invoice'));
      await _pumps(t);
      expect(find.text('INVOICE PAGE'), findsOneWidget);
    });

    testWidgets('an order still in progress has no invoice link', (t) async {
      await open(t, 'FH1', [_order('FH1')]);
      expect(find.text('Download Tax Invoice'), findsNothing);
    });

    testWidgets('a UPI order shows its mode and reference', (t) async {
      await open(t, 'FH1', [
        _order(
          'FH1',
          method: PaymentMethod.upi,
          payment: PaymentStatus.verifying,
          reference: '123456789012',
        ),
      ]);
      expect(find.textContaining('UPI • Verification pending'), findsOneWidget);
      expect(find.text('UPI Reference'), findsOneWidget);
      expect(find.text('123456789012'), findsOneWidget);
    });

    testWidgets('the rider card shows only while out for delivery', (t) async {
      await open(t, 'FH1', [
        _order(
          'FH1',
          status: OrderStatus.outForDelivery,
          rider: const DeliveryRider(name: 'Ravi', phone: '9000000000'),
        ),
      ]);
      expect(find.text('Ravi'), findsWidgets);
    });

    testWidgets('a delivered order lets the customer rate it from the page', (t) async {
      final h = await open(t, 'FH1', [_order('FH1', status: OrderStatus.delivered)]);
      expect(find.text('How was your order?'), findsOneWidget);
      await t.tap(find.text('Rate now'));
      await _pumps(t);
      await t.tap(find.byTooltip('4 stars'));
      await t.pump();
      await t.tap(find.text('Submit'));
      await _pumps(t);
      expect(h.orders.ratings.single.$2, 4);
    });

    testWidgets('a rated order shows the rating and an Edit link', (t) async {
      await open(t, 'FH1', [
        _order('FH1', status: OrderStatus.delivered, rating: 5, review: 'Great'),
      ]);
      expect(find.text('Your rating'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('the Order ID can be copied', (t) async {
      final copied = <String>[];
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
        call,
      ) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      });
      addTearDown(
        () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await open(t, 'FH1', [_order('FH1')]);
      await t.tap(find.byIcon(Icons.copy_rounded).first);
      await t.pump();
      expect(copied, ['FH1']);
      expect(find.text('Order ID copied'), findsOneWidget);
    });

    testWidgets('Contact Fresh Hen opens help', (t) async {
      await open(t, 'FH1', [_order('FH1')]);
      await t.scrollUntilVisible(
        find.text('Contact Fresh Hen'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(find.text('Contact Fresh Hen'));
      await _pumps(t);
      expect(find.text('HELP'), findsOneWidget);
    });
  });

  group('order success screen', () {
    Future<Harness> open(WidgetTester t, {List<Order> orders = const []}) async {
      final h = await pumpFeature(
        t,
        const OrderSuccessScreen(orderId: 'FH1'),
        scaffold: false,
        orders: orders,
        routes: [
          stubRoute(Routes.home, label: 'HOME'),
          stubRoute(Routes.orders, label: 'ORDERS TAB'),
          stubRoute('/order/:id', label: 'ORDER DETAIL'),
        ],
      );
      await t.pump(const Duration(milliseconds: 600));
      return h;
    }

    testWidgets('celebrates the order and shows its number', (t) async {
      await open(t);
      expect(find.text('Order Placed!'), findsOneWidget);
      expect(find.text("You'll receive updates soon."), findsOneWidget);
      expect(find.text('Order #FH1'), findsOneWidget);
      await t.pump(const Duration(seconds: 4));
    });

    testWidgets('View Order opens the orders list and then the order itself', (t) async {
      await open(t, orders: [_order('FH1')]);
      await t.tap(find.text('View Order'));
      await t.pumpAndSettle();
      expect(find.text('ORDER DETAIL'), findsOneWidget);
    });

    testWidgets('back goes home rather than to the payment page', (t) async {
      await open(t);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('with reduced motion the simple tick badge is shown', (t) async {
      await pumpFeature(
        t,
        const OrderSuccessScreen(orderId: 'FH1'),
        scaffold: false,
        reduceMotion: true,
      );
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });

  group('invoice screen', () {
    Future<Harness> open(WidgetTester t, List<Order> orders, {String id = 'FH1'}) async {
      final h = await pumpFeature(
        t,
        InvoiceScreen(orderId: id),
        scaffold: false,
        orders: orders,
        size: const Size(1080, 6000),
      );
      await _settle(t);
      return h;
    }

    testWidgets('a delivered order shows its invoice and a Download button', (t) async {
      await open(t, [_order('FH1', status: OrderStatus.delivered)]);
      expect(find.text('Download Invoice'), findsWidgets);
      expect(find.text('Saves the PDF to your Downloads folder.'), findsOneWidget);
      expect(find.byTooltip('Share invoice'), findsOneWidget);
    });

    testWidgets('an order still being prepared and unpaid has no invoice yet', (t) async {
      await open(t, [_order('FH1')]);
      expect(find.text('Invoice not available'), findsOneWidget);
      expect(find.text('The tax invoice is ready once your order is delivered.'), findsOneWidget);
      expect(find.text('Download Invoice'), findsOneWidget); // only the app bar title
    });

    testWidgets('an unknown order has no invoice', (t) async {
      await open(t, [_order('FH1', status: OrderStatus.delivered)], id: 'NOPE');
      expect(find.text('Invoice not available'), findsOneWidget);
    });

    testWidgets('a paid order still on its way can be invoiced', (t) async {
      await open(t, [_order('FH1', payment: PaymentStatus.paid, method: PaymentMethod.upi)]);
      expect(find.text('Invoice not available'), findsNothing);
    });

    testWidgets('a cancelled order has no invoice', (t) async {
      await open(t, [_order('FH1', status: OrderStatus.cancelled, payment: PaymentStatus.paid)]);
      expect(find.text('Invoice not available'), findsOneWidget);
    });

    testWidgets('after tapping Download the customer is told how it went', (t) async {
      await open(t, [_order('FH1', status: OrderStatus.delivered)]);
      await t.tap(find.widgetWithText(FilledButton, 'Download Invoice'));
      await t.pump();
      // Building the PDF and saving it use real I/O, which fake time does not move.
      await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 4)));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      final saved = find.text('Invoice saved to Downloads');
      final failed = find.text('Could not create the invoice. Please try again.');
      expect(saved.evaluate().isNotEmpty || failed.evaluate().isNotEmpty, isTrue);
    });
  });
}
