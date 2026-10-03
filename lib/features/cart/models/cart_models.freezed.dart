// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CartLine {

 String get id; String get productId; String get name; String get unitLabel; String get image; int get unitPrice;/// Price before discount; null when the item is not discounted.
 int? get unitMrp; int get quantity; bool get isAddon;
/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartLineCopyWith<CartLine> get copyWith => _$CartLineCopyWithImpl<CartLine>(this as CartLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CartLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.unitLabel, _this.unitLabel) || other.unitLabel == _this.unitLabel)&&(identical(other.image, _this.image) || other.image == _this.image)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.unitMrp, _this.unitMrp) || other.unitMrp == _this.unitMrp)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.isAddon, _this.isAddon) || other.isAddon == _this.isAddon));
}


@override
int get hashCode {
  final _this = this as CartLine;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.name,_this.unitLabel,_this.image,_this.unitPrice,_this.unitMrp,_this.quantity,_this.isAddon);
}

@override
String toString() {
  final _this = this as CartLine;
  return 'CartLine(id: ${_this.id}, productId: ${_this.productId}, name: ${_this.name}, unitLabel: ${_this.unitLabel}, image: ${_this.image}, unitPrice: ${_this.unitPrice}, unitMrp: ${_this.unitMrp}, quantity: ${_this.quantity}, isAddon: ${_this.isAddon})';
}


}

/// @nodoc
abstract mixin class $CartLineCopyWith<$Res>  {
  factory $CartLineCopyWith(CartLine value, $Res Function(CartLine) _then) = _$CartLineCopyWithImpl;
@useResult
$Res call({
 String id, String productId, String name, String unitLabel, String image, int unitPrice, int? unitMrp, int quantity, bool isAddon
});




}
/// @nodoc
class _$CartLineCopyWithImpl<$Res>
    implements $CartLineCopyWith<$Res> {
  _$CartLineCopyWithImpl(this._self, this._then);

  final CartLine _self;
  final $Res Function(CartLine) _then;

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? name = null,Object? unitLabel = null,Object? image = null,Object? unitPrice = null,Object? unitMrp = freezed,Object? quantity = null,Object? isAddon = null,}) {
  return _then(CartLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitLabel: null == unitLabel ? _self.unitLabel : unitLabel // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,unitMrp: freezed == unitMrp ? _self.unitMrp : unitMrp // ignore: cast_nullable_to_non_nullable
as int?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,isAddon: null == isAddon ? _self.isAddon : isAddon // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CartLine].
extension CartLinePatterns on CartLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartLine value)  $default,){
final _that = this;
switch (_that) {
case _CartLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartLine value)?  $default,){
final _that = this;
switch (_that) {
case _CartLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productId,  String name,  String unitLabel,  String image,  int unitPrice,  int? unitMrp,  int quantity,  bool isAddon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartLine() when $default != null:
return $default(_that.id,_that.productId,_that.name,_that.unitLabel,_that.image,_that.unitPrice,_that.unitMrp,_that.quantity,_that.isAddon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productId,  String name,  String unitLabel,  String image,  int unitPrice,  int? unitMrp,  int quantity,  bool isAddon)  $default,) {final _that = this;
switch (_that) {
case _CartLine():
return $default(_that.id,_that.productId,_that.name,_that.unitLabel,_that.image,_that.unitPrice,_that.unitMrp,_that.quantity,_that.isAddon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productId,  String name,  String unitLabel,  String image,  int unitPrice,  int? unitMrp,  int quantity,  bool isAddon)?  $default,) {final _that = this;
switch (_that) {
case _CartLine() when $default != null:
return $default(_that.id,_that.productId,_that.name,_that.unitLabel,_that.image,_that.unitPrice,_that.unitMrp,_that.quantity,_that.isAddon);case _:
  return null;

}
}

}

/// @nodoc


class _CartLine extends CartLine {
  const _CartLine({required this.id, required this.productId, required this.name, required this.unitLabel, required this.image, required this.unitPrice, this.unitMrp, this.quantity = 1, this.isAddon = false}): super._();
  

@override final  String id;
@override final  String productId;
@override final  String name;
@override final  String unitLabel;
@override final  String image;
@override final  int unitPrice;
/// Price before discount; null when the item is not discounted.
@override final  int? unitMrp;
@override@JsonKey() final  int quantity;
@override@JsonKey() final  bool isAddon;

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartLineCopyWith<_CartLine> get copyWith => __$CartLineCopyWithImpl<_CartLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitLabel, unitLabel) || other.unitLabel == unitLabel)&&(identical(other.image, image) || other.image == image)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.unitMrp, unitMrp) || other.unitMrp == unitMrp)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.isAddon, isAddon) || other.isAddon == isAddon));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,name,unitLabel,image,unitPrice,unitMrp,quantity,isAddon);
}

@override
String toString() {
    return 'CartLine(id: $id, productId: $productId, name: $name, unitLabel: $unitLabel, image: $image, unitPrice: $unitPrice, unitMrp: $unitMrp, quantity: $quantity, isAddon: $isAddon)';
}


}

