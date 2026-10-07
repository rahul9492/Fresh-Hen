import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/features/account/widgets/menu_group.dart';
import 'package:fresh_hen/features/address/models/address.dart';
import 'package:fresh_hen/features/address/providers/address_providers.dart';
import 'package:fresh_hen/features/address/repositories/address_repository.dart';
import 'package:fresh_hen/features/address/widgets/address_form_sheet.dart';
import 'package:fresh_hen/features/address/widgets/address_picker_sheet.dart';
import 'package:fresh_hen/features/auth/widgets/otp_field.dart';
import 'package:fresh_hen/features/auth/widgets/profile_form.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';

import '../../support/feature_harness.dart';
import '../../support/pump.dart';

class _RejectingAddresses extends FakeAddresses {
  _RejectingAddresses(super.list);

  @override
  Future<Address> create(Address address) async => throw Exception('server said no');
}

Address _addr(String id, {String pincode = '201301', bool isDefault = false, AddressLabel label = AddressLabel.home}) =>
    homeAddress.copyWith(id: id, pincode: pincode, isDefault: isDefault, label: label, house: 'House $id');

Future<Harness> _openForm(
  WidgetTester t, {
  Address? existing,
  List<Address> addresses = const [],
  void Function(Address?)? onResult,
  AddressRepository? repo,
}) async {
  final h = await pumpFeature(
    t,
    Builder(
      builder: (c) => TextButton(
        onPressed: () async {
          final saved = await showAddressFormSheet(c, existing: existing);
          onResult?.call(saved);
        },
        child: const Text('open'),
      ),
    ),
    addresses: addresses,
    addressRepo: repo,
  );
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
  return h;
}

Finder _field(int i) => find.byType(TextFormField).at(i);

Future<void> _fill(WidgetTester t, {String house = 'Flat 1', String area = 'Sector 62', String city = 'Noida', String pin = '201301'}) async {
  await t.enterText(_field(0), house);
  await t.enterText(_field(1), area);
  await t.enterText(_field(3), city);
  await t.enterText(_field(4), pin);
  await t.pump();
}

