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

_OrderBill _$OrderBillFromJson(Map<String, dynamic> json) => _OrderBill(
  itemTotal: (json['itemTotal'] as num).toInt(),
  mrpTotal: (json['mrpTotal'] as num).toInt(),
  deliveryFee: (json['deliveryFee'] as num).toInt(),
  discount: (json['discount'] as num?)?.toInt() ?? 0,
  taxes: (json['taxes'] as num?)?.toInt() ?? 0,
  couponCode: json['couponCode'] as String?,
);

Map<String, dynamic> _$OrderBillToJson(_OrderBill instance) =>
    <String, dynamic>{
      'itemTotal': instance.itemTotal,
      'mrpTotal': instance.mrpTotal,
      'deliveryFee': instance.deliveryFee,
      'discount': instance.discount,
      'taxes': instance.taxes,
      'couponCode': instance.couponCode,
    };

_OrderEvent _$OrderEventFromJson(Map<String, dynamic> json) => _OrderEvent(
  status: $enumDecode(
    _$OrderStatusEnumMap,
    json['status'],
    unknownValue: OrderStatus.confirmed,
  ),
  at: DateTime.parse(json['at'] as String),
);

Map<String, dynamic> _$OrderEventToJson(_OrderEvent instance) =>
    <String, dynamic>{
      'status': _$OrderStatusEnumMap[instance.status]!,
      'at': instance.at.toIso8601String(),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.outForDelivery: 'outForDelivery',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};

_DeliveryRider _$DeliveryRiderFromJson(Map<String, dynamic> json) =>
    _DeliveryRider(
      name: json['name'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$DeliveryRiderToJson(_DeliveryRider instance) =>
    <String, dynamic>{'name': instance.name, 'phone': instance.phone};

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  placedAt: DateTime.parse(json['placedAt'] as String),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  bill: OrderBill.fromJson(json['bill'] as Map<String, dynamic>),
  address: json['address'] as String,
  addressLabel: json['addressLabel'] as String? ?? 'Home',
  status:
      $enumDecodeNullable(
        _$OrderStatusEnumMap,
        json['status'],
        unknownValue: OrderStatus.confirmed,
      ) ??
      OrderStatus.confirmed,
  paymentMethod:
      $enumDecodeNullable(_$PaymentMethodEnumMap, json['paymentMethod']) ??
      PaymentMethod.cash,
  paymentStatus:
      $enumDecodeNullable(
        _$PaymentStatusEnumMap,
        json['paymentStatus'],
        unknownValue: PaymentStatus.verifying,
      ) ??
      PaymentStatus.due,
  slot: json['slot'] == null
      ? null
      : DeliverySlot.fromJson(json['slot'] as Map<String, dynamic>),
  instructions: json['instructions'] as String?,
  deliveredAt: json['deliveredAt'] == null
      ? null
      : DateTime.parse(json['deliveredAt'] as String),
  paymentReference: json['paymentReference'] as String?,
  paymentProof: json['paymentProof'] as String?,
  rating: (json['rating'] as num?)?.toInt(),
  review: json['review'] as String?,
  cancelReason: json['cancelReason'] as String?,
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => OrderEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OrderEvent>[],
  rider: json['rider'] == null
      ? null
      : DeliveryRider.fromJson(json['rider'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'placedAt': instance.placedAt.toIso8601String(),
  'lines': instance.lines,
  'bill': instance.bill,
  'address': instance.address,
  'addressLabel': instance.addressLabel,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
  'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
  'slot': instance.slot,
  'instructions': instance.instructions,
  'deliveredAt': instance.deliveredAt?.toIso8601String(),
  'paymentReference': instance.paymentReference,
  'paymentProof': instance.paymentProof,
  'rating': instance.rating,
  'review': instance.review,
  'cancelReason': instance.cancelReason,
  'events': instance.events,
  'rider': instance.rider,
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.upi: 'upi',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.due: 'due',
  PaymentStatus.verifying: 'verifying',
  PaymentStatus.paid: 'paid',
  PaymentStatus.rejected: 'rejected',
};
