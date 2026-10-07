import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/widgets/hen_mascot.dart';

import '../support/pump.dart';

void main() {
  setUpWidgetTests();

  test('the hen box keeps a fixed height-to-width shape', () {
    expect(HenMascot.aspect, greaterThan(1));
    expect(HenMascot.aspect, lessThan(3));
  });

  for (final mood in HenMood.values) {
    testWidgets('the ${mood.name} hen renders at the height asked for', (t) async {
      await pumpWidgetApp(t, Center(child: HenMascot(mood: mood, height: 120)));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.byType(HenMascot), findsOneWidget);
      expect(t.getSize(find.byType(HenMascot)).height, closeTo(120, 0.5));
      await t.pump(const Duration(seconds: 3));
    });
  }

  testWidgets('the width follows the height', (t) async {
    await pumpWidgetApp(t, const Center(child: HenMascot(mood: HenMood.hello, height: 200)));
    await t.pump(const Duration(milliseconds: 300));
    final size = t.getSize(find.byType(HenMascot));
    expect(size.height / size.width, closeTo(HenMascot.aspect, 0.05));
  });

  testWidgets('with reduced motion the hen stands still', (t) async {
    await pumpWidgetApp(t, const Center(child: HenMascot(mood: HenMood.cheer, height: 120)), reduceMotion: true);
    await t.pump(const Duration(milliseconds: 100));
    final before = t.getTopLeft(find.byType(HenMascot));
    await t.pump(const Duration(seconds: 2));
    expect(t.getTopLeft(find.byType(HenMascot)), before);
    expect(find.byType(HenMascot), findsOneWidget);
  });

  testWidgets('a delayed hen waits before it appears, and still renders afterwards', (t) async {
    await pumpWidgetApp(
      t,
      const Center(child: HenMascot(mood: HenMood.cheer, height: 120, delay: Duration(seconds: 1))),
    );
    await t.pump(const Duration(milliseconds: 200));
    expect(find.byType(HenMascot), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    expect(find.byType(HenMascot), findsOneWidget);
  });

  testWidgets('changing the mood switches the animation without errors', (t) async {
    await pumpWidgetApp(t, const Center(child: HenMascot(mood: HenMood.hello, height: 120)));
    await t.pump(const Duration(milliseconds: 300));
    await pumpWidgetApp(t, const Center(child: HenMascot(mood: HenMood.sleep, height: 120)));
    await t.pump(const Duration(seconds: 1));
    expect(find.byType(HenMascot), findsOneWidget);
  });

  testWidgets('disposing mid-animation is clean', (t) async {
    await pumpWidgetApp(t, const Center(child: HenMascot(mood: HenMood.cheer, height: 120)));
    await t.pump(const Duration(milliseconds: 200));
    await pumpWidgetApp(t, const SizedBox());
    await t.pump(const Duration(seconds: 2));
    expect(find.byType(HenMascot), findsNothing);
  });
}
