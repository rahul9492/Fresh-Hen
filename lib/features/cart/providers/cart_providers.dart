import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/prefs_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../catalog/models/catalog_models.dart';
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
  static CartLine _withVariantId(CartLine l) => l.isAddon || l.variantId != null
      ? l
      : l.copyWith(variantId: l.id.split(':').last);

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
int lineQuantity(Ref ref, String lineId) => ref
    .watch(cartProvider)
    .where((l) => l.id == lineId)
    .fold(0, (sum, l) => sum + l.quantity);
