import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/features/cart/providers/cart_providers.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';
import 'package:fresh_hen/features/catalog/providers/catalog_providers.dart';
import 'package:fresh_hen/features/catalog/widgets/product_card.dart';
import 'package:fresh_hen/features/home/screens/categories_screen.dart';
import 'package:fresh_hen/features/home/screens/home_screen.dart';
import 'package:fresh_hen/features/home/screens/product_list_screen.dart';
import 'package:fresh_hen/features/home/screens/search_screen.dart';

import '../../support/feature_harness.dart';
import '../../support/fixtures.dart';
import '../../support/pump.dart';

const _categories = [
  Category(id: 'chicken', name: 'Chicken', image: 'x'),
  Category(id: 'eggs', name: 'Eggs', image: 'y'),
  Category(id: 'fish', name: 'Fish', image: 'z'),
];

const _banner = PromoBanner(
  eyebrow: 'FARM FRESH',
  title: 'Fresh Chicken',
  highlight: 'Delivered Daily',
  description: 'Straight from the farm.',
  image: 'img',
  categoryId: 'chicken',
);

final _products = [
  product(
    'Whole Chicken',
    categoryId: 'chicken',
    isPopular: true,
    ratingCount: 300,
    variants: [variant('v1', 300)],
  ),
  product(
    'Curry Cut',
    categoryId: 'chicken',
    isRecommended: true,
    ratingCount: 200,
    variants: [variant('v1', 250)],
  ),
  product(
    'Farm Eggs',
    categoryId: 'eggs',
    isPopular: true,
    ratingCount: 500,
    variants: [variant('v1', 90)],
  ),
  product(
    'Salmon',
    categoryId: 'fish',
    isRecommended: true,
    ratingCount: 50,
    variants: [variant('v1', 800)],
  ),
];

