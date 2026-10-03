// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Address {

 String get id; AddressLabel get label;/// Name for an "Other" address, e.g. "Mom's place".
 String? get customLabel;/// House / flat / floor / building.
 String get house;/// Area, sector, street or village.
 String get area; String get landmark; String get city; String get pincode;/// Who receives the order at this address.
 String get name; String get phone; bool get isDefault;
/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressCopyWith<Address> get copyWith => _$AddressCopyWithImpl<Address>(this as Address, _$identity);

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Address;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Address&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.customLabel, _this.customLabel) || other.customLabel == _this.customLabel)&&(identical(other.house, _this.house) || other.house == _this.house)&&(identical(other.area, _this.area) || other.area == _this.area)&&(identical(other.landmark, _this.landmark) || other.landmark == _this.landmark)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.pincode, _this.pincode) || other.pincode == _this.pincode)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Address;
  return Object.hash(runtimeType,_this.id,_this.label,_this.customLabel,_this.house,_this.area,_this.landmark,_this.city,_this.pincode,_this.name,_this.phone,_this.isDefault);
}

@override
String toString() {
  final _this = this as Address;
  return 'Address(id: ${_this.id}, label: ${_this.label}, customLabel: ${_this.customLabel}, house: ${_this.house}, area: ${_this.area}, landmark: ${_this.landmark}, city: ${_this.city}, pincode: ${_this.pincode}, name: ${_this.name}, phone: ${_this.phone}, isDefault: ${_this.isDefault})';
}


}

/// @nodoc
abstract mixin class $AddressCopyWith<$Res>  {
  factory $AddressCopyWith(Address value, $Res Function(Address) _then) = _$AddressCopyWithImpl;
@useResult
$Res call({
 String id, AddressLabel label, String? customLabel, String house, String area, String landmark, String city, String pincode, String name, String phone, bool isDefault
});




}
/// @nodoc
class _$AddressCopyWithImpl<$Res>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._self, this._then);

  final Address _self;
  final $Res Function(Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? customLabel = freezed,Object? house = null,Object? area = null,Object? landmark = null,Object? city = null,Object? pincode = null,Object? name = null,Object? phone = null,Object? isDefault = null,}) {
  return _then(Address(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as AddressLabel,customLabel: freezed == customLabel ? _self.customLabel : customLabel // ignore: cast_nullable_to_non_nullable
as String?,house: null == house ? _self.house : house // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,landmark: null == landmark ? _self.landmark : landmark // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,pincode: null == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Address].
extension AddressPatterns on Address {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Address value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Address value)  $default,){
final _that = this;
switch (_that) {
case _Address():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Address value)?  $default,){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AddressLabel label,  String? customLabel,  String house,  String area,  String landmark,  String city,  String pincode,  String name,  String phone,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.id,_that.label,_that.customLabel,_that.house,_that.area,_that.landmark,_that.city,_that.pincode,_that.name,_that.phone,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AddressLabel label,  String? customLabel,  String house,  String area,  String landmark,  String city,  String pincode,  String name,  String phone,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _Address():
return $default(_that.id,_that.label,_that.customLabel,_that.house,_that.area,_that.landmark,_that.city,_that.pincode,_that.name,_that.phone,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AddressLabel label,  String? customLabel,  String house,  String area,  String landmark,  String city,  String pincode,  String name,  String phone,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.id,_that.label,_that.customLabel,_that.house,_that.area,_that.landmark,_that.city,_that.pincode,_that.name,_that.phone,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Address extends Address {
  const _Address({required this.id, required this.label, this.customLabel, required this.house, required this.area, this.landmark = '', required this.city, required this.pincode, required this.name, required this.phone, this.isDefault = false}): super._();
  factory _Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

@override final  String id;
@override final  AddressLabel label;
/// Name for an "Other" address, e.g. "Mom's place".
@override final  String? customLabel;
/// House / flat / floor / building.
@override final  String house;
/// Area, sector, street or village.
@override final  String area;
@override@JsonKey() final  String landmark;
@override final  String city;
@override final  String pincode;
/// Who receives the order at this address.
@override final  String name;
@override final  String phone;
@override@JsonKey() final  bool isDefault;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressCopyWith<_Address> get copyWith => __$AddressCopyWithImpl<_Address>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Address&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.customLabel, customLabel) || other.customLabel == customLabel)&&(identical(other.house, house) || other.house == house)&&(identical(other.area, area) || other.area == area)&&(identical(other.landmark, landmark) || other.landmark == landmark)&&(identical(other.city, city) || other.city == city)&&(identical(other.pincode, pincode) || other.pincode == pincode)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,customLabel,house,area,landmark,city,pincode,name,phone,isDefault);
}

@override
String toString() {
    return 'Address(id: $id, label: $label, customLabel: $customLabel, house: $house, area: $area, landmark: $landmark, city: $city, pincode: $pincode, name: $name, phone: $phone, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$AddressCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$AddressCopyWith(_Address value, $Res Function(_Address) _then) = __$AddressCopyWithImpl;
@override @useResult
$Res call({
 String id, AddressLabel label, String? customLabel, String house, String area, String landmark, String city, String pincode, String name, String phone, bool isDefault
});




}
/// @nodoc
class __$AddressCopyWithImpl<$Res>
    implements _$AddressCopyWith<$Res> {
  __$AddressCopyWithImpl(this._self, this._then);

  final _Address _self;
  final $Res Function(_Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? customLabel = freezed,Object? house = null,Object? area = null,Object? landmark = null,Object? city = null,Object? pincode = null,Object? name = null,Object? phone = null,Object? isDefault = null,}) {
  return _then(_Address(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as AddressLabel,customLabel: freezed == customLabel ? _self.customLabel : customLabel // ignore: cast_nullable_to_non_nullable
as String?,house: null == house ? _self.house : house // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,landmark: null == landmark ? _self.landmark : landmark // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,pincode: null == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