/// @nodoc
abstract mixin class _$CartLineCopyWith<$Res> implements $CartLineCopyWith<$Res> {
  factory _$CartLineCopyWith(_CartLine value, $Res Function(_CartLine) _then) = __$CartLineCopyWithImpl;
@override @useResult
$Res call({
 String id, String productId, String name, String unitLabel, String image, int unitPrice, int? unitMrp, int quantity, bool isAddon
});




}
/// @nodoc
class __$CartLineCopyWithImpl<$Res>
    implements _$CartLineCopyWith<$Res> {
  __$CartLineCopyWithImpl(this._self, this._then);

  final _CartLine _self;
  final $Res Function(_CartLine) _then;

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? name = null,Object? unitLabel = null,Object? image = null,Object? unitPrice = null,Object? unitMrp = freezed,Object? quantity = null,Object? isAddon = null,}) {
  return _then(_CartLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitLabel: null == unitLabel ? _self.unitLabel : unitLabel // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,unitMrp: freezed == unitMrp ? _self.unitMrp : unitMrp // ignore: cast_nullable_to_non_nullable
as int?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,isAddon: null == isAddon ? _self.isAddon : isAddon // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$CartSummary {

 int get itemCount; int get itemTotal;
/// Create a copy of CartSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartSummaryCopyWith<CartSummary> get copyWith => _$CartSummaryCopyWithImpl<CartSummary>(this as CartSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CartSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartSummary&&(identical(other.itemCount, _this.itemCount) || other.itemCount == _this.itemCount)&&(identical(other.itemTotal, _this.itemTotal) || other.itemTotal == _this.itemTotal));
}


@override
int get hashCode {
  final _this = this as CartSummary;
  return Object.hash(runtimeType,_this.itemCount,_this.itemTotal);
}

@override
String toString() {
  final _this = this as CartSummary;
  return 'CartSummary(itemCount: ${_this.itemCount}, itemTotal: ${_this.itemTotal})';
}


}

/// @nodoc
abstract mixin class $CartSummaryCopyWith<$Res>  {
  factory $CartSummaryCopyWith(CartSummary value, $Res Function(CartSummary) _then) = _$CartSummaryCopyWithImpl;
@useResult
$Res call({
 int itemCount, int itemTotal
});




}
/// @nodoc
class _$CartSummaryCopyWithImpl<$Res>
    implements $CartSummaryCopyWith<$Res> {
  _$CartSummaryCopyWithImpl(this._self, this._then);

  final CartSummary _self;
  final $Res Function(CartSummary) _then;

/// Create a copy of CartSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemCount = null,Object? itemTotal = null,}) {
  return _then(CartSummary(
itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,itemTotal: null == itemTotal ? _self.itemTotal : itemTotal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CartSummary].
extension CartSummaryPatterns on CartSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartSummary value)  $default,){
final _that = this;
switch (_that) {
case _CartSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CartSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int itemCount,  int itemTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartSummary() when $default != null:
return $default(_that.itemCount,_that.itemTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int itemCount,  int itemTotal)  $default,) {final _that = this;
switch (_that) {
case _CartSummary():
return $default(_that.itemCount,_that.itemTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int itemCount,  int itemTotal)?  $default,) {final _that = this;
switch (_that) {
case _CartSummary() when $default != null:
return $default(_that.itemCount,_that.itemTotal);case _:
  return null;

}
}

}

/// @nodoc


class _CartSummary extends CartSummary {
  const _CartSummary({required this.itemCount, required this.itemTotal}): super._();
  

@override final  int itemCount;
@override final  int itemTotal;

/// Create a copy of CartSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartSummaryCopyWith<_CartSummary> get copyWith => __$CartSummaryCopyWithImpl<_CartSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartSummary&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.itemTotal, itemTotal) || other.itemTotal == itemTotal));
}


@override
int get hashCode {
    return Object.hash(runtimeType,itemCount,itemTotal);
}

@override
String toString() {
    return 'CartSummary(itemCount: $itemCount, itemTotal: $itemTotal)';
}


}

/// @nodoc
abstract mixin class _$CartSummaryCopyWith<$Res> implements $CartSummaryCopyWith<$Res> {
  factory _$CartSummaryCopyWith(_CartSummary value, $Res Function(_CartSummary) _then) = __$CartSummaryCopyWithImpl;
@override @useResult
$Res call({
 int itemCount, int itemTotal
});




}
/// @nodoc
class __$CartSummaryCopyWithImpl<$Res>
    implements _$CartSummaryCopyWith<$Res> {
  __$CartSummaryCopyWithImpl(this._self, this._then);

  final _CartSummary _self;
  final $Res Function(_CartSummary) _then;

/// Create a copy of CartSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemCount = null,Object? itemTotal = null,}) {
  return _then(_CartSummary(
itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,itemTotal: null == itemTotal ? _self.itemTotal : itemTotal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
