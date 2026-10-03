import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

enum AddressLabel {
  home('Home'),
  work('Work'),
  other('Other');

  const AddressLabel(this.title);

  final String title;
}

@freezed
abstract class Address with _$Address {
  const Address._();

  const factory Address({
    required String id,
    required AddressLabel label,

    /// Name for an "Other" address, e.g. "Mom's place".
    String? customLabel,

    /// House / flat / floor / building.
    required String house,

    /// Area, sector, street or village.
    required String area,
    @Default('') String landmark,
    required String city,
    required String pincode,

    /// Who receives the order at this address.
    required String name,
    required String phone,
    @Default(false) bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

  /// "Home", "Work" or the custom name of an "Other" address.
  String get title {
    final custom = customLabel?.trim() ?? '';
    return label == AddressLabel.other && custom.isNotEmpty ? custom : label.title;
  }

  /// One-line postal address.
  String get line => [
        house,
        area,
        if (landmark.trim().isNotEmpty) 'Near ${landmark.trim()}',
        '$city - $pincode',
      ].join(', ');

  String get fullText => '$title • $line';
}
