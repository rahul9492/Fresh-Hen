import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/widgets/animated_rupees.dart';
import 'package:fresh_hen/core/widgets/celebration.dart';
import 'package:fresh_hen/core/widgets/staggered_fade_in.dart';
import 'package:fresh_hen/core/widgets/press_scale.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  celebrationAndStaggerTests();
  testWidgets('AnimatedRupees shows the first amount at once, then counts to a new one', (t) async {
    await t.pumpWidget(_app(const AnimatedRupees(100)));
    expect(find.text('₹100'), findsOneWidget);

    await t.pumpWidget(_app(const AnimatedRupees(600)));
    await t.pump(const Duration(milliseconds: 200));
    final mid = tester(t);
    expect(mid, inInclusiveRange(101, 599)); // on its way

    await t.pumpAndSettle();
    expect(find.text('₹600'), findsOneWidget);
  });

  testWidgets('AnimatedRupees keeps the prefix, e.g. a minus for a discount', (t) async {
    await t.pumpWidget(_app(const AnimatedRupees(50, prefix: '−')));
    expect(find.text('−₹50'), findsOneWidget);
  });

  testWidgets('PressScale shrinks while pressed and still lets the child be tapped', (t) async {
    var taps = 0;
    await t.pumpWidget(
      _app(
        PressScale(
          child: GestureDetector(
            onTap: () => taps++,
            child: const SizedBox(key: Key('target'), width: 100, height: 100, child: ColoredBox(color: Colors.red)),
          ),
        ),
      ),
    );
    double scale() => t.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    expect(scale(), 1);

    final gesture = await t.startGesture(t.getCenter(find.byKey(const Key('target'))));
    await t.pump();
    expect(scale(), lessThan(1));

    await gesture.up();
    await t.pumpAndSettle();
    expect(scale(), 1);
    expect(taps, 1);
  });

  testWidgets('PressScale lets go when the finger drags away', (t) async {
    await t.pumpWidget(
      _app(const PressScale(child: SizedBox(key: Key('target'), width: 100, height: 100, child: ColoredBox(color: Colors.red)))),
    );
    final gesture = await t.startGesture(t.getCenter(find.byKey(const Key('target'))));
    await t.pump();
    await gesture.moveBy(const Offset(0, 40));
    await t.pump();
    expect(t.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await gesture.up();
  });
}

/// The amount currently shown, read from the rendered text.
int tester(WidgetTester t) {
  final text = t.widget<Text>(find.byType(Text)).data!;
  return int.parse(text.replaceAll(RegExp(r'[^0-9]'), ''));
}

void celebrationAndStaggerTests() {
  testWidgets('StaggeredFadeIn: first items fade in one after another, later ones show at once', (t) async {
    await t.pumpWidget(
      _app(
        const Column(
          children: [
            StaggeredFadeIn(index: 0, child: Text('first')),
            StaggeredFadeIn(index: 3, child: Text('fourth')),
            StaggeredFadeIn(index: 20, child: Text('late')),
          ],
        ),
      ),
    );
    double opacityOf(String text) => t
        .widget<Opacity>(find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first)
        .opacity;

    expect(opacityOf('late'), 1); // past the animated range: no animation
    expect(opacityOf('fourth'), 0); // still waiting its turn
    await t.pump(const Duration(milliseconds: 120));
    expect(opacityOf('first'), greaterThan(0));
    expect(opacityOf('first'), lessThan(1));

    await t.pumpAndSettle();
    expect(opacityOf('first'), 1);
    expect(opacityOf('fourth'), 1);
  });

  testWidgets('showCelebration shows the banner, then removes itself', (t) async {
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold();
          },
        ),
      ),
    );
    expect(showCelebration(ctx, title: 'CODE applied!', subtitle: 'You saved ₹50'), isTrue);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('CODE applied!'), findsOneWidget);
    expect(find.text('You saved ₹50'), findsOneWidget);

    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('CODE applied!'), findsNothing);
  });

  testWidgets('showCelebration does nothing when animations are off', (t) async {
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (c) {
              ctx = c;
              return const Scaffold();
            },
          ),
        ),
      ),
    );
    expect(showCelebration(ctx, title: 'x'), isFalse);
  });
}
