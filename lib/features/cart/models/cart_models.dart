import 'package:freezed_annotation/freezed_annotation.dart';

import '../../catalog/models/catalog_models.dart';

part 'cart_models.freezed.dart';
part 'cart_models.g.dart';

@freezed
abstract class CartLine with _$CartLine {
  const CartLine._();

  const factory CartLine({
    required String id,
    required String productId,

    /// The pack picked; null for add-ons. Sent with the order so the server
    /// prices it, instead of trusting [unitPrice].
    String? variantId,
    required String name,
    required String unitLabel,
    required String image,
    required int unitPrice,

    /// Price before discount; null when the item is not discounted.
    int? unitMrp,
    @Default(1) int quantity,
    @Default(false) bool isAddon,

    /// The pack's order limit when it was added; null means no limit.
    int? maxQuantity,

    /// Pack weight in grams; with [productId] it names the pack when ordering.
    int? grams,

    /// GST % of the item, charged on [total].
    @Default(0) int taxPercent,
  }) = _CartLine;

  factory CartLine.fromJson(Map<String, dynamic> json) => _$CartLineFromJson(json);

  factory CartLine.fromVariant(Product product, ProductVariant variant) => CartLine(
        id: '${product.id}:${variant.id}',
        productId: product.id,
        variantId: variant.id,
        name: product.name,
        unitLabel: variant.label,
        image: product.image,
        unitPrice: variant.price,
        unitMrp: variant.mrp,
        maxQuantity: variant.maxQuantity,
        grams: variant.grams,
        taxPercent: product.taxPercent,
      );

  factory CartLine.fromAccompaniment(Accompaniment item) => CartLine(
        id: 'addon:${item.id}',
        productId: item.id,
        name: item.name,
        unitLabel: item.weight,
        image: item.image,
        unitPrice: item.price,
        isAddon: true,
        grams: item.grams,
        taxPercent: item.taxPercent,
      );

  int get total => unitPrice * quantity;

  int get mrpTotal => (unitMrp != null && unitMrp! > unitPrice ? unitMrp! : unitPrice) * quantity;

  bool get isDiscounted => mrpTotal > total;

  /// GST on this line, unrounded; the bill rounds the sum once.
  double get tax => total * taxPercent / 100;

  /// [quantity] capped at the pack's order limit.
  int capped(int quantity) => maxQuantity != null && quantity > maxQuantity! ? maxQuantity! : quantity;
}

@freezed
abstract class CartSummary with _$CartSummary {
  const CartSummary._();

  const factory CartSummary({
    required int itemCount,
    required int itemTotal,
  }) = _CartSummary;

  bool get isEmpty => itemCount == 0;
}
