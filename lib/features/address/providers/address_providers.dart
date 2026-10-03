import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/prefs_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/address.dart';

part 'address_providers.g.dart';

/// The signed-in customer's saved addresses, kept on the device per phone
/// number. A new customer starts with none and adds one at checkout.
@Riverpod(keepAlive: true)
class Addresses extends _$Addresses {
  String get _key => 'addresses.${ref.read(sessionPhoneProvider) ?? 'guest'}';

  @override
  List<Address> build() {
    ref.watch(sessionPhoneProvider);
    final raw = ref.read(sharedPrefsProvider).getString(_key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(Address.fromJson)
          .toList();
    } catch (_) {
      return const []; // corrupt or outdated data: start clean rather than crash
    }
  }

  void _set(List<Address> addresses) {
    // Exactly one default whenever there is at least one address.
    final normalized = addresses.isEmpty || addresses.any((a) => a.isDefault)
        ? addresses
        : [addresses.first.copyWith(isDefault: true), ...addresses.skip(1)];
    state = normalized;
    ref
        .read(sharedPrefsProvider)
        .setString(_key, jsonEncode([for (final a in normalized) a.toJson()]));
  }

  /// Adds or updates [address]. Callers that want it used for the next order
  /// also call `selectedAddressIdProvider.notifier.select`.
  void save(Address address) {
    var list = [
      for (final a in state)
        if (a.id != address.id) address.isDefault ? a.copyWith(isDefault: false) : a,
    ];
    final index = state.indexWhere((a) => a.id == address.id);
    list = index == -1 ? [...list, address] : (list..insert(index, address));
    _set(list);
  }

  void makeDefault(String id) =>
      _set([for (final a in state) a.copyWith(isDefault: a.id == id)]);

  void remove(String id) => _set(state.where((a) => a.id != id).toList());
}

/// The address the next order goes to: the customer's pick, else the default.
@Riverpod(keepAlive: true)
class SelectedAddressId extends _$SelectedAddressId {
  String? _picked;

  @override
  String? build() {
    final addresses = ref.watch(addressesProvider);
    if (addresses.any((a) => a.id == _picked)) return _picked;
    _picked = null;
    return (addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull)?.id;
  }

  void select(String id) => state = _picked = id;
}

@Riverpod(keepAlive: true)
Address? selectedAddress(Ref ref) {
  final id = ref.watch(selectedAddressIdProvider);
  return ref.watch(addressesProvider).where((a) => a.id == id).firstOrNull;
}
