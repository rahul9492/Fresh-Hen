// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreSettings {

/// Admin switch: when off the cart offers "Order now" only.
 bool get scheduleEnabled;/// "Order now" promise, depending on rider availability.
 int get etaMinMinutes; int get etaMaxMinutes; bool get cashOnDeliveryEnabled;/// UPI QR the admin uploaded: a URL (or a bundled asset in mock mode).
/// UPI is offered only while one is set.
 String? get upiQrImage; String? get upiId; String get upiPayeeName; int get deliveryFee; int get freeDeliveryAbove; int get packagingFee;/// GST on fresh, unprocessed meat and eggs is nil, so this is usually 0.
 int get taxPercent; String get legalName; String get gstin; String get fssaiLicense; String get storeAddress; String get supportPhone; String get supportEmail;
/// Create a copy of StoreSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreSettingsCopyWith<StoreSettings> get copyWith => _$StoreSettingsCopyWithImpl<StoreSettings>(this as StoreSettings, _$identity);

  /// Serializes this StoreSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StoreSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreSettings&&(identical(other.scheduleEnabled, _this.scheduleEnabled) || other.scheduleEnabled == _this.scheduleEnabled)&&(identical(other.etaMinMinutes, _this.etaMinMinutes) || other.etaMinMinutes == _this.etaMinMinutes)&&(identical(other.etaMaxMinutes, _this.etaMaxMinutes) || other.etaMaxMinutes == _this.etaMaxMinutes)&&(identical(other.cashOnDeliveryEnabled, _this.cashOnDeliveryEnabled) || other.cashOnDeliveryEnabled == _this.cashOnDeliveryEnabled)&&(identical(other.upiQrImage, _this.upiQrImage) || other.upiQrImage == _this.upiQrImage)&&(identical(other.upiId, _this.upiId) || other.upiId == _this.upiId)&&(identical(other.upiPayeeName, _this.upiPayeeName) || other.upiPayeeName == _this.upiPayeeName)&&(identical(other.deliveryFee, _this.deliveryFee) || other.deliveryFee == _this.deliveryFee)&&(identical(other.freeDeliveryAbove, _this.freeDeliveryAbove) || other.freeDeliveryAbove == _this.freeDeliveryAbove)&&(identical(other.packagingFee, _this.packagingFee) || other.packagingFee == _this.packagingFee)&&(identical(other.taxPercent, _this.taxPercent) || other.taxPercent == _this.taxPercent)&&(identical(other.legalName, _this.legalName) || other.legalName == _this.legalName)&&(identical(other.gstin, _this.gstin) || other.gstin == _this.gstin)&&(identical(other.fssaiLicense, _this.fssaiLicense) || other.fssaiLicense == _this.fssaiLicense)&&(identical(other.storeAddress, _this.storeAddress) || other.storeAddress == _this.storeAddress)&&(identical(other.supportPhone, _this.supportPhone) || other.supportPhone == _this.supportPhone)&&(identical(other.supportEmail, _this.supportEmail) || other.supportEmail == _this.supportEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StoreSettings;
  return Object.hash(runtimeType,_this.scheduleEnabled,_this.etaMinMinutes,_this.etaMaxMinutes,_this.cashOnDeliveryEnabled,_this.upiQrImage,_this.upiId,_this.upiPayeeName,_this.deliveryFee,_this.freeDeliveryAbove,_this.packagingFee,_this.taxPercent,_this.legalName,_this.gstin,_this.fssaiLicense,_this.storeAddress,_this.supportPhone,_this.supportEmail);
}

@override
String toString() {
  final _this = this as StoreSettings;
  return 'StoreSettings(scheduleEnabled: ${_this.scheduleEnabled}, etaMinMinutes: ${_this.etaMinMinutes}, etaMaxMinutes: ${_this.etaMaxMinutes}, cashOnDeliveryEnabled: ${_this.cashOnDeliveryEnabled}, upiQrImage: ${_this.upiQrImage}, upiId: ${_this.upiId}, upiPayeeName: ${_this.upiPayeeName}, deliveryFee: ${_this.deliveryFee}, freeDeliveryAbove: ${_this.freeDeliveryAbove}, packagingFee: ${_this.packagingFee}, taxPercent: ${_this.taxPercent}, legalName: ${_this.legalName}, gstin: ${_this.gstin}, fssaiLicense: ${_this.fssaiLicense}, storeAddress: ${_this.storeAddress}, supportPhone: ${_this.supportPhone}, supportEmail: ${_this.supportEmail})';
}


}

