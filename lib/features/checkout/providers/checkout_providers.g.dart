// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The only place that decides mock vs remote for checkout data.

@ProviderFor(checkoutRepository)
final checkoutRepositoryProvider = CheckoutRepositoryProvider._();

/// The only place that decides mock vs remote for checkout data.

final class CheckoutRepositoryProvider
    extends
        $FunctionalProvider<
          CheckoutRepository,
          CheckoutRepository,
          CheckoutRepository
        >
    with $Provider<CheckoutRepository> {
  /// The only place that decides mock vs remote for checkout data.
  CheckoutRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutRepositoryHash();

  @$internal
  @override
  $ProviderElement<CheckoutRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckoutRepository create(Ref ref) {
    return checkoutRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutRepository>(value),
    );
  }
}

String _$checkoutRepositoryHash() =>
    r'4cb72d2f2dcd0dea091a6e2c7a198cc22ff6eeee';

/// Admin-managed checkout rules. The cart refreshes this when it opens, so a
/// change in the admin app (schedule switch, new QR) shows up without a restart.

@ProviderFor(storeSettings)
final storeSettingsProvider = StoreSettingsProvider._();

/// Admin-managed checkout rules. The cart refreshes this when it opens, so a
/// change in the admin app (schedule switch, new QR) shows up without a restart.

final class StoreSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<StoreSettings>,
          StoreSettings,
          FutureOr<StoreSettings>
        >
    with $FutureModifier<StoreSettings>, $FutureProvider<StoreSettings> {
  /// Admin-managed checkout rules. The cart refreshes this when it opens, so a
  /// change in the admin app (schedule switch, new QR) shows up without a restart.
  StoreSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeSettingsHash();

  @$internal
  @override
  $FutureProviderElement<StoreSettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StoreSettings> create(Ref ref) {
    return storeSettings(ref);
  }
}

String _$storeSettingsHash() => r'9edf3a9d908b572a467d2faf47d3bc7d454d0f3a';

/// Loaded settings, or the defaults while they load so the cart can render.

@ProviderFor(currentStoreSettings)
final currentStoreSettingsProvider = CurrentStoreSettingsProvider._();

/// Loaded settings, or the defaults while they load so the cart can render.

final class CurrentStoreSettingsProvider
    extends $FunctionalProvider<StoreSettings, StoreSettings, StoreSettings>
    with $Provider<StoreSettings> {
  /// Loaded settings, or the defaults while they load so the cart can render.
  CurrentStoreSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentStoreSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentStoreSettingsHash();

  @$internal
  @override
  $ProviderElement<StoreSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoreSettings create(Ref ref) {
    return currentStoreSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreSettings>(value),
    );
  }
}

String _$currentStoreSettingsHash() =>
    r'961a178704abda7ba63fde1c758eecc32e050f59';

/// Fetched fresh each time the slot picker opens, so full slots are current.

@ProviderFor(deliveryDays)
final deliveryDaysProvider = DeliveryDaysProvider._();

/// Fetched fresh each time the slot picker opens, so full slots are current.

final class DeliveryDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeliveryDay>>,
          List<DeliveryDay>,
          FutureOr<List<DeliveryDay>>
        >
    with
        $FutureModifier<List<DeliveryDay>>,
        $FutureProvider<List<DeliveryDay>> {
  /// Fetched fresh each time the slot picker opens, so full slots are current.
  DeliveryDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryDaysHash();

  @$internal
  @override
  $FutureProviderElement<List<DeliveryDay>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DeliveryDay>> create(Ref ref) {
    return deliveryDays(ref);
  }
}

String _$deliveryDaysHash() => r'2eabdd365c58230582debfeedcd25a961f2bd6d4';

@ProviderFor(coupons)
final couponsProvider = CouponsProvider._();

final class CouponsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Coupon>>,
          List<Coupon>,
          FutureOr<List<Coupon>>
        >
    with $FutureModifier<List<Coupon>>, $FutureProvider<List<Coupon>> {
  CouponsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'couponsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$couponsHash();

  @$internal
  @override
  $FutureProviderElement<List<Coupon>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Coupon>> create(Ref ref) {
    return coupons(ref);
  }
}

String _$couponsHash() => r'553bebe1543b73617920ec36b22345c3c090e9ff';

