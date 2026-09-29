import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../catalog/models/catalog_models.dart';
import '../models/cart_models.dart';

part 'cart_providers.g.dart';

@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  @override
  List<CartLine> build() => const [];

  void add(CartLine line) {
    final index = state.indexWhere((l) => l.id == line.id);
    if (index == -1) {
      state = [...state, line];
    } else {
      increment(line.id);
    }
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
  final itemTotal = lines.fold<int>(0, (sum, l) => sum + l.total);
  final free = itemTotal == 0 || itemTotal >= AppConstants.freeDeliveryThreshold;
  return CartSummary(
    itemCount: lines.fold<int>(0, (sum, l) => sum + l.quantity),
    itemTotal: itemTotal,
    deliveryFee: free ? 0 : AppConstants.deliveryFee,
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
