// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The only place that decides mock vs remote for addresses.

@ProviderFor(addressRepository)
final addressRepositoryProvider = AddressRepositoryProvider._();

/// The only place that decides mock vs remote for addresses.

final class AddressRepositoryProvider
    extends
        $FunctionalProvider<
          AddressRepository,
          AddressRepository,
          AddressRepository
        >
    with $Provider<AddressRepository> {
  /// The only place that decides mock vs remote for addresses.
  AddressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addressRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addressRepositoryHash();

  @$internal
  @override
  $ProviderElement<AddressRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddressRepository create(Ref ref) {
    return addressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddressRepository>(value),
    );
  }
}

String _$addressRepositoryHash() => r'068ea2f178bcc5769a80b313409491ea0cc6177f';

/// The signed-in customer's saved addresses. Shows the copy cached on the
/// device at once, then refreshes from the server. Changes show immediately
/// and roll back if the server rejects them.

@ProviderFor(Addresses)
final addressesProvider = AddressesProvider._();

/// The signed-in customer's saved addresses. Shows the copy cached on the
/// device at once, then refreshes from the server. Changes show immediately
/// and roll back if the server rejects them.
final class AddressesProvider
    extends $NotifierProvider<Addresses, List<Address>> {
  /// The signed-in customer's saved addresses. Shows the copy cached on the
  /// device at once, then refreshes from the server. Changes show immediately
  /// and roll back if the server rejects them.
  AddressesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addressesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addressesHash();

  @$internal
  @override
  Addresses create() => Addresses();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Address> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Address>>(value),
    );
  }
}

String _$addressesHash() => r'a7a46fe8ac9a29646566f75d3ab288a6790b2bd4';

/// The signed-in customer's saved addresses. Shows the copy cached on the
/// device at once, then refreshes from the server. Changes show immediately
/// and roll back if the server rejects them.

abstract class _$Addresses extends $Notifier<List<Address>> {
  List<Address> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Address>, List<Address>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Address>, List<Address>>,
              List<Address>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The address the next order goes to: the customer's pick, else the default.

@ProviderFor(SelectedAddressId)
final selectedAddressIdProvider = SelectedAddressIdProvider._();

/// The address the next order goes to: the customer's pick, else the default.
final class SelectedAddressIdProvider
    extends $NotifierProvider<SelectedAddressId, String?> {
  /// The address the next order goes to: the customer's pick, else the default.
  SelectedAddressIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAddressIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAddressIdHash();

  @$internal
  @override
  SelectedAddressId create() => SelectedAddressId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedAddressIdHash() => r'b0154ef8ecb0ba6a6a667517bcdd7207ccc14799';

/// The address the next order goes to: the customer's pick, else the default.

abstract class _$SelectedAddressId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(selectedAddress)
final selectedAddressProvider = SelectedAddressProvider._();

final class SelectedAddressProvider
    extends $FunctionalProvider<Address?, Address?, Address?>
    with $Provider<Address?> {
  SelectedAddressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAddressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAddressHash();

  @$internal
  @override
  $ProviderElement<Address?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Address? create(Ref ref) {
    return selectedAddress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Address? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Address?>(value),
    );
  }
}

String _$selectedAddressHash() => r'487790925dd07a67c5d470b6df70e83259a0b19a';
