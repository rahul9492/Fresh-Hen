import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/widgets/brand_refresh.dart';

Widget _app(Future<void> Function() onRefresh) => MaterialApp(
      home: Scaffold(
        body: BrandRefresh(
          onRefresh: onRefresh,
          child: ListView(
            children: [for (var i = 0; i < 20; i++) SizedBox(height: 60, child: Text('row $i'))],
          ),
        ),
      ),
    );

/// Drags the list down by [distance] and lets go, like a finger pulling to refresh.
Future<void> _pull(WidgetTester t, double distance) async {
  final gesture = await t.startGesture(t.getCenter(find.text('row 0')));
  for (var i = 0; i < 10; i++) {
    await gesture.moveBy(Offset(0, distance / 10));
    await t.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  // The list springs back over a few frames; the refresh starts as it does.
  for (var i = 0; i < 15; i++) {
    await t.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('a long pull refreshes once, shows the indicator, and ends when the work does', (t) async {
    var calls = 0;
    final done = Completer<void>();
    await t.pumpWidget(_app(() {
      calls++;
      return done.future;
    }));

    await _pull(t, 400);
    expect(calls, 1);
    expect(find.byIcon(Icons.egg_alt_rounded), findsOneWidget);

    // Still loading: another pull does not start a second refresh.
    await _pull(t, 400);
    expect(calls, 1);

    done.complete();
    await t.pumpAndSettle();
    expect(find.text('row 0'), findsOneWidget);
  });

  testWidgets('a short pull springs back without refreshing', (t) async {
    var calls = 0;
    await t.pumpWidget(_app(() async => calls++));

    final gesture = await t.startGesture(t.getCenter(find.text('row 0')));
    await gesture.moveBy(const Offset(0, 40));
    await t.pump();
    await gesture.up();
    await t.pumpAndSettle();
    expect(calls, 0);
  });
}
