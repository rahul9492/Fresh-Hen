import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/core/errors/app_exception.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/repositories/order_repository.dart' show tooLateToCancel;
import 'package:fresh_hen/features/orders/widgets/awaiting_payment_card.dart';
import 'package:fresh_hen/features/orders/widgets/cancel_order_sheet.dart';
import 'package:fresh_hen/features/orders/widgets/on_the_way_card.dart';
import 'package:fresh_hen/features/orders/widgets/order_actions.dart';
import 'package:fresh_hen/features/orders/widgets/order_card.dart';
import 'package:fresh_hen/features/orders/widgets/order_status_scene.dart';
import 'package:fresh_hen/features/orders/widgets/order_status_style.dart';
import 'package:fresh_hen/features/orders/widgets/payment_issue_card.dart';
import 'package:fresh_hen/features/orders/widgets/pulsing_dot.dart';
import 'package:fresh_hen/features/orders/widgets/rate_experience_sheet.dart';
import 'package:fresh_hen/features/orders/widgets/route_scene.dart';
import 'package:fresh_hen/features/orders/widgets/stage_card.dart';

import '../../support/feature_harness.dart';
import '../../support/fixtures.dart';
import '../../support/pump.dart';

CartLine _line(String id, {int quantity = 1}) =>
    CartLine.fromVariant(product(id).copyWith(name: id), variant('v1', 100, label: '500 g')).copyWith(quantity: quantity);

Order _order(
  OrderStatus status, {
  String id = 'FH1',
  List<CartLine>? lines,
  int? rating,
  String? review,
  PaymentMethod method = PaymentMethod.cash,
  PaymentStatus payment = PaymentStatus.due,
  DeliverySlot? slot,
  DateTime? deliveredAt,
  String? cancelReason,
  DeliveryRider? rider,
}) =>
    Order(
      id: id,
      placedAt: DateTime(2026, 10, 1, 16, 28),
      lines: lines ?? [_line('Eggs')],
      bill: const OrderBill(itemTotal: 100, mrpTotal: 100, deliveryFee: 40),
      address: 'Flat 1, Noida',
      status: status,
      paymentMethod: method,
      paymentStatus: payment,
      slot: slot,
      rating: rating,
      review: review,
      deliveredAt: deliveredAt,
      cancelReason: cancelReason,
      rider: rider,
    );

