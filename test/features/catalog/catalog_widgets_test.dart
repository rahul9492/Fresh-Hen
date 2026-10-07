import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/constants/app_constants.dart';
import 'package:fresh_hen/core/widgets/add_control.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';
import 'package:fresh_hen/features/catalog/providers/catalog_providers.dart';
import 'package:fresh_hen/features/catalog/widgets/filter_sheet.dart';
import 'package:fresh_hen/features/catalog/widgets/product_add_control.dart';
import 'package:fresh_hen/features/catalog/widgets/product_card.dart';
import 'package:fresh_hen/features/catalog/widgets/product_grid.dart';
import 'package:fresh_hen/features/catalog/widgets/product_options_sheet.dart';

import '../../support/feature_harness.dart';
import '../../support/fixtures.dart';
import '../../support/pump.dart';

const _masala = Accompaniment(
  id: 'acc-masala',
  name: 'Chicken Masala',
  weight: '100 g',
  price: 80,
  rating: 4.5,
  ratingCount: 1200,
  image: 'x',
);

final _simple = product('Eggs', variants: [variant('v1', 90, label: '6 pcs')]);
final _multi = product(
  'Chicken',
  variants: [variant('500', 200, mrp: 250, label: '500 g'), variant('1000', 380, label: '1 kg')],
  accompaniments: const [_masala],
);
final _soldOut = product('Fish', variants: [variant('v1', 300, inStock: false, label: '1 kg')]);

