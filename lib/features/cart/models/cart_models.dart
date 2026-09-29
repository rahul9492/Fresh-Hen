import 'package:freezed_annotation/freezed_annotation.dart';

import '../../catalog/models/catalog_models.dart';

part 'cart_models.freezed.dart';

@freezed
abstract class CartLine with _$CartLine {
  const CartLine._();

  const factory CartLine({
    required String id,
    required String productId,
    required String name,
    required String unitLabel,
    required String image,
    required int unitPrice,
    @Default(1) int quantity,
    @Default(false) bool isAddon,
  }) = _CartLine;

  factory CartLine.fromVariant(Product product, ProductVariant variant) => CartLine(
        id: '${product.id}:${variant.id}',
        productId: product.id,
        name: product.name,
        unitLabel: variant.label,
        image: product.image,
        unitPrice: variant.price,
      );

  factory CartLine.fromAccompaniment(Accompaniment item) => CartLine(
        id: 'addon:${item.id}',
        productId: item.id,
        name: item.name,
        unitLabel: item.weight,
        image: item.image,
        unitPrice: item.price,
        isAddon: true,
      );

  int get total => unitPrice * quantity;
}

@freezed
abstract class CartSummary with _$CartSummary {
  const CartSummary._();

  const factory CartSummary({
    required int itemCount,
    required int itemTotal,
    required int deliveryFee,
  }) = _CartSummary;

  int get grandTotal => itemTotal + deliveryFee;
  bool get isEmpty => itemCount == 0;
}
