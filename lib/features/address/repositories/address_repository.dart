import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_call.dart';
import '../../../core/network/endpoints.dart';
import '../models/address.dart';

/// The customer's saved delivery addresses. The server owns ids and keeps
/// exactly one default.
abstract interface class AddressRepository {
  Future<List<Address>> fetch();

  /// Returns the address with the id the server gave it.
  Future<Address> create(Address address);

  Future<Address> update(Address address);

  Future<void> remove(String id);

  Future<void> makeDefault(String id);
}

/// Inserts or replaces [address]; a new default clears the old one.
List<Address> upsertAddress(List<Address> list, Address address) {
  final others = [
    for (final a in list)
      if (a.id != address.id) address.isDefault ? a.copyWith(isDefault: false) : a,
  ];
  final index = list.indexWhere((a) => a.id == address.id);
  return index == -1 ? [...others, address] : (others..insert(index, address));
}

/// Exactly one default whenever there is at least one address.
List<Address> withOneDefault(List<Address> list) =>
    list.isEmpty || list.any((a) => a.isDefault)
        ? list
        : [list.first.copyWith(isDefault: true), ...list.skip(1)];

/// Stands in for the server: keeps addresses on the device per phone number.
class MockAddressRepository implements AddressRepository {
  MockAddressRepository(this._prefs, this._phone);

  final SharedPreferences _prefs;
  final String? Function() _phone;

  String get _key => 'addresses.${_phone() ?? 'guest'}';

  @override
  Future<List<Address>> fetch() async => _read();

  @override
  Future<Address> create(Address address) async {
    _write(upsertAddress(_read(), address));
    return address;
  }

  @override
  Future<Address> update(Address address) => create(address);

  @override
  Future<void> remove(String id) async => _write(_read().where((a) => a.id != id).toList());

  @override
  Future<void> makeDefault(String id) async =>
      _write([for (final a in _read()) a.copyWith(isDefault: a.id == id)]);

  List<Address> _read() => decodeAddresses(_prefs.getString(_key));

  void _write(List<Address> list) => _prefs.setString(_key, encodeAddresses(withOneDefault(list)));
}

/// Assumed API shape (adjust when the contract lands):
/// * `GET /addresses` -> `{ "data": [ Address ] }`
/// * `POST /addresses` Address without `id` -> `{ "data": Address }`
/// * `PUT /addresses/{id}` Address -> `{ "data": Address }`
/// * `DELETE /addresses/{id}`
/// * `POST /addresses/{id}/default`
///
/// An address is `{ id, label: home|work|other, customLabel, house, area,
/// landmark, city, pincode, name, phone, isDefault }`. The server should
/// reject pincodes it doesn't deliver to with a 4xx `{ "message" }`.
class RemoteAddressRepository implements AddressRepository {
  RemoteAddressRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Address>> fetch() => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>(Endpoints.addresses);
        return (res.data?['data'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(Address.fromJson)
            .toList();
      });

  @override
  Future<Address> create(Address address) => apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          Endpoints.addresses,
          data: address.toJson()..remove('id'),
        );
        return Address.fromJson(res.data?['data'] as Map<String, dynamic>);
      });

  @override
  Future<Address> update(Address address) => apiCall(() async {
        final res = await _dio.put<Map<String, dynamic>>(
          Endpoints.address(address.id),
          data: address.toJson(),
        );
        return Address.fromJson(res.data?['data'] as Map<String, dynamic>);
      });

  @override
  Future<void> remove(String id) => apiCall(() async {
        await _dio.delete<void>(Endpoints.address(id));
      });

  @override
  Future<void> makeDefault(String id) => apiCall(() async {
        await _dio.post<void>(Endpoints.addressDefault(id));
      });
}

/// Saved-list encoding shared by the mock and the on-device cache.
String encodeAddresses(List<Address> list) => jsonEncode([for (final a in list) a.toJson()]);

/// Corrupt or outdated data gives an empty list rather than a crash.
List<Address> decodeAddresses(String? raw) {
  if (raw == null) return const [];
  try {
    return (jsonDecode(raw) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Address.fromJson)
        .toList();
  } catch (_) {
    return const [];
  }
}
