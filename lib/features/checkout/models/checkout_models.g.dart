// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreSettings _$StoreSettingsFromJson(Map<String, dynamic> json) =>
    _StoreSettings(
      scheduleEnabled: json['scheduleEnabled'] as bool? ?? false,
      etaMinMinutes: (json['etaMinMinutes'] as num?)?.toInt() ?? 45,
      etaMaxMinutes: (json['etaMaxMinutes'] as num?)?.toInt() ?? 90,
      cashOnDeliveryEnabled: json['cashOnDeliveryEnabled'] as bool? ?? true,
      upiQrImage: json['upiQrImage'] as String?,
      upiId: json['upiId'] as String?,
      upiPayeeName: json['upiPayeeName'] as String? ?? 'Fresh Hen',
      deliveryFee: (json['deliveryFee'] as num?)?.toInt() ?? 40,
      freeDeliveryAbove: (json['freeDeliveryAbove'] as num?)?.toInt() ?? 499,
      packagingFee: (json['packagingFee'] as num?)?.toInt() ?? 0,
      taxPercent: (json['taxPercent'] as num?)?.toInt() ?? 0,
      legalName: json['legalName'] as String? ?? 'Fresh Hen Foods Pvt. Ltd.',
      gstin: json['gstin'] as String? ?? '',
      fssaiLicense: json['fssaiLicense'] as String? ?? '',
      storeAddress: json['storeAddress'] as String? ?? '',
      supportPhone: json['supportPhone'] as String? ?? '',
      supportEmail: json['supportEmail'] as String? ?? '',
      termsUrl: json['termsUrl'] as String? ?? '',
      privacyUrl: json['privacyUrl'] as String? ?? '',
      deliveryPincodes:
          (json['deliveryPincodes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$StoreSettingsToJson(_StoreSettings instance) =>
    <String, dynamic>{
      'scheduleEnabled': instance.scheduleEnabled,
      'etaMinMinutes': instance.etaMinMinutes,
      'etaMaxMinutes': instance.etaMaxMinutes,
      'cashOnDeliveryEnabled': instance.cashOnDeliveryEnabled,
      'upiQrImage': instance.upiQrImage,
      'upiId': instance.upiId,
      'upiPayeeName': instance.upiPayeeName,
      'deliveryFee': instance.deliveryFee,
      'freeDeliveryAbove': instance.freeDeliveryAbove,
      'packagingFee': instance.packagingFee,
      'taxPercent': instance.taxPercent,
      'legalName': instance.legalName,
      'gstin': instance.gstin,
      'fssaiLicense': instance.fssaiLicense,
      'storeAddress': instance.storeAddress,
      'supportPhone': instance.supportPhone,
      'supportEmail': instance.supportEmail,
      'termsUrl': instance.termsUrl,
      'privacyUrl': instance.privacyUrl,
      'deliveryPincodes': instance.deliveryPincodes,
    };

_Coupon _$CouponFromJson(Map<String, dynamic> json) => _Coupon(
  code: json['code'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  percentOff: (json['percentOff'] as num?)?.toInt() ?? 0,
  flatOff: (json['flatOff'] as num?)?.toInt() ?? 0,
  maxDiscount: (json['maxDiscount'] as num?)?.toInt() ?? 0,
  minOrder: (json['minOrder'] as num?)?.toInt() ?? 0,
  firstOrderOnly: json['firstOrderOnly'] as bool? ?? false,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$CouponToJson(_Coupon instance) => <String, dynamic>{
  'code': instance.code,
  'title': instance.title,
  'description': instance.description,
  'percentOff': instance.percentOff,
  'flatOff': instance.flatOff,
  'maxDiscount': instance.maxDiscount,
  'minOrder': instance.minOrder,
  'firstOrderOnly': instance.firstOrderOnly,
  'expiresAt': instance.expiresAt?.toIso8601String(),
};

_DeliveryDay _$DeliveryDayFromJson(Map<String, dynamic> json) => _DeliveryDay(
  date: DateTime.parse(json['date'] as String),
  slots: (json['slots'] as List<dynamic>)
      .map((e) => DeliverySlot.fromJson(e as Map<String, dynamic>))
      .toList(),
  closedReason: json['closedReason'] as String?,
);

Map<String, dynamic> _$DeliveryDayToJson(_DeliveryDay instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'slots': instance.slots,
      'closedReason': instance.closedReason,
    };