/// @nodoc
abstract mixin class $StoreSettingsCopyWith<$Res>  {
  factory $StoreSettingsCopyWith(StoreSettings value, $Res Function(StoreSettings) _then) = _$StoreSettingsCopyWithImpl;
@useResult
$Res call({
 bool scheduleEnabled, int etaMinMinutes, int etaMaxMinutes, bool cashOnDeliveryEnabled, String? upiQrImage, String? upiId, String upiPayeeName, int deliveryFee, int freeDeliveryAbove, int packagingFee, int taxPercent, String legalName, String gstin, String fssaiLicense, String storeAddress, String supportPhone, String supportEmail
});




}
/// @nodoc
class _$StoreSettingsCopyWithImpl<$Res>
    implements $StoreSettingsCopyWith<$Res> {
  _$StoreSettingsCopyWithImpl(this._self, this._then);

  final StoreSettings _self;
  final $Res Function(StoreSettings) _then;

/// Create a copy of StoreSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scheduleEnabled = null,Object? etaMinMinutes = null,Object? etaMaxMinutes = null,Object? cashOnDeliveryEnabled = null,Object? upiQrImage = freezed,Object? upiId = freezed,Object? upiPayeeName = null,Object? deliveryFee = null,Object? freeDeliveryAbove = null,Object? packagingFee = null,Object? taxPercent = null,Object? legalName = null,Object? gstin = null,Object? fssaiLicense = null,Object? storeAddress = null,Object? supportPhone = null,Object? supportEmail = null,}) {
  return _then(StoreSettings(
scheduleEnabled: null == scheduleEnabled ? _self.scheduleEnabled : scheduleEnabled // ignore: cast_nullable_to_non_nullable
as bool,etaMinMinutes: null == etaMinMinutes ? _self.etaMinMinutes : etaMinMinutes // ignore: cast_nullable_to_non_nullable
as int,etaMaxMinutes: null == etaMaxMinutes ? _self.etaMaxMinutes : etaMaxMinutes // ignore: cast_nullable_to_non_nullable
as int,cashOnDeliveryEnabled: null == cashOnDeliveryEnabled ? _self.cashOnDeliveryEnabled : cashOnDeliveryEnabled // ignore: cast_nullable_to_non_nullable
as bool,upiQrImage: freezed == upiQrImage ? _self.upiQrImage : upiQrImage // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,upiPayeeName: null == upiPayeeName ? _self.upiPayeeName : upiPayeeName // ignore: cast_nullable_to_non_nullable
as String,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as int,freeDeliveryAbove: null == freeDeliveryAbove ? _self.freeDeliveryAbove : freeDeliveryAbove // ignore: cast_nullable_to_non_nullable
as int,packagingFee: null == packagingFee ? _self.packagingFee : packagingFee // ignore: cast_nullable_to_non_nullable
as int,taxPercent: null == taxPercent ? _self.taxPercent : taxPercent // ignore: cast_nullable_to_non_nullable
as int,legalName: null == legalName ? _self.legalName : legalName // ignore: cast_nullable_to_non_nullable
as String,gstin: null == gstin ? _self.gstin : gstin // ignore: cast_nullable_to_non_nullable
as String,fssaiLicense: null == fssaiLicense ? _self.fssaiLicense : fssaiLicense // ignore: cast_nullable_to_non_nullable
as String,storeAddress: null == storeAddress ? _self.storeAddress : storeAddress // ignore: cast_nullable_to_non_nullable
as String,supportPhone: null == supportPhone ? _self.supportPhone : supportPhone // ignore: cast_nullable_to_non_nullable
as String,supportEmail: null == supportEmail ? _self.supportEmail : supportEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreSettings].
extension StoreSettingsPatterns on StoreSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreSettings value)  $default,){
final _that = this;
switch (_that) {
case _StoreSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreSettings value)?  $default,){
final _that = this;
switch (_that) {
case _StoreSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool scheduleEnabled,  int etaMinMinutes,  int etaMaxMinutes,  bool cashOnDeliveryEnabled,  String? upiQrImage,  String? upiId,  String upiPayeeName,  int deliveryFee,  int freeDeliveryAbove,  int packagingFee,  int taxPercent,  String legalName,  String gstin,  String fssaiLicense,  String storeAddress,  String supportPhone,  String supportEmail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreSettings() when $default != null:
return $default(_that.scheduleEnabled,_that.etaMinMinutes,_that.etaMaxMinutes,_that.cashOnDeliveryEnabled,_that.upiQrImage,_that.upiId,_that.upiPayeeName,_that.deliveryFee,_that.freeDeliveryAbove,_that.packagingFee,_that.taxPercent,_that.legalName,_that.gstin,_that.fssaiLicense,_that.storeAddress,_that.supportPhone,_that.supportEmail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool scheduleEnabled,  int etaMinMinutes,  int etaMaxMinutes,  bool cashOnDeliveryEnabled,  String? upiQrImage,  String? upiId,  String upiPayeeName,  int deliveryFee,  int freeDeliveryAbove,  int packagingFee,  int taxPercent,  String legalName,  String gstin,  String fssaiLicense,  String storeAddress,  String supportPhone,  String supportEmail)  $default,) {final _that = this;
switch (_that) {
case _StoreSettings():
return $default(_that.scheduleEnabled,_that.etaMinMinutes,_that.etaMaxMinutes,_that.cashOnDeliveryEnabled,_that.upiQrImage,_that.upiId,_that.upiPayeeName,_that.deliveryFee,_that.freeDeliveryAbove,_that.packagingFee,_that.taxPercent,_that.legalName,_that.gstin,_that.fssaiLicense,_that.storeAddress,_that.supportPhone,_that.supportEmail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool scheduleEnabled,  int etaMinMinutes,  int etaMaxMinutes,  bool cashOnDeliveryEnabled,  String? upiQrImage,  String? upiId,  String upiPayeeName,  int deliveryFee,  int freeDeliveryAbove,  int packagingFee,  int taxPercent,  String legalName,  String gstin,  String fssaiLicense,  String storeAddress,  String supportPhone,  String supportEmail)?  $default,) {final _that = this;
switch (_that) {
case _StoreSettings() when $default != null:
return $default(_that.scheduleEnabled,_that.etaMinMinutes,_that.etaMaxMinutes,_that.cashOnDeliveryEnabled,_that.upiQrImage,_that.upiId,_that.upiPayeeName,_that.deliveryFee,_that.freeDeliveryAbove,_that.packagingFee,_that.taxPercent,_that.legalName,_that.gstin,_that.fssaiLicense,_that.storeAddress,_that.supportPhone,_that.supportEmail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreSettings extends StoreSettings {
  const _StoreSettings({this.scheduleEnabled = false, this.etaMinMinutes = 45, this.etaMaxMinutes = 90, this.cashOnDeliveryEnabled = true, this.upiQrImage, this.upiId, this.upiPayeeName = 'Fresh Hen', this.deliveryFee = 40, this.freeDeliveryAbove = 499, this.packagingFee = 0, this.taxPercent = 0, this.legalName = 'Fresh Hen Foods Pvt. Ltd.', this.gstin = '', this.fssaiLicense = '', this.storeAddress = '', this.supportPhone = '', this.supportEmail = ''}): super._();
  factory _StoreSettings.fromJson(Map<String, dynamic> json) => _$StoreSettingsFromJson(json);

/// Admin switch: when off the cart offers "Order now" only.
@override@JsonKey() final  bool scheduleEnabled;
/// "Order now" promise, depending on rider availability.
@override@JsonKey() final  int etaMinMinutes;
@override@JsonKey() final  int etaMaxMinutes;
@override@JsonKey() final  bool cashOnDeliveryEnabled;
/// UPI QR the admin uploaded: a URL (or a bundled asset in mock mode).
/// UPI is offered only while one is set.
@override final  String? upiQrImage;
@override final  String? upiId;
@override@JsonKey() final  String upiPayeeName;
@override@JsonKey() final  int deliveryFee;
@override@JsonKey() final  int freeDeliveryAbove;
@override@JsonKey() final  int packagingFee;
/// GST on fresh, unprocessed meat and eggs is nil, so this is usually 0.
@override@JsonKey() final  int taxPercent;
@override@JsonKey() final  String legalName;
@override@JsonKey() final  String gstin;
@override@JsonKey() final  String fssaiLicense;
@override@JsonKey() final  String storeAddress;
@override@JsonKey() final  String supportPhone;
@override@JsonKey() final  String supportEmail;

/// Create a copy of StoreSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreSettingsCopyWith<_StoreSettings> get copyWith => __$StoreSettingsCopyWithImpl<_StoreSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreSettings&&(identical(other.scheduleEnabled, scheduleEnabled) || other.scheduleEnabled == scheduleEnabled)&&(identical(other.etaMinMinutes, etaMinMinutes) || other.etaMinMinutes == etaMinMinutes)&&(identical(other.etaMaxMinutes, etaMaxMinutes) || other.etaMaxMinutes == etaMaxMinutes)&&(identical(other.cashOnDeliveryEnabled, cashOnDeliveryEnabled) || other.cashOnDeliveryEnabled == cashOnDeliveryEnabled)&&(identical(other.upiQrImage, upiQrImage) || other.upiQrImage == upiQrImage)&&(identical(other.upiId, upiId) || other.upiId == upiId)&&(identical(other.upiPayeeName, upiPayeeName) || other.upiPayeeName == upiPayeeName)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.freeDeliveryAbove, freeDeliveryAbove) || other.freeDeliveryAbove == freeDeliveryAbove)&&(identical(other.packagingFee, packagingFee) || other.packagingFee == packagingFee)&&(identical(other.taxPercent, taxPercent) || other.taxPercent == taxPercent)&&(identical(other.legalName, legalName) || other.legalName == legalName)&&(identical(other.gstin, gstin) || other.gstin == gstin)&&(identical(other.fssaiLicense, fssaiLicense) || other.fssaiLicense == fssaiLicense)&&(identical(other.storeAddress, storeAddress) || other.storeAddress == storeAddress)&&(identical(other.supportPhone, supportPhone) || other.supportPhone == supportPhone)&&(identical(other.supportEmail, supportEmail) || other.supportEmail == supportEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,scheduleEnabled,etaMinMinutes,etaMaxMinutes,cashOnDeliveryEnabled,upiQrImage,upiId,upiPayeeName,deliveryFee,freeDeliveryAbove,packagingFee,taxPercent,legalName,gstin,fssaiLicense,storeAddress,supportPhone,supportEmail);
}

@override
String toString() {
    return 'StoreSettings(scheduleEnabled: $scheduleEnabled, etaMinMinutes: $etaMinMinutes, etaMaxMinutes: $etaMaxMinutes, cashOnDeliveryEnabled: $cashOnDeliveryEnabled, upiQrImage: $upiQrImage, upiId: $upiId, upiPayeeName: $upiPayeeName, deliveryFee: $deliveryFee, freeDeliveryAbove: $freeDeliveryAbove, packagingFee: $packagingFee, taxPercent: $taxPercent, legalName: $legalName, gstin: $gstin, fssaiLicense: $fssaiLicense, storeAddress: $storeAddress, supportPhone: $supportPhone, supportEmail: $supportEmail)';
}


}

/// @nodoc
abstract mixin class _$StoreSettingsCopyWith<$Res> implements $StoreSettingsCopyWith<$Res> {
  factory _$StoreSettingsCopyWith(_StoreSettings value, $Res Function(_StoreSettings) _then) = __$StoreSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool scheduleEnabled, int etaMinMinutes, int etaMaxMinutes, bool cashOnDeliveryEnabled, String? upiQrImage, String? upiId, String upiPayeeName, int deliveryFee, int freeDeliveryAbove, int packagingFee, int taxPercent, String legalName, String gstin, String fssaiLicense, String storeAddress, String supportPhone, String supportEmail
});




}
/// @nodoc
class __$StoreSettingsCopyWithImpl<$Res>
    implements _$StoreSettingsCopyWith<$Res> {
  __$StoreSettingsCopyWithImpl(this._self, this._then);

  final _StoreSettings _self;
  final $Res Function(_StoreSettings) _then;

/// Create a copy of StoreSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scheduleEnabled = null,Object? etaMinMinutes = null,Object? etaMaxMinutes = null,Object? cashOnDeliveryEnabled = null,Object? upiQrImage = freezed,Object? upiId = freezed,Object? upiPayeeName = null,Object? deliveryFee = null,Object? freeDeliveryAbove = null,Object? packagingFee = null,Object? taxPercent = null,Object? legalName = null,Object? gstin = null,Object? fssaiLicense = null,Object? storeAddress = null,Object? supportPhone = null,Object? supportEmail = null,}) {
  return _then(_StoreSettings(
scheduleEnabled: null == scheduleEnabled ? _self.scheduleEnabled : scheduleEnabled // ignore: cast_nullable_to_non_nullable
as bool,etaMinMinutes: null == etaMinMinutes ? _self.etaMinMinutes : etaMinMinutes // ignore: cast_nullable_to_non_nullable
as int,etaMaxMinutes: null == etaMaxMinutes ? _self.etaMaxMinutes : etaMaxMinutes // ignore: cast_nullable_to_non_nullable
as int,cashOnDeliveryEnabled: null == cashOnDeliveryEnabled ? _self.cashOnDeliveryEnabled : cashOnDeliveryEnabled // ignore: cast_nullable_to_non_nullable
as bool,upiQrImage: freezed == upiQrImage ? _self.upiQrImage : upiQrImage // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,upiPayeeName: null == upiPayeeName ? _self.upiPayeeName : upiPayeeName // ignore: cast_nullable_to_non_nullable
as String,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as int,freeDeliveryAbove: null == freeDeliveryAbove ? _self.freeDeliveryAbove : freeDeliveryAbove // ignore: cast_nullable_to_non_nullable
as int,packagingFee: null == packagingFee ? _self.packagingFee : packagingFee // ignore: cast_nullable_to_non_nullable
as int,taxPercent: null == taxPercent ? _self.taxPercent : taxPercent // ignore: cast_nullable_to_non_nullable
as int,legalName: null == legalName ? _self.legalName : legalName // ignore: cast_nullable_to_non_nullable
as String,gstin: null == gstin ? _self.gstin : gstin // ignore: cast_nullable_to_non_nullable
as String,fssaiLicense: null == fssaiLicense ? _self.fssaiLicense : fssaiLicense // ignore: cast_nullable_to_non_nullable
as String,storeAddress: null == storeAddress ? _self.storeAddress : storeAddress // ignore: cast_nullable_to_non_nullable
as String,supportPhone: null == supportPhone ? _self.supportPhone : supportPhone // ignore: cast_nullable_to_non_nullable
as String,supportEmail: null == supportEmail ? _self.supportEmail : supportEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Coupon {

 String get code;/// Short headline, e.g. "20% OFF up to ₹100".
 String get title; String get description; int get percentOff; int get flatOff;/// Cap for percentage coupons; 0 means no cap.
 int get maxDiscount; int get minOrder; bool get firstOrderOnly; DateTime? get expiresAt;
/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CouponCopyWith<Coupon> get copyWith => _$CouponCopyWithImpl<Coupon>(this as Coupon, _$identity);

  /// Serializes this Coupon to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Coupon;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Coupon&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.percentOff, _this.percentOff) || other.percentOff == _this.percentOff)&&(identical(other.flatOff, _this.flatOff) || other.flatOff == _this.flatOff)&&(identical(other.maxDiscount, _this.maxDiscount) || other.maxDiscount == _this.maxDiscount)&&(identical(other.minOrder, _this.minOrder) || other.minOrder == _this.minOrder)&&(identical(other.firstOrderOnly, _this.firstOrderOnly) || other.firstOrderOnly == _this.firstOrderOnly)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Coupon;
  return Object.hash(runtimeType,_this.code,_this.title,_this.description,_this.percentOff,_this.flatOff,_this.maxDiscount,_this.minOrder,_this.firstOrderOnly,_this.expiresAt);
}

@override
String toString() {
  final _this = this as Coupon;
  return 'Coupon(code: ${_this.code}, title: ${_this.title}, description: ${_this.description}, percentOff: ${_this.percentOff}, flatOff: ${_this.flatOff}, maxDiscount: ${_this.maxDiscount}, minOrder: ${_this.minOrder}, firstOrderOnly: ${_this.firstOrderOnly}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $CouponCopyWith<$Res>  {
  factory $CouponCopyWith(Coupon value, $Res Function(Coupon) _then) = _$CouponCopyWithImpl;
@useResult
$Res call({
 String code, String title, String description, int percentOff, int flatOff, int maxDiscount, int minOrder, bool firstOrderOnly, DateTime? expiresAt
});




}
/// @nodoc
class _$CouponCopyWithImpl<$Res>
    implements $CouponCopyWith<$Res> {
  _$CouponCopyWithImpl(this._self, this._then);

  final Coupon _self;
  final $Res Function(Coupon) _then;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? title = null,Object? description = null,Object? percentOff = null,Object? flatOff = null,Object? maxDiscount = null,Object? minOrder = null,Object? firstOrderOnly = null,Object? expiresAt = freezed,}) {
  return _then(Coupon(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,percentOff: null == percentOff ? _self.percentOff : percentOff // ignore: cast_nullable_to_non_nullable
as int,flatOff: null == flatOff ? _self.flatOff : flatOff // ignore: cast_nullable_to_non_nullable
as int,maxDiscount: null == maxDiscount ? _self.maxDiscount : maxDiscount // ignore: cast_nullable_to_non_nullable
as int,minOrder: null == minOrder ? _self.minOrder : minOrder // ignore: cast_nullable_to_non_nullable
as int,firstOrderOnly: null == firstOrderOnly ? _self.firstOrderOnly : firstOrderOnly // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Coupon].
extension CouponPatterns on Coupon {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Coupon value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Coupon() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Coupon value)  $default,){
final _that = this;
switch (_that) {
case _Coupon():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Coupon value)?  $default,){
final _that = this;
switch (_that) {
case _Coupon() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String title,  String description,  int percentOff,  int flatOff,  int maxDiscount,  int minOrder,  bool firstOrderOnly,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Coupon() when $default != null:
return $default(_that.code,_that.title,_that.description,_that.percentOff,_that.flatOff,_that.maxDiscount,_that.minOrder,_that.firstOrderOnly,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String title,  String description,  int percentOff,  int flatOff,  int maxDiscount,  int minOrder,  bool firstOrderOnly,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _Coupon():
return $default(_that.code,_that.title,_that.description,_that.percentOff,_that.flatOff,_that.maxDiscount,_that.minOrder,_that.firstOrderOnly,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String title,  String description,  int percentOff,  int flatOff,  int maxDiscount,  int minOrder,  bool firstOrderOnly,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Coupon() when $default != null:
return $default(_that.code,_that.title,_that.description,_that.percentOff,_that.flatOff,_that.maxDiscount,_that.minOrder,_that.firstOrderOnly,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Coupon extends Coupon {
  const _Coupon({required this.code, required this.title, required this.description, this.percentOff = 0, this.flatOff = 0, this.maxDiscount = 0, this.minOrder = 0, this.firstOrderOnly = false, this.expiresAt}): super._();
  factory _Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);

@override final  String code;
/// Short headline, e.g. "20% OFF up to ₹100".
@override final  String title;
@override final  String description;
@override@JsonKey() final  int percentOff;
@override@JsonKey() final  int flatOff;
/// Cap for percentage coupons; 0 means no cap.
@override@JsonKey() final  int maxDiscount;
@override@JsonKey() final  int minOrder;
@override@JsonKey() final  bool firstOrderOnly;
@override final  DateTime? expiresAt;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CouponCopyWith<_Coupon> get copyWith => __$CouponCopyWithImpl<_Coupon>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CouponToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Coupon&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.percentOff, percentOff) || other.percentOff == percentOff)&&(identical(other.flatOff, flatOff) || other.flatOff == flatOff)&&(identical(other.maxDiscount, maxDiscount) || other.maxDiscount == maxDiscount)&&(identical(other.minOrder, minOrder) || other.minOrder == minOrder)&&(identical(other.firstOrderOnly, firstOrderOnly) || other.firstOrderOnly == firstOrderOnly)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,title,description,percentOff,flatOff,maxDiscount,minOrder,firstOrderOnly,expiresAt);
}

@override
String toString() {
    return 'Coupon(code: $code, title: $title, description: $description, percentOff: $percentOff, flatOff: $flatOff, maxDiscount: $maxDiscount, minOrder: $minOrder, firstOrderOnly: $firstOrderOnly, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$CouponCopyWith<$Res> implements $CouponCopyWith<$Res> {
  factory _$CouponCopyWith(_Coupon value, $Res Function(_Coupon) _then) = __$CouponCopyWithImpl;
@override @useResult
$Res call({
 String code, String title, String description, int percentOff, int flatOff, int maxDiscount, int minOrder, bool firstOrderOnly, DateTime? expiresAt
});




}
/// @nodoc
class __$CouponCopyWithImpl<$Res>
    implements _$CouponCopyWith<$Res> {
  __$CouponCopyWithImpl(this._self, this._then);

  final _Coupon _self;
  final $Res Function(_Coupon) _then;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? title = null,Object? description = null,Object? percentOff = null,Object? flatOff = null,Object? maxDiscount = null,Object? minOrder = null,Object? firstOrderOnly = null,Object? expiresAt = freezed,}) {
  return _then(_Coupon(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,percentOff: null == percentOff ? _self.percentOff : percentOff // ignore: cast_nullable_to_non_nullable
as int,flatOff: null == flatOff ? _self.flatOff : flatOff // ignore: cast_nullable_to_non_nullable
as int,maxDiscount: null == maxDiscount ? _self.maxDiscount : maxDiscount // ignore: cast_nullable_to_non_nullable
as int,minOrder: null == minOrder ? _self.minOrder : minOrder // ignore: cast_nullable_to_non_nullable
as int,firstOrderOnly: null == firstOrderOnly ? _self.firstOrderOnly : firstOrderOnly // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$DeliveryDay {

 DateTime get date; List<DeliverySlot> get slots;/// Set when the store is closed that day (holiday, weekly off).
 String? get closedReason;
/// Create a copy of DeliveryDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryDayCopyWith<DeliveryDay> get copyWith => _$DeliveryDayCopyWithImpl<DeliveryDay>(this as DeliveryDay, _$identity);

  /// Serializes this DeliveryDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeliveryDay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryDay&&(identical(other.date, _this.date) || other.date == _this.date)&&const DeepCollectionEquality().equals(other.slots, _this.slots)&&(identical(other.closedReason, _this.closedReason) || other.closedReason == _this.closedReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeliveryDay;
  return Object.hash(runtimeType,_this.date,const DeepCollectionEquality().hash(_this.slots),_this.closedReason);
}

@override
String toString() {
  final _this = this as DeliveryDay;
  return 'DeliveryDay(date: ${_this.date}, slots: ${_this.slots}, closedReason: ${_this.closedReason})';
}


}

/// @nodoc
abstract mixin class $DeliveryDayCopyWith<$Res>  {
  factory $DeliveryDayCopyWith(DeliveryDay value, $Res Function(DeliveryDay) _then) = _$DeliveryDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, List<DeliverySlot> slots, String? closedReason
});




}
/// @nodoc
class _$DeliveryDayCopyWithImpl<$Res>
    implements $DeliveryDayCopyWith<$Res> {
  _$DeliveryDayCopyWithImpl(this._self, this._then);

  final DeliveryDay _self;
  final $Res Function(DeliveryDay) _then;

/// Create a copy of DeliveryDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? slots = null,Object? closedReason = freezed,}) {
  return _then(DeliveryDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as List<DeliverySlot>,closedReason: freezed == closedReason ? _self.closedReason : closedReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryDay].
extension DeliveryDayPatterns on DeliveryDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryDay value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryDay value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  List<DeliverySlot> slots,  String? closedReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryDay() when $default != null:
return $default(_that.date,_that.slots,_that.closedReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  List<DeliverySlot> slots,  String? closedReason)  $default,) {final _that = this;
switch (_that) {
case _DeliveryDay():
return $default(_that.date,_that.slots,_that.closedReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  List<DeliverySlot> slots,  String? closedReason)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryDay() when $default != null:
return $default(_that.date,_that.slots,_that.closedReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryDay extends DeliveryDay {
  const _DeliveryDay({required this.date, required  List<DeliverySlot> slots, this.closedReason}): _slots = slots,super._();
  factory _DeliveryDay.fromJson(Map<String, dynamic> json) => _$DeliveryDayFromJson(json);

@override final  DateTime date;
 final  List<DeliverySlot> _slots;
@override List<DeliverySlot> get slots {
  if (_slots is EqualUnmodifiableListView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slots);
}

/// Set when the store is closed that day (holiday, weekly off).
@override final  String? closedReason;

/// Create a copy of DeliveryDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryDayCopyWith<_DeliveryDay> get copyWith => __$DeliveryDayCopyWithImpl<_DeliveryDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryDayToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryDay&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.slots, _slots)&&(identical(other.closedReason, closedReason) || other.closedReason == closedReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,const DeepCollectionEquality().hash(_slots),closedReason);
}

@override
String toString() {
    return 'DeliveryDay(date: $date, slots: $slots, closedReason: $closedReason)';
}


}

/// @nodoc
abstract mixin class _$DeliveryDayCopyWith<$Res> implements $DeliveryDayCopyWith<$Res> {
  factory _$DeliveryDayCopyWith(_DeliveryDay value, $Res Function(_DeliveryDay) _then) = __$DeliveryDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, List<DeliverySlot> slots, String? closedReason
});




}
/// @nodoc
class __$DeliveryDayCopyWithImpl<$Res>
    implements _$DeliveryDayCopyWith<$Res> {
  __$DeliveryDayCopyWithImpl(this._self, this._then);

  final _DeliveryDay _self;
  final $Res Function(_DeliveryDay) _then;

/// Create a copy of DeliveryDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? slots = null,Object? closedReason = freezed,}) {
  return _then(_DeliveryDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,slots: null == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as List<DeliverySlot>,closedReason: freezed == closedReason ? _self.closedReason : closedReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CheckoutState {

 String get instructions; Coupon? get coupon; DeliveryMode get mode; DeliverySlot? get slot;/// True once the customer tapped "Continue" and picked how to receive the order.
 bool get timingConfirmed;
/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutStateCopyWith<CheckoutState> get copyWith => _$CheckoutStateCopyWithImpl<CheckoutState>(this as CheckoutState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CheckoutState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutState&&(identical(other.instructions, _this.instructions) || other.instructions == _this.instructions)&&(identical(other.coupon, _this.coupon) || other.coupon == _this.coupon)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.slot, _this.slot) || other.slot == _this.slot)&&(identical(other.timingConfirmed, _this.timingConfirmed) || other.timingConfirmed == _this.timingConfirmed));
}


@override
int get hashCode {
  final _this = this as CheckoutState;
  return Object.hash(runtimeType,_this.instructions,_this.coupon,_this.mode,_this.slot,_this.timingConfirmed);
}

@override
String toString() {
  final _this = this as CheckoutState;
  return 'CheckoutState(instructions: ${_this.instructions}, coupon: ${_this.coupon}, mode: ${_this.mode}, slot: ${_this.slot}, timingConfirmed: ${_this.timingConfirmed})';
}


}

/// @nodoc
abstract mixin class $CheckoutStateCopyWith<$Res>  {
  factory $CheckoutStateCopyWith(CheckoutState value, $Res Function(CheckoutState) _then) = _$CheckoutStateCopyWithImpl;
@useResult
$Res call({
 String instructions, Coupon? coupon, DeliveryMode mode, DeliverySlot? slot, bool timingConfirmed
});


$CouponCopyWith<$Res>? get coupon;$DeliverySlotCopyWith<$Res>? get slot;

}
/// @nodoc
class _$CheckoutStateCopyWithImpl<$Res>
    implements $CheckoutStateCopyWith<$Res> {
  _$CheckoutStateCopyWithImpl(this._self, this._then);

  final CheckoutState _self;
  final $Res Function(CheckoutState) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? instructions = null,Object? coupon = freezed,Object? mode = null,Object? slot = freezed,Object? timingConfirmed = null,}) {
  return _then(CheckoutState(
instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,coupon: freezed == coupon ? _self.coupon : coupon // ignore: cast_nullable_to_non_nullable
as Coupon?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DeliveryMode,slot: freezed == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as DeliverySlot?,timingConfirmed: null == timingConfirmed ? _self.timingConfirmed : timingConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CouponCopyWith<$Res>? get coupon {
    if (_self.coupon == null) {
    return null;
  }

  return $CouponCopyWith<$Res>(_self.coupon!, (value) {
    return _then(_self.copyWith(coupon: value));
  });
}/// Create a copy of CheckoutState
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


/// Adds pattern-matching-related methods to [CheckoutState].
extension CheckoutStatePatterns on CheckoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutState value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutState value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String instructions,  Coupon? coupon,  DeliveryMode mode,  DeliverySlot? slot,  bool timingConfirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
return $default(_that.instructions,_that.coupon,_that.mode,_that.slot,_that.timingConfirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String instructions,  Coupon? coupon,  DeliveryMode mode,  DeliverySlot? slot,  bool timingConfirmed)  $default,) {final _that = this;
switch (_that) {
case _CheckoutState():
return $default(_that.instructions,_that.coupon,_that.mode,_that.slot,_that.timingConfirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String instructions,  Coupon? coupon,  DeliveryMode mode,  DeliverySlot? slot,  bool timingConfirmed)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
return $default(_that.instructions,_that.coupon,_that.mode,_that.slot,_that.timingConfirmed);case _:
  return null;

}
}

}

/// @nodoc


class _CheckoutState implements CheckoutState {
  const _CheckoutState({this.instructions = '', this.coupon, this.mode = DeliveryMode.now, this.slot, this.timingConfirmed = false});
  

@override@JsonKey() final  String instructions;
@override final  Coupon? coupon;
@override@JsonKey() final  DeliveryMode mode;
@override final  DeliverySlot? slot;
/// True once the customer tapped "Continue" and picked how to receive the order.
@override@JsonKey() final  bool timingConfirmed;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutStateCopyWith<_CheckoutState> get copyWith => __$CheckoutStateCopyWithImpl<_CheckoutState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutState&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.coupon, coupon) || other.coupon == coupon)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.timingConfirmed, timingConfirmed) || other.timingConfirmed == timingConfirmed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,instructions,coupon,mode,slot,timingConfirmed);
}

