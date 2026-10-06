import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/prefs_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../catalog/models/catalog_models.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../models/cart_models.dart';

part 'cart_providers.g.dart';

/// The cart, kept on the device per phone number so it survives an app restart.
@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  String get _key => 'cart.${ref.read(sessionPhoneProvider) ?? 'guest'}';

  @override
  List<CartLine> build() {
    ref.watch(sessionPhoneProvider);
    listenSelf((_, lines) => _save(lines));
    final raw = ref.read(sharedPrefsProvider).getString(_key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(CartLine.fromJson)
          .map(_withVariantId)
          .toList();
    } catch (_) {
      return const []; // corrupt or outdated data: start clean rather than crash
    }
  }

  /// Carts saved before lines carried their pack id: recover it from the line
  /// id (`productId:variantId`) so the order can still be priced by the server.
  static CartLine _withVariantId(CartLine l) =>
      l.isAddon || l.variantId != null ? l : l.copyWith(variantId: l.id.split(':').last);

  void _save(List<CartLine> lines) {
    final prefs = ref.read(sharedPrefsProvider);
    if (lines.isEmpty) {
      prefs.remove(_key);
    } else {
      prefs.setString(_key, jsonEncode([for (final l in lines) l.toJson()]));
    }
  }

  void add(CartLine line) {
    final index = state.indexWhere((l) => l.id == line.id);
    if (index == -1) {
      state = [...state, line];
    } else {
      increment(line.id);
    }
  }

  /// Adds [lines] with their quantities, topping up lines already in the cart.
  void addAll(Iterable<CartLine> lines) {
    final next = [...state];
    for (final line in lines) {
      final index = next.indexWhere((l) => l.id == line.id);
      if (index == -1) {
        next.add(line);
      } else {
        next[index] = next[index].copyWith(quantity: next[index].quantity + line.quantity);
      }
    }
    state = next;
  }

  /// Sets the only selected variant of [product], replacing any other variant.
  void selectVariant(Product product, ProductVariant variant) {
    final id = CartLine.fromVariant(product, variant).id;
    if (state.any((l) => l.id == id)) return;
    state = [
      ...state.where((l) => l.isAddon || l.productId != product.id),
      CartLine.fromVariant(product, variant),
    ];
  }

  void increment(String id) => _update(id, 1);

  void decrement(String id) => _update(id, -1);

  void clear() => state = const [];

  /// Puts a whole cleared cart back (the "Clear cart" snackbar's Undo).
  void restoreAll(List<CartLine> lines) {
    if (state.isEmpty) state = lines;
  }

  /// Puts a removed [line] back where it was (the snackbar's Undo).
  void restore(CartLine line, int index) {
    if (state.any((l) => l.id == line.id)) return;
    final next = [...state];
    next.insert(index.clamp(0, next.length), line);
    state = next;
  }

  /// Drops the lines with these ids, e.g. the ones that sold out.
  void removeAll(Set<String> ids) => state = [
    for (final l in state)
      if (!ids.contains(l.id)) l,
  ];

  void _update(String id, int delta) {
    state = [
      for (final line in state)
        if (line.id != id)
          line
        else if (line.quantity + delta > 0)
          line.copyWith(quantity: line.quantity + delta),
    ];
  }
}

@riverpod
CartSummary cartSummary(Ref ref) {
  final lines = ref.watch(cartProvider);
  return CartSummary(
    itemCount: lines.fold<int>(0, (sum, l) => sum + l.quantity),
    itemTotal: lines.fold<int>(0, (sum, l) => sum + l.total),
  );
}

@riverpod
int productQuantity(Ref ref, String productId) => ref
    .watch(cartProvider)
    .where((l) => l.productId == productId)
    .fold(0, (sum, l) => sum + l.quantity);

@riverpod
int lineQuantity(Ref ref, String lineId) =>
    ref.watch(cartProvider).where((l) => l.id == lineId).fold(0, (sum, l) => sum + l.quantity);

/// Ids of cart lines that can't be bought right now: the pack or add-on sold out
/// after it was added (the cart is saved between sessions), or it left the
/// catalog. Empty while the catalog is still loading, so nothing is blocked on a guess.
@riverpod
Set<String> soldOutLineIds(Ref ref) {
  final products = ref.watch(productsProvider).value;
  if (products == null) return const {};

  final byId = {for (final p in products) p.id: p};
  final addons = {
    for (final p in products)
      for (final a in p.accompaniments) a.id: a,
  };

  bool available(CartLine line) {
    if (line.isAddon) return addons[line.productId]?.inStock ?? false;
    final variants = byId[line.productId]?.variants ?? const <ProductVariant>[];
    return variants.any((v) => v.id == line.variantId && v.inStock);
  }

  return {
    for (final line in ref.watch(cartProvider))
      if (!available(line)) line.id,
  };
}
