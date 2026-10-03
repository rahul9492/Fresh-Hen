// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in customer's saved addresses, kept on the device per phone
/// number. A new customer starts with none and adds one at checkout.

@ProviderFor(Addresses)
final addressesProvider = AddressesProvider._();

/// The signed-in customer's saved addresses, kept on the device per phone
/// number. A new customer starts with none and adds one at checkout.
final class AddressesProvider
    extends $NotifierProvider<Addresses, List<Address>> {
  /// The signed-in customer's saved addresses, kept on the device per phone
  /// number. A new customer starts with none and adds one at checkout.
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

String _$addressesHash() => r'c2e24d21bfc0e1031f4397893aa383459c1ad313';

/// The signed-in customer's saved addresses, kept on the device per phone
/// number. A new customer starts with none and adds one at checkout.

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
