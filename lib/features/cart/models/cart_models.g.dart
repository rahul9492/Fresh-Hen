// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartLine _$CartLineFromJson(Map<String, dynamic> json) => _CartLine(
  id: json['id'] as String,
  productId: json['productId'] as String,
  variantId: json['variantId'] as String?,
  name: json['name'] as String,
  unitLabel: json['unitLabel'] as String,
  image: json['image'] as String,
  unitPrice: (json['unitPrice'] as num).toInt(),
  unitMrp: (json['unitMrp'] as num?)?.toInt(),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  isAddon: json['isAddon'] as bool? ?? false,
);

Map<String, dynamic> _$CartLineToJson(_CartLine instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'variantId': instance.variantId,
  'name': instance.name,
  'unitLabel': instance.unitLabel,
  'image': instance.image,
  'unitPrice': instance.unitPrice,
  'unitMrp': instance.unitMrp,
  'quantity': instance.quantity,
  'isAddon': instance.isAddon,
};
