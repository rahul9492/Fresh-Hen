// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliverySlot {

 String get id; DateTime get start; DateTime get end;/// False when the slot is full or too close to start.
 bool get available;
/// Create a copy of DeliverySlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliverySlotCopyWith<DeliverySlot> get copyWith => _$DeliverySlotCopyWithImpl<DeliverySlot>(this as DeliverySlot, _$identity);

  /// Serializes this DeliverySlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeliverySlot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliverySlot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.available, _this.available) || other.available == _this.available));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeliverySlot;
  return Object.hash(runtimeType,_this.id,_this.start,_this.end,_this.available);
}

@override
String toString() {
  final _this = this as DeliverySlot;
  return 'DeliverySlot(id: ${_this.id}, start: ${_this.start}, end: ${_this.end}, available: ${_this.available})';
}


}

/// @nodoc
abstract mixin class $DeliverySlotCopyWith<$Res>  {
  factory $DeliverySlotCopyWith(DeliverySlot value, $Res Function(DeliverySlot) _then) = _$DeliverySlotCopyWithImpl;
@useResult
$Res call({
 String id, DateTime start, DateTime end, bool available
});




}
/// @nodoc
class _$DeliverySlotCopyWithImpl<$Res>
    implements $DeliverySlotCopyWith<$Res> {
  _$DeliverySlotCopyWithImpl(this._self, this._then);

  final DeliverySlot _self;
  final $Res Function(DeliverySlot) _then;

/// Create a copy of DeliverySlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? start = null,Object? end = null,Object? available = null,}) {
  return _then(DeliverySlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliverySlot].
extension DeliverySlotPatterns on DeliverySlot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliverySlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliverySlot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliverySlot value)  $default,){
final _that = this;
switch (_that) {
case _DeliverySlot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliverySlot value)?  $default,){
final _that = this;
switch (_that) {
case _DeliverySlot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime start,  DateTime end,  bool available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliverySlot() when $default != null:
return $default(_that.id,_that.start,_that.end,_that.available);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime start,  DateTime end,  bool available)  $default,) {final _that = this;
switch (_that) {
case _DeliverySlot():
return $default(_that.id,_that.start,_that.end,_that.available);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime start,  DateTime end,  bool available)?  $default,) {final _that = this;
switch (_that) {
case _DeliverySlot() when $default != null:
return $default(_that.id,_that.start,_that.end,_that.available);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliverySlot extends DeliverySlot {
  const _DeliverySlot({required this.id, required this.start, required this.end, this.available = true}): super._();
  factory _DeliverySlot.fromJson(Map<String, dynamic> json) => _$DeliverySlotFromJson(json);

@override final  String id;
@override final  DateTime start;
@override final  DateTime end;
/// False when the slot is full or too close to start.
@override@JsonKey() final  bool available;

/// Create a copy of DeliverySlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliverySlotCopyWith<_DeliverySlot> get copyWith => __$DeliverySlotCopyWithImpl<_DeliverySlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliverySlotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliverySlot&&(identical(other.id, id) || other.id == id)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.available, available) || other.available == available));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,start,end,available);
}

@override
String toString() {
    return 'DeliverySlot(id: $id, start: $start, end: $end, available: $available)';
}


}

/// @nodoc
abstract mixin class _$DeliverySlotCopyWith<$Res> implements $DeliverySlotCopyWith<$Res> {
  factory _$DeliverySlotCopyWith(_DeliverySlot value, $Res Function(_DeliverySlot) _then) = __$DeliverySlotCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime start, DateTime end, bool available
});




}
/// @nodoc
class __$DeliverySlotCopyWithImpl<$Res>
    implements _$DeliverySlotCopyWith<$Res> {
  __$DeliverySlotCopyWithImpl(this._self, this._then);

  final _DeliverySlot _self;
  final $Res Function(_DeliverySlot) _then;

/// Create a copy of DeliverySlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? start = null,Object? end = null,Object? available = null,}) {
  return _then(_DeliverySlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$OrderBill {

 int get itemTotal;/// Sum of MRPs, to show what the customer saved on item prices.
 int get mrpTotal; int get deliveryFee; int get discount; int get taxes; String? get couponCode;
/// Create a copy of OrderBill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderBillCopyWith<OrderBill> get copyWith => _$OrderBillCopyWithImpl<OrderBill>(this as OrderBill, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderBill;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderBill&&(identical(other.itemTotal, _this.itemTotal) || other.itemTotal == _this.itemTotal)&&(identical(other.mrpTotal, _this.mrpTotal) || other.mrpTotal == _this.mrpTotal)&&(identical(other.deliveryFee, _this.deliveryFee) || other.deliveryFee == _this.deliveryFee)&&(identical(other.discount, _this.discount) || other.discount == _this.discount)&&(identical(other.taxes, _this.taxes) || other.taxes == _this.taxes)&&(identical(other.couponCode, _this.couponCode) || other.couponCode == _this.couponCode));
}


@override
int get hashCode {
  final _this = this as OrderBill;
  return Object.hash(runtimeType,_this.itemTotal,_this.mrpTotal,_this.deliveryFee,_this.discount,_this.taxes,_this.couponCode);
}

@override
String toString() {
  final _this = this as OrderBill;
  return 'OrderBill(itemTotal: ${_this.itemTotal}, mrpTotal: ${_this.mrpTotal}, deliveryFee: ${_this.deliveryFee}, discount: ${_this.discount}, taxes: ${_this.taxes}, couponCode: ${_this.couponCode})';
}


}

/// @nodoc
abstract mixin class $OrderBillCopyWith<$Res>  {
  factory $OrderBillCopyWith(OrderBill value, $Res Function(OrderBill) _then) = _$OrderBillCopyWithImpl;
@useResult
$Res call({
 int itemTotal, int mrpTotal, int deliveryFee, int discount, int taxes, String? couponCode
});




}
/// @nodoc
class _$OrderBillCopyWithImpl<$Res>
    implements $OrderBillCopyWith<$Res> {
  _$OrderBillCopyWithImpl(this._self, this._then);

  final OrderBill _self;
  final $Res Function(OrderBill) _then;

/// Create a copy of OrderBill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemTotal = null,Object? mrpTotal = null,Object? deliveryFee = null,Object? discount = null,Object? taxes = null,Object? couponCode = freezed,}) {
  return _then(OrderBill(
itemTotal: null == itemTotal ? _self.itemTotal : itemTotal // ignore: cast_nullable_to_non_nullable
as int,mrpTotal: null == mrpTotal ? _self.mrpTotal : mrpTotal // ignore: cast_nullable_to_non_nullable
as int,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as int,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as int,taxes: null == taxes ? _self.taxes : taxes // ignore: cast_nullable_to_non_nullable
as int,couponCode: freezed == couponCode ? _self.couponCode : couponCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderBill].
extension OrderBillPatterns on OrderBill {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderBill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderBill() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderBill value)  $default,){
final _that = this;
switch (_that) {
case _OrderBill():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderBill value)?  $default,){
final _that = this;
switch (_that) {
case _OrderBill() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int itemTotal,  int mrpTotal,  int deliveryFee,  int discount,  int taxes,  String? couponCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderBill() when $default != null:
return $default(_that.itemTotal,_that.mrpTotal,_that.deliveryFee,_that.discount,_that.taxes,_that.couponCode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int itemTotal,  int mrpTotal,  int deliveryFee,  int discount,  int taxes,  String? couponCode)  $default,) {final _that = this;
switch (_that) {
case _OrderBill():
return $default(_that.itemTotal,_that.mrpTotal,_that.deliveryFee,_that.discount,_that.taxes,_that.couponCode);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int itemTotal,  int mrpTotal,  int deliveryFee,  int discount,  int taxes,  String? couponCode)?  $default,) {final _that = this;
switch (_that) {
case _OrderBill() when $default != null:
return $default(_that.itemTotal,_that.mrpTotal,_that.deliveryFee,_that.discount,_that.taxes,_that.couponCode);case _:
  return null;

}
}

}

/// @nodoc


class _OrderBill extends OrderBill {
  const _OrderBill({required this.itemTotal, required this.mrpTotal, required this.deliveryFee, this.discount = 0, this.taxes = 0, this.couponCode}): super._();
  

@override final  int itemTotal;
/// Sum of MRPs, to show what the customer saved on item prices.
@override final  int mrpTotal;
@override final  int deliveryFee;
@override@JsonKey() final  int discount;
@override@JsonKey() final  int taxes;
@override final  String? couponCode;

/// Create a copy of OrderBill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderBillCopyWith<_OrderBill> get copyWith => __$OrderBillCopyWithImpl<_OrderBill>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderBill&&(identical(other.itemTotal, itemTotal) || other.itemTotal == itemTotal)&&(identical(other.mrpTotal, mrpTotal) || other.mrpTotal == mrpTotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.taxes, taxes) || other.taxes == taxes)&&(identical(other.couponCode, couponCode) || other.couponCode == couponCode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,itemTotal,mrpTotal,deliveryFee,discount,taxes,couponCode);
}

@override
String toString() {
    return 'OrderBill(itemTotal: $itemTotal, mrpTotal: $mrpTotal, deliveryFee: $deliveryFee, discount: $discount, taxes: $taxes, couponCode: $couponCode)';
}


}

/// @nodoc
abstract mixin class _$OrderBillCopyWith<$Res> implements $OrderBillCopyWith<$Res> {
  factory _$OrderBillCopyWith(_OrderBill value, $Res Function(_OrderBill) _then) = __$OrderBillCopyWithImpl;
@override @useResult
$Res call({
 int itemTotal, int mrpTotal, int deliveryFee, int discount, int taxes, String? couponCode
});




}
/// @nodoc
class __$OrderBillCopyWithImpl<$Res>
    implements _$OrderBillCopyWith<$Res> {
  __$OrderBillCopyWithImpl(this._self, this._then);

  final _OrderBill _self;
  final $Res Function(_OrderBill) _then;

/// Create a copy of OrderBill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemTotal = null,Object? mrpTotal = null,Object? deliveryFee = null,Object? discount = null,Object? taxes = null,Object? couponCode = freezed,}) {
  return _then(_OrderBill(
itemTotal: null == itemTotal ? _self.itemTotal : itemTotal // ignore: cast_nullable_to_non_nullable
as int,mrpTotal: null == mrpTotal ? _self.mrpTotal : mrpTotal // ignore: cast_nullable_to_non_nullable
as int,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as int,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as int,taxes: null == taxes ? _self.taxes : taxes // ignore: cast_nullable_to_non_nullable
as int,couponCode: freezed == couponCode ? _self.couponCode : couponCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Order {

 String get id; DateTime get placedAt; List<CartLine> get lines; OrderBill get bill;/// Full delivery address as printed on the invoice.
 String get address; String get addressLabel; OrderStatus get status; PaymentMethod get paymentMethod; PaymentStatus get paymentStatus;/// Null means "order now" (delivered within the store's ETA).
 DeliverySlot? get slot; String? get instructions; DateTime? get deliveredAt;/// UPI transaction reference (UTR) the customer typed, if any.
 String? get paymentReference;/// Where the uploaded UPI screenshot lives (URL or storage key).
 String? get paymentProof;/// 1-5 stars and an optional comment once the customer rates the order.
 int? get rating; String? get review;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Order;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.placedAt, _this.placedAt) || other.placedAt == _this.placedAt)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.bill, _this.bill) || other.bill == _this.bill)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.addressLabel, _this.addressLabel) || other.addressLabel == _this.addressLabel)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.paymentMethod, _this.paymentMethod) || other.paymentMethod == _this.paymentMethod)&&(identical(other.paymentStatus, _this.paymentStatus) || other.paymentStatus == _this.paymentStatus)&&(identical(other.slot, _this.slot) || other.slot == _this.slot)&&(identical(other.instructions, _this.instructions) || other.instructions == _this.instructions)&&(identical(other.deliveredAt, _this.deliveredAt) || other.deliveredAt == _this.deliveredAt)&&(identical(other.paymentReference, _this.paymentReference) || other.paymentReference == _this.paymentReference)&&(identical(other.paymentProof, _this.paymentProof) || other.paymentProof == _this.paymentProof)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.review, _this.review) || other.review == _this.review));
}