void main() {
  setUpWidgetTests();

  group('ProductAddControl', () {
    testWidgets('a simple product is added straight to the cart, then shows a stepper', (t) async {
      final h = await pumpFeature(t, Center(child: ProductAddControl(product: _simple)));
      await t.tap(find.text('Add'));
      await t.pump(const Duration(milliseconds: 500));

      expect(h.container.read(cartProvider).single.id, 'Eggs:v1');
      expect(find.byType(QtyStepper), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('the stepper raises and lowers the quantity, and removes at zero', (t) async {
      final h = await pumpFeature(t, Center(child: ProductAddControl(product: _simple)));
      await t.tap(find.text('Add'));
      await t.pump(const Duration(milliseconds: 500));

      await t.tap(find.byIcon(Icons.add_rounded));
      await t.pump(const Duration(milliseconds: 500));
      expect(h.container.read(cartProvider).single.quantity, 2);

      await t.tap(find.byIcon(Icons.remove_rounded));
      await t.pump(const Duration(milliseconds: 500));
      await t.tap(find.byIcon(Icons.remove_rounded));
      await t.pump(const Duration(milliseconds: 500));
      expect(h.container.read(cartProvider), isEmpty);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('a product with several packs opens the options sheet instead of adding', (t) async {
      final h = await pumpFeature(t, Center(child: ProductAddControl(product: _multi)));
      await t.tap(find.text('Add'));
      await t.pumpAndSettle();

      expect(h.container.read(cartProvider), isEmpty);
      expect(find.byType(ProductOptionsSheet), findsOneWidget);
    });

    testWidgets('a sold-out product cannot be added', (t) async {
      final h = await pumpFeature(t, Center(child: ProductAddControl(product: _soldOut)));
      expect(find.text('Sold out'), findsOneWidget);
      await t.tap(find.text('Sold out'), warnIfMissed: false);
      expect(h.container.read(cartProvider), isEmpty);
    });

    testWidgets('the round style adds with the plus button', (t) async {
      final h = await pumpFeature(
        t,
        Center(child: ProductAddControl(product: _simple, style: AddControlStyle.round)),
      );
      await t.tap(find.byIcon(Icons.add_rounded));
      await t.pump(const Duration(milliseconds: 500));
      expect(h.container.read(cartProvider).single.quantity, 1);
    });

    testWidgets('with several packs in the cart, lowering the count opens the sheet', (t) async {
      final h = await pumpFeature(t, Center(child: ProductAddControl(product: _multi)));
      final cart = h.container.read(cartProvider.notifier);
      cart.addAll([
        CartLineFor.pack(_multi, 0),
        CartLineFor.pack(_multi, 1),
      ]);
      await t.pump(const Duration(milliseconds: 500));

      await t.tap(find.byIcon(Icons.remove_rounded));
      await t.pumpAndSettle();
      expect(find.byType(ProductOptionsSheet), findsOneWidget);
    });
  });

  group('ProductCard', () {
    testWidgets('shows the name, pack, price and rating', (t) async {
      await pumpFeature(
        t,
        SizedBox(width: 180, height: 320, child: ProductCard(product: _simple)),
      );
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('6 pcs'), findsOneWidget);
      expect(find.text('₹90'), findsOneWidget);
      expect(find.text('4.0'), findsOneWidget);
    });

    testWidgets('the heart toggles the wishlist', (t) async {
      final h = await pumpFeature(
        t,
        SizedBox(width: 180, height: 320, child: ProductCard(product: _simple)),
      );
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      await t.tap(find.byIcon(Icons.favorite_border_rounded));
      await t.pump(const Duration(milliseconds: 100));
      expect(h.container.read(favoritesProvider), contains('Eggs'));
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      await t.tap(find.byIcon(Icons.favorite_rounded));
      await t.pump(const Duration(milliseconds: 100));
      expect(h.container.read(favoritesProvider), isNot(contains('Eggs')));
    });

    testWidgets('a product already saved shows a filled heart', (t) async {
      await pumpFeature(
        t,
        SizedBox(width: 180, height: 320, child: ProductCard(product: _simple)),
        prefs: {
          'wishlist.$testPhone': ['Eggs'],
        },
      );
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('tapping the card opens the product page', (t) async {
      await pumpFeature(
        t,
        SizedBox(width: 180, height: 320, child: ProductCard(product: _simple)),
        routes: [stubRoute('/product/:id', label: 'DETAIL')],
      );
      await t.tap(find.text('Eggs'));
      await t.pumpAndSettle();
      expect(find.text('DETAIL'), findsOneWidget);
    });

    testWidgets('the card uses the first pack that is in stock', (t) async {
      final p = product('Mix', variants: [variant('a', 100, inStock: false, label: 'small'), variant('b', 200, label: 'large')]);
      await pumpFeature(t, SizedBox(width: 180, height: 320, child: ProductCard(product: p)));
      expect(find.text('large'), findsOneWidget);
      expect(find.text('₹200'), findsOneWidget);
    });
  });

  group('ProductGrid', () {
    testWidgets('lists the products in a grid', (t) async {
      await pumpFeature(
        t,
        ProductGrid(products: [_simple, _multi, _soldOut]),
        products: [_simple, _multi, _soldOut],
      );
      await t.pump(const Duration(seconds: 1));
      expect(find.byType(ProductCard), findsNWidgets(3));
    });

    testWidgets('no products shows the empty message', (t) async {
      await pumpFeature(t, const ProductGrid(products: []));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('No items found'), findsOneWidget);
      expect(find.text('Try a different search or category.'), findsOneWidget);
    });

    testWidgets('a header scrolls away with the grid', (t) async {
      await pumpFeature(
        t,
        ProductGrid(
          products: List.generate(20, (i) => product('P$i')),
          header: const SizedBox(height: 120, child: Text('HEADER')),
        ),
      );
      await t.pump(const Duration(seconds: 1));
      expect(find.text('HEADER'), findsOneWidget);
      await t.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await t.pump();
      expect(find.text('HEADER'), findsNothing);
    });

    testWidgets('the embedded grid sits inside another scroll view without its own scrolling', (t) async {
      await pumpFeature(
        t,
        SingleChildScrollView(child: ProductGrid(products: [_simple, _soldOut], embedded: true)),
      );
      await t.pump(const Duration(seconds: 1));
      expect(find.byType(ProductCard), findsNWidgets(2));
      final grid = t.widget<GridView>(find.byType(GridView));
      expect(grid.physics, isA<NeverScrollableScrollPhysics>());
    });

    int cardsInFirstRow(WidgetTester t) {
      final top = t.getTopLeft(find.byType(ProductCard).first).dy;
      return find.byType(ProductCard).evaluate().toList().indexed.where((e) {
        return t.getTopLeft(find.byType(ProductCard).at(e.$1)).dy == top;
      }).length;
    }

    testWidgets('a phone shows two columns', (t) async {
      final items = List.generate(8, (i) => product('P$i'));
      await pumpFeature(t, ProductGrid(products: items, embedded: true), size: const Size(1080, 4000));
      await t.pump(const Duration(seconds: 1));
      expect(cardsInFirstRow(t), 2);
    });

    testWidgets('a wide screen fits more than two across', (t) async {
      final items = List.generate(8, (i) => product('P$i'));
      await pumpFeature(t, ProductGrid(products: items, embedded: true), size: const Size(3000, 4000));
      await t.pump(const Duration(seconds: 1));
      expect(cardsInFirstRow(t), greaterThan(2));
    });

    testWidgets('the rail scrolls sideways', (t) async {
      await pumpFeature(
        t,
        ProductRail(products: List.generate(6, (i) => product('P$i'))),
      );
      await t.pump(const Duration(seconds: 1));
      expect(t.widget<ListView>(find.byType(ListView)).scrollDirection, Axis.horizontal);
      expect(find.text('P0'), findsOneWidget);
      await t.drag(find.byType(ListView), const Offset(-600, 0));
      await t.pump();
      expect(find.text('P0'), findsNothing);
    });
  });

  group('ProductOptionsSheet', () {
    Future<Harness> open(WidgetTester t, {Product? p}) async {
      final h = await pumpFeature(
        t,
        Builder(builder: (c) => TextButton(onPressed: () => showProductOptionsSheet(c, p ?? _multi), child: const Text('open'))),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      return h;
    }

    testWidgets('lists every pack with its price, and the add-ons', (t) async {
      await open(t);
      expect(find.text('Chicken'), findsOneWidget);
      expect(find.textContaining('500 g'), findsOneWidget);
      expect(find.textContaining('1 kg'), findsOneWidget);
      expect(find.text('Chicken Masala'), findsOneWidget);
      expect(find.text('Add Accompaniments'), findsOneWidget);
      expect(find.text('100 g • ₹80'), findsOneWidget);
    });

    testWidgets('a product with no add-ons has no accompaniments section', (t) async {
      await open(t, p: product('Plain', variants: [variant('a', 100, label: 'a'), variant('b', 200, label: 'b')]));
      expect(find.text('Add Accompaniments'), findsNothing);
    });

    testWidgets('adding packs and add-ons fills the cart, and Done sums them up', (t) async {
      final h = await open(t);
      expect(find.text('Done'), findsOneWidget);

      await t.tap(find.text('Add').first); // the 500 g pack
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Done • 1 item • ₹200'), findsOneWidget);

      await t.tap(find.text('Add').last); // the masala
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Done • 2 items • ₹280'), findsOneWidget);
      expect(h.container.read(cartProvider).map((l) => l.id), containsAll(['Chicken:500', 'addon:acc-masala']));
    });

    testWidgets('the steppers inside raise and lower a pack', (t) async {
      final h = await open(t);
      await t.tap(find.text('Add').first);
      await t.pump(const Duration(milliseconds: 500));
      await t.tap(find.byIcon(Icons.add_rounded).first);
      await t.pump(const Duration(milliseconds: 500));
      expect(h.container.read(cartProvider).firstWhere((l) => l.id == 'Chicken:500').quantity, 2);
    });

    testWidgets('a sold-out pack cannot be added', (t) async {
      final p = product('Fish', variants: [variant('a', 100, label: 'small', inStock: false), variant('b', 200, label: 'large')]);
      final h = await open(t, p: p);
      expect(find.text('Sold out'), findsOneWidget);
      await t.tap(find.text('Sold out'), warnIfMissed: false);
      expect(h.container.read(cartProvider), isEmpty);
    });

    testWidgets('the close button and Done both dismiss it', (t) async {
      await open(t);
      await t.tap(find.text('Done'));
      await t.pumpAndSettle();
      expect(find.byType(ProductOptionsSheet), findsNothing);

      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Close'));
      await t.pumpAndSettle();
      expect(find.byType(ProductOptionsSheet), findsNothing);
    });
  });

  group('FilterSheet', () {
    Future<void> pumpOpener(WidgetTester t, ProductQuery initial, void Function(ProductQuery?) onResult) async {
      await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(
            onPressed: () async => onResult(await showFilterSheet(c, initial)),
            child: const Text('open'),
          ),
        ),
        overrides: [
          categoriesProvider.overrideWith(
            (ref) async => const [
              Category(id: 'chicken', name: 'Chicken', image: 'x'),
              Category(id: 'eggs', name: 'Eggs', image: 'y'),
            ],
          ),
        ],
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('shows sort options, categories and the price range', (t) async {
      await pumpOpener(t, const ProductQuery(), (_) {});
      expect(find.text('Sort by'), findsOneWidget);
      for (final s in ProductSort.values) {
        expect(find.text(s.label), findsOneWidget, reason: s.name);
      }
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Chicken'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('Price range'), findsOneWidget);
      expect(find.text('₹0 - ₹${AppConstants.filterPriceMax}+'), findsOneWidget);
    });

    testWidgets('applying returns the chosen sort and category', (t) async {
      ProductQuery? result;
      await pumpOpener(t, const ProductQuery(), (q) => result = q);
      await t.tap(find.text('Price: Low to High'));
      await t.tap(find.text('Eggs'));
      await t.pump();
      await t.tap(find.text('Show results'));
      await t.pumpAndSettle();

      expect(result?.sort, ProductSort.priceLow);
      expect(result?.categoryId, 'eggs');
    });

    testWidgets('opens with the current filters selected', (t) async {
      ProductQuery? result;
      await pumpOpener(
        t,
        const ProductQuery(sort: ProductSort.rating, categoryId: 'chicken', minPrice: 100, maxPrice: 400),
        (q) => result = q,
      );
      expect(find.text('₹100 - ₹400'), findsOneWidget);
      await t.tap(find.text('Show results'));
      await t.pumpAndSettle();
      expect(result?.sort, ProductSort.rating);
      expect(result?.categoryId, 'chicken');
      expect((result?.minPrice, result?.maxPrice), (100, 400));
    });

    testWidgets('Reset goes back to the defaults', (t) async {
      ProductQuery? result;
      await pumpOpener(
        t,
        const ProductQuery(sort: ProductSort.rating, categoryId: 'chicken', minPrice: 100, maxPrice: 400),
        (q) => result = q,
      );
      await t.tap(find.text('Reset'));
      await t.pump();
      await t.tap(find.text('Show results'));
      await t.pumpAndSettle();
      expect(result, const ProductQuery());
    });

    testWidgets('dragging the slider ends sets a price range; the full range clears it', (t) async {
      ProductQuery? result;
      await pumpOpener(t, const ProductQuery(), (q) => result = q);
      final slider = find.byType(RangeSlider);
      final left = t.getTopLeft(slider).dx;
      final width = t.getSize(slider).width;

      // Pull the top handle to about the middle.
      await t.dragFrom(Offset(left + width - 24, t.getCenter(slider).dy), Offset(-width / 2, 0));
      await t.pump();
      await t.tap(find.text('Show results'));
      await t.pumpAndSettle();
      expect(result?.maxPrice, isNotNull);
      expect(result!.maxPrice!, lessThan(AppConstants.filterPriceMax));
      expect(result?.minPrice, 0);
    });
  });
}

/// Builds a cart line for one of a product's packs.
class CartLineFor {
  static CartLine pack(Product p, int index) => CartLine.fromVariant(p, p.variants[index]);
}
