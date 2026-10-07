import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/widgets/add_control.dart';
import 'package:fresh_hen/core/widgets/animated_rupees.dart';
import 'package:fresh_hen/core/widgets/pop_on_change.dart';
import 'package:fresh_hen/core/widgets/press_scale.dart';
import 'package:fresh_hen/core/widgets/staggered_fade_in.dart';

import '../support/pump.dart';

void main() {
  setUpWidgetTests();

  group('AddControl', () {
    Widget control({
      int quantity = 0,
      bool available = true,
      AddControlStyle style = AddControlStyle.pill,
      List<String>? log,
    }) =>
        AddControl(
          quantity: quantity,
          available: available,
          style: style,
          onAdd: () => log?.add('add'),
          onIncrement: () => log?.add('inc'),
          onDecrement: () => log?.add('dec'),
        );

    testWidgets('with nothing in the cart it offers Add', (t) async {
      final log = <String>[];
      await pumpWidgetApp(t, control(log: log));
      expect(find.text('Add'), findsOneWidget);
      await t.tap(find.text('Add'));
      expect(log, ['add']);
    });

    testWidgets('a sold-out item cannot be added', (t) async {
      final log = <String>[];
      await pumpWidgetApp(t, control(available: false, log: log));
      expect(find.text('Sold out'), findsOneWidget);
      expect(find.text('Add'), findsNothing);
      await t.tap(find.text('Sold out'), warnIfMissed: false);
      expect(log, isEmpty);
    });

    testWidgets('the round style adds with the plus button, and is disabled when sold out', (t) async {
      final log = <String>[];
      await pumpWidgetApp(t, control(style: AddControlStyle.round, log: log));
      await t.tap(find.byIcon(Icons.add_rounded));
      expect(log, ['add']);

      log.clear();
      await pumpWidgetApp(t, control(style: AddControlStyle.round, available: false, log: log));
      await t.tap(find.byIcon(Icons.add_rounded), warnIfMissed: false);
      expect(log, isEmpty);
    });

    testWidgets('once added it becomes a stepper showing the quantity', (t) async {
      final log = <String>[];
      await pumpWidgetApp(t, control(quantity: 2, log: log));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Add'), findsNothing);

      await t.tap(find.byIcon(Icons.add_rounded));
      await t.tap(find.byIcon(Icons.remove_rounded));
      expect(log, ['inc', 'dec']);
    });

    testWidgets('swaps between Add and the stepper as the quantity changes', (t) async {
      await pumpWidgetApp(t, control(quantity: 0));
      expect(find.text('Add'), findsOneWidget);
      await pumpWidgetApp(t, control(quantity: 1));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Add'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('QtyStepper and QtyCount', () {
    testWidgets('the light look still works and shows its count', (t) async {
      var up = 0;
      await pumpWidgetApp(
        t,
        QtyStepper(quantity: 3, light: true, onIncrement: () => up++, onDecrement: () {}),
      );
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('3'), findsOneWidget);
      await t.tap(find.byIcon(Icons.add_rounded));
      expect(up, 1);
    });

    testWidgets('the number changes when the quantity does', (t) async {
      Widget stepper(int q) => QtyStepper(quantity: q, onIncrement: () {}, onDecrement: () {});
      await pumpWidgetApp(t, stepper(1));
      await t.pump(const Duration(milliseconds: 500));
      await pumpWidgetApp(t, stepper(2));
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('with reduced motion the number is plain text', (t) async {
      await pumpWidgetApp(t, const QtyCount(quantity: 4, style: TextStyle()), reduceMotion: true);
      expect(find.text('4'), findsOneWidget);
      expect(find.byType(AnimatedSwitcher), findsNothing);
    });
  });

  group('PressScale', () {
    double scaleOf(WidgetTester t) => t.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

    testWidgets('shrinks while pressed and returns on release', (t) async {
      await pumpWidgetApp(t, const Center(child: PressScale(scale: 0.9, child: SizedBox(width: 100, height: 100))));
      expect(scaleOf(t), 1);

      final gesture = await t.startGesture(t.getCenter(find.byType(PressScale)));
      await t.pump();
      expect(scaleOf(t), 0.9);

      await gesture.up();
      await t.pump();
      expect(scaleOf(t), 1);
    });

    testWidgets('lets go as soon as the finger starts dragging', (t) async {
      await pumpWidgetApp(t, const Center(child: PressScale(scale: 0.9, child: SizedBox(width: 100, height: 100))));
      final gesture = await t.startGesture(t.getCenter(find.byType(PressScale)));
      await t.pump();
      expect(scaleOf(t), 0.9);
      await gesture.moveBy(const Offset(0, 40));
      await t.pump();
      expect(scaleOf(t), 1);
      await gesture.up();
    });

    testWidgets('does nothing when disabled or when animations are off', (t) async {
      await pumpWidgetApp(t, const PressScale(enabled: false, child: Text('x')));
      expect(find.byType(AnimatedScale), findsNothing);
      await pumpWidgetApp(t, const PressScale(child: Text('x')), reduceMotion: true);
      expect(find.byType(AnimatedScale), findsNothing);
    });

    testWidgets("the child's own tap still works", (t) async {
      var taps = 0;
      await pumpWidgetApp(t, PressScale(child: ElevatedButton(onPressed: () => taps++, child: const Text('Go'))));
      await t.tap(find.text('Go'));
      expect(taps, 1);
    });
  });

  group('PopOnChange', () {
    double scaleOf(WidgetTester t) => t
        .widget<ScaleTransition>(
          find.descendant(of: find.byType(PopOnChange), matching: find.byType(ScaleTransition)),
        )
        .scale
        .value;

    testWidgets('grows briefly when the value changes, then settles', (t) async {
      Widget badge(int v) => PopOnChange(value: v, child: Text('$v'));
      await pumpWidgetApp(t, badge(1));
      expect(scaleOf(t), 1);

      await pumpWidgetApp(t, badge(2));
      await t.pump(const Duration(milliseconds: 100));
      expect(scaleOf(t), greaterThan(1.05));

      await t.pump(const Duration(seconds: 2));
      expect(scaleOf(t), closeTo(1, 0.001));
    });

    testWidgets('stays still when the value is unchanged or animations are off', (t) async {
      await pumpWidgetApp(t, const PopOnChange(value: 1, child: Text('1')));
      await pumpWidgetApp(t, const PopOnChange(value: 1, child: Text('1')));
      await t.pump(const Duration(milliseconds: 100));
      expect(scaleOf(t), 1);

      await pumpWidgetApp(t, const PopOnChange(value: 1, child: Text('a')), reduceMotion: true);
      await pumpWidgetApp(t, const PopOnChange(value: 2, child: Text('a')), reduceMotion: true);
      await t.pump(const Duration(milliseconds: 100));
      expect(scaleOf(t), 1);
    });
  });

  group('AnimatedRupees', () {
    testWidgets('shows the amount at once the first time', (t) async {
      await pumpWidgetApp(t, const AnimatedRupees(1250));
      await t.pump();
      expect(find.text('₹1,250'), findsOneWidget);
    });

    testWidgets('counts to a new amount, ending exactly on it', (t) async {
      await pumpWidgetApp(t, const AnimatedRupees(100));
      await t.pump();
      await pumpWidgetApp(t, const AnimatedRupees(500));
      await t.pump(const Duration(milliseconds: 150));
      final midway = (t.widget<Text>(find.byType(Text)).data!).replaceAll(RegExp('[^0-9]'), '');
      expect(int.parse(midway), inInclusiveRange(101, 499));

      await t.pump(const Duration(seconds: 1));
      expect(find.text('₹500'), findsOneWidget);
    });

    testWidgets('takes a prefix, and jumps straight there with reduced motion', (t) async {
      await pumpWidgetApp(t, const AnimatedRupees(50, prefix: '- '));
      await t.pump();
      expect(find.text('- ₹50'), findsOneWidget);

      await pumpWidgetApp(t, const AnimatedRupees(10), reduceMotion: true);
      await pumpWidgetApp(t, const AnimatedRupees(99), reduceMotion: true);
      await t.pump();
      expect(find.text('₹99'), findsOneWidget);
    });
  });

  group('StaggeredFadeIn', () {
    double opacityOf(WidgetTester t) =>
        t.widget<Opacity>(find.descendant(of: find.byType(StaggeredFadeIn), matching: find.byType(Opacity))).opacity;

    testWidgets('an early item starts hidden and fades in', (t) async {
      await pumpWidgetApp(t, const StaggeredFadeIn(index: 0, child: Text('first')));
      expect(opacityOf(t), 0);
      await t.pump(const Duration(seconds: 1));
      expect(opacityOf(t), 1);
    });

    testWidgets('a later item waits for the ones before it', (t) async {
      await pumpWidgetApp(t, const StaggeredFadeIn(index: 5, child: Text('sixth')));
      await t.pump(const Duration(milliseconds: 100));
      expect(opacityOf(t), 0); // its turn has not come yet
      await t.pump(const Duration(seconds: 2));
      expect(opacityOf(t), 1);
    });

    testWidgets('items past the limit, and reduced motion, appear at once', (t) async {
      await pumpWidgetApp(t, const StaggeredFadeIn(index: 8, child: Text('ninth')));
      expect(opacityOf(t), 1);
      await pumpWidgetApp(t, const StaggeredFadeIn(index: 0, child: Text('x')), reduceMotion: true);
      expect(opacityOf(t), 1);
    });

    testWidgets('the limit can be raised', (t) async {
      await pumpWidgetApp(t, const StaggeredFadeIn(index: 8, maxAnimated: 20, child: Text('ninth')));
      expect(opacityOf(t), 0);
      await t.pump(const Duration(seconds: 3));
      expect(opacityOf(t), 1);
    });
  });
}