@override
int get hashCode {
  final _this = this as Order;
  return Object.hash(runtimeType,_this.id,_this.placedAt,const DeepCollectionEquality().hash(_this.lines),_this.bill,_this.address,_this.addressLabel,_this.status,_this.paymentMethod,_this.paymentStatus,_this.slot,_this.instructions,_this.deliveredAt,_this.paymentReference,_this.paymentProof,_this.rating,_this.review);
}

@override
String toString() {
  final _this = this as Order;
  return 'Order(id: ${_this.id}, placedAt: ${_this.placedAt}, lines: ${_this.lines}, bill: ${_this.bill}, address: ${_this.address}, addressLabel: ${_this.addressLabel}, status: ${_this.status}, paymentMethod: ${_this.paymentMethod}, paymentStatus: ${_this.paymentStatus}, slot: ${_this.slot}, instructions: ${_this.instructions}, deliveredAt: ${_this.deliveredAt}, paymentReference: ${_this.paymentReference}, paymentProof: ${_this.paymentProof}, rating: ${_this.rating}, review: ${_this.review})';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, DateTime placedAt, List<CartLine> lines, OrderBill bill, String address, String addressLabel, OrderStatus status, PaymentMethod paymentMethod, PaymentStatus paymentStatus, DeliverySlot? slot, String? instructions, DateTime? deliveredAt, String? paymentReference, String? paymentProof, int? rating, String? review
});


