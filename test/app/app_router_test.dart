import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/app.dart';
import 'package:fresh_hen/app/router/router.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/core/push/push_service.dart';
import 'package:fresh_hen/features/address/providers/address_providers.dart';
import 'package:fresh_hen/features/auth/models/app_user.dart';
import 'package:fresh_hen/features/auth/providers/auth_provider.dart';
import 'package:fresh_hen/features/catalog/providers/catalog_providers.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';
import 'package:fresh_hen/features/checkout/providers/checkout_providers.dart';
import 'package:fresh_hen/features/onboarding/providers/onboarding_provider.dart';
import 'package:fresh_hen/features/orders/providers/order_providers.dart';

import '../support/feature_harness.dart';
import '../support/fixtures.dart';
import '../support/pump.dart';

/// The whole app with its real router, on in-memory data.
Future<ProviderContainer> _app(
  WidgetTester t, {
  bool signedIn = false,
  bool onboardingSeen = false,
}) async {
  t.view.physicalSize = const Size(1080, 4000);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  ignoreLayoutOverflow();

  final (container, _) = await makeContainer(
    signedIn: false, // the session comes from the device, below
    prefs: {
      if (onboardingSeen) 'onboarding.seen': true,
      if (signedIn)
        'auth.users': '{"9876543210":{"phone":"9876543210","name":"Rahul Kumar","email":null}}',
      if (signedIn) 'auth.session_phone': '9876543210',
    },
    overrides: [
      pushServiceProvider.overrideWith(FakePush.new),
      catalogRepositoryProvider.overrideWithValue(FakeCatalog([product('hen', isPopular: true)])),
      checkoutRepositoryProvider.overrideWithValue(FakeCheckout(mockStoreSettings)),
      addressRepositoryProvider.overrideWithValue(FakeAddresses(const [homeAddress])),
      orderRepositoryProvider.overrideWithValue(FakeOrders()),
    ],
  );
  addTearDown(container.dispose);
  await t.pumpWidget(UncontrolledProviderScope(container: container, child: const FreshHenApp()));
  await t.pump();
  await t.pump(const Duration(milliseconds: 600));
  return container;
}

Finder _tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

String _where(ProviderContainer c) =>
    c.read(goRouterProvider).routeInformationProvider.value.uri.path;

