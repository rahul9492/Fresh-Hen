import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';
import 'package:fresh_hen/features/catalog/providers/catalog_providers.dart';
import 'package:fresh_hen/features/catalog/repositories/catalog_repository.dart';
import 'package:fresh_hen/features/catalog/repositories/wishlist_repository.dart';

import '../../support/fixtures.dart';

class _FakeCatalog implements CatalogRepository {
  _FakeCatalog(this.items);

  final List<Product> items;

  @override
  Future<List<Category>> categories() async => const [];

  @override
  Future<List<Product>> products() async => items;

  @override
  Future<List<PromoBanner>> banners() async => const [];
}

class _FakeWishlist implements WishlistRepository {
  _FakeWishlist([Set<String> start = const {}]) : server = {...start};

  final Set<String> server;
  bool failWrites = false;
  bool failReads = false;

  @override
  Future<Set<String>> fetch() async {
    if (failReads) throw Exception('offline');
    return {...server};
  }

  @override
  Future<void> add(String productId) async {
    if (failWrites) throw Exception('rejected');
    server.add(productId);
  }

  @override
  Future<void> remove(String productId) async {
    if (failWrites) throw Exception('rejected');
    server.remove(productId);
  }
}

Future<ProviderContainer> _withCatalog(List<Product> items) async {
  final (c, _) = await makeContainer(
    overrides: [catalogRepositoryProvider.overrideWithValue(_FakeCatalog(items))],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('Product', () {
    test('default pack is the first one in stock', () {
      final p = product('a', variants: [
        variant('s', 100, inStock: false),
        variant('m', 200),
        variant('l', 300),
      ]);
      expect(p.defaultVariant.id, 'm');
    });

    test('with every pack sold out the first is still the default, and the product is out', () {
      final p = product('a', variants: [
        variant('s', 100, inStock: false),
        variant('m', 200, inStock: false),
      ]);
      expect(p.defaultVariant.id, 's');
      expect(p.inStock, isFalse);
    });

    test('in stock when any pack is', () {
      final p = product('a', variants: [variant('s', 100, inStock: false), variant('m', 200)]);
      expect(p.inStock, isTrue);
    });

    test('images put the main picture first', () {
      final p = product('a').copyWith(gallery: ['g1', 'g2']);
      expect(p.images, ['img-a', 'g1', 'g2']);
    });

    test('needs options when it has several packs or add-ons', () {
      expect(product('a').needsOptions, isFalse);
      expect(product('a', variants: [variant('s', 1), variant('m', 2)]).needsOptions, isTrue);
      const addon = Accompaniment(
        id: 'x',
        name: 'X',
        weight: '1',
        price: 1,
        rating: 1,
        ratingCount: 1,
        image: 'i',
      );
      expect(product('a', accompaniments: [addon]).needsOptions, isTrue);
    });

    test('survives a JSON round trip', () {
      final p = product('a', isPopular: true).copyWith(gallery: ['g']);
      expect(Product.fromJson(jsonDecode(jsonEncode(p)) as Map<String, dynamic>), p);
    });
  });

  test('every sort has a label, and the default query shows everything by popularity', () {
    expect(ProductSort.values.map((s) => s.label), everyElement(isNotEmpty));
    const q = ProductQuery();
    expect(q.sort, ProductSort.popular);
    expect(q.search, '');
    expect(q.categoryId, isNull);
  });

  group('filteredProducts', () {
    final catalog = [
      product('Whole Chicken',
          variants: [variant('1', 300)], ratingCount: 50, rating: 4.1, isPopular: true),
      product('Chicken Curry Cut',
          variants: [variant('1', 250)], ratingCount: 200, rating: 4.8, isRecommended: true),
      product('Mutton', categoryId: 'mutton', variants: [variant('1', 700)], ratingCount: 10, rating: 4.5),
      product('Eggs',
          categoryId: 'eggs',
          variants: [variant('1', 90)],
          ratingCount: 500,
          rating: 3.9,
          isPopular: true),
    ];

    Future<List<String>> run(ProductQuery q) async {
      final c = await _withCatalog(catalog);
      return (await c.read(filteredProductsProvider(q).future)).map((p) => p.id).toList();
    }

    test('no filter returns all, most rated first', () async {
      expect(await run(const ProductQuery()), ['Eggs', 'Chicken Curry Cut', 'Whole Chicken', 'Mutton']);
    });

    test('by category', () async {
      expect(await run(const ProductQuery(categoryId: 'mutton')), ['Mutton']);
      expect(await run(const ProductQuery(categoryId: 'nothing')), isEmpty);
    });

    test('search ignores case and surrounding spaces', () async {
      expect(await run(const ProductQuery(search: '  CHICKEN ')), ['Chicken Curry Cut', 'Whole Chicken']);
      expect(await run(const ProductQuery(search: 'zzz')), isEmpty);
    });

    test('popular and recommended only', () async {
      expect(await run(const ProductQuery(popularOnly: true)), ['Eggs', 'Whole Chicken']);
      expect(await run(const ProductQuery(recommendedOnly: true)), ['Chicken Curry Cut']);
    });

    test('price range is inclusive and uses the default pack', () async {
      expect(
        await run(const ProductQuery(minPrice: 250, maxPrice: 300, sort: ProductSort.priceLow)),
        ['Chicken Curry Cut', 'Whole Chicken'],
      );
      expect(await run(const ProductQuery(minPrice: 701)), isEmpty);
      expect(await run(const ProductQuery(maxPrice: 89)), isEmpty);
    });

    test('sorting', () async {
      expect(await run(const ProductQuery(sort: ProductSort.priceLow)),
          ['Eggs', 'Chicken Curry Cut', 'Whole Chicken', 'Mutton']);
      expect(await run(const ProductQuery(sort: ProductSort.priceHigh)),
          ['Mutton', 'Whole Chicken', 'Chicken Curry Cut', 'Eggs']);
      expect(await run(const ProductQuery(sort: ProductSort.rating)),
          ['Chicken Curry Cut', 'Mutton', 'Whole Chicken', 'Eggs']);
    });

    test('filters combine', () async {
      expect(
        await run(const ProductQuery(search: 'chicken', popularOnly: true, maxPrice: 300)),
        ['Whole Chicken'],
      );
    });

    test('a product is found by id, or null', () async {
      final c = await _withCatalog(catalog);
      expect((await c.read(productByIdProvider('Eggs').future))?.id, 'Eggs');
      expect(await c.read(productByIdProvider('nope').future), isNull);
    });
  });

  test('the selected category can be set and cleared', () async {
    final (c, _) = await makeContainer();
    addTearDown(c.dispose);
    c.listen(selectedCategoryProvider, (_, _) {});
    expect(c.read(selectedCategoryProvider), isNull);
    c.read(selectedCategoryProvider.notifier).select('eggs');
    expect(c.read(selectedCategoryProvider), 'eggs');
    c.read(selectedCategoryProvider.notifier).select(null);
    expect(c.read(selectedCategoryProvider), isNull);
  });

  group('wishlist (Favorites)', () {
    Future<(ProviderContainer, _FakeWishlist)> setUpFavs({
      Set<String> server = const {},
      Map<String, Object> prefs = const {},
      bool signedIn = true,
    }) async {
      final repo = _FakeWishlist(server);
      final (c, _) = await makeContainer(
        prefs: prefs,
        signedIn: signedIn,
        overrides: [wishlistRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(favoritesProvider, (_, _) {});
      return (c, repo);
    }

    test('starts from the copy cached on the device, then refreshes from the server', () async {
      final (c, _) = await setUpFavs(
        server: {'b'},
        prefs: {
          'wishlist.cache.$testPhone': ['a'],
        },
      );
      expect(c.read(favoritesProvider), {'a'}); // at once, from the device
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(favoritesProvider), {'b'});
    });

    test('offline, the cached set stays', () async {
      final repo = _FakeWishlist()..failReads = true;
      final (c, _) = await makeContainer(
        prefs: {
          'wishlist.cache.$testPhone': ['a', 'b'],
        },
        overrides: [wishlistRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(favoritesProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(favoritesProvider), {'a', 'b'});
    });

    test('a toggle shows at once, reaches the server, and is cached', () async {
      final (c, repo) = await setUpFavs();
      final ok = await c.read(favoritesProvider.notifier).toggle('a');
      expect(ok, isTrue);
      expect(c.read(favoritesProvider), {'a'});
      expect(repo.server, {'a'});

      final off = await c.read(favoritesProvider.notifier).toggle('a');
      expect(off, isTrue);
      expect(c.read(favoritesProvider), isEmpty);
      expect(repo.server, isEmpty);
    });

    test('a rejected add flips the heart back', () async {
      final (c, repo) = await setUpFavs();
      repo.failWrites = true;
      final ok = await c.read(favoritesProvider.notifier).toggle('a');
      expect(ok, isFalse);
      expect(c.read(favoritesProvider), isEmpty);
    });

    test('a rejected remove puts the heart back on', () async {
      final (c, repo) = await setUpFavs(server: {'a'});
      await c.read(favoritesProvider.notifier).refresh();
      repo.failWrites = true;
      final ok = await c.read(favoritesProvider.notifier).toggle('a');
      expect(ok, isFalse);
      expect(c.read(favoritesProvider), {'a'});
    });

    test('a guest does not call the server on start', () async {
      final (c, repo) = await setUpFavs(server: {'x'}, signedIn: false);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(favoritesProvider), isEmpty);
      expect(repo.server, {'x'});
    });
  });

  group('MockWishlistRepository', () {
    test('keeps ids per phone number and adds and removes them', () async {
      final (_, prefs) = await makeContainer();
      String? phone = '111';
      final repo = MockWishlistRepository(prefs, () => phone);

      await repo.add('a');
      await repo.add('b');
      await repo.add('a'); // idempotent
      expect(await repo.fetch(), {'a', 'b'});

      phone = '222';
      expect(await repo.fetch(), isEmpty);

      phone = '111';
      await repo.remove('a');
      await repo.remove('zzz'); // absent: harmless
      expect(await repo.fetch(), {'b'});

      phone = null;
      await repo.add('g');
      expect(prefs.getStringList('wishlist.guest'), ['g']);
    });
  });
}