$OrderBillCopyWith<$Res> get bill;$DeliverySlotCopyWith<$Res>? get slot;

}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? placedAt = null,Object? lines = null,Object? bill = null,Object? address = null,Object? addressLabel = null,Object? status = null,Object? paymentMethod = null,Object? paymentStatus = null,Object? slot = freezed,Object? instructions = freezed,Object? deliveredAt = freezed,Object? paymentReference = freezed,Object? paymentProof = freezed,Object? rating = freezed,Object? review = freezed,}) {
  return _then(Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,bill: null == bill ? _self.bill : bill // ignore: cast_nullable_to_non_nullable
as OrderBill,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressLabel: null == addressLabel ? _self.addressLabel : addressLabel // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,slot: freezed == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as DeliverySlot?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,paymentProof: freezed == paymentProof ? _self.paymentProof : paymentProof // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderBillCopyWith<$Res> get bill {
  
  return $OrderBillCopyWith<$Res>(_self.bill, (value) {
    return _then(_self.copyWith(bill: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliverySlotCopyWith<$Res>? get slot {
    if (_self.slot == null) {
    return null;
  }

  return $DeliverySlotCopyWith<$Res>(_self.slot!, (value) {
    return _then(_self.copyWith(slot: value));
  });
}
}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime placedAt,  List<CartLine> lines,  OrderBill bill,  String address,  String addressLabel,  OrderStatus status,  PaymentMethod paymentMethod,  PaymentStatus paymentStatus,  DeliverySlot? slot,  String? instructions,  DateTime? deliveredAt,  String? paymentReference,  String? paymentProof,  int? rating,  String? review)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.placedAt,_that.lines,_that.bill,_that.address,_that.addressLabel,_that.status,_that.paymentMethod,_that.paymentStatus,_that.slot,_that.instructions,_that.deliveredAt,_that.paymentReference,_that.paymentProof,_that.rating,_that.review);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime placedAt,  List<CartLine> lines,  OrderBill bill,  String address,  String addressLabel,  OrderStatus status,  PaymentMethod paymentMethod,  PaymentStatus paymentStatus,  DeliverySlot? slot,  String? instructions,  DateTime? deliveredAt,  String? paymentReference,  String? paymentProof,  int? rating,  String? review)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.placedAt,_that.lines,_that.bill,_that.address,_that.addressLabel,_that.status,_that.paymentMethod,_that.paymentStatus,_that.slot,_that.instructions,_that.deliveredAt,_that.paymentReference,_that.paymentProof,_that.rating,_that.review);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime placedAt,  List<CartLine> lines,  OrderBill bill,  String address,  String addressLabel,  OrderStatus status,  PaymentMethod paymentMethod,  PaymentStatus paymentStatus,  DeliverySlot? slot,  String? instructions,  DateTime? deliveredAt,  String? paymentReference,  String? paymentProof,  int? rating,  String? review)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.placedAt,_that.lines,_that.bill,_that.address,_that.addressLabel,_that.status,_that.paymentMethod,_that.paymentStatus,_that.slot,_that.instructions,_that.deliveredAt,_that.paymentReference,_that.paymentProof,_that.rating,_that.review);case _:
  return null;

}
}

}

