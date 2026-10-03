// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliverySlot _$DeliverySlotFromJson(Map<String, dynamic> json) =>
    _DeliverySlot(
      id: json['id'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      available: json['available'] as bool? ?? true,
    );

Map<String, dynamic> _$DeliverySlotToJson(_DeliverySlot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'available': instance.available,
    };
