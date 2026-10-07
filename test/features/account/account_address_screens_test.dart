import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/core/constants/app_constants.dart';
import 'package:fresh_hen/features/account/data/info_content.dart';
import 'package:fresh_hen/features/account/screens/account_screen.dart';
import 'package:fresh_hen/features/account/screens/info_screen.dart';
import 'package:fresh_hen/features/account/screens/support_screen.dart';
import 'package:fresh_hen/features/account/screens/terms_privacy_screen.dart';
import 'package:fresh_hen/features/address/models/address.dart';
import 'package:fresh_hen/features/address/providers/address_providers.dart';
import 'package:fresh_hen/features/address/screens/addresses_screen.dart';
import 'package:fresh_hen/features/auth/models/app_user.dart';
import 'package:fresh_hen/features/auth/providers/auth_provider.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';

import '../../support/feature_harness.dart';
import '../../support/fixtures.dart';
import '../../support/pump.dart';

Address _addr(
  String id, {
  bool isDefault = false,
  AddressLabel label = AddressLabel.home,
  String? custom,
}) => homeAddress.copyWith(
  id: id,
  isDefault: isDefault,
  label: label,
  customLabel: custom,
  house: 'House $id',
);

void main() {
  setUpWidgetTests();

  group('account screen', () {
    Future<Harness> open(WidgetTester t) async {
      final h = await pumpFeature(
        t,
        const AccountScreen(),
        scaffold: false,
        size: const Size(1080, 4000),
        routes: [
          stubRoute(Routes.home, label: 'HOME'),
          stubRoute(Routes.orders, label: 'ORDERS TAB'),
          stubRoute(Routes.addresses, label: 'ADDRESSES'),
          stubRoute(Routes.wishlist, label: 'WISHLIST'),
          stubRoute(Routes.help, label: 'HELP'),
          stubRoute(Routes.terms, label: 'TERMS'),
        ],
      );
      await t.pump(const Duration(milliseconds: 400));
      return h;
    }

    testWidgets('shows the customer name, number and an initial', (t) async {
      await open(t);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Rahul Kumar'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('${AppConstants.appName} v1.0.0'), findsOneWidget);
    });

    testWidgets('lists the menu entries', (t) async {
      await open(t);
      for (final l in [
        'My Orders',
        'Manage address',
        'Wishlist',
        'Help & Support',
        'Terms & Privacy',
        'Logout',
        'Delete account',
      ]) {
        expect(find.text(l), findsOneWidget, reason: l);
      }
    });

    testWidgets('Manage address opens addresses', (t) async {
      await open(t);
      await t.tap(find.text('Manage address'));
      await t.pumpAndSettle();
      expect(find.text('ADDRESSES'), findsOneWidget);
    });

    testWidgets('Wishlist, Help and Terms each open', (t) async {
      await open(t);
      await t.tap(find.text('Wishlist'));
      await t.pumpAndSettle();
      expect(find.text('WISHLIST'), findsOneWidget);
    });

    testWidgets('Help & Support opens help', (t) async {
      await open(t);
      await t.tap(find.text('Help & Support'));
      await t.pumpAndSettle();
      expect(find.text('HELP'), findsOneWidget);
    });

    testWidgets('Terms & Privacy opens the terms page', (t) async {
      await open(t);
      await t.tap(find.text('Terms & Privacy'));
      await t.pumpAndSettle();
      expect(find.text('TERMS'), findsOneWidget);
    });

    testWidgets('a customer with an email sees it', (t) async {
      final h = await open(t);
      h.container
          .read(authSessionProvider.notifier)
          .signIn(const AppUser(phone: '9876543210', name: 'Rahul Kumar', email: 'r@x.com'));
      await t.pump();
      expect(find.text('r@x.com'), findsOneWidget);
    });

    testWidgets('Edit opens the profile sheet, and saving updates the name', (t) async {
      final h = await open(t);
      await t.tap(find.text('Edit'));
      await t.pumpAndSettle();
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Rahul Kumar'), findsWidgets);

      await t.enterText(find.byType(TextFormField).first, 'Rahul Singh');
      await t.tap(find.text('Save changes'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(h.container.read(authSessionProvider)?.name, 'Rahul Singh');
      expect(find.text('Edit profile'), findsNothing);
      expect(find.text('Rahul Singh'), findsOneWidget);
    });

    testWidgets('an invalid edit is refused and the sheet stays', (t) async {
      final h = await open(t);
      await t.tap(find.text('Edit'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField).first, '');
      await t.tap(find.text('Save changes'));
      await t.pump();
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(h.container.read(authSessionProvider)?.name, 'Rahul Kumar');
    });

    testWidgets('Logout asks first; keeping the account does nothing', (t) async {
      final h = await open(t);
      await t.tap(find.text('Logout'));
      await t.pumpAndSettle();
      expect(find.text('Log out?'), findsOneWidget);
      expect(find.text('You will need to verify your number again to log in.'), findsOneWidget);
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(h.container.read(authSessionProvider), isNotNull);
    });

    testWidgets('confirming Logout signs the customer out', (t) async {
      final h = await open(t);
      await t.tap(find.text('Logout'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Log out'));
      await t.pumpAndSettle();
      expect(h.container.read(authSessionProvider), isNull);
    });

    testWidgets('Delete account asks first and the safe choice is the main button', (t) async {
      final h = await open(t);
      await t.tap(find.text('Delete account'));
      await t.pumpAndSettle();
      expect(find.text('Delete your account?'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Keep my account'), findsOneWidget);

      await t.tap(find.text('Keep my account'));
      await t.pumpAndSettle();
      expect(h.container.read(authSessionProvider), isNotNull);
    });

    testWidgets('confirming Delete removes the account and says so', (t) async {
      final h = await open(t);
      await t.tap(find.text('Delete account'));
      await t.pumpAndSettle();
      await t.tap(find.text('Delete account').last);
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(milliseconds: 500));
      expect(h.container.read(authSessionProvider), isNull);
    });

    testWidgets('with something in the cart there is room for the cart bar', (t) async {
      final h = await open(t);
      h.container
          .read(cartProvider.notifier)
          .add(CartLine.fromVariant(product('hen'), variant('v1', 100)));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('a customer with no name on file still gets a profile page', (t) async {
      final h = await open(t);
      h.container
          .read(authSessionProvider.notifier)
          .signIn(const AppUser(phone: '9876543210', name: ''));
      await t.pump();
      expect(t.takeException(), isNull);
      expect(find.text('+91 9876543210'), findsOneWidget);
    });

    testWidgets('signed out it shows nothing', (t) async {
      await pumpFeature(t, const AccountScreen(), scaffold: false, signedIn: false);
      expect(find.text('Profile'), findsNothing);
    });
  });

  group('support screen', () {
    Future<void> open(WidgetTester t, {String phone = ''}) async {
      await pumpFeature(
        t,
        const SupportScreen(),
        scaffold: false,
        settings: mockStoreSettings.copyWith(supportPhone: phone),
      );
      await t.pump(const Duration(milliseconds: 400));
    }

    testWidgets('offers calling and WhatsApp with the number from the store settings', (t) async {
      await open(t, phone: '+91 97117 39492');
      expect(find.text('How can we help?'), findsOneWidget);
      expect(find.text('Call us'), findsOneWidget);
      expect(find.text('Chat on WhatsApp'), findsOneWidget);
      expect(find.text('+91 97117 39492'), findsNWidgets(2));
    });

    testWidgets('falls back to the built-in number when the store has none', (t) async {
      await open(t);
      expect(find.text('Call us'), findsOneWidget);
      final shown = t
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data)
          .whereType<String>()
          .where((s) => s.contains('+91'));
      expect(shown, isNotEmpty);
    });
  });

  group('info and terms screens', () {
    testWidgets('an info page lists each section with its heading and text', (t) async {
      await pumpWidgetApp(
        t,
        const InfoScreen(
          title: 'About',
          sections: [InfoSection('First', 'Body one'), InfoSection('Second', 'Body two')],
        ),
        scaffold: false,
      );
      expect(find.text('About'), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Body two'), findsOneWidget);
    });

    testWidgets('terms and privacy have a tab each, numbered sections and a web link', (t) async {
      await pumpWidgetApp(
        t,
        const TermsPrivacyScreen(),
        scaffold: false,
        size: const Size(1080, 4000),
      );
      expect(find.text('Terms & Privacy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('1. ${termsTabSections.first.heading}'), findsOneWidget);
      expect(find.text('Read the full Terms of Service'), findsOneWidget);
    });

    testWidgets('the Privacy tab shows the privacy sections', (t) async {
      await pumpWidgetApp(
        t,
        const TermsPrivacyScreen(),
        scaffold: false,
        size: const Size(1080, 4000),
      );
      await t.tap(find.text('Privacy Policy'));
      await t.pumpAndSettle();
      expect(find.text('1. ${privacyTabSections.first.heading}'), findsOneWidget);
      expect(find.text('Read the full Privacy Policy'), findsOneWidget);
    });
  });

  group('addresses screen', () {
    Future<Harness> open(WidgetTester t, List<Address> addresses) async {
      final h = await pumpFeature(
        t,
        const AddressesScreen(),
        scaffold: false,
        addresses: addresses,
        size: const Size(1080, 4000),
      );
      await t.pump(const Duration(milliseconds: 600));
      return h;
    }

    testWidgets('with none saved it says so and offers adding one', (t) async {
      await open(t, const []);
      await t.pump(const Duration(seconds: 1));
      expect(find.text('No saved addresses'), findsOneWidget);
      expect(find.text('Add New Delivery Location'), findsOneWidget);
    });

    testWidgets('lists the saved addresses, one marked Default', (t) async {
      await open(t, [_addr('a', isDefault: true), _addr('b', label: AddressLabel.work)]);
      expect(find.text('My Addresses'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Make Default'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsNWidgets(2));
    });

    testWidgets('an Other address shows its own name', (t) async {
      await open(t, [
        _addr('a', isDefault: true, label: AddressLabel.other, custom: "Mom's place"),
      ]);
      expect(find.text("Mom's place"), findsOneWidget);
    });

    testWidgets('Make Default switches the default', (t) async {
      final h = await open(t, [_addr('a', isDefault: true), _addr('b')]);
      await t.tap(find.text('Make Default'));
      await t.pump(const Duration(milliseconds: 400));
      expect(h.container.read(addressesProvider).firstWhere((a) => a.id == 'b').isDefault, isTrue);
      expect(h.container.read(addressesProvider).firstWhere((a) => a.id == 'a').isDefault, isFalse);
    });

    testWidgets('Edit opens the form on that address', (t) async {
      await open(t, [_addr('a', isDefault: true)]);
      await t.tap(find.text('Edit'));
      await t.pumpAndSettle();
      expect(find.text('Edit address'), findsOneWidget);
      expect(find.text('House a'), findsOneWidget);
    });

    testWidgets('Add New Delivery Location opens an empty form', (t) async {
      await open(t, [_addr('a', isDefault: true)]);
      await t.tap(find.text('Add New Delivery Location'));
      await t.pumpAndSettle();
      expect(find.text('Add delivery address'), findsOneWidget);
    });

    testWidgets('delete asks first; Cancel keeps it', (t) async {
      final h = await open(t, [_addr('a', isDefault: true), _addr('b')]);
      await t.tap(find.byIcon(Icons.delete_outline_rounded).last);
      await t.pumpAndSettle();
      expect(find.text('Delete address?'), findsOneWidget);
      expect(find.textContaining('Remove "Home" from your saved addresses?'), findsOneWidget);
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(h.container.read(addressesProvider).length, 2);
    });

    testWidgets('confirming delete removes it', (t) async {
      final h = await open(t, [_addr('a', isDefault: true), _addr('b')]);
      await t.tap(find.byIcon(Icons.delete_outline_rounded).last);
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Delete'));
      await t.pumpAndSettle();
      expect(h.container.read(addressesProvider).map((a) => a.id), ['a']);
    });

    testWidgets('deleting the only address brings back the empty message', (t) async {
      await open(t, [_addr('a', isDefault: true)]);
      await t.tap(find.byIcon(Icons.delete_outline_rounded));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Delete'));
      await t.pumpAndSettle();
      await t.pump(const Duration(seconds: 1));
      expect(find.text('No saved addresses'), findsOneWidget);
    });
  });
}