Future<void> _go(WidgetTester t, ProviderContainer c, String location) async {
  c.read(goRouterProvider).go(location);
  await t.pump();
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  setUpWidgetTests();

  group('before signing in', () {
    testWidgets('a new install starts on onboarding', (t) async {
      final c = await _app(t);
      expect(_where(c), Routes.onboarding);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('once onboarding has been seen, the app starts on login', (t) async {
      final c = await _app(t, onboardingSeen: true);
      expect(_where(c), Routes.login);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('finishing onboarding moves on to login', (t) async {
      final c = await _app(t);
      for (var i = 0; i < 2; i++) {
        await t.tap(find.text('Next'));
        await t.pumpAndSettle();
      }
      await t.tap(find.text('Get Started'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(c.read(onboardingSeenProvider), isTrue);
      expect(_where(c), Routes.login);
    });

    testWidgets('private pages send a signed-out visitor to login', (t) async {
      final c = await _app(t, onboardingSeen: true);
      for (final page in [
        Routes.cart,
        Routes.orders,
        Routes.account,
        Routes.home,
        Routes.wishlist,
        '/product/hen',
      ]) {
        await _go(t, c, page);
        expect(_where(c), Routes.login, reason: page);
      }
    });

    testWidgets('the login, OTP and profile pages can be reached', (t) async {
      final c = await _app(t, onboardingSeen: true);
      await _go(t, c, Routes.otpFor('9876543210'));
      expect(_where(c), Routes.otp);
      expect(find.text('Verify OTP'), findsOneWidget);

      await _go(t, c, Routes.profileSetupFor('9876543210'));
      expect(_where(c), Routes.profileSetup);
      expect(find.text('Create Your Profile'), findsOneWidget);
    });

    testWidgets('the OTP page keeps the number it was opened with', (t) async {
      final c = await _app(t, onboardingSeen: true);
      await _go(t, c, Routes.otpFor('9123456789'));
      expect(find.text('We have sent a 4 digit code to +91 91234 56789'), findsOneWidget);
      c.dispose();
    });
  });

  group('signed in', () {
    testWidgets('the app opens on Home', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      expect(_where(c), Routes.home);
      expect(find.text('Popular Picks'), findsOneWidget);
    });

    testWidgets('onboarding, login and the root all lead Home', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      for (final page in [Routes.root, Routes.onboarding, Routes.login]) {
        await _go(t, c, page);
        expect(_where(c), Routes.home, reason: page);
      }
    });

    testWidgets('the bottom tabs switch between Home, Categories, Orders and Account', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      await t.tap(_tab('Categories'));
      await t.pump(const Duration(milliseconds: 600));
      expect(_where(c), Routes.categories);

      await t.tap(_tab('Orders'));
      await t.pump(const Duration(milliseconds: 600));
      expect(_where(c), Routes.orders);

      await t.tap(_tab('Account'));
      await t.pump(const Duration(milliseconds: 600));
      expect(_where(c), Routes.account);

      await t.tap(_tab('Home'));
      await t.pump(const Duration(milliseconds: 600));
      expect(_where(c), Routes.home);
    });

    testWidgets('deep links open their pages', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      await _go(t, c, Routes.cart);
      expect(_where(c), Routes.cart);
      expect(find.text('Your cart is empty'), findsOneWidget);

      await _go(t, c, Routes.search);
      expect(_where(c), Routes.search);

      await _go(t, c, Routes.wishlist);
      expect(_where(c), Routes.wishlist);

      await _go(t, c, Routes.addresses);
      expect(_where(c), Routes.addresses);

      await _go(t, c, Routes.help);
      expect(find.text('Help & Support'), findsWidgets);

      await _go(t, c, Routes.terms);
      expect(find.text('Terms & Privacy'), findsWidgets);
    });

    testWidgets('a product link opens that product', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      await _go(t, c, Routes.productFor('hen'));
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('hen'), findsWidgets);
    });

    testWidgets('a product list link carries its title and section', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      await _go(t, c, Routes.productsFor(title: 'Popular Picks', section: 'popular'));
      expect(find.text('Popular Picks'), findsWidgets);
      expect(find.text('Search in Popular Picks...'), findsOneWidget);
    });

    testWidgets('an unknown order link shows that the order was not found', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      await _go(t, c, Routes.orderFor('NOPE'));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Order not found'), findsOneWidget);
    });

    testWidgets('the order success link reads the id from the address', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      await _go(t, c, Routes.orderSuccessFor('FH77'));
      expect(find.text('Order #FH77'), findsOneWidget);
      await t.pump(const Duration(seconds: 4));
    });

    testWidgets('signing out sends the customer to login', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      await c.read(authSessionProvider.notifier).signOut();
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(_where(c), Routes.login);
    });

    testWidgets('signing in from the login page lands on Home', (t) async {
      final c = await _app(t, onboardingSeen: true);
      expect(_where(c), Routes.login);
      c
          .read(authSessionProvider.notifier)
          .signIn(const AppUser(phone: '9876543210', name: 'Rahul Kumar'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(_where(c), Routes.home);
    });
  });

  group('back button on the tabs', () {
    testWidgets('from another tab it goes back to Home', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      await t.tap(_tab('Orders'));
      await t.pump(const Duration(milliseconds: 600));
      expect(_where(c), Routes.orders);

      await t.binding.handlePopRoute();
      await t.pump(const Duration(milliseconds: 600));
      expect(_where(c), Routes.home);
    });

    testWidgets('on Home it asks before closing the app, and Stay keeps it open', (t) async {
      final c = await _app(t, signedIn: true, onboardingSeen: true);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.text('Exit app?'), findsOneWidget);
      expect(find.text('Are you sure you want to close Fresh Hen?'), findsOneWidget);
      // Staying is the main button.
      expect(find.widgetWithText(FilledButton, 'Stay'), findsOneWidget);

      await t.tap(find.text('Stay'));
      await t.pumpAndSettle();
      expect(find.text('Exit app?'), findsNothing);
      expect(_where(c), Routes.home);
    });

    testWidgets('Exit closes the app', (t) async {
      final closed = <String>[];
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
        call,
      ) async {
        if (call.method == 'SystemNavigator.pop') closed.add(call.method);
        return null;
      });
      addTearDown(
        () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await _app(t, signedIn: true, onboardingSeen: true);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      await t.tap(find.text('Exit'));
      await t.pumpAndSettle();
      expect(closed, ['SystemNavigator.pop']);
    });
  });

  group('the app shell', () {
    testWidgets('has the app title, no debug banner and the light theme', (t) async {
      await _app(t, signedIn: true, onboardingSeen: true);
      final app = t.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.debugShowCheckedModeBanner, isFalse);
      expect(app.title, isNotEmpty);
      expect(app.theme?.brightness, Brightness.light);
    });

    testWidgets('a white strip is kept clear at the bottom of every screen', (t) async {
      await _app(t, signedIn: true, onboardingSeen: true);
      expect(
        find.byWidgetPredicate((w) => w is AnnotatedRegion<SystemUiOverlayStyle>),
        findsWidgets,
      );
    });
  });
}
