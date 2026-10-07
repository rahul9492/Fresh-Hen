import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/features/address/models/address.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';
import 'package:fresh_hen/features/catalog/providers/catalog_providers.dart';
import 'package:fresh_hen/features/home/widgets/category_strip.dart';
import 'package:fresh_hen/features/home/widgets/home_header.dart';
import 'package:fresh_hen/features/home/widgets/promo_carousel.dart';

import '../../support/feature_harness.dart';
import '../../support/fixtures.dart';
import '../../support/pump.dart';

const _categories = [
  Category(id: 'chicken', name: 'Chicken', image: 'x'),
  Category(id: 'eggs', name: 'Eggs', image: 'y'),
  Category(id: 'fish', name: 'Fish', image: 'z'),
];

PromoBanner _banner(String title, {String category = 'chicken'}) => PromoBanner(
      eyebrow: 'FRESH',
      title: title,
      highlight: 'Delivered Daily',
      description: 'Straight from the farm.',
      image: 'img',
      categoryId: category,
    );

void main() {
  setUpWidgetTests();

  group('CategoryStrip', () {
    Widget strip({String? selected, List<String?>? log}) => CategoryStrip(
          categories: _categories,
          selectedId: selected,
          onSelected: (id) => log?.add(id),
        );

    testWidgets('shows All and every category', (t) async {
      await pumpWidgetApp(t, strip());
      for (final n in ['All', 'Chicken', 'Eggs', 'Fish']) {
        expect(find.text(n), findsOneWidget, reason: n);
      }
    });

    testWidgets('tapping a category reports its id, All reports null', (t) async {
      final log = <String?>[];
      await pumpWidgetApp(t, strip(log: log));
      await t.tap(find.text('Eggs'));
      await t.tap(find.text('All'));
      expect(log, ['eggs', null]);
    });

    testWidgets('the selected one is bold and underlined', (t) async {
      await pumpWidgetApp(t, strip(selected: 'eggs'));
      await t.pump(const Duration(milliseconds: 300));
      expect(t.widget<Text>(find.text('Eggs')).style?.fontWeight, FontWeight.w700);
      expect(t.widget<Text>(find.text('Fish')).style?.fontWeight, FontWeight.w500);

      final underlines = t.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
      final sizes = [for (var i = 0; i < underlines.length; i++) t.getSize(find.byType(AnimatedContainer).at(i)).width];
      expect(sizes.where((w) => w == 22).length, 1);
    });

    testWidgets('with nothing chosen, All is the selected one', (t) async {
      await pumpWidgetApp(t, strip());
      await t.pump(const Duration(milliseconds: 300));
      expect(t.widget<Text>(find.text('All')).style?.fontWeight, FontWeight.w700);
    });

    testWidgets('scrolls sideways when there are many categories', (t) async {
      await pumpWidgetApp(
        t,
        CategoryStrip(
          categories: [for (var i = 0; i < 12; i++) Category(id: 'c$i', name: 'Cat$i', image: 'x')],
          selectedId: null,
          onSelected: (_) {},
        ),
      );
      expect(find.text('Cat11'), findsNothing);
      await t.drag(find.byType(ListView), const Offset(-1500, 0));
      await t.pump();
      expect(find.text('Cat11'), findsOneWidget);
    });

    testWidgets('a long name is cut with an ellipsis rather than overflowing', (t) async {
      await pumpWidgetApp(
        t,
        CategoryStrip(
          categories: const [Category(id: 'long', name: 'Country Style Farm Fresh Hen', image: 'x')],
          selectedId: null,
          onSelected: (_) {},
        ),
      );
      final text = t.widget<Text>(find.text('Country Style Farm Fresh Hen'));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });

  group('HomeHeader', () {
    testWidgets('shows the brand and invites adding an address when there is none', (t) async {
      await pumpFeature(t, const HomeHeader(), addresses: const []);
      expect(find.textContaining('Fresh', findRichText: true), findsOneWidget);
      expect(find.text('Add delivery address'), findsOneWidget);
      expect(find.text('Tap to add where we should deliver'), findsOneWidget);
    });

    testWidgets('shows where the order will go', (t) async {
      await pumpFeature(t, const HomeHeader());
      await t.pump(const Duration(milliseconds: 200));
      expect(find.text('Deliver to Home'), findsOneWidget);
      expect(find.text(homeAddress.line), findsOneWidget);
    });

    testWidgets('an Other address shows its own name', (t) async {
      await pumpFeature(
        t,
        const HomeHeader(),
        addresses: [homeAddress.copyWith(label: AddressLabel.other, customLabel: "Mom's place")],
      );
      await t.pump(const Duration(milliseconds: 200));
      expect(find.text("Deliver to Mom's place"), findsOneWidget);
    });

    testWidgets('tapping the address opens the address list', (t) async {
      await pumpFeature(t, const HomeHeader(), routes: [stubRoute(Routes.addresses, label: 'ADDRESSES')]);
      await t.tap(find.text('Add delivery address').evaluate().isEmpty ? find.text('Deliver to Home') : find.text('Add delivery address'));
      await t.pumpAndSettle();
      expect(find.text('ADDRESSES'), findsOneWidget);
    });

    testWidgets('the cart button opens the cart and shows how many are in it', (t) async {
      final h = await pumpFeature(t, const HomeHeader(), routes: [stubRoute(Routes.cart, label: 'CART')]);
      expect(t.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);

      h.container.read(cartProvider.notifier).add(
            CartLine.fromVariant(product('hen'), variant('v1', 100)).copyWith(quantity: 3),
          );
      await t.pump(const Duration(milliseconds: 500));
      expect(t.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
      expect(find.text('3'), findsOneWidget);

      await t.tap(find.byIcon(Icons.shopping_cart_outlined));
      await t.pumpAndSettle();
      expect(find.text('CART'), findsOneWidget);
    });
  });

  group('HomeSearchRow', () {
    testWidgets('tapping the search bar opens search', (t) async {
      await pumpFeature(t, const HomeSearchRow(), routes: [stubRoute(Routes.search, label: 'SEARCH')]);
      await t.tap(find.text('Search...'));
      await t.pumpAndSettle();
      expect(find.text('SEARCH'), findsOneWidget);
    });

    testWidgets('the filter button opens the filter sheet, and applying it opens search', (t) async {
      await pumpFeature(
        t,
        const HomeSearchRow(),
        routes: [stubRoute(Routes.search, label: 'SEARCH')],
        overrides: [categoriesProvider.overrideWith((ref) async => _categories)],
      );
      await t.tap(find.byIcon(Icons.tune_rounded));
      await t.pumpAndSettle();
      expect(find.text('Filters'), findsOneWidget);

      await t.tap(find.text('Show results'));
      await t.pumpAndSettle();
      expect(find.text('SEARCH'), findsOneWidget);
    });

    testWidgets('closing the filter sheet without applying stays on Home', (t) async {
      await pumpFeature(
        t,
        const HomeSearchRow(),
        routes: [stubRoute(Routes.search, label: 'SEARCH')],
        overrides: [categoriesProvider.overrideWith((ref) async => _categories)],
      );
      await t.tap(find.byIcon(Icons.tune_rounded));
      await t.pumpAndSettle();
      await t.tapAt(const Offset(5, 5));
      await t.pumpAndSettle();
      expect(find.text('SEARCH'), findsNothing);
    });
  });

  group('pinned search header', () {
    Widget page({double lead = 0}) => CustomScrollView(
          slivers: [
            if (lead > 0) SliverToBoxAdapter(child: SizedBox(height: lead, child: const Text('logo'))),
            const SliverPersistentHeader(pinned: true, delegate: HomeSearchPinnedDelegate()),
            SliverList.builder(itemCount: 30, itemBuilder: (_, i) => SizedBox(height: 80, child: Text('row $i'))),
          ],
        );

    BoxShadow? shadowNow(WidgetTester t) {
      final box = t.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration as BoxDecoration;
      return box.boxShadow?.firstOrNull;
    }

    testWidgets('has the search bar height and no shadow at rest', (t) async {
      await pumpFeature(t, page());
      expect(t.getSize(find.byType(HomeSearchRow)).height, 48);
      expect(shadowNow(t), isNull);
    });

    testWidgets('a shadow appears once content scrolls under it', (t) async {
      await pumpFeature(t, page());
      await t.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await t.pump(const Duration(milliseconds: 300));
      expect(shadowNow(t), isNotNull);
    });

    testWidgets('on Home, where the logo scrolls away first, the shadow waits until the bar is at the top', (t) async {
      await pumpFeature(t, page(lead: 120));
      await t.drag(find.byType(CustomScrollView), const Offset(0, -60));
      await t.pump(const Duration(milliseconds: 300));
      expect(shadowNow(t), isNull); // the logo is still partly on screen above the bar

      await t.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await t.pump(const Duration(milliseconds: 300));
      expect(shadowNow(t), isNotNull);
    });

    testWidgets('the shadow goes away again at the top of the page', (t) async {
      await pumpFeature(t, page(lead: 120));
      await t.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await t.pump(const Duration(milliseconds: 300));
      expect(shadowNow(t), isNotNull);
      await t.drag(find.byType(CustomScrollView), const Offset(0, 800));
      await t.pump(const Duration(milliseconds: 300));
      expect(shadowNow(t), isNull);
    });

    test('its size never changes', () {
      const delegate = HomeSearchPinnedDelegate();
      expect(delegate.minExtent, delegate.maxExtent);
      expect(delegate.minExtent, HomeSearchPinnedDelegate.extent);
      expect(delegate.shouldRebuild(const HomeSearchPinnedDelegate()), isFalse);
    });
  });

  group('PromoCarousel', () {
    testWidgets('shows the first banner and one dot per banner', (t) async {
      await pumpFeature(t, PromoCarousel(banners: [_banner('Fresh Chicken'), _banner('Farm Eggs')]));
      expect(find.text('Fresh Chicken'), findsOneWidget);
      expect(find.text('Order Now'), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsNWidgets(2));
    });

    testWidgets('swiping moves to the next banner and its dot', (t) async {
      await pumpFeature(t, PromoCarousel(banners: [_banner('Fresh Chicken'), _banner('Farm Eggs')]));
      await t.drag(find.byType(PageView), const Offset(-500, 0));
      await t.pumpAndSettle();
      expect(find.text('Farm Eggs'), findsOneWidget);

      final widths = [for (var i = 0; i < 2; i++) t.getSize(find.byType(AnimatedContainer).at(i)).width];
      expect(widths, [13, 24]); // dot width plus its margins
    });

    testWidgets('advances by itself every four seconds, and loops back', (t) async {
      await pumpFeature(t, PromoCarousel(banners: [_banner('One'), _banner('Two')]));
      expect(find.text('One'), findsOneWidget);
      await t.pump(const Duration(seconds: 4));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Two'), findsOneWidget);
      await t.pump(const Duration(seconds: 4));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('One'), findsOneWidget);
    });

    testWidgets('it pauses while a finger is down, and resumes afterwards', (t) async {
      await pumpFeature(t, PromoCarousel(banners: [_banner('One'), _banner('Two')]));
      final gesture = await t.startGesture(t.getCenter(find.byType(PageView)));
      await t.pump(const Duration(seconds: 6));
      expect(find.text('One'), findsOneWidget); // did not move while held

      await gesture.up();
      await t.pump(const Duration(seconds: 4));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('a single banner does not auto-scroll', (t) async {
      await pumpFeature(t, PromoCarousel(banners: [_banner('Only')]));
      await t.pump(const Duration(seconds: 9));
      expect(find.text('Only'), findsOneWidget);
    });

    testWidgets('Order Now opens that banner category', (t) async {
      await pumpFeature(
        t,
        PromoCarousel(banners: [_banner('Fresh Chicken', category: 'chicken')]),
        routes: [stubRoute(Routes.products, label: 'PRODUCTS')],
      );
      await t.tap(find.text('Order Now'));
      await t.pumpAndSettle();
      expect(find.text('PRODUCTS'), findsOneWidget);
    });

    testWidgets('disposing stops the timer without errors', (t) async {
      await pumpFeature(t, PromoCarousel(banners: [_banner('One'), _banner('Two')]));
      await pumpFeature(t, const SizedBox());
      await t.pump(const Duration(seconds: 10));
    });
  });
}
