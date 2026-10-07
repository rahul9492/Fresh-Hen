import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:fresh_hen/features/address/widgets/address_form_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The pincode error must follow the value as it is edited: it appears for an
/// area the shop doesn't serve and clears as soon as a served pincode is typed.
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  final original = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (d) {
      final text = d.exceptionAsString();
      if (!text.contains('overflowed') && !text.contains('google_fonts')) original?.call(d);
    };
  });
  tearDown(() => FlutterError.onError = original);

  Future<void> openForm(WidgetTester t, {double width = 1080}) async {
    t.view.physicalSize = Size(width, 2340);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    SharedPreferences.setMockInitialValues({
      'auth.users': '{"9876543210":{"phone":"9876543210","name":"Rahul","email":null}}',
      'auth.session_phone': '9876543210',
    });
    final prefs = await SharedPreferences.getInstance();
    await t.pumpWidget(ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const MaterialApp(home: Scaffold(body: AddressFormSheet())),
    ));
    // Let the delivery area load.
    await t.pump(const Duration(seconds: 2));
  }

  Finder pincodeField() => find.byType(TextFormField).at(4);

  testWidgets('the unserved-pincode error clears once a served pincode is entered', (t) async {
    await openForm(t);

    await t.enterText(pincodeField(), '222222');
    await t.pump();
    expect(find.text("We don't deliver here yet"), findsOneWidget);

    await t.enterText(pincodeField(), '201301');
    await t.pump();
    expect(find.text("We don't deliver here yet"), findsNothing);
  });

  testWidgets('the error stays on a single line on a narrow phone', (t) async {
    await openForm(t, width: 960); // a 320dp-wide screen
    await t.enterText(pincodeField(), '222222');
    await t.pump();

    final message = find.text("We don't deliver here yet");
    expect(message, findsOneWidget);
    // Shrunk to fit by a FittedBox, not wrapped onto a second line.
    expect(find.ancestor(of: message, matching: find.byType(FittedBox)), findsOneWidget);
    final height = t.getSize(message).height;
    expect(height, lessThan(20));
  });
}
