import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/env.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/prefs_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/address.dart';
import '../repositories/address_repository.dart';

part 'address_providers.g.dart';

/// The only place that decides mock vs remote for addresses.
@Riverpod(keepAlive: true)
AddressRepository addressRepository(Ref ref) {
  if (Env.useMock) {
    return MockAddressRepository(
      ref.watch(sharedPrefsProvider),
      () => ref.read(sessionPhoneProvider),
    );
  }
  return RemoteAddressRepository(ref.watch(dioProvider));
}

/// The signed-in customer's saved addresses. Shows the copy cached on the
/// device at once, then refreshes from the server. Changes show immediately
/// and roll back if the server rejects them.
@Riverpod(keepAlive: true)
class Addresses extends _$Addresses {
  String get _cacheKey => 'addresses.cache.${ref.read(sessionPhoneProvider) ?? 'guest'}';

  AddressRepository get _repo => ref.read(addressRepositoryProvider);

  /// Local changes made, and how many are still waiting on the server. A refresh
  /// that overlaps either would bring back the list as it was before the change.
  var _edits = 0;
  var _pending = 0;

  @override
  List<Address> build() {
    final phone = ref.watch(sessionPhoneProvider);
    if (phone != null) Future.microtask(refresh);
    return decodeAddresses(ref.read(sharedPrefsProvider).getString(_cacheKey));
  }

  /// Reloads from the server. Offline, the cached list stays.
  Future<void> refresh() async {
    final phone = ref.read(sessionPhoneProvider);
    final edits = _edits;
    try {
      final fresh = await _repo.fetch();
      // A change made while this was loading is newer than what the server sent.
      if (ref.mounted && ref.read(sessionPhoneProvider) == phone && edits == _edits && _pending == 0) _set(fresh);
    } catch (_) {}
  }

  /// Adds or updates [address] and returns it as saved, with the server's id
  /// for a new one. Callers that want it used for the next order also call
  /// `selectedAddressIdProvider.notifier.select` with that id.
  Future<Address> save(Address address) async {
    _edits++;
    _pending++;
    final isNew = state.every((a) => a.id != address.id);
    final before = state;
    _set(upsertAddress(state, address));
    try {
      final saved = isNew ? await _repo.create(address) : await _repo.update(address);
      _set(upsertAddress([for (final a in state) a.id == address.id ? saved : a], saved));
      return saved;
    } catch (_) {
      _set(before);
      rethrow;
    } finally {
      _syncWhenIdle();
    }
  }

  Future<void> makeDefault(String id) => _change(
        [for (final a in state) a.copyWith(isDefault: a.id == id)],
        () => _repo.makeDefault(id),
      );

  Future<void> remove(String id) =>
      _change(state.where((a) => a.id != id).toList(), () => _repo.remove(id));

  Future<void> _change(List<Address> next, Future<void> Function() send) async {
    _edits++;
    _pending++;
    final before = state;
    _set(next);
    try {
      await send();
    } catch (_) {
      _set(before);
      rethrow;
    } finally {
      _syncWhenIdle();
    }
  }

  /// Once the last change has been answered, take the server's list, which now
  /// includes it, in case a refresh was skipped while changes were in flight.
  void _syncWhenIdle() {
    if (--_pending == 0 && ref.mounted) unawaited(refresh());
  }

  void _set(List<Address> addresses) {
    state = withOneDefault(addresses);
    ref.read(sharedPrefsProvider).setString(_cacheKey, encodeAddresses(state));
  }
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