@override
String toString() {
    return 'CheckoutState(instructions: $instructions, coupon: $coupon, mode: $mode, slot: $slot, timingConfirmed: $timingConfirmed)';
}


}

/// @nodoc
abstract mixin class _$CheckoutStateCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory _$CheckoutStateCopyWith(_CheckoutState value, $Res Function(_CheckoutState) _then) = __$CheckoutStateCopyWithImpl;
@override @useResult
$Res call({
 String instructions, Coupon? coupon, DeliveryMode mode, DeliverySlot? slot, bool timingConfirmed
});


@override $CouponCopyWith<$Res>? get coupon;@override $DeliverySlotCopyWith<$Res>? get slot;

}
/// @nodoc
class __$CheckoutStateCopyWithImpl<$Res>
    implements _$CheckoutStateCopyWith<$Res> {
  __$CheckoutStateCopyWithImpl(this._self, this._then);

  final _CheckoutState _self;
  final $Res Function(_CheckoutState) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? instructions = null,Object? coupon = freezed,Object? mode = null,Object? slot = freezed,Object? timingConfirmed = null,}) {
  return _then(_CheckoutState(
instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,coupon: freezed == coupon ? _self.coupon : coupon // ignore: cast_nullable_to_non_nullable
as Coupon?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DeliveryMode,slot: freezed == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as DeliverySlot?,timingConfirmed: null == timingConfirmed ? _self.timingConfirmed : timingConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CouponCopyWith<$Res>? get coupon {
    if (_self.coupon == null) {
    return null;
  }

  return $CouponCopyWith<$Res>(_self.coupon!, (value) {
    return _then(_self.copyWith(coupon: value));
  });
}/// Create a copy of CheckoutState
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
