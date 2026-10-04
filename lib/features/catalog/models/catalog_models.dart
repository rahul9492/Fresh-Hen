import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_models.freezed.dart';
part 'catalog_models.g.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    /// Asset path in mock mode, image URL from the API.
    required String image,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@freezed
abstract class ProductVariant with _$ProductVariant {
  const factory ProductVariant({
    required String id,
    required String label,
    required int price,
    int? mrp,

    /// Set from the admin app when this pack runs out for the day.
    @Default(true) bool inStock,
  }) = _ProductVariant;

  factory ProductVariant.fromJson(Map<String, dynamic> json) => _$ProductVariantFromJson(json);
}

@freezed
abstract class Accompaniment with _$Accompaniment {
  const factory Accompaniment({
    required String id,
    required String name,
    required String weight,
    required int price,
    required double rating,
    required int ratingCount,
    required String image,
    @Default(true) bool inStock,
  }) = _Accompaniment;

  factory Accompaniment.fromJson(Map<String, dynamic> json) => _$AccompanimentFromJson(json);
}

@freezed
abstract class Product with _$Product {
  const Product._();

  const factory Product({
    required String id,
    required String name,
    required String categoryId,
    required String image,
    @Default(<String>[]) List<String> gallery,
    required double rating,
    required int ratingCount,
    required List<ProductVariant> variants,
    @Default(<Accompaniment>[]) List<Accompaniment> accompaniments,
    @Default(false) bool isPopular,
    @Default(false) bool isRecommended,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  /// The first pack that can be bought, so quick-add never picks a sold-out one.
  ProductVariant get defaultVariant =>
      variants.firstWhere((v) => v.inStock, orElse: () => variants.first);

  /// False when every pack is sold out.
  bool get inStock => variants.any((v) => v.inStock);

  List<String> get images => [image, ...gallery];

  /// True when the customer must choose from the options sheet before adding.
  bool get needsOptions => variants.length > 1 || accompaniments.isNotEmpty;
}

@freezed
abstract class PromoBanner with _$PromoBanner {
  const factory PromoBanner({
    required String eyebrow,
    required String title,
    required String highlight,
    required String description,
    required String image,
    required String categoryId,
  }) = _PromoBanner;

  factory PromoBanner.fromJson(Map<String, dynamic> json) => _$PromoBannerFromJson(json);
}

enum ProductSort {
  popular('Popular'),
  priceLow('Price: Low to High'),
  priceHigh('Price: High to Low'),
  rating('Top Rated');

  const ProductSort(this.label);

  final String label;
}

@freezed
abstract class ProductQuery with _$ProductQuery {
  const factory ProductQuery({
    String? categoryId,
    @Default('') String search,
    @Default(ProductSort.popular) ProductSort sort,
    @Default(false) bool popularOnly,
    @Default(false) bool recommendedOnly,
    int? minPrice,
    int? maxPrice,
  }) = _ProductQuery;
}
