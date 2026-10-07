import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/features/catalog/widgets/empty_wishlist.dart';
import 'package:fresh_hen/features/orders/widgets/empty_orders.dart';
import 'package:google_fonts/google_fonts.dart';

/// The premium empty states for Wishlist and Orders: content, call to action,
/// and the shared entrance/floating pieces they are built from.
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  final original = FlutterError.onError;
  setUp(() {
    // Google Fonts can't be fetched in tests; ignore only that and layout noise.
    FlutterError.onError = (d) {
      final text = d.exceptionAsString();
      if (!text.contains('overflowed') && !text.contains('google_fonts')) original?.call(d);
    };
  });
  tearDown(() => FlutterError.onError = original);

  Future<void> show(WidgetTester t, Widget child) async {
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: Scaffold(body: child)));
    // The hero loops forever, so settle by time rather than pumpAndSettle.
    await t.pump(const Duration(seconds: 1));
  }

  testWidgets('empty wishlist shows its message and steps, and the button browses', (t) async {
    var browsed = 0;
    await show(t, EmptyWishlist(onBrowse: () => browsed++));

    expect(find.text('Nothing saved yet'), findsOneWidget);
    expect(find.textContaining('favourites one tap away'), findsOneWidget);
    expect(find.text('Find something fresh'), findsOneWidget);
    expect(find.text('Tap the heart'), findsOneWidget);
    expect(find.text('Reorder anytime'), findsOneWidget);

    await t.tap(find.text('Start exploring'));
    expect(browsed, 1);
  });

  testWidgets('empty orders shows its message and steps, and the button starts shopping', (t) async {
    var shopped = 0;
    await show(t, EmptyOrders(onShop: () => shopped++));

    expect(find.text('No orders yet'), findsOneWidget);
    expect(find.textContaining('first fresh order'), findsOneWidget);
    expect(find.text('Pick your items'), findsOneWidget);
    expect(find.text('We deliver fresh'), findsOneWidget);
    expect(find.text('Track it live'), findsOneWidget);

    await t.tap(find.text('Start shopping'));
    expect(shopped, 1);
  });

  testWidgets('the content fades in rather than appearing at once', (t) async {
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: Scaffold(body: EmptyOrders(onShop: () {}))));
    await t.pump(const Duration(milliseconds: 50));
    final early = t.widget<Opacity>(find.byType(Opacity).first).opacity;
    await t.pump(const Duration(seconds: 1));
    final late = t.widget<Opacity>(find.byType(Opacity).first).opacity;
    expect(early, lessThan(1));
    expect(late, 1);
  });
}
