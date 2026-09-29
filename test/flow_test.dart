import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/app.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
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

    await t.ensureVisible(find.byIcon(Icons.add_rounded).first);
    await t.pump();
    await t.tap(find.byIcon(Icons.add_rounded).first);
    await t.pumpAndSettle();
    expect(find.text('Quantity'), findsOneWidget);
    await t.tap(find.text('Add').first);
    await t.pumpAndSettle();
    await t.tap(find.textContaining('Done'));
    await t.pumpAndSettle();
    expect(find.text('View Cart'), findsOneWidget);
    await t.tap(find.text('View Cart'));
    await t.pumpAndSettle();
    expect(find.text('Bill details'), findsOneWidget);
    await t.tap(find.textContaining('Place Order'));
    await t.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Order placed!'), findsOneWidget);
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
}
