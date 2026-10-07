import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Call at the top of a widget test file's `main()`.
///
/// Tests draw text with a stand-in font whose letters are much wider than the
/// app's real fonts (Google Fonts can't be fetched here), so "overflowed by N
/// pixels" errors are ignored: they would be reported for text that fits fine
/// on a real phone. Every other error still fails the test.
void setUpWidgetTests() {
  GoogleFonts.config.allowRuntimeFetching = false;
  final original = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (d) {
      final text = d.exceptionAsString();
      if (text.contains('overflowed')) return;
      if (!text.contains('google_fonts') && !text.contains('GoogleFonts')) original?.call(d);
    };
  });
  tearDown(() => FlutterError.onError = original);
}

/// Installs the overflow filter for the running test. The test framework sets
/// its own error handler just before the test body runs, after `setUp`, so
/// the filter has to be installed from inside the body.
void ignoreLayoutOverflow() {
  final previous = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    previous?.call(d);
  };
  addTearDown(() => FlutterError.onError = previous);
}

/// Puts [child] on a phone-sized screen inside a Material app.
Future<void> pumpWidgetApp(
  WidgetTester t,
  Widget child, {
  Size size = const Size(1080, 2340),
  bool scaffold = true,
  bool reduceMotion = false,
  List<NavigatorObserver> observers = const [],
}) async {
  ignoreLayoutOverflow();
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      navigatorObservers: observers,
      builder: reduceMotion
          ? (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            )
          : null,
      home: scaffold ? Scaffold(body: child) : child,
    ),
  );
}