Future<void> _loaded(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  setUpWidgetTests();

  group('Home screen', () {
    Future<Harness> open(WidgetTester t) async {
      final h = await pumpFeature(
        t,
        const HomeScreen(),
        scaffold: false,
        products: _products,
        categories: _categories,
        banners: const [_banner],
        size: const Size(1080, 4000),
        routes: [
          stubRoute(Routes.categories, label: 'CATEGORIES TAB'),
          stubRoute(Routes.products, label: 'PRODUCT LIST'),
        ],
      );
      await _loaded(t);
      return h;
    }

    testWidgets('shows the brand, banner, categories and the two product rails', (t) async {
      await open(t);
      expect(find.textContaining('Fresh', findRichText: true), findsWidgets);
      expect(find.text('Fresh Chicken'), findsOneWidget); // the banner
      expect(find.text('Categories'), findsOneWidget);
      for (final c in ['All', 'Chicken', 'Eggs', 'Fish']) {
        expect(find.text(c), findsOneWidget, reason: c);
      }
      expect(find.text('Popular Picks'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);
    });

    testWidgets('Popular Picks holds only popular items, Recommended only recommended ones', (
      t,
    ) async {
      await open(t);
      // Whole Chicken and Farm Eggs are popular; Curry Cut and Salmon are recommended.
      expect(find.text('Whole Chicken'), findsOneWidget);
      expect(find.text('Farm Eggs'), findsOneWidget);
      expect(find.text('Curry Cut'), findsOneWidget);
      expect(find.text('Salmon'), findsOneWidget);
    });

    testWidgets('picking a category swaps the rails for that category grid', (t) async {
      await open(t);
      await t.tap(find.text('Eggs'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));

      expect(find.text('Popular Picks'), findsNothing);
      expect(find.text('Recommended'), findsNothing);
      expect(find.text('Farm Eggs'), findsOneWidget);
      expect(find.text('Whole Chicken'), findsNothing);
    });

    testWidgets('All brings the rails back', (t) async {
      final h = await open(t);
      await t.tap(find.text('Fish'));
      await t.pump(const Duration(milliseconds: 600));
      expect(h.container.read(selectedCategoryProvider), 'fish');

      await t.tap(find.text('All'));
      await t.pump(const Duration(milliseconds: 600));
      expect(h.container.read(selectedCategoryProvider), isNull);
      expect(find.text('Popular Picks'), findsOneWidget);
    });

    testWidgets('See All opens the categories tab', (t) async {
      await open(t);
      await t.tap(find.text('See All'));
      await t.pumpAndSettle();
      expect(find.text('CATEGORIES TAB'), findsOneWidget);
    });

    testWidgets('View all opens the full list for that rail', (t) async {
      await open(t);
      await t.tap(find.text('View all →').first);
      await t.pumpAndSettle();
      expect(find.text('PRODUCT LIST'), findsOneWidget);
    });

    testWidgets('adding to the cart from a rail updates the cart', (t) async {
      final h = await open(t);
      await t.tap(find.text('Add').first);
      await t.pump(const Duration(milliseconds: 500));
      expect(h.container.read(cartProvider), isNotEmpty);
    });

    testWidgets('without banners the page still shows everything else', (t) async {
      await pumpFeature(
        t,
        const HomeScreen(),
        scaffold: false,
        products: _products,
        categories: _categories,
        size: const Size(1080, 4000),
      );
      await _loaded(t);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Popular Picks'), findsOneWidget);
    });

    testWidgets('pulling down reloads the catalog', (t) async {
      final h = await open(t);
      final before = h.container.read(productsProvider);
      await t.fling(find.byType(CustomScrollView), const Offset(0, 400), 1000);
      await t.pump(const Duration(milliseconds: 300));
      await t.pump(const Duration(seconds: 2));
      expect(h.container.read(productsProvider).value, isNotNull);
      expect(before.value, isNotNull);
    });
  });

  group('Categories screen', () {
    Future<Harness> open(WidgetTester t, {List<Category> categories = _categories}) async {
      final h = await pumpFeature(
        t,
        const CategoriesScreen(),
        scaffold: false,
        products: _products,
        categories: categories,
        routes: [
          stubRoute(Routes.home, label: 'HOME'),
          stubRoute(Routes.addresses, label: 'ADDRESSES'),
          stubRoute(Routes.products, label: 'PRODUCT LIST'),
        ],
      );
      await _loaded(t);
      return h;
    }

    testWidgets('lists every category with how many items it has', (t) async {
      await open(t);
      expect(find.text('Select Category'), findsOneWidget);
      expect(find.text('3 Collections'), findsOneWidget);
      expect(find.text('Chicken'), findsOneWidget);
      expect(find.text('2 Items'), findsOneWidget); // chicken
      expect(find.text('1 Item'), findsNWidgets(2)); // eggs and fish
    });

    testWidgets('a category with nothing in it says 0 Items; one collection is singular', (
      t,
    ) async {
      await open(
        t,
        categories: const [Category(id: 'empty', name: 'Empty', image: 'x')],
      );
      expect(find.text('1 Collection'), findsOneWidget);
      expect(find.text('0 Items'), findsOneWidget);
    });

    testWidgets('tapping a category opens its products', (t) async {
      await open(t);
      await t.tap(find.text('Eggs'));
      await t.pumpAndSettle();
      expect(find.text('PRODUCT LIST'), findsOneWidget);
    });

    testWidgets('the arrow goes back Home', (t) async {
      await open(t);
      await t.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await t.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('the header shows where the order goes and opens addresses', (t) async {
      await open(t);
      expect(find.text('Deliver to Home'), findsOneWidget);
      await t.tap(find.text('Deliver to Home'));
      await t.pumpAndSettle();
      expect(find.text('ADDRESSES'), findsOneWidget);
    });

    testWidgets('with no address it invites adding one', (t) async {
      await pumpFeature(
        t,
        const CategoriesScreen(),
        scaffold: false,
        categories: _categories,
        addresses: const [],
      );
      await _loaded(t);
      expect(find.text('Add delivery address'), findsOneWidget);
    });
  });

  group('Product list screen', () {
    Future<void> open(
      WidgetTester t, {
      String title = 'Chicken',
      String? category,
      String? section,
    }) async {
      await pumpFeature(
        t,
        ProductListScreen(title: title, categoryId: category, section: section),
        scaffold: false,
        products: _products,
        size: const Size(1080, 3000),
        routes: [stubRoute(Routes.search, label: 'SEARCH')],
      );
      await _loaded(t);
    }

    testWidgets('shows the title and a search bar naming it', (t) async {
      await open(t);
      expect(find.text('Chicken'), findsWidgets);
      expect(find.text('Search in Chicken...'), findsOneWidget);
    });

    testWidgets('a category shows only its products', (t) async {
      await open(t, category: 'chicken');
      expect(find.text('Whole Chicken'), findsOneWidget);
      expect(find.text('Curry Cut'), findsOneWidget);
      expect(find.text('Farm Eggs'), findsNothing);
    });

    testWidgets('the popular section shows only popular items', (t) async {
      await open(t, title: 'Popular Picks', section: 'popular');
      expect(find.byType(ProductCard), findsNWidgets(2));
      expect(find.text('Whole Chicken'), findsOneWidget);
      expect(find.text('Farm Eggs'), findsOneWidget);
    });

    testWidgets('the recommended section shows only recommended items', (t) async {
      await open(t, title: 'Recommended', section: 'recommended');
      expect(find.byType(ProductCard), findsNWidgets(2));
      expect(find.text('Curry Cut'), findsOneWidget);
      expect(find.text('Salmon'), findsOneWidget);
    });

    testWidgets('tapping the search bar opens search', (t) async {
      await open(t, category: 'chicken');
      await t.tap(find.text('Search in Chicken...'));
      await t.pumpAndSettle();
      expect(find.text('SEARCH'), findsOneWidget);
    });

    testWidgets('a category with no products says so', (t) async {
      await open(t, category: 'nothing-here');
      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('the cart bar appears once something is added', (t) async {
      await open(t, category: 'chicken');
      expect(find.text('View cart'), findsNothing);
      await t.tap(find.text('Add').first);
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('View cart'), findsOneWidget);
    });
  });

  group('Search screen', () {
    Future<Harness> open(WidgetTester t, {ProductQuery? initial}) async {
      final h = await pumpFeature(
        t,
        SearchScreen(initialQuery: initial),
        scaffold: false,
        products: _products,
        categories: _categories,
        size: const Size(1080, 3000),
      );
      await _loaded(t);
      return h;
    }

    Future<void> type(WidgetTester t, String text) async {
      await t.enterText(find.byType(TextField), text);
      await t.pump(const Duration(milliseconds: 400)); // past the debounce
      await t.pump(const Duration(milliseconds: 300));
    }

    testWidgets('starts with popular searches and no results', (t) async {
      await open(t);
      expect(find.text('Popular searches'), findsOneWidget);
      expect(find.text('Chicken curry cut'), findsOneWidget);
      expect(find.byType(ProductCard), findsNothing);
      expect(find.text('Search chicken, mutton, eggs...'), findsOneWidget);
    });

    testWidgets('tapping a popular search fills the box and shows matches', (t) async {
      await open(t);
      await t.tap(find.text('Eggs'));
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 400));
      expect(t.widget<TextField>(find.byType(TextField)).controller!.text, 'Eggs');
      expect(find.text('Farm Eggs'), findsOneWidget);
    });

    testWidgets('typing finds products after a short pause', (t) async {
      await open(t);
      await t.enterText(find.byType(TextField), 'curry');
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byType(ProductCard), findsNothing); // still waiting
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Curry Cut'), findsOneWidget);
      expect(find.text('Farm Eggs'), findsNothing);
    });

    testWidgets('nothing matching shows the empty message', (t) async {
      await open(t);
      await type(t, 'zzzz');
      expect(find.text('No items found'), findsOneWidget);
      expect(find.text('Try a different search or adjust filters.'), findsOneWidget);
    });

    testWidgets('clearing the box goes back to the suggestions', (t) async {
      await open(t);
      await type(t, 'eggs');
      expect(find.text('Farm Eggs'), findsOneWidget);
      await t.tap(find.byIcon(Icons.close_rounded));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Popular searches'), findsOneWidget);
    });

    testWidgets('opening with a category narrows the hint and the results', (t) async {
      await open(t, initial: const ProductQuery(categoryId: 'chicken'));
      expect(find.text('Search in Chicken...'), findsOneWidget);
      expect(find.text('Whole Chicken'), findsOneWidget);
      expect(find.text('Farm Eggs'), findsNothing);
      expect(find.widgetWithText(InputChip, 'Chicken'), findsOneWidget);
    });

    testWidgets('removing a filter chip widens the results', (t) async {
      await open(t, initial: const ProductQuery(categoryId: 'chicken'));
      await t.tap(
        find.descendant(of: find.widgetWithText(InputChip, 'Chicken'), matching: find.byType(Icon)),
      );
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Popular searches'), findsOneWidget); // no criteria left
    });

    testWidgets('the filter button has no dot until a filter is on', (t) async {
      await open(t);
      expect(t.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
    });

    testWidgets('the filter button shows a dot when opened with a filter', (t) async {
      await open(t, initial: const ProductQuery(categoryId: 'eggs'));
      expect(t.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
    });

    testWidgets('a price range is shown as a chip and applied', (t) async {
      await open(t, initial: const ProductQuery(minPrice: 0, maxPrice: 100));
      expect(find.widgetWithText(InputChip, '₹0 - ₹100'), findsOneWidget);
      expect(find.text('Farm Eggs'), findsOneWidget);
      expect(find.text('Whole Chicken'), findsNothing);
    });

    testWidgets('a sort other than the default is shown as a chip', (t) async {
      await open(t, initial: const ProductQuery(sort: ProductSort.priceLow));
      expect(find.widgetWithText(InputChip, ProductSort.priceLow.label), findsOneWidget);
    });

    testWidgets('the filter sheet applies a sort but keeps what was typed', (t) async {
      await open(t);
      await type(t, 'c'); // matches Whole Chicken (300) and Curry Cut (250)
      await t.tap(find.byIcon(Icons.tune_rounded));
      await t.pumpAndSettle();
      await t.tap(find.text('Price: High to Low'));
      await t.pump();
      await t.tap(find.text('Show results'));
      await t.pumpAndSettle();

      expect(t.widget<TextField>(find.byType(TextField)).controller!.text, 'c');
      expect(find.widgetWithText(InputChip, 'Price: High to Low'), findsOneWidget);
      // Dearest first: Whole Chicken comes before Curry Cut.
      expect(
        t.getTopLeft(find.text('Whole Chicken')).dx < t.getTopLeft(find.text('Curry Cut')).dx,
        isTrue,
      );
    });

    testWidgets('sorting low to high puts the cheaper one first', (t) async {
      await open(
        t,
        initial: const ProductQuery(search: 'c', sort: ProductSort.priceLow),
      );
      expect(
        t.getTopLeft(find.text('Curry Cut')).dx < t.getTopLeft(find.text('Whole Chicken')).dx,
        isTrue,
      );
    });
  });
}
