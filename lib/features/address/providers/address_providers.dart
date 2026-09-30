import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/address.dart';

part 'address_providers.g.dart';

@Riverpod(keepAlive: true)
class Addresses extends _$Addresses {
  @override
  List<Address> build() {
    ref.watch(sessionPhoneProvider);
    final user = ref.read(authSessionProvider);
    final name = user?.name ?? 'Customer';
    final phone = user?.phone ?? '';
    return [
      Address(
        id: 'home',
        label: AddressLabel.home,
        name: name,
        phone: phone,
        line: 'House No. 123, Green Park Main, Koramangala, Bengaluru - 560034',
      ),
      Address(
        id: 'work',
        label: AddressLabel.work,
        name: name,
        phone: phone,
        line: 'Tower B, Embassy Tech Village, Indiranagar, Bengaluru - 560038',
      ),
    ];
  }

  void save(Address address) {
    final exists = state.any((a) => a.id == address.id);
    state = exists
        ? [for (final a in state) a.id == address.id ? address : a]
        : [...state, address];
    if (!exists) ref.read(selectedAddressIdProvider.notifier).select(address.id);
  }

  bool remove(String id) {
    if (state.length <= 1) return false;
    state = state.where((a) => a.id != id).toList();
    final selected = ref.read(selectedAddressIdProvider);
    if (selected == id) ref.read(selectedAddressIdProvider.notifier).select(state.first.id);
    return true;
  }
}

@Riverpod(keepAlive: true)
class SelectedAddressId extends _$SelectedAddressId {
  @override
  String build() => 'home';

  void select(String id) => state = id;
}

@Riverpod(keepAlive: true)
Address selectedAddress(Ref ref) {
  final addresses = ref.watch(addressesProvider);
  final id = ref.watch(selectedAddressIdProvider);
  return addresses.firstWhere((a) => a.id == id, orElse: () => addresses.first);
}
