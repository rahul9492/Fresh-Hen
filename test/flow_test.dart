import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/app.dart';
import 'package:fresh_hen/app/router/router.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:fresh_hen/core/utils/formatters.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/providers/order_providers.dart';
import 'package:fresh_hen/features/address/widgets/address_form_sheet.dart';
import 'package:fresh_hen/features/catalog/widgets/product_options_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester t, SharedPreferences prefs) async {
  await t.pumpWidget(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const FreshHenApp(),
  ));
  await t.pumpAndSettle();
}

Future<void> login(WidgetTester t) async {
  await t.enterText(find.byType(TextField), '9876543210');
  await t.pump();
  await t.tap(find.text('Continue'));
  await t.pumpAndSettle(const Duration(seconds: 1));
  await t.enterText(find.byType(TextField), '1234');
  await t.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  final original = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) original?.call(d);
    };
  });
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('new user: onboarding -> otp -> profile -> home -> cart, then returning user skips profile', (t) async {
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 3;
    final prefs = await SharedPreferences.getInstance();
    await pumpApp(t, prefs);
    expect(find.text('Next'), findsOneWidget);
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    await t.tap(find.text('Get Started'));
    await t.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
    await login(t);
    expect(find.text('Create Your Profile'), findsOneWidget);
    await t.enterText(find.byType(TextFormField).first, 'Rahul Kumar');
    await t.tap(find.text('Complete Setup & Explore'));
    await t.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Popular Picks'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    final cardAdd = find.text('Add').first;
    await t.ensureVisible(cardAdd);
    await t.pump();
    await t.tap(cardAdd);
    await t.pumpAndSettle();
    expect(find.text('Quantity'), findsOneWidget);
    await t.tap(find
        .descendant(of: find.byType(ProductOptionsSheet), matching: find.text('Add'))
        .first);
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Close'));
    await t.pumpAndSettle();
    expect(find.text('Quantity'), findsNothing);
    expect(find.text('View cart'), findsOneWidget);
    await t.tap(find.text('View cart'));
    await t.pumpAndSettle();
    expect(find.text('Your cart'), findsOneWidget);
    expect(find.text('Bill Summary'), findsOneWidget);
    // A new user has no address yet, so checkout starts there. Placing the
    // order itself is covered in checkout_test.dart.
    expect(find.textContaining('Add'), findsWidgets);
    expect(find.textContaining('Address'), findsWidgets);
    // The cart reloads store settings on open; let that mock request finish.
    await t.pump(const Duration(seconds: 2));
  });

  testWidgets('registered user goes straight to home', (t) async {
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 3;
    SharedPreferences.setMockInitialValues({
      'onboarding.seen': true,
      'auth.users': '{"9876543210":{"phone":"9876543210","name":"Rahul","email":null}}',
    });
    final prefs = await SharedPreferences.getInstance();
    await pumpApp(t, prefs);
    await login(t);
    expect(find.text('Create Your Profile'), findsNothing);
    expect(find.text('Popular Picks'), findsOneWidget);
  });

  testWidgets('checkout end to end: add an item, add an address, pay cash, see the order', (t) async {
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    SharedPreferences.setMockInitialValues({
      'onboarding.seen': true,
      'auth.users': '{"9876543210":{"phone":"9876543210","name":"Rahul","email":null}}',
    });
    final prefs = await SharedPreferences.getInstance();
    await pumpApp(t, prefs);
    await login(t);
    final container = ProviderScope.containerOf(t.element(find.byType(MaterialApp)));

    // Home: add the first product's first pack.
    final cardAdd = find.text('Add').first;
    await t.ensureVisible(cardAdd);
    await t.pump();
    await t.tap(cardAdd);
    await t.pumpAndSettle();
    await t.tap(find
        .descendant(of: find.byType(ProductOptionsSheet), matching: find.text('Add'))
        .first);
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Close'));
    await t.pumpAndSettle();
    final itemTotal = container.read(cartSummaryProvider).itemTotal;
    expect(itemTotal, greaterThan(0));

    // Cart: no address yet, so checkout starts by adding one.
    await t.tap(find.text('View cart'));
    await t.pump(const Duration(seconds: 2));
    await t.pumpAndSettle();
    // "Add Address & Slot", or "Add Delivery Address" when scheduling is off.
    await t.tap(find.textContaining(RegExp(r'^Add (Address|Delivery Address)')));
    await t.pumpAndSettle();
    final fields = find.descendant(of: find.byType(AddressFormSheet), matching: find.byType(TextFormField));
    await t.enterText(fields.at(0), 'Flat 503, Tower C'); // house
    await t.enterText(fields.at(1), 'Sector 62'); // area
    await t.enterText(fields.at(3), 'Noida'); // city
    await t.enterText(fields.at(4), '201301'); // pincode, inside the delivery area
    await t.tap(find.text('Confirm'));
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    expect(find.byType(AddressFormSheet), findsNothing);

    // Pay cash on delivery.
    await t.tap(find.text('Proceed to Payment'));
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    await t.tap(find.text('Cash on Delivery'));
    await t.pumpAndSettle();
    final total = itemTotal + (itemTotal >= 499 ? 0 : 40);
    await t.tap(find.text('Place Order • ${rupees(total)}'));
    await t.pump(const Duration(seconds: 2));
    await t.pumpAndSettle();
    expect(find.text('Order Placed!'), findsOneWidget);

    // The order is saved with the amount shown, and the cart is empty.
    final order = container.read(ordersProvider).value!.first;
    expect(order.total, total);
    expect(order.paymentMethod, PaymentMethod.cash);
    expect(order.status, OrderStatus.confirmed);
    expect(container.read(cartProvider), isEmpty);

    // It shows at the top of the Orders tab.
    container.read(goRouterProvider).go(Routes.orders);
    await t.pump(const Duration(seconds: 2));
    await t.pumpAndSettle();
    expect(find.text('#${order.id}'), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
  });
}
