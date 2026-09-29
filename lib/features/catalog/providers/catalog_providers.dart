import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/prefs_provider.dart';
import '../models/catalog_models.dart';
import '../repositories/catalog_repository.dart';

part 'catalog_providers.g.dart';

@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) => MockCatalogRepository();

@Riverpod(keepAlive: true)
Future<List<Category>> categories(Ref ref) => ref.watch(catalogRepositoryProvider).categories();

@Riverpod(keepAlive: true)
Future<List<Product>> products(Ref ref) => ref.watch(catalogRepositoryProvider).products();

@Riverpod(keepAlive: true)
Future<List<PromoBanner>> banners(Ref ref) => ref.watch(catalogRepositoryProvider).banners();

@riverpod
Future<Product?> productById(Ref ref, String id) async {
  final all = await ref.watch(productsProvider.future);
  return all.where((p) => p.id == id).firstOrNull;
}

@riverpod
Future<List<Product>> filteredProducts(Ref ref, ProductQuery query) async {
  final all = await ref.watch(productsProvider.future);
  final needle = query.search.trim().toLowerCase();

  final matches = all.where((p) {
    if (query.categoryId != null && p.categoryId != query.categoryId) return false;
    if (query.popularOnly && !p.isPopular) return false;
    if (query.recommendedOnly && !p.isRecommended) return false;
    final price = p.defaultVariant.price;
    if (query.minPrice != null && price < query.minPrice!) return false;
    if (query.maxPrice != null && price > query.maxPrice!) return false;
    return needle.isEmpty || p.name.toLowerCase().contains(needle);
  }).toList();

  int price(Product p) => p.defaultVariant.price;
  switch (query.sort) {
    case ProductSort.popular:
      matches.sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
    case ProductSort.priceLow:
      matches.sort((a, b) => price(a).compareTo(price(b)));
    case ProductSort.priceHigh:
      matches.sort((a, b) => price(b).compareTo(price(a)));
    case ProductSort.rating:
      matches.sort((a, b) => b.rating.compareTo(a.rating));
  }
  return matches;
}

@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

@Riverpod(keepAlive: true)
class Favorites extends _$Favorites {
  static const _key = 'catalog.favorites';

  @override
  Set<String> build() => (ref.read(sharedPrefsProvider).getStringList(_key) ?? []).toSet();

  void toggle(String productId) {
    state = state.contains(productId)
        ? ({...state}..remove(productId))
        : {...state, productId};
    ref.read(sharedPrefsProvider).setStringList(_key, state.toList());
  }
}