/// True when the customer has never had an order delivered or on its way.
/// Unknown (still loading) counts as false so first-order coupons aren't misused.

@ProviderFor(isFirstOrder)
final isFirstOrderProvider = IsFirstOrderProvider._();

/// True when the customer has never had an order delivered or on its way.
/// Unknown (still loading) counts as false so first-order coupons aren't misused.

final class IsFirstOrderProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// True when the customer has never had an order delivered or on its way.
  /// Unknown (still loading) counts as false so first-order coupons aren't misused.
  IsFirstOrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isFirstOrderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isFirstOrderHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isFirstOrder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isFirstOrderHash() => r'9e1675f728e16db7c676a2e3509f16e30b42630b';

@ProviderFor(Checkout)
final checkoutProvider = CheckoutProvider._();

final class CheckoutProvider
    extends $NotifierProvider<Checkout, CheckoutState> {
  CheckoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutHash();

  @$internal
  @override
  Checkout create() => Checkout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutState>(value),
    );
  }
}

String _$checkoutHash() => r'c524e11d70c4bef8cc7188fbf0407bc7378203f4';

abstract class _$Checkout extends $Notifier<CheckoutState> {
  CheckoutState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CheckoutState, CheckoutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckoutState, CheckoutState>,
              CheckoutState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The delivery mode that will actually be used: scheduling falls back to
/// "Order now" if the admin switched it off after the customer picked a slot.

@ProviderFor(deliveryMode)
final deliveryModeProvider = DeliveryModeProvider._();

/// The delivery mode that will actually be used: scheduling falls back to
/// "Order now" if the admin switched it off after the customer picked a slot.

final class DeliveryModeProvider
    extends $FunctionalProvider<DeliveryMode, DeliveryMode, DeliveryMode>
    with $Provider<DeliveryMode> {
  /// The delivery mode that will actually be used: scheduling falls back to
  /// "Order now" if the admin switched it off after the customer picked a slot.
  DeliveryModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryModeHash();

  @$internal
  @override
  $ProviderElement<DeliveryMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeliveryMode create(Ref ref) {
    return deliveryMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeliveryMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeliveryMode>(value),
    );
  }
}

String _$deliveryModeHash() => r'1751d94644f5488f435a79eaa11e94dd54f7ef2d';

/// Why the applied coupon doesn't apply right now (e.g. cart dropped below the
/// minimum), or null. The coupon stays applied and kicks in again once valid.

@ProviderFor(couponIssue)
final couponIssueProvider = CouponIssueProvider._();

/// Why the applied coupon doesn't apply right now (e.g. cart dropped below the
/// minimum), or null. The coupon stays applied and kicks in again once valid.

final class CouponIssueProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Why the applied coupon doesn't apply right now (e.g. cart dropped below the
  /// minimum), or null. The coupon stays applied and kicks in again once valid.
  CouponIssueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'couponIssueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$couponIssueHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return couponIssue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$couponIssueHash() => r'9fd4eec17f56d3b0b22c0ada6ca33b581b527a99';

@ProviderFor(checkoutBill)
final checkoutBillProvider = CheckoutBillProvider._();

final class CheckoutBillProvider
    extends $FunctionalProvider<OrderBill, OrderBill, OrderBill>
    with $Provider<OrderBill> {
  CheckoutBillProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutBillProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutBillHash();

  @$internal
  @override
  $ProviderElement<OrderBill> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderBill create(Ref ref) {
    return checkoutBill(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderBill value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderBill>(value),
    );
  }
}

String _$checkoutBillHash() => r'804356e1c9cbc1dc947ded6a1461b2c488046d77';

@ProviderFor(checkoutStep)
final checkoutStepProvider = CheckoutStepProvider._();

final class CheckoutStepProvider
    extends $FunctionalProvider<CheckoutStep, CheckoutStep, CheckoutStep>
    with $Provider<CheckoutStep> {
  CheckoutStepProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutStepProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutStepHash();

  @$internal
  @override
  $ProviderElement<CheckoutStep> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CheckoutStep create(Ref ref) {
    return checkoutStep(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutStep value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutStep>(value),
    );
  }
}

String _$checkoutStepHash() => r'51ac1f9141d67cd6ed96ff8c61c5de8ed2038db8';
