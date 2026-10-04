// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The cart, kept on the device per phone number so it survives an app restart.

@ProviderFor(Cart)
final cartProvider = CartProvider._();

/// The cart, kept on the device per phone number so it survives an app restart.
final class CartProvider extends $NotifierProvider<Cart, List<CartLine>> {
  /// The cart, kept on the device per phone number so it survives an app restart.
  CartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartHash();

  @$internal
  @override
  Cart create() => Cart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CartLine> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CartLine>>(value),
    );
  }
}

String _$cartHash() => r'60240da1734bee2417cc653a4281824cb54bd626';

/// The cart, kept on the device per phone number so it survives an app restart.

abstract class _$Cart extends $Notifier<List<CartLine>> {
  List<CartLine> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<CartLine>, List<CartLine>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<CartLine>, List<CartLine>>,
              List<CartLine>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(cartSummary)
final cartSummaryProvider = CartSummaryProvider._();

final class CartSummaryProvider
    extends $FunctionalProvider<CartSummary, CartSummary, CartSummary>
    with $Provider<CartSummary> {
  CartSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartSummaryHash();

  @$internal
  @override
  $ProviderElement<CartSummary> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CartSummary create(Ref ref) {
    return cartSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartSummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartSummary>(value),
    );
  }
}

String _$cartSummaryHash() => r'f76c7b2405de7822e395e78703efeea22c7031f4';

@ProviderFor(productQuantity)
final productQuantityProvider = ProductQuantityFamily._();

final class ProductQuantityProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  ProductQuantityProvider._({
    required ProductQuantityFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productQuantityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productQuantityHash();

  @override
  String toString() {
    return r'productQuantityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return productQuantity(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProductQuantityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productQuantityHash() => r'5b4f592f31eaaf141228a5a23f13d79c3777a32e';

final class ProductQuantityFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  ProductQuantityFamily._()
    : super(
        retry: null,
        name: r'productQuantityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductQuantityProvider call(String productId) =>
      ProductQuantityProvider._(argument: productId, from: this);

  @override
  String toString() => r'productQuantityProvider';
}

@ProviderFor(lineQuantity)
final lineQuantityProvider = LineQuantityFamily._();

final class LineQuantityProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  LineQuantityProvider._({
    required LineQuantityFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'lineQuantityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineQuantityHash();

  @override
  String toString() {
    return r'lineQuantityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return lineQuantity(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LineQuantityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineQuantityHash() => r'6e160787832de1ff8a13ccc5fa414fea67f8a122';

final class LineQuantityFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  LineQuantityFamily._()
    : super(
        retry: null,
        name: r'lineQuantityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LineQuantityProvider call(String lineId) =>
      LineQuantityProvider._(argument: lineId, from: this);

  @override
  String toString() => r'lineQuantityProvider';
}
