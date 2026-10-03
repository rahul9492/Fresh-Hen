// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  id: json['id'] as String,
  label: $enumDecode(_$AddressLabelEnumMap, json['label']),
  customLabel: json['customLabel'] as String?,
  house: json['house'] as String,
  area: json['area'] as String,
  landmark: json['landmark'] as String? ?? '',
  city: json['city'] as String,
  pincode: json['pincode'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  isDefault: json['isDefault'] as bool? ?? false,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'id': instance.id,
  'label': _$AddressLabelEnumMap[instance.label]!,
  'customLabel': instance.customLabel,
  'house': instance.house,
  'area': instance.area,
  'landmark': instance.landmark,
  'city': instance.city,
  'pincode': instance.pincode,
  'name': instance.name,
  'phone': instance.phone,
  'isDefault': instance.isDefault,
};

const _$AddressLabelEnumMap = {
  AddressLabel.home: 'home',
  AddressLabel.work: 'work',
  AddressLabel.other: 'other',
};
