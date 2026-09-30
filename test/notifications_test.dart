import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/app.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:fresh_hen/core/utils/formatters.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> openHome(WidgetTester t) async {
  t.view.physicalSize = const Size(1080, 2340);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  SharedPreferences.setMockInitialValues({
    'onboarding.seen': true,
    'auth.users': '{"9876543210":{"phone":"9876543210","name":"Rahul","email":null}}',
  });
  final prefs = await SharedPreferences.getInstance();
  await t.pumpWidget(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const FreshHenApp(),
  ));
  await t.pumpAndSettle();
  await t.enterText(find.byType(TextField), '9876543210');
  await t.pump();
  await t.tap(find.text('Continue'));
  await t.pumpAndSettle(const Duration(seconds: 1));
  await t.enterText(find.byType(TextField), '1234');
  await t.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  Badge bellBadge(WidgetTester t) => t.widget<Badge>(
        find.ancestor(
          of: find.byIcon(Icons.notifications_none_rounded),
          matching: find.byType(Badge),
        ),
      );

  final original = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) original?.call(d);
    };
  });
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('bell opens notifications, tapping reads, mark all read clears the badge', (t) async {
    await openHome(t);
    expect(find.text('Popular Picks'), findsOneWidget);
    expect(bellBadge(t).isLabelVisible, isTrue); // unread dot

    await t.tap(find.byIcon(Icons.notifications_none_rounded));
    await t.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Your order is out for delivery'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);

    // Filter narrows the list.
    await t.tap(find.text('Offers'));
    await t.pumpAndSettle();
    expect(find.text('Your order is out for delivery'), findsNothing);
    expect(find.text('Flat 20% off on Country Hen'), findsOneWidget);
    await t.tap(find.text('All'));
    await t.pumpAndSettle();

    await t.tap(find.text('Mark all read'));
    await t.pumpAndSettle();
    final button = t.widget<TextButton>(find.widgetWithText(TextButton, 'Mark all read'));
    expect(button.onPressed, isNull);

    await t.pageBack();
    await t.pumpAndSettle();
    expect(bellBadge(t).isLabelVisible, isFalse);
  });

  testWidgets('swipe removes a notification and undo restores it', (t) async {
    await openHome(t);
    await t.tap(find.byIcon(Icons.notifications_none_rounded));
    await t.pumpAndSettle(const Duration(seconds: 1));

    await t.drag(find.text('Your order is out for delivery'), const Offset(-600, 0));
    await t.pumpAndSettle();
    expect(find.text('Your order is out for delivery'), findsNothing);
    expect(find.text('Notification removed'), findsOneWidget);

    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(find.text('Your order is out for delivery'), findsOneWidget);
    // Let the (cancelled) delete timer window pass without side effects.
    await t.pump(const Duration(seconds: 5));
  });

  test('timeAgo formats relative times', () {
    final now = DateTime(2026, 9, 30, 12);
    expect(timeAgo(now.subtract(const Duration(seconds: 20)), now: now), 'Just now');
    expect(timeAgo(now.subtract(const Duration(minutes: 12)), now: now), '12m ago');
    expect(timeAgo(now.subtract(const Duration(hours: 3)), now: now), '3h ago');
    expect(timeAgo(now.subtract(const Duration(hours: 30)), now: now), 'Yesterday');
    expect(timeAgo(now.subtract(const Duration(days: 4)), now: now), '4d ago');
  });
}