/// @nodoc


class _Order extends Order {
  const _Order({required this.id, required this.placedAt, required  List<CartLine> lines, required this.bill, required this.address, this.addressLabel = 'Home', this.status = OrderStatus.confirmed, this.paymentMethod = PaymentMethod.cash, this.paymentStatus = PaymentStatus.due, this.slot, this.instructions, this.deliveredAt, this.paymentReference, this.paymentProof, this.rating, this.review}): _lines = lines,super._();
  

@override final  String id;
@override final  DateTime placedAt;
 final  List<CartLine> _lines;
@override List<CartLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  OrderBill bill;
/// Full delivery address as printed on the invoice.
@override final  String address;
@override@JsonKey() final  String addressLabel;
@override@JsonKey() final  OrderStatus status;
@override@JsonKey() final  PaymentMethod paymentMethod;
@override@JsonKey() final  PaymentStatus paymentStatus;
/// Null means "order now" (delivered within the store's ETA).
@override final  DeliverySlot? slot;
@override final  String? instructions;
@override final  DateTime? deliveredAt;
/// UPI transaction reference (UTR) the customer typed, if any.
@override final  String? paymentReference;
/// Where the uploaded UPI screenshot lives (URL or storage key).
@override final  String? paymentProof;
/// 1-5 stars and an optional comment once the customer rates the order.
@override final  int? rating;
@override final  String? review;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.bill, bill) || other.bill == bill)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressLabel, addressLabel) || other.addressLabel == addressLabel)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.paymentProof, paymentProof) || other.paymentProof == paymentProof)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,placedAt,const DeepCollectionEquality().hash(_lines),bill,address,addressLabel,status,paymentMethod,paymentStatus,slot,instructions,deliveredAt,paymentReference,paymentProof,rating,review);
}