void main() {
  setUpWidgetTests();

  group('order wording and colours', () {
    test('every status has an icon and its own colour', () {
      final colours = OrderStatus.values.map((s) => s.color).toSet();
      expect(colours.length, OrderStatus.values.length);
      for (final s in OrderStatus.values) {
        expect(s.icon, isA<IconData>());
      }
    });

    test('the label follows what is really happening', () {
      expect(_order(OrderStatus.preparing).statusLabel, 'Being prepared');
      expect(_order(OrderStatus.delivered).statusLabel, 'Delivered');
      expect(_order(OrderStatus.confirmed).statusLabel, 'Confirmed');
      final slot = DeliverySlot(id: 's', start: DateTime(2026, 10, 9, 10), end: DateTime(2026, 10, 9, 11));
      expect(_order(OrderStatus.confirmed, slot: slot).statusLabel, 'Scheduled');
      expect(
        _order(OrderStatus.confirmed, method: PaymentMethod.upi, payment: PaymentStatus.verifying).statusLabel,
        'Awaiting confirmation',
      );
      expect(
        _order(OrderStatus.preparing, method: PaymentMethod.upi, payment: PaymentStatus.rejected).statusLabel,
        'Payment issue',
      );
    });

    test('a rejected payment wins over an awaiting one, and a cancelled order is plain cancelled', () {
      final cancelled = _order(OrderStatus.cancelled, method: PaymentMethod.upi, payment: PaymentStatus.rejected);
      expect(cancelled.statusLabel, 'Cancelled');
      expect(cancelled.statusIcon, OrderStatus.cancelled.icon);
    });

    test('icons and colours match the label', () {
      final awaiting = _order(OrderStatus.confirmed, method: PaymentMethod.upi, payment: PaymentStatus.verifying);
      expect(awaiting.statusIcon, Icons.hourglass_top_rounded);
      expect(awaiting.statusColor, isNot(OrderStatus.confirmed.color));

      final issue = _order(OrderStatus.preparing, payment: PaymentStatus.rejected);
      expect(issue.statusIcon, Icons.error_outline_rounded);
      expect(issue.statusColor, issue.statusColor);

      final slot = DeliverySlot(id: 's', start: DateTime(2026, 10, 9, 10), end: DateTime(2026, 10, 9, 11));
      expect(_order(OrderStatus.confirmed, slot: slot).statusIcon, Icons.event_available_rounded);
      expect(_order(OrderStatus.delivered).statusColor, OrderStatus.delivered.color);
    });

    test('the detail line under the status', () {
      final now = DateTime.now();
      expect(_order(OrderStatus.outForDelivery).statusDetail(eta: '45 mins'), 'Your order is on the way');
      expect(_order(OrderStatus.preparing).statusDetail(eta: '45 mins'), 'Arriving in 45 mins');
      expect(_order(OrderStatus.delivered).statusDetail(eta: ''), 'Delivered');
      expect(
        _order(OrderStatus.delivered, deliveredAt: now).statusDetail(eta: ''),
        startsWith('Delivered today at'),
      );
      expect(_order(OrderStatus.cancelled).statusDetail(eta: ''), 'This order was cancelled');
      expect(
        _order(OrderStatus.cancelled, cancelReason: 'Ordered by mistake').statusDetail(eta: ''),
        'Cancelled: Ordered by mistake',
      );
      expect(
        _order(OrderStatus.confirmed, method: PaymentMethod.upi, payment: PaymentStatus.verifying).statusDetail(eta: '45 mins'),
        contains('checking your payment'),
      );
      expect(
        _order(OrderStatus.preparing, payment: PaymentStatus.rejected).statusDetail(eta: ''),
        contains("couldn't verify your payment"),
      );
      final slot = DeliverySlot(id: 's', start: DateTime.now().add(const Duration(days: 1)), end: DateTime.now().add(const Duration(days: 1, hours: 1)));
      expect(_order(OrderStatus.confirmed, slot: slot).statusDetail(eta: ''), startsWith('Arriving Tomorrow'));
    });
  });

  group('OrderCard', () {
    Widget card(Order o, {List<String>? log}) => SingleChildScrollView(
          child: OrderCard(
            order: o,
            onReorder: () => log?.add('reorder'),
            onRate: () => log?.add('rate'),
            onHelp: () => log?.add('help'),
            onTap: () => log?.add('open'),
          ),
        );

    testWidgets('shows the status, id, total, date and items', (t) async {
      await pumpWidgetApp(t, card(_order(OrderStatus.preparing, lines: [_line('Eggs', quantity: 2)])));
      expect(find.text('Being prepared'), findsOneWidget);
      expect(find.text('#FH1'), findsOneWidget);
      expect(find.textContaining('₹140'), findsOneWidget);
      expect(find.textContaining('01 Oct'), findsOneWidget);
      expect(find.textContaining('Eggs'), findsWidgets);
    });

    testWidgets('an order in progress offers help only', (t) async {
      final log = <String>[];
      await pumpWidgetApp(t, card(_order(OrderStatus.preparing), log: log));
      expect(find.text('Reorder'), findsNothing);
      expect(find.text('Rate order'), findsNothing);
      await t.tap(find.text('Help & Support'));
      expect(log, ['help']);
    });

    testWidgets('a delivered order offers reorder and rating', (t) async {
      final log = <String>[];
      await pumpWidgetApp(t, card(_order(OrderStatus.delivered), log: log));
      await t.tap(find.text('Reorder'));
      await t.tap(find.text('Rate order'));
      expect(log, ['reorder', 'rate']);
      expect(find.text('Help & Support'), findsNothing);
    });

    testWidgets('a rated order shows its stars, and tapping lets the customer change it', (t) async {
      final log = <String>[];
      await pumpWidgetApp(t, card(_order(OrderStatus.delivered, rating: 4), log: log));
      expect(find.text('Rated'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
      expect(find.text('Rate order'), findsNothing);
      await t.tap(find.text('Rated'));
      expect(log, ['rate']);
    });

    testWidgets('a cancelled order offers reorder and help', (t) async {
      await pumpWidgetApp(t, card(_order(OrderStatus.cancelled)));
      expect(find.text('Reorder'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Rate order'), findsNothing);
    });

    testWidgets('a rejected payment shows a banner that opens help', (t) async {
      final log = <String>[];
      await pumpWidgetApp(t, card(_order(OrderStatus.preparing, method: PaymentMethod.upi, payment: PaymentStatus.rejected), log: log));
      expect(find.text('Payment issue'), findsOneWidget);
      expect(find.text("We couldn't verify your payment. Tap to contact us."), findsOneWidget);
      await t.tap(find.textContaining("couldn't verify"));
      expect(log, ['help']);
    });

    testWidgets('tapping the header or the items opens the order', (t) async {
      final log = <String>[];
      await pumpWidgetApp(t, card(_order(OrderStatus.preparing), log: log));
      await t.tap(find.text('Being prepared'));
      await t.tap(find.textContaining('Eggs').first);
      expect(log, ['open', 'open']);
    });

    testWidgets('a long order starts with two items and expands to all', (t) async {
      final lines = [for (var i = 0; i < 5; i++) _line('Item$i')];
      await pumpWidgetApp(t, card(_order(OrderStatus.preparing, lines: lines)));
      expect(find.textContaining('Item0'), findsOneWidget);
      expect(find.textContaining('Item1'), findsOneWidget);
      expect(find.textContaining('Item2'), findsNothing);
      expect(find.text('+3 more items'), findsOneWidget);

      await t.tap(find.text('+3 more items'));
      await t.pumpAndSettle();
      expect(find.textContaining('Item4'), findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);

      await t.tap(find.text('Show less'));
      await t.pumpAndSettle();
      expect(find.textContaining('Item4'), findsNothing);
    });

    testWidgets('three items are all shown with no toggle', (t) async {
      final lines = [for (var i = 0; i < 3; i++) _line('Item$i')];
      await pumpWidgetApp(t, card(_order(OrderStatus.preparing, lines: lines)));
      expect(find.textContaining('Item2'), findsOneWidget);
      expect(find.textContaining('more items'), findsNothing);
    });
  });

  group('order actions', () {
    late Order delivered;
    setUp(() => delivered = _order(OrderStatus.delivered, id: 'FH9'));

    Future<Harness> pump(WidgetTester t, Order o, Future<void> Function(BuildContext, WidgetRef, Order) action) {
      return pumpFeature(
        t,
        Consumer(
          builder: (context, ref, _) => TextButton(onPressed: () => action(context, ref, o), child: const Text('go')),
        ),
        orders: [o],
        routes: [stubRoute(Routes.cart, label: 'CART PAGE')],
      );
    }

    testWidgets('reorder puts every item back in the cart and opens it', (t) async {
      final order = _order(OrderStatus.delivered, lines: [_line('Eggs', quantity: 2), _line('Fish')]);
      final h = await pumpFeature(
        t,
        Consumer(
          builder: (context, ref, _) => TextButton(onPressed: () => repeatOrder(context, ref, order), child: const Text('go')),
        ),
        routes: [stubRoute(Routes.cart, label: 'CART PAGE')],
      );
      h.container.read(cartProvider.notifier).add(_line('Eggs'));

      await t.tap(find.text('go'));
      await t.pumpAndSettle();

      final cart = h.container.read(cartProvider);
      expect(cart.firstWhere((l) => l.id == 'Eggs:v1').quantity, 3); // 1 already there + 2
      expect(cart.any((l) => l.id == 'Fish:v1'), isTrue);
      expect(find.text('CART PAGE'), findsOneWidget);
    });

    testWidgets('rating: the chosen stars and comment are saved, with thanks', (t) async {
      final h = await pump(t, delivered, rateOrder);
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('4 stars'));
      await t.enterText(find.byType(TextField), '  Fresh!  ');
      await t.pump();
      await t.tap(find.text('Submit'));
      await t.pumpAndSettle();

      expect(h.orders.ratings.single, ('FH9', 4, 'Fresh!'));
      expect(find.text('Thanks for your feedback!'), findsOneWidget);
    });

    testWidgets('rating: dismissing the sheet saves nothing', (t) async {
      final h = await pump(t, delivered, rateOrder);
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      await t.tapAt(const Offset(5, 5));
      await t.pumpAndSettle();
      expect(h.orders.ratings, isEmpty);
      expect(find.text('Thanks for your feedback!'), findsNothing);
    });

    testWidgets('cancel: the chosen reason is sent and the customer is told', (t) async {
      final confirmed = _order(OrderStatus.confirmed, id: 'FH5');
      final h = await pump(t, confirmed, cancelOrder);
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      await t.tap(find.text('Wrong delivery address'));
      await t.pump();
      await t.tap(find.widgetWithText(FilledButton, 'Cancel order'));
      await t.pumpAndSettle();

      expect(h.orders.cancels.single, ('FH5', 'Wrong delivery address'));
      expect(find.text('Your order has been cancelled'), findsOneWidget);
    });

    testWidgets('cancel: keeping the order does nothing', (t) async {
      final h = await pump(t, _order(OrderStatus.confirmed, id: 'FH5'), cancelOrder);
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Close'));
      await t.pumpAndSettle();
      expect(h.orders.cancels, isEmpty);
    });

    testWidgets('cancel: a refusal from the store is shown to the customer', (t) async {
      final confirmed = _order(OrderStatus.confirmed, id: 'FH5');
      final h = await pumpFeature(
        t,
        Consumer(
          builder: (context, ref, _) => TextButton(onPressed: () => cancelOrder(context, ref, confirmed), child: const Text('go')),
        ),
        orders: [confirmed],
        overrides: const [],
      );
      // Make the store refuse: swap the order list entry so the repository throws.
      h.orders.orders.clear();
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      await t.tap(find.text('Other'));
      await t.pump();
      await t.tap(find.widgetWithText(FilledButton, 'Cancel order'));
      await t.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('cancel order sheet', () {
    Future<void> open(WidgetTester t, Order o, void Function(String?) onResult) async {
      await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(
            onPressed: () async => onResult(await showCancelOrderSheet(c, order: o)),
            child: const Text('open'),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('lists the reasons, and the button waits for a choice', (t) async {
      await open(t, _order(OrderStatus.confirmed), (_) {});
      expect(find.text('Cancel order?'), findsOneWidget);
      for (final r in ['Ordered by mistake', 'Want to change items or quantity', 'Delivery time is too late', 'Wrong delivery address', 'Other']) {
        expect(find.text(r), findsOneWidget, reason: r);
      }
      expect(t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Cancel order')).onPressed, isNull);
    });

    testWidgets('choosing a reason enables the button and returns the reason', (t) async {
      String? result;
      await open(t, _order(OrderStatus.confirmed), (r) => result = r);
      await t.tap(find.text('Delivery time is too late'));
      await t.pump();
      await t.tap(find.widgetWithText(FilledButton, 'Cancel order'));
      await t.pumpAndSettle();
      expect(result, 'Delivery time is too late');
    });

    testWidgets('a UPI order is told about the refund; cash is not', (t) async {
      await open(t, _order(OrderStatus.confirmed, method: PaymentMethod.upi), (_) {});
      expect(find.textContaining('refunded by the store'), findsOneWidget);
    });

    testWidgets('no refund note for cash on delivery', (t) async {
      await open(t, _order(OrderStatus.confirmed), (_) {});
      expect(find.textContaining('refunded'), findsNothing);
    });

    testWidgets('closing returns nothing', (t) async {
      String? result = 'unset';
      await open(t, _order(OrderStatus.confirmed), (r) => result = r);
      await t.tap(find.byTooltip('Close'));
      await t.pumpAndSettle();
      expect(result, isNull);
    });
  });

  group('rate experience sheet', () {
    Future<void> open(WidgetTester t, Order o, void Function(OrderReview?) onResult) async {
      await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(
            onPressed: () async => onResult(await showRateExperienceSheet(c, order: o)),
            child: const Text('open'),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('starts unrated: Submit is off and it asks for a star', (t) async {
      await open(t, _order(OrderStatus.delivered), (_) {});
      expect(find.text('Rate Your Experience'), findsOneWidget);
      expect(find.text('Tap a star to rate'), findsOneWidget);
      expect(t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Submit')).onPressed, isNull);
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
    });

    testWidgets('each star gives its own caption', (t) async {
      await open(t, _order(OrderStatus.delivered), (_) {});
      const captions = ['Terrible', 'Bad', 'Okay', 'Good', 'Loved it!'];
      for (var i = 0; i < 5; i++) {
        await t.tap(find.byTooltip('${i + 1} star${i == 0 ? '' : 's'}'));
        await t.pump();
        expect(find.text(captions[i]), findsOneWidget);
        expect(find.byIcon(Icons.star_rounded), findsNWidgets(i + 1));
      }
    });

    testWidgets('submitting returns the stars and the trimmed comment', (t) async {
      OrderReview? result;
      await open(t, _order(OrderStatus.delivered), (r) => result = r);
      await t.tap(find.byTooltip('5 stars'));
      await t.enterText(find.byType(TextField), '  Loved the chicken  ');
      await t.pump();
      await t.tap(find.text('Submit'));
      await t.pumpAndSettle();
      expect(result?.stars, 5);
      expect(result?.comment, 'Loved the chicken');
    });

    testWidgets('a comment is optional', (t) async {
      OrderReview? result;
      await open(t, _order(OrderStatus.delivered), (r) => result = r);
      await t.tap(find.byTooltip('3 stars'));
      await t.pump();
      await t.tap(find.text('Submit'));
      await t.pumpAndSettle();
      expect(result?.stars, 3);
      expect(result?.comment, '');
    });

    testWidgets('changing an earlier rating starts from it', (t) async {
      OrderReview? result;
      await open(t, _order(OrderStatus.delivered, rating: 2, review: 'Meh'), (r) => result = r);
      expect(find.text('Bad'), findsOneWidget);
      expect(find.text('Meh'), findsOneWidget);
      await t.tap(find.text('Submit'));
      await t.pumpAndSettle();
      expect(result?.stars, 2);
      expect(result?.comment, 'Meh');
    });

    testWidgets('the comment counter follows typing and stops at 250', (t) async {
      await open(t, _order(OrderStatus.delivered), (_) {});
      expect(find.text('0/250 characters'), findsOneWidget);
      await t.enterText(find.byType(TextField), 'x' * 300);
      await t.pump();
      expect(find.text('250/250 characters'), findsOneWidget);
    });
  });

  group('status scene and cards', () {
    Future<void> scene(WidgetTester t, Order o, {bool reduceMotion = false}) async {
      await pumpWidgetApp(t, SingleChildScrollView(child: OrderStatusScene(order: o)), reduceMotion: reduceMotion);
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
    }

    testWidgets('while a UPI payment is checked it says it is waiting', (t) async {
      await scene(t, _order(OrderStatus.confirmed, method: PaymentMethod.upi, payment: PaymentStatus.verifying));
      expect(find.text('Waiting for confirmation'), findsOneWidget);
      expect(find.textContaining("checking your payment screenshot"), findsOneWidget);
    });

    testWidgets('a rejected payment shows the help card instead', (t) async {
      await scene(t, _order(OrderStatus.preparing, method: PaymentMethod.upi, payment: PaymentStatus.rejected));
      expect(find.text("We couldn't verify your payment"), findsOneWidget);
      expect(find.text('Waiting for confirmation'), findsNothing);
    });

    testWidgets('preparing and delivered each have their own card', (t) async {
      await scene(t, _order(OrderStatus.preparing));
      expect(find.text('Your order is being prepared'), findsOneWidget);
      expect(find.text('Cleaning, cutting and packing it fresh'), findsOneWidget);
    });

    testWidgets('a delivered order says so', (t) async {
      await scene(t, _order(OrderStatus.delivered));
      expect(find.text('Order delivered'), findsOneWidget);
      expect(find.text('Enjoy your fresh meal!'), findsOneWidget);
    });

    testWidgets('out for delivery names the rider when known', (t) async {
      await scene(t, _order(OrderStatus.outForDelivery, rider: const DeliveryRider(name: 'Ravi', phone: '9000000000')));
      expect(find.text('Your order is on the way'), findsOneWidget);
      expect(find.text('Ravi is bringing it fresh to your door'), findsOneWidget);
    });

    testWidgets('out for delivery without a rider uses a general line', (t) async {
      await scene(t, _order(OrderStatus.outForDelivery));
      expect(find.text('Fresh from our store to your door'), findsOneWidget);
    });

    testWidgets('a confirmed or cancelled order has no scene at all', (t) async {
      await scene(t, _order(OrderStatus.confirmed));
      expect(find.byType(StageCard), findsNothing);
      expect(find.byType(AwaitingPaymentCard), findsNothing);
      await scene(t, _order(OrderStatus.cancelled));
      expect(find.byType(StageCard), findsNothing);
    });

    testWidgets('the scene changes as the order moves along', (t) async {
      await scene(t, _order(OrderStatus.preparing));
      expect(find.text('Your order is being prepared'), findsOneWidget);
      await pumpWidgetApp(t, SingleChildScrollView(child: OrderStatusScene(order: _order(OrderStatus.delivered))));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Order delivered'), findsOneWidget);
      expect(find.text('Your order is being prepared'), findsNothing);
    });

    testWidgets('with reduced motion the cards still show their text', (t) async {
      await scene(t, _order(OrderStatus.outForDelivery), reduceMotion: true);
      expect(find.text('Your order is on the way'), findsOneWidget);
    });

    testWidgets('the help card opens support', (t) async {
      await pumpFeature(
        t,
        const PaymentIssueCard(),
        routes: [stubRoute(Routes.help, label: 'HELP PAGE')],
      );
      await t.tap(find.text('Contact support'));
      await t.pumpAndSettle();
      expect(find.text('HELP PAGE'), findsOneWidget);
    });

    testWidgets('a stage card shows its title and subtitle even when the animation cannot load', (t) async {
      await pumpWidgetApp(
        t,
        const StageCard(lottie: 'assets/missing.json', fallbackIcon: Icons.restaurant_rounded, title: 'Cooking', subtitle: 'Soon'),
      );
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Cooking'), findsOneWidget);
      expect(find.text('Soon'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
    });

    testWidgets('the awaiting card and the route scene render and animate without errors', (t) async {
      await pumpWidgetApp(t, const Column(children: [AwaitingPaymentCard(), SizedBox(height: 118, child: RouteScene())]));
      await t.pump(const Duration(milliseconds: 500));
      await t.pump(const Duration(seconds: 2));
      expect(find.byType(RouteScene), findsOneWidget);
    });

    testWidgets('the on-the-way card shows the route', (t) async {
      await pumpWidgetApp(t, const OnTheWayCard(rider: null));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.byType(RouteScene), findsOneWidget);
    });

    testWidgets('the pulsing dot animates, and stops with reduced motion', (t) async {
      await pumpWidgetApp(t, const SizedBox(width: 30, height: 30, child: PulsingDot()));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.byType(PulsingDot), findsOneWidget);

      await pumpWidgetApp(t, const SizedBox(width: 30, height: 30, child: PulsingDot()), reduceMotion: true);
      await t.pump(const Duration(seconds: 3));
      expect(find.byType(PulsingDot), findsOneWidget);
    });
  });

  test('the cancel refusal text is the one the repository raises', () {
    expect(const AppException(tooLateToCancel).message, contains('already being prepared'));
  });
}
