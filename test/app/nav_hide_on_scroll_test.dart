import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/app.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The bottom tabs slide away while scrolling down a tab and come back on
/// scrolling up, so lists get the whole screen.
void main() {
  final original = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) original?.call(d);
    };
  });
  GoogleFonts.config.allowRuntimeFetching = false;

  double navHeight(WidgetTester t) => t.getSize(find.byType(SizeTransition).last).height;

  testWidgets('bottom tabs hide on scroll down and return on scroll up', (t) async {
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
    expect(find.text('Popular Picks'), findsOneWidget);

    final shown = navHeight(t);
    expect(shown, greaterThan(40));

    // Scroll Home down: the tabs slide away.
    final home = find.byType(CustomScrollView).first;
    await t.drag(home, const Offset(0, -300));
    await t.pumpAndSettle();
    expect(navHeight(t), lessThan(1));

    // Scroll back up a little: they come back.
    await t.drag(home, const Offset(0, 120));
    await t.pumpAndSettle();
    expect(navHeight(t), closeTo(shown, 0.5));

    // Hidden again, then back at the top of the page they always show.
    await t.drag(home, const Offset(0, -300));
    await t.pumpAndSettle();
    expect(navHeight(t), lessThan(1));
    await t.drag(home, const Offset(0, 2000)); // back to the top
    await t.pumpAndSettle();
    expect(navHeight(t), closeTo(shown, 0.5));
  });
}