@override
String toString() {
    return 'Order(id: $id, placedAt: $placedAt, lines: $lines, bill: $bill, address: $address, addressLabel: $addressLabel, status: $status, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, slot: $slot, instructions: $instructions, deliveredAt: $deliveredAt, paymentReference: $paymentReference, paymentProof: $paymentProof, rating: $rating, review: $review)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime placedAt, List<CartLine> lines, OrderBill bill, String address, String addressLabel, OrderStatus status, PaymentMethod paymentMethod, PaymentStatus paymentStatus, DeliverySlot? slot, String? instructions, DateTime? deliveredAt, String? paymentReference, String? paymentProof, int? rating, String? review
});


@override $OrderBillCopyWith<$Res> get bill;@override $DeliverySlotCopyWith<$Res>? get slot;

}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? placedAt = null,Object? lines = null,Object? bill = null,Object? address = null,Object? addressLabel = null,Object? status = null,Object? paymentMethod = null,Object? paymentStatus = null,Object? slot = freezed,Object? instructions = freezed,Object? deliveredAt = freezed,Object? paymentReference = freezed,Object? paymentProof = freezed,Object? rating = freezed,Object? review = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,bill: null == bill ? _self.bill : bill // ignore: cast_nullable_to_non_nullable
as OrderBill,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,addressLabel: null == addressLabel ? _self.addressLabel : addressLabel // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,slot: freezed == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as DeliverySlot?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,paymentProof: freezed == paymentProof ? _self.paymentProof : paymentProof // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderBillCopyWith<$Res> get bill {
  
  return $OrderBillCopyWith<$Res>(_self.bill, (value) {
    return _then(_self.copyWith(bill: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliverySlotCopyWith<$Res>? get slot {
    if (_self.slot == null) {
    return null;
  }

  return $DeliverySlotCopyWith<$Res>(_self.slot!, (value) {
    return _then(_self.copyWith(slot: value));
  });
}
}

// dart format on
