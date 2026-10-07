import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/env.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/prefs_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/catalog_models.dart';
import '../repositories/catalog_repository.dart';
import '../repositories/wishlist_repository.dart';

part 'catalog_providers.g.dart';

/// The only place that decides mock vs remote for the catalog.
@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) {
  if (Env.useMock) return MockCatalogRepository();
  return RemoteCatalogRepository(ref.watch(dioProvider));
}

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

/// The only place that decides mock vs remote for the wishlist.
@Riverpod(keepAlive: true)
WishlistRepository wishlistRepository(Ref ref) {
  if (Env.useMock) {
    return MockWishlistRepository(
      ref.watch(sharedPrefsProvider),
      () => ref.read(sessionPhoneProvider),
    );
  }
  return RemoteWishlistRepository(ref.watch(dioProvider));
}

/// Wishlisted product ids. Shows the copy cached on the device at once, then
/// refreshes from the server; a toggle shows immediately and rolls back if the
/// server rejects it.
@Riverpod(keepAlive: true)
class Favorites extends _$Favorites {
  String get _cacheKey => 'wishlist.cache.${ref.read(sessionPhoneProvider) ?? 'guest'}';

  WishlistRepository get _repo => ref.read(wishlistRepositoryProvider);

  /// Taps made, and how many are still waiting on the server. A refresh that
  /// overlaps either would bring back the wishlist as it was before the tap.
  var _edits = 0;
  var _pending = 0;

  @override
  Set<String> build() {
    final phone = ref.watch(sessionPhoneProvider);
    if (phone != null) Future.microtask(refresh);
    return (ref.read(sharedPrefsProvider).getStringList(_cacheKey) ?? const []).toSet();
  }

  /// Reloads from the server. Offline, the cached set stays.
  Future<void> refresh() async {
    final phone = ref.read(sessionPhoneProvider);
    final edits = _edits;
    try {
      final fresh = await _repo.fetch();
      // A heart tapped while this was loading is newer than what the server sent.
      if (ref.mounted && ref.read(sessionPhoneProvider) == phone && edits == _edits && _pending == 0) _set(fresh);
    } catch (_) {}
  }

  /// Returns false if the server rejected it (the heart flips back).
  Future<bool> toggle(String productId) async {
    _edits++;
    _pending++;
    final adding = !state.contains(productId);
    _set(adding ? {...state, productId} : ({...state}..remove(productId)));
    try {
      adding ? await _repo.add(productId) : await _repo.remove(productId);
      return true;
    } catch (_) {
      if (ref.mounted) {
        _set(adding ? ({...state}..remove(productId)) : {...state, productId});
      }
      return false;
    } finally {
      // Take the server's list once the last tap is answered, in case a refresh
      // was skipped while taps were in flight.
      if (--_pending == 0 && ref.mounted) unawaited(refresh());
    }
  }

  void _set(Set<String> ids) {
    state = ids;
    ref.read(sharedPrefsProvider).setStringList(_cacheKey, ids.toList());
  }
}
