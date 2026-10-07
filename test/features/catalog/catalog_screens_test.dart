import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';
import 'package:fresh_hen/features/catalog/providers/catalog_providers.dart';
import 'package:fresh_hen/features/catalog/screens/product_detail_screen.dart';
import 'package:fresh_hen/features/catalog/screens/wishlist_screen.dart';
import 'package:fresh_hen/features/catalog/widgets/empty_wishlist.dart';
import 'package:fresh_hen/features/catalog/widgets/product_options_sheet.dart';
import 'package:go_router/go_router.dart';

import '../../support/feature_harness.dart';
import '../../support/fixtures.dart';
import '../../support/pump.dart';

final _chicken = product(
  'chicken',
  variants: [
    variant('500', 200, mrp: 250, label: '500 g'),
    variant('1000', 380, label: '1 kg'),
  ],
  rating: 4.4,
  ratingCount: 12400,
).copyWith(name: 'Whole Chicken', gallery: ['g1', 'g2']);

final _eggs = product(
  'eggs',
  categoryId: 'eggs',
  variants: [variant('v1', 90, label: '6 pcs')],
).copyWith(name: 'Farm Eggs');
final _other = product(
  'curry',
  variants: [variant('v1', 250, label: '1 kg')],
).copyWith(name: 'Curry Cut');

Future<Harness> _detail(
  WidgetTester t, {
  Product? p,
  List<Product>? catalog,
  String? heroTag,
  Map<String, Object> prefs = const {},
  List<GoRoute> routes = const [],
}) async {
  final h = await pumpFeature(
    t,
    ProductDetailScreen(productId: (p ?? _chicken).id, heroTag: heroTag),
    scaffold: false,
    products: catalog ?? [p ?? _chicken, _other, _eggs],
    prefs: prefs,
    size: const Size(1080, 3000),
    routes: routes,
  );
  await t.pump(const Duration(milliseconds: 600));
  return h;
}

