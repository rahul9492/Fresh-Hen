// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderRepository)
final orderRepositoryProvider = OrderRepositoryProvider._();

final class OrderRepositoryProvider
    extends
        $FunctionalProvider<OrderRepository, OrderRepository, OrderRepository>
    with $Provider<OrderRepository> {
  OrderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderRepository create(Ref ref) {
    return orderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderRepository>(value),
    );
  }
}

String _$orderRepositoryHash() => r'dee06663f1fff54035d6193c01ba818caa5c4917';

@ProviderFor(Orders)
final ordersProvider = OrdersProvider._();

final class OrdersProvider extends $AsyncNotifierProvider<Orders, List<Order>> {
  OrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ordersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ordersHash();

  @$internal
  @override
  Orders create() => Orders();
}

String _$ordersHash() => r'489295d4c167c33326348caecf690b722dfc77f4';

abstract class _$Orders extends $AsyncNotifier<List<Order>> {
  FutureOr<List<Order>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One order by id, from the loaded history.

@ProviderFor(order)
final orderProvider = OrderFamily._();

/// One order by id, from the loaded history.

final class OrderProvider
    extends $FunctionalProvider<AsyncValue<Order?>, Order?, FutureOr<Order?>>
    with $FutureModifier<Order?>, $FutureProvider<Order?> {
  /// One order by id, from the loaded history.
  OrderProvider._({
    required OrderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderHash();

  @override
  String toString() {
    return r'orderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Order?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Order?> create(Ref ref) {
    final argument = this.argument as String;
    return order(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderHash() => r'c72c82b60c19525b44bec499f6b2f8232dc78507';

/// One order by id, from the loaded history.

final class OrderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Order?>, String> {
  OrderFamily._()
    : super(
        retry: null,
        name: r'orderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One order by id, from the loaded history.

  OrderProvider call(String id) => OrderProvider._(argument: id, from: this);

  @override
  String toString() => r'orderProvider';
}

@ProviderFor(PlaceOrder)
final placeOrderProvider = PlaceOrderProvider._();

final class PlaceOrderProvider
    extends $AsyncNotifierProvider<PlaceOrder, Order?> {
  PlaceOrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placeOrderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placeOrderHash();

  @$internal
  @override
  PlaceOrder create() => PlaceOrder();
}

String _$placeOrderHash() => r'228bae6779dc8319a966c65e6db0e92db9d5a3ad';

abstract class _$PlaceOrder extends $AsyncNotifier<Order?> {
  FutureOr<Order?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Order?>, Order?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Order?>, Order?>,
              AsyncValue<Order?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
