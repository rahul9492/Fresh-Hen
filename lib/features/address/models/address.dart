import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';

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
    required String name,
    required String phone,
    required String line,
  }) = _Address;

  String get fullText => '${label.title} • $line';
}