void main() {
  setUpWidgetTests();

  group('address form', () {
    testWidgets('a complete address is saved, selected, and closes the sheet', (t) async {
      Address? result;
      final h = await _openForm(t, onResult: (a) => result = a);
      expect(find.text('Add delivery address'), findsOneWidget);
      await _fill(t);

      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();

      expect(result?.house, 'Flat 1');
      expect(result?.pincode, '201301');
      expect(result?.name, 'Rahul Kumar');
      expect(result?.phone, '9876543210');
      expect(h.container.read(addressesProvider).single.house, 'Flat 1');
      expect(h.container.read(selectedAddressProvider)?.house, 'Flat 1');
      expect(find.text('Add delivery address'), findsNothing);
    });

    testWidgets('required fields are checked before saving', (t) async {
      Address? result;
      final h = await _openForm(t, onResult: (a) => result = a);

      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();

      expect(find.text('Enter your house or flat number'), findsOneWidget);
      expect(find.text('Enter your area or street'), findsOneWidget);
      expect(find.text('Enter your city'), findsOneWidget);
      expect(find.text('Enter a valid pincode'), findsOneWidget);
      expect(find.text('Add delivery address'), findsOneWidget); // still open
      expect(h.container.read(addressesProvider), isEmpty);
      expect(result, isNull);
    });

    testWidgets('a one-letter value does not count as an entry', (t) async {
      await _openForm(t);
      await _fill(t, house: 'A', area: 'B', city: 'C');
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(find.text('Enter your house or flat number'), findsOneWidget);
      expect(find.text('Enter your city'), findsOneWidget);
    });

    testWidgets('the pincode accepts only six digits that do not start with zero', (t) async {
      await _openForm(t);
      await t.enterText(_field(4), '20a13b01xyz99');
      await t.pump();
      expect(t.widget<TextFormField>(_field(4)).controller!.text, '201301');

      await t.enterText(_field(4), '012345');
      await t.pump();
      expect(find.text('Enter a valid pincode'), findsOneWidget);

      await t.enterText(_field(4), '2013');
      await t.pump();
      expect(find.text('Enter a valid pincode'), findsOneWidget);

      await t.enterText(_field(4), '201301');
      await t.pump();
      expect(find.text('Enter a valid pincode'), findsNothing);
    });

    testWidgets('an area we do not serve shows the message and blocks saving', (t) async {
      final h = await _openForm(t);
      await _fill(t, pin: '110001');
      expect(find.text("We don't deliver here yet"), findsOneWidget);

      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(h.container.read(addressesProvider), isEmpty);
      expect(find.text('Add delivery address'), findsOneWidget);
    });

    testWidgets('every served pincode is accepted', (t) async {
      await _openForm(t);
      for (final pin in mockStoreSettings.deliveryPincodes) {
        await t.enterText(_field(4), pin);
        await t.pump();
        expect(find.text("We don't deliver here yet"), findsNothing, reason: pin);
      }
    });

    testWidgets('the receiver is one line when the profile is complete, with Edit to change it', (t) async {
      await _openForm(t);
      expect(find.textContaining('Receiver:', findRichText: true), findsOneWidget);
      expect(find.textContaining('Rahul Kumar, +91 9876543210', findRichText: true), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));

      await t.tap(find.text('Edit'));
      await t.pump();
      expect(find.byType(TextFormField), findsNWidgets(7)); // name and phone appear
    });

    testWidgets('a changed receiver is saved with the address', (t) async {
      Address? result;
      await _openForm(t, onResult: (a) => result = a);
      await t.tap(find.text('Edit'));
      await t.pump();
      await t.enterText(_field(5), 'Asha Devi');
      await t.enterText(_field(6), '9000000001');
      await _fill(t);
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.name, 'Asha Devi');
      expect(result?.phone, '9000000001');
    });

    testWidgets('the label can be Home, Work or Other with its own name', (t) async {
      Address? result;
      await _openForm(t, onResult: (a) => result = a);
      await _fill(t);

      await t.tap(find.text('Work'));
      await t.pump();
      expect(find.text('Save as'), findsNothing);

      await t.tap(find.text('Other'));
      await t.pump();
      expect(find.text('Save as'), findsOneWidget);
      await t.enterText(find.byType(TextFormField).last, "Mom's place");

      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.label, AddressLabel.other);
      expect(result?.customLabel, "Mom's place");
      expect(result?.title, "Mom's place");
    });

    testWidgets('a Work address does not keep a custom name', (t) async {
      Address? result;
      await _openForm(t, onResult: (a) => result = a);
      await _fill(t);
      await t.tap(find.text('Other'));
      await t.pump();
      await t.enterText(find.byType(TextFormField).last, 'Gym');
      await t.tap(find.text('Work'));
      await t.pump();
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.label, AddressLabel.work);
      expect(result?.customLabel, isNull);
    });

    testWidgets('the first address is always the default and the box is locked', (t) async {
      Address? result;
      await _openForm(t, onResult: (a) => result = a);
      expect(find.text('Default address (your first address)'), findsOneWidget);
      expect(t.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
      await _fill(t);
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.isDefault, isTrue);
    });

    testWidgets('a later address can be made the default', (t) async {
      Address? result;
      final h = await _openForm(t, addresses: [_addr('a', isDefault: true)], onResult: (a) => result = a);
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text('Make this my default address'), findsOneWidget);

      await t.tap(find.text('Make this my default address'));
      await t.pump();
      expect(t.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      await _fill(t);
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();

      expect(result?.isDefault, isTrue);
      expect(h.container.read(addressesProvider).where((a) => a.isDefault).length, 1);
    });

    testWidgets('a later address is not the default unless chosen', (t) async {
      Address? result;
      await _openForm(t, addresses: [_addr('a', isDefault: true)], onResult: (a) => result = a);
      await t.pump(const Duration(milliseconds: 100));
      await _fill(t);
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.isDefault, isFalse);
    });

    testWidgets('editing starts from the saved address and keeps its id', (t) async {
      Address? result;
      final existing = _addr('keep', isDefault: true, label: AddressLabel.work);
      final h = await _openForm(t, existing: existing, addresses: [existing], onResult: (a) => result = a);
      await t.pump(const Duration(milliseconds: 100));

      expect(find.text('Edit address'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('House keep'), findsOneWidget);

      await t.enterText(_field(0), 'New house');
      await t.tap(find.text('Save changes'));
      await t.pumpAndSettle();

      expect(result?.id, 'keep');
      expect(result?.house, 'New house');
      expect(result?.label, AddressLabel.work);
      expect(h.container.read(addressesProvider).single.house, 'New house');
    });

    testWidgets('a server rejection shows an error and keeps the sheet open', (t) async {
      final h = await _openForm(
        t,
        repo: _RejectingAddresses(const []),
      );
      await _fill(t);
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();

      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
      expect(find.text('Add delivery address'), findsOneWidget);
      expect(h.container.read(addressesProvider), isEmpty);
    });

    testWidgets('values are trimmed', (t) async {
      Address? result;
      await _openForm(t, onResult: (a) => result = a);
      await _fill(t, house: '  Flat 9  ', area: ' Sector 62 ', city: ' Noida ');
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.house, 'Flat 9');
      expect(result?.area, 'Sector 62');
      expect(result?.city, 'Noida');
    });
  });

  group('address picker', () {
    Future<Harness> open(WidgetTester t, {List<Address>? addresses, StoreSettingsOverride? settings}) async {
      final h = await pumpFeature(
        t,
        Builder(builder: (c) => TextButton(onPressed: () => showAddressPickerSheet(c), child: const Text('open'))),
        addresses: addresses ?? [_addr('a', isDefault: true), _addr('b', label: AddressLabel.work)],
        settings: settings?.call(),
      );
      await t.pump(const Duration(milliseconds: 100));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      return h;
    }

    testWidgets('lists the saved addresses, marks the default and the selected one', (t) async {
      await open(t);
      expect(find.text('Select delivery address'), findsOneWidget);
      expect(find.text('House a'), findsNothing); // the line carries it
      expect(find.textContaining('House a'), findsOneWidget);
      expect(find.textContaining('House b'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_off_rounded), findsOneWidget);
      expect(find.text('Rahul • +91 9876543210'), findsNWidgets(2));
    });

    testWidgets('picking one selects it and closes the sheet', (t) async {
      final h = await open(t);
      await t.tap(find.textContaining('House b'));
      await t.pumpAndSettle();
      expect(h.container.read(selectedAddressIdProvider), 'b');
      expect(find.text('Select delivery address'), findsNothing);
    });

    testWidgets('an address outside the delivery area cannot be picked', (t) async {
      final h = await open(
        t,
        addresses: [_addr('a', isDefault: true), _addr('far', pincode: '110001')],
      );
      expect(find.text("We don't deliver to 110001 yet"), findsOneWidget);
      await t.tap(find.textContaining('House far'));
      await t.pumpAndSettle();
      expect(h.container.read(selectedAddressIdProvider), 'a');
      expect(find.text('Select delivery address'), findsOneWidget);
    });

    testWidgets('Add new address opens the form, and a saved one closes both sheets', (t) async {
      final h = await open(t);
      await t.tap(find.text('Add new address'));
      await t.pumpAndSettle();
      expect(find.text('Add delivery address'), findsOneWidget);

      await _fill(t, house: 'Brand new');
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(find.text('Select delivery address'), findsNothing);
      expect(h.container.read(addressesProvider).any((a) => a.house == 'Brand new'), isTrue);
    });

    testWidgets('the pencil edits that address', (t) async {
      await open(t);
      await t.tap(find.byTooltip('Edit address').first);
      await t.pumpAndSettle();
      expect(find.text('Edit address'), findsOneWidget);
    });

    testWidgets('the label icons match the labels', (t) async {
      expect(addressIcon(AddressLabel.home), Icons.home_rounded);
      expect(addressIcon(AddressLabel.work), Icons.work_rounded);
      expect(addressIcon(AddressLabel.other), Icons.place_rounded);
    });
  });

  group('OtpField', () {
    testWidgets('shows one box per digit, empty at first', (t) async {
      await pumpWidgetApp(t, OtpField(onChanged: (_) {}));
      // Four boxes, each an empty dot; the one being typed into shows a caret instead.
      expect(find.byIcon(Icons.circle).evaluate().length, inInclusiveRange(3, 4));
    });

    testWidgets('typing fills the boxes and reports each change', (t) async {
      final seen = <String>[];
      await pumpWidgetApp(t, OtpField(onChanged: seen.add));
      await t.enterText(find.byType(TextField), '12');
      await t.pump();
      expect(seen, ['12']);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await t.enterText(find.byType(TextField), '1234');
      await t.pump();
      expect(seen.last, '1234');
      expect(find.byIcon(Icons.circle), findsNothing);
    });

    testWidgets('only digits are accepted, and no more than the length', (t) async {
      final seen = <String>[];
      await pumpWidgetApp(t, OtpField(onChanged: seen.add));
      await t.enterText(find.byType(TextField), '1a2b3c4d5e6');
      await t.pump();
      expect(seen.last, '1234');
    });

    testWidgets('a different length changes the number of boxes', (t) async {
      await pumpWidgetApp(t, OtpField(length: 6, onChanged: (_) {}));
      expect(find.byIcon(Icons.circle).evaluate().length, inInclusiveRange(5, 6));
    });

    testWidgets('tapping the boxes brings up the keyboard', (t) async {
      await pumpWidgetApp(t, OtpField(onChanged: (_) {}));
      final shown = <String>[];
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.textInput, (call) async {
        shown.add(call.method);
        return null;
      });
      addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.textInput, null));
      await t.tap(find.byType(OtpField));
      await t.pump();
      expect(shown, contains('TextInput.show'));
    });
  });

  group('ProfileForm', () {
    Widget form({String? name, String? email, bool loading = false, void Function(String, String?)? onSubmit}) =>
        SingleChildScrollView(
          child: ProfileForm(
            submitLabel: 'Save',
            loading: loading,
            initialName: name,
            initialEmail: email,
            onSubmit: onSubmit ?? (_, _) {},
          ),
        );

    testWidgets('starts with the details it is given', (t) async {
      await pumpWidgetApp(t, form(name: 'Rahul Kumar', email: 'r@x.com'));
      expect(find.text('Rahul Kumar'), findsOneWidget);
      expect(find.text('r@x.com'), findsOneWidget);
    });

    testWidgets('a name is required', (t) async {
      String? sent;
      await pumpWidgetApp(t, form(onSubmit: (n, _) => sent = n));
      await t.tap(find.text('Save'));
      await t.pump();
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(sent, isNull);
    });

    testWidgets('a short name and a bad email are refused', (t) async {
      String? sent;
      await pumpWidgetApp(t, form(onSubmit: (n, _) => sent = n));
      await t.enterText(find.byType(TextFormField).first, 'A');
      await t.enterText(find.byType(TextFormField).last, 'not-an-email');
      await t.tap(find.text('Save'));
      await t.pump();
      expect(find.text('Name is too short'), findsOneWidget);
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(sent, isNull);
    });

    testWidgets('a valid form is sent trimmed; the email can be left empty', (t) async {
      String? name;
      String? email = 'unset';
      await pumpWidgetApp(t, form(onSubmit: (n, e) {
        name = n;
        email = e;
      }));
      await t.enterText(find.byType(TextFormField).first, '  Rahul Kumar ');
      await t.tap(find.text('Save'));
      await t.pump();
      expect(name, 'Rahul Kumar');
      expect(email, isEmpty);

      await t.enterText(find.byType(TextFormField).last, ' r@x.com ');
      await t.tap(find.text('Save'));
      await t.pump();
      expect(email, 'r@x.com');
    });

    testWidgets('the keyboard Done on the email field submits', (t) async {
      String? name;
      await pumpWidgetApp(t, form(onSubmit: (n, _) => name = n));
      await t.enterText(find.byType(TextFormField).first, 'Rahul Kumar');
      await t.enterText(find.byType(TextFormField).last, 'r@x.com');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pump();
      expect(name, 'Rahul Kumar');
    });

    testWidgets('while saving, the button shows a spinner and cannot be pressed twice', (t) async {
      var sends = 0;
      await pumpWidgetApp(t, form(name: 'Rahul Kumar', loading: true, onSubmit: (_, _) => sends++));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await t.tap(find.byType(FilledButton), warnIfMissed: false);
      expect(sends, 0);
    });
  });

  group('MenuGroup', () {
    testWidgets('shows each row and runs the tapped one', (t) async {
      final tapped = <String>[];
      await pumpWidgetApp(
        t,
        MenuGroup(items: [
          MenuItem(icon: Icons.person, label: 'Profile', onTap: () => tapped.add('profile')),
          MenuItem(icon: Icons.help, label: 'Help', onTap: () => tapped.add('help')),
          MenuItem(icon: Icons.logout, label: 'Log out', color: Colors.red, showChevron: false, onTap: () => tapped.add('out')),
        ]),
      );
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2)); // not on the last

      await t.tap(find.text('Help'));
      await t.tap(find.text('Log out'));
      expect(tapped, ['help', 'out']);
    });

    testWidgets('a coloured row is bold and uses that colour', (t) async {
      await pumpWidgetApp(
        t,
        MenuGroup(items: [
          MenuItem(icon: Icons.logout, label: 'Log out', color: Colors.red, onTap: () {}),
        ]),
      );
      final text = t.widget<Text>(find.text('Log out'));
      expect(text.style?.color, Colors.red);
      expect(text.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('a single row has no divider', (t) async {
      await pumpWidgetApp(t, MenuGroup(items: [MenuItem(icon: Icons.person, label: 'Profile', onTap: () {})]));
      expect(find.byType(Divider), findsNothing);
    });
  });
}

typedef StoreSettingsOverride = dynamic Function();
