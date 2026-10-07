import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/widgets/animated_nav_icon.dart';
import 'package:fresh_hen/core/widgets/auth_scaffold.dart';
import 'package:fresh_hen/core/widgets/brand_badge.dart';
import 'package:fresh_hen/core/widgets/celebration.dart';
import 'package:fresh_hen/core/widgets/fly_to_cart.dart';
import 'package:fresh_hen/core/widgets/image_upload_button.dart';
import 'package:fresh_hen/core/widgets/lottie_nav_icon.dart';
import 'package:fresh_hen/core/widgets/product_hero.dart';
import 'package:fresh_hen/core/widgets/scroll_fade_away.dart';
import 'package:fresh_hen/core/widgets/shimmer_box.dart';

import '../support/pump.dart';

void main() {
  setUpWidgetTests();

  group('shimmer placeholders', () {
    testWidgets('a shimmer box keeps its size and animates without settling', (t) async {
      await pumpWidgetApp(t, const Center(child: ShimmerBox(width: 120, height: 20)));
      expect(t.getSize(find.byType(ShimmerBox)), const Size(120, 20));
      await t.pump(const Duration(milliseconds: 600)); // mid sweep: still fine
      expect(find.byType(ShimmerBox), findsOneWidget);
    });

    testWidgets('a shimmer list shows the requested number of rows', (t) async {
      await pumpWidgetApp(t, const ShimmerList(itemCount: 3, itemHeight: 60));
      expect(find.byType(ShimmerBox), findsNWidgets(3));
    });

    testWidgets('the order skeleton and list render their rows', (t) async {
      await pumpWidgetApp(t, const SizedBox(height: 900, child: OrderListSkeleton(itemCount: 2)));
      expect(find.byType(OrderCardSkeleton), findsNWidgets(2));
      expect(find.byType(ShimmerBox), findsWidgets);
    });

    testWidgets('the skeleton list cannot be scrolled', (t) async {
      await pumpWidgetApp(t, const ShimmerList(itemCount: 20));
      final list = t.widget<ListView>(find.byType(ListView));
      expect(list.physics, isA<NeverScrollableScrollPhysics>());
    });
  });

  group('ImageUploadButton', () {
    Widget button({
      bool loading = false,
      bool showCamera = true,
      bool Function()? beforePick,
      List<String>? log,
    }) =>
        ImageUploadButton(
          label: 'Upload Screenshot',
          loading: loading,
          showCamera: showCamera,
          beforePick: beforePick,
          onImage: (_) => log?.add('image'),
        );

    testWidgets('shows its label and a camera button', (t) async {
      await pumpWidgetApp(t, button());
      expect(find.text('Upload Screenshot'), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
      expect(find.byTooltip('Take a photo'), findsOneWidget);
    });

    testWidgets('the camera part can be left out', (t) async {
      await pumpWidgetApp(t, button(showCamera: false));
      expect(find.byIcon(Icons.photo_camera_outlined), findsNothing);
    });

    testWidgets('while uploading it shows a spinner and both parts are disabled', (t) async {
      await pumpWidgetApp(t, button(loading: true));
      expect(find.text('Upload Screenshot'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      expect(t.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed, isNull);
    });

    testWidgets('a long label shrinks instead of being cut off', (t) async {
      await pumpWidgetApp(
        t,
        const SizedBox(
          width: 200,
          child: ImageUploadButton(label: 'Upload a very long screenshot name', onImage: _ignore),
        ),
      );
      expect(find.ancestor(of: find.textContaining('very long'), matching: find.byType(FittedBox)), findsOneWidget);
    });

    testWidgets('the button is the standard height', (t) async {
      await pumpWidgetApp(t, button());
      expect(t.getSize(find.byType(FilledButton)).height, ImageUploadButton.height);
    });

    testWidgets('when the caller says no (beforePick), the picker never opens', (t) async {
      var asked = 0;
      final log = <String>[];
      await pumpWidgetApp(t, button(beforePick: () => ++asked == 0, log: log));
      await t.tap(find.text('Upload Screenshot'));
      await t.pump();
      await t.tap(find.byIcon(Icons.photo_camera_outlined));
      await t.pump();
      expect(asked, 2);
      expect(log, isEmpty);
      expect(find.byType(CircularProgressIndicator), findsNothing); // never went busy
    });
  });

  group('celebration', () {
    testWidgets('shows its banner over the page, then removes itself', (t) async {
      late BuildContext ctx;
      await pumpWidgetApp(t, Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }));
      final shown = showCelebration(ctx, title: 'Coupon applied!', subtitle: 'You saved ₹50');
      expect(shown, isTrue);
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('Coupon applied!'), findsOneWidget);
      expect(find.text('You saved ₹50'), findsOneWidget);

      await t.pump(const Duration(seconds: 4));
      expect(find.text('Coupon applied!'), findsNothing);
    });

    testWidgets('the subtitle is optional', (t) async {
      late BuildContext ctx;
      await pumpWidgetApp(t, Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }));
      showCelebration(ctx, title: 'Done');
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('Done'), findsOneWidget);
      await t.pump(const Duration(seconds: 4));
    });

    testWidgets('with reduced motion nothing is shown, so the caller can use a snackbar', (t) async {
      late BuildContext ctx;
      await pumpWidgetApp(
        t,
        Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
        reduceMotion: true,
      );
      expect(showCelebration(ctx, title: 'Done'), isFalse);
      await t.pump();
      expect(find.text('Done'), findsNothing);
    });
  });

  group('fly to cart', () {
    testWidgets('does nothing when no cart bar is on the page', (t) async {
      late BuildContext ctx;
      await pumpWidgetApp(t, Builder(builder: (c) {
        ctx = c;
        return const SizedBox(width: 10, height: 10);
      }));
      final before = Overlay.of(ctx);
      flyToCart(ctx, 'assets/x.png');
      await t.pump();
      expect(before, isNotNull);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('with a registered cart bar, a small copy flies and then goes away', (t) async {
      late BuildContext ctx;
      final key = GlobalKey();
      await pumpWidgetApp(
        t,
        Column(children: [
          Builder(builder: (c) {
            ctx = c;
            return const SizedBox(width: 30, height: 30);
          }),
          SizedBox(key: key, width: 20, height: 20),
        ]),
      );
      final target = (bar: ctx, thumbs: key);
      registerCartFlyTarget(target);
      addTearDown(() => unregisterCartFlyTarget(target));

      flyToCart(ctx, 'assets/missing.png');
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byType(Image), findsOneWidget);

      await t.pump(const Duration(seconds: 2));
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('does nothing with reduced motion', (t) async {
      late BuildContext ctx;
      final key = GlobalKey();
      await pumpWidgetApp(
        t,
        Column(children: [
          Builder(builder: (c) {
            ctx = c;
            return const SizedBox(width: 30, height: 30);
          }),
          SizedBox(key: key, width: 20, height: 20),
        ]),
        reduceMotion: true,
      );
      final target = (bar: ctx, thumbs: key);
      registerCartFlyTarget(target);
      addTearDown(() => unregisterCartFlyTarget(target));
      flyToCart(ctx, 'assets/missing.png');
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byType(Image), findsNothing);
    });
  });

  group('navigation icons', () {
    double scale(WidgetTester t) => t
        .widget<ScaleTransition>(find.descendant(of: find.byType(AnimatedNavIcon), matching: find.byType(ScaleTransition)))
        .scale
        .value;

    testWidgets('the selected icon pops once and settles at its normal size', (t) async {
      await pumpWidgetApp(t, const AnimatedNavIcon(Icons.home));
      await t.pump(const Duration(milliseconds: 120));
      expect(scale(t), lessThan(1));
      await t.pump(const Duration(milliseconds: 600));
      expect(scale(t), closeTo(1, 0.001));
    });

    testWidgets('with reduced motion it just sits there', (t) async {
      await pumpWidgetApp(t, const AnimatedNavIcon(Icons.home), reduceMotion: true);
      await t.pump(const Duration(milliseconds: 120));
      expect(scale(t), 1);
    });

    testWidgets('an animation file that cannot load falls back to the simple icon', (t) async {
      await pumpWidgetApp(t, const LottieNavIcon('assets/lottie/missing.json', fallback: Icons.home_rounded));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });
  });

  group('product hero', () {
    testWidgets('wraps the picture in a Hero with the given tag and corners', (t) async {
      await pumpWidgetApp(t, const ProductHero(tag: 'p1', source: 'assets/x.png', radius: 18, width: 64, height: 64));
      expect(t.widget<Hero>(find.byType(Hero)).tag, 'p1');
      expect(t.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius, BorderRadius.circular(18));
    });

    testWidgets('flies between two pages and lands without errors', (t) async {
      final nav = GlobalKey<NavigatorState>();
      t.view.physicalSize = const Size(1080, 2340);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        navigatorKey: nav,
        home: const Scaffold(body: Align(alignment: Alignment.topLeft, child: ProductHero(tag: 'p', source: 'a.png', radius: 8, width: 60, height: 60))),
      ));
      nav.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: ProductHero(tag: 'p', source: 'a.png', radius: 24, width: 300, height: 300))),
      ));
      await t.pump();
      await t.pump(const Duration(milliseconds: 150)); // mid flight
      expect(find.byType(Hero), findsWidgets);
      await t.pumpAndSettle();

      nav.currentState!.pop();
      await t.pumpAndSettle();
      expect(find.byType(ProductHero), findsOneWidget);
    });
  });

  group('scroll fade away', () {
    testWidgets('shows its child inside a scrollable, and as-is outside of one', (t) async {
      await pumpWidgetApp(t, const ScrollFadeAway(child: Text('banner')));
      expect(find.text('banner'), findsOneWidget);

      await pumpWidgetApp(
        t,
        ListView(children: const [ScrollFadeAway(child: SizedBox(height: 200, child: Text('banner'))), SizedBox(height: 2000)]),
      );
      expect(find.text('banner'), findsOneWidget);
    });

    testWidgets('fades out as the page scrolls it away', (t) async {
      await pumpWidgetApp(
        t,
        ListView(children: const [ScrollFadeAway(child: SizedBox(height: 200, child: Text('banner'))), SizedBox(height: 3000)]),
      );
      double opacity() => t.widgetList<Opacity>(find.descendant(of: find.byType(ScrollFadeAway), matching: find.byType(Opacity))).first.opacity;
      expect(opacity(), 1);
      await t.drag(find.byType(ListView), const Offset(0, -150));
      await t.pump();
      expect(opacity(), lessThan(1));
    });

    testWidgets('does nothing with reduced motion', (t) async {
      await pumpWidgetApp(
        t,
        ListView(children: const [ScrollFadeAway(child: SizedBox(height: 200, child: Text('banner'))), SizedBox(height: 3000)]),
        reduceMotion: true,
      );
      await t.drag(find.byType(ListView), const Offset(0, -150));
      await t.pump();
      expect(find.descendant(of: find.byType(ScrollFadeAway), matching: find.byType(Opacity)), findsNothing);
    });
  });

  group('AuthScaffold', () {
    testWidgets('shows the badge, title, subtitle, content and terms', (t) async {
      await pumpWidgetApp(
        t,
        const AuthScaffold(title: 'Welcome', subtitle: 'Enter your number', child: Text('FORM')),
        scaffold: false,
      );
      expect(find.byType(BrandBadge), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Enter your number'), findsOneWidget);
      expect(find.text('FORM'), findsOneWidget);
      expect(find.textContaining('Terms of Service', findRichText: true), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
    });

    testWidgets('the badge can be hidden', (t) async {
      await pumpWidgetApp(
        t,
        const AuthScaffold(title: 'T', subtitle: 'S', showBadge: false, child: SizedBox()),
        scaffold: false,
      );
      expect(find.byType(BrandBadge), findsNothing);
    });

    testWidgets('the back button goes to the previous page', (t) async {
      await pumpWidgetApp(
        t,
        Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const AuthScaffold(title: 'Step 2', subtitle: 's', showBack: true, child: SizedBox()),
              )),
              child: const Text('next'),
            ),
          ),
        ),
      );
      await t.tap(find.text('next'));
      await t.pumpAndSettle();
      expect(find.text('Step 2'), findsOneWidget);
      await t.tap(find.byIcon(Icons.chevron_left_rounded));
      await t.pumpAndSettle();
      expect(find.text('Step 2'), findsNothing);
      expect(find.text('next'), findsOneWidget);
    });
  });
}

void _ignore(Object _) {}