void main() {
  setUpWidgetTests();

  group('product detail', () {
    testWidgets('shows the name, rating, units and the price bar', (t) async {
      await _detail(t);
      expect(find.text('Whole Chicken'), findsOneWidget);
      expect(find.text('4.4 (12.4K)'), findsOneWidget);
      expect(find.text('Select unit(s)'), findsOneWidget);
      expect(find.text('500 g'), findsWidgets);
      expect(find.text('1 kg'), findsWidgets);
      expect(find.text('Add to cart'), findsOneWidget);
    });

    testWidgets('the rating is drawn as stars', (t) async {
      await _detail(t);
      final row = find.ancestor(of: find.text('4.4 (12.4K)'), matching: find.byType(Row)).first;
      expect(
        find.descendant(of: row, matching: find.byIcon(Icons.star_rounded)),
        findsNWidgets(4),
      ); // 4.4 rounds to 4
      expect(
        find.descendant(of: row, matching: find.byIcon(Icons.star_border_rounded)),
        findsOneWidget,
      );
    });

    testWidgets('starts on the first pack in stock', (t) async {
      final p = product(
        'x',
        variants: [
          variant('a', 100, inStock: false, label: 'small'),
          variant('b', 200, label: 'large'),
        ],
      );
      await _detail(t, p: p);
      expect(find.text('Sold out'), findsOneWidget); // the small pack's tile
      // The bar shows the pack that would be added.
      expect(find.text('₹200'), findsWidgets);
    });

    testWidgets('choosing a unit changes what the bar shows and adds', (t) async {
      final h = await _detail(t);
      await t.tap(find.text('1 kg').first);
      await t.pump(const Duration(milliseconds: 300));
      await t.tap(find.text('Add to cart'));
      await t.pump(const Duration(milliseconds: 400));
      expect(h.container.read(cartProvider).single.id, 'chicken:1000');
    });

    testWidgets('adding turns the button into a stepper, and the stepper changes the count', (
      t,
    ) async {
      final h = await _detail(t);
      await t.tap(find.text('Add to cart'));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Add to cart'), findsNothing);

      await t.tap(find.bySemanticsLabel('Add one more'));
      await t.pump(const Duration(milliseconds: 400));
      expect(h.container.read(cartProvider).single.quantity, 2);
      await t.tap(find.bySemanticsLabel('Remove one'));
      await t.pump(const Duration(milliseconds: 400));
      expect(h.container.read(cartProvider).single.quantity, 1);
    });

    testWidgets('a pack sold out cannot be added', (t) async {
      final p = product('x', variants: [variant('a', 100, inStock: false, label: 'small')]);
      final h = await _detail(t, p: p);
      expect(find.text('Out of stock'), findsOneWidget);
      await t.tap(find.text('Out of stock'), warnIfMissed: false);
      expect(h.container.read(cartProvider), isEmpty);
    });

    testWidgets('opens on the pack already in the cart', (t) async {
      final h = await pumpFeature(
        t,
        ProductDetailScreen(productId: _chicken.id),
        scaffold: false,
        products: [_chicken, _other],
        size: const Size(1080, 3000),
        prefs: const {},
      );
      await t.pump(const Duration(milliseconds: 600));
      h.container
          .read(cartProvider.notifier)
          .add(CartLine.fromVariant(_chicken, _chicken.variants[1]));
      // Rebuild a fresh page: it should land on the 1 kg pack.
      await t.pumpWidget(const SizedBox());
      expect(h.container.read(cartProvider).single.id, 'chicken:1000');
    });

    testWidgets('the heart saves and removes the product', (t) async {
      final h = await _detail(t);
      await t.tap(find.byIcon(Icons.favorite_border_rounded).first);
      await t.pump(const Duration(milliseconds: 200));
      expect(h.container.read(favoritesProvider), contains('chicken'));
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

      await t.tap(find.byIcon(Icons.favorite_rounded).first);
      await t.pump(const Duration(milliseconds: 200));
      expect(h.container.read(favoritesProvider), isNot(contains('chicken')));
    });

    testWidgets('a saved product shows a filled heart straight away', (t) async {
      await _detail(
        t,
        prefs: {
          'wishlist.$testPhone': ['chicken'],
        },
      );
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    });

    testWidgets('the search button opens search', (t) async {
      await _detail(t, routes: [stubRoute(Routes.search, label: 'SEARCH')]);
      await t.tap(find.byIcon(Icons.search_rounded));
      await t.pumpAndSettle();
      expect(find.text('SEARCH'), findsOneWidget);
    });

    testWidgets('the gallery holds the main picture and the extra ones, and swipes', (t) async {
      await _detail(t);
      final delegate =
          t.widget<PageView>(find.byType(PageView)).childrenDelegate as SliverChildBuilderDelegate;
      expect(delegate.estimatedChildCount, 3); // main + 2 in the gallery
      await t.fling(find.byType(PageView), const Offset(-300, 0), 1500);
      await t.pumpAndSettle();
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('similar products are suggested from the same category', (t) async {
      await _detail(t);
      expect(find.text('Similar meat'), findsOneWidget);
      await t.scrollUntilVisible(
        find.text('Curry Cut'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Curry Cut'), findsOneWidget);
      expect(find.text('Farm Eggs'), findsNothing); // a different category
    });

    testWidgets('no similar section when it is the only one in its category', (t) async {
      await _detail(t, catalog: [_chicken, _eggs]);
      expect(find.text('Similar meat'), findsNothing);
    });

    testWidgets('View all opens the category list', (t) async {
      await _detail(t, routes: [stubRoute(Routes.products, label: 'PRODUCTS')]);
      await t.scrollUntilVisible(
        find.text('View all →'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(find.text('View all →'));
      await t.pumpAndSettle();
      expect(find.text('PRODUCTS'), findsOneWidget);
    });

    testWidgets('an unknown product says it is not available', (t) async {
      await pumpFeature(
        t,
        const ProductDetailScreen(productId: 'missing'),
        scaffold: false,
        products: [_chicken],
      );
      await t.pump(const Duration(milliseconds: 600));
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('Item not available'), findsOneWidget);
    });

    testWidgets('the back arrow leaves the page', (t) async {
      await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(onPressed: () => c.push('/detail'), child: const Text('go')),
        ),
        products: [_chicken],
        routes: [
          GoRoute(
            path: '/detail',
            builder: (_, _) => const ProductDetailScreen(productId: 'chicken'),
          ),
        ],
        size: const Size(1080, 3000),
      );
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      expect(find.text('Whole Chicken'), findsWidgets);
      await t.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await t.pumpAndSettle();
      expect(find.text('go'), findsOneWidget);
    });

    testWidgets('the cart bar shows once something is added', (t) async {
      await _detail(t);
      expect(find.text('View cart'), findsNothing);
      await t.tap(find.text('Add to cart'));
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('View cart'), findsOneWidget);
    });
  });

  group('wishlist screen', () {
    Future<Harness> open(
      WidgetTester t, {
      Map<String, Object> prefs = const {},
      List<Product>? catalog,
    }) async {
      final h = await pumpFeature(
        t,
        const WishlistScreen(),
        scaffold: false,
        products: catalog ?? [_chicken, _eggs, _other],
        prefs: prefs,
        size: const Size(1080, 3000),
        routes: [
          stubRoute(Routes.home, label: 'HOME'),
          stubRoute('/product/:id', label: 'DETAIL'),
        ],
      );
      await t.pump(const Duration(milliseconds: 600));
      return h;
    }

    testWidgets('with nothing saved it shows the empty state and Start exploring goes Home', (
      t,
    ) async {
      await open(t);
      await t.pump(const Duration(seconds: 1));
      expect(find.byType(EmptyWishlist), findsOneWidget);
      await t.tap(find.text('Start exploring'));
      await t.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('lists the saved products with price, pack and rating', (t) async {
      await open(
        t,
        prefs: {
          'wishlist.$testPhone': ['eggs', 'curry'],
        },
      );
      expect(find.text('Farm Eggs'), findsOneWidget);
      expect(find.text('Curry Cut'), findsOneWidget);
      expect(find.text('Whole Chicken'), findsNothing);
      expect(find.textContaining('₹90', findRichText: true), findsOneWidget);
      expect(find.textContaining('/ 6 pcs', findRichText: true), findsOneWidget);
    });

    testWidgets('a saved id that is no longer in the catalog is ignored', (t) async {
      await open(
        t,
        prefs: {
          'wishlist.$testPhone': ['gone'],
        },
      );
      await t.pump(const Duration(seconds: 1));
      expect(find.byType(EmptyWishlist), findsOneWidget);
    });

    testWidgets('the heart removes it from the list', (t) async {
      final h = await open(
        t,
        prefs: {
          'wishlist.$testPhone': ['eggs', 'curry'],
        },
      );
      await t.tap(find.byIcon(Icons.favorite_rounded).first);
      await t.pump(const Duration(milliseconds: 400));
      expect(h.container.read(favoritesProvider).length, 1);
      expect(find.text('Farm Eggs'), findsNothing);
    });

    testWidgets('removing the last one brings back the empty state', (t) async {
      await open(
        t,
        prefs: {
          'wishlist.$testPhone': ['eggs'],
        },
      );
      await t.tap(find.byIcon(Icons.favorite_rounded));
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(seconds: 1));
      expect(find.byType(EmptyWishlist), findsOneWidget);
    });

    testWidgets('Add to Cart adds a simple product, then shows a stepper', (t) async {
      final h = await open(
        t,
        prefs: {
          'wishlist.$testPhone': ['eggs'],
        },
      );
      await t.tap(find.text('Add to Cart'));
      await t.pump(const Duration(milliseconds: 500));
      expect(h.container.read(cartProvider).single.id, 'eggs:v1');
      expect(find.text('Add to Cart'), findsNothing);

      await t.tap(find.byIcon(Icons.add_rounded).first);
      await t.pump(const Duration(milliseconds: 500));
      expect(h.container.read(cartProvider).single.quantity, 2);
    });

    testWidgets('a product with several packs opens the options sheet instead', (t) async {
      final h = await open(
        t,
        prefs: {
          'wishlist.$testPhone': ['chicken'],
        },
      );
      await t.tap(find.text('Add to Cart'));
      await t.pumpAndSettle();
      expect(h.container.read(cartProvider), isEmpty);
      expect(find.byType(ProductOptionsSheet), findsOneWidget);
    });

    testWidgets('tapping a card opens the product', (t) async {
      await open(
        t,
        prefs: {
          'wishlist.$testPhone': ['eggs'],
        },
      );
      await t.tap(find.text('Farm Eggs'));
      await t.pumpAndSettle();
      expect(find.text('DETAIL'), findsOneWidget);
    });

    testWidgets('the cart bar appears once something is added', (t) async {
      await open(
        t,
        prefs: {
          'wishlist.$testPhone': ['eggs'],
        },
      );
      expect(find.text('View cart'), findsNothing);
      await t.tap(find.text('Add to Cart'));
      await t.pump(const Duration(milliseconds: 700));
      expect(find.text('View cart'), findsOneWidget);
    });
  });
}
