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

final class OrdersProvider extends $NotifierProvider<Orders, List<Order>> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Order> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Order>>(value),
    );
  }
}

String _$ordersHash() => r'e67c515b2ca371950af35debaa808518c99e948d';

abstract class _$Orders extends $Notifier<List<Order>> {
  List<Order> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Order>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Order>, List<Order>>,
              List<Order>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
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

String _$placeOrderHash() => r'eaddfbb95235e2f02ff942d7a9777b857c8a7901';

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
