// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  name: json['name'] as String,
  image: json['image'] as String,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image': instance.image,
};

_ProductVariant _$ProductVariantFromJson(Map<String, dynamic> json) =>
    _ProductVariant(
      id: json['id'] as String,
      label: json['label'] as String,
      price: (json['price'] as num).toInt(),
      mrp: (json['mrp'] as num?)?.toInt(),
      inStock: json['inStock'] as bool? ?? true,
    );

Map<String, dynamic> _$ProductVariantToJson(_ProductVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'price': instance.price,
      'mrp': instance.mrp,
      'inStock': instance.inStock,
    };

_Accompaniment _$AccompanimentFromJson(Map<String, dynamic> json) =>
    _Accompaniment(
      id: json['id'] as String,
      name: json['name'] as String,
      weight: json['weight'] as String,
      price: (json['price'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      ratingCount: (json['ratingCount'] as num).toInt(),
      image: json['image'] as String,
      inStock: json['inStock'] as bool? ?? true,
    );

Map<String, dynamic> _$AccompanimentToJson(_Accompaniment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'weight': instance.weight,
      'price': instance.price,
      'rating': instance.rating,
      'ratingCount': instance.ratingCount,
      'image': instance.image,
      'inStock': instance.inStock,
    };

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  categoryId: json['categoryId'] as String,
  image: json['image'] as String,
  gallery:
      (json['gallery'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  rating: (json['rating'] as num).toDouble(),
  ratingCount: (json['ratingCount'] as num).toInt(),
  variants: (json['variants'] as List<dynamic>)
      .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
      .toList(),
  accompaniments:
      (json['accompaniments'] as List<dynamic>?)
          ?.map((e) => Accompaniment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Accompaniment>[],
  isPopular: json['isPopular'] as bool? ?? false,
  isRecommended: json['isRecommended'] as bool? ?? false,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'categoryId': instance.categoryId,
  'image': instance.image,
  'gallery': instance.gallery,
  'rating': instance.rating,
  'ratingCount': instance.ratingCount,
  'variants': instance.variants,
  'accompaniments': instance.accompaniments,
  'isPopular': instance.isPopular,
  'isRecommended': instance.isRecommended,
};

_PromoBanner _$PromoBannerFromJson(Map<String, dynamic> json) => _PromoBanner(
  eyebrow: json['eyebrow'] as String,
  title: json['title'] as String,
  highlight: json['highlight'] as String,
  description: json['description'] as String,
  image: json['image'] as String,
  categoryId: json['categoryId'] as String,
);

Map<String, dynamic> _$PromoBannerToJson(_PromoBanner instance) =>
    <String, dynamic>{
      'eyebrow': instance.eyebrow,
      'title': instance.title,
      'highlight': instance.highlight,
      'description': instance.description,
      'image': instance.image,
      'categoryId': instance.categoryId,
    };
