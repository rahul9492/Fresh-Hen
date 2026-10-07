import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/errors/app_exception.dart';
import 'package:fresh_hen/core/push/push_service.dart';
import 'package:fresh_hen/features/address/models/address.dart';
import 'package:fresh_hen/features/address/providers/address_providers.dart';
import 'package:fresh_hen/features/address/repositories/address_repository.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';
import 'package:fresh_hen/features/catalog/providers/catalog_providers.dart';
import 'package:fresh_hen/features/catalog/repositories/catalog_repository.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';
import 'package:fresh_hen/features/checkout/models/checkout_models.dart';
import 'package:fresh_hen/features/checkout/providers/checkout_providers.dart';
import 'package:fresh_hen/features/checkout/repositories/checkout_repository.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/providers/order_providers.dart';
import 'package:fresh_hen/features/orders/repositories/order_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'fixtures.dart';
import 'pump.dart' show ignoreLayoutOverflow;

/// Push without Firebase.
class FakePush extends PushService {
  FakePush(super.ref);

  @override
  Stream<Map<String, dynamic>> get received => const Stream.empty();

  @override
  Future<void> unregister() async {}
}

/// A catalog served straight from memory.
class FakeCatalog implements CatalogRepository {
  FakeCatalog(this.items, {this.categoryList = const [], this.bannerList = const []});

  final List<Product> items;
  final List<Category> categoryList;
  final List<PromoBanner> bannerList;

  @override
  Future<List<Category>> categories() async => categoryList;

  @override
  Future<List<Product>> products() async => items;

  @override
  Future<List<PromoBanner>> banners() async => bannerList;
}

/// Store settings and coupons without the mock latency.
class FakeCheckout extends MockCheckoutRepository {
  FakeCheckout(this.value, {this.couponList, this.days});

  final StoreSettings value;
  final List<Coupon>? couponList;
  final List<DeliveryDay>? days;

  @override
  Future<StoreSettings> settings() async => value;

  @override
  Future<List<Coupon>> coupons() async => couponList ?? mockCoupons(DateTime.now());

  @override
  Future<List<DeliveryDay>> deliveryDays() async => days ?? mockDeliveryDays(DateTime.now());

  @override
  Future<Coupon> findCoupon(String code) async {
    final wanted = code.trim().toUpperCase();
    final all = couponList ?? mockCoupons(DateTime.now());
    return all.firstWhere(
      (c) => c.code == wanted,
      orElse: () => throw const AppException('This coupon code is not valid'),
    );
  }
}

/// A server that remembers what it is told, like the real one.
class FakeAddresses implements AddressRepository {
  FakeAddresses(List<Address> start) : list = [...start];

  List<Address> list;

  @override
  Future<List<Address>> fetch() async => [...list];

  @override
  Future<Address> create(Address address) async {
    list = upsertAddress(list, address);
    return address;
  }

  @override
  Future<Address> update(Address address) async {
    list = upsertAddress(list, address);
    return address;
  }

  @override
  Future<void> remove(String id) async => list = list.where((a) => a.id != id).toList();

  @override
  Future<void> makeDefault(String id) async =>
      list = [for (final a in list) a.copyWith(isDefault: a.id == id)];
}

/// Orders kept in memory, with no latency.
class FakeOrders implements OrderRepository {
  FakeOrders([List<Order> start = const []]) : orders = [...start];

  final List<Order> orders;
  final List<OrderRequest> placed = [];
  final List<(String, int, String?)> ratings = [];
  final List<(String, String)> cancels = [];
  bool failPlace = false;

  /// How long placing takes, so a test can look at the screen meanwhile.
  Duration placeLatency = Duration.zero;

  @override
  Future<List<Order>> fetch() async => List.of(orders);

  @override
  Future<String> uploadPaymentProof(Uint8List bytes, String fileName) async => 'proof/$fileName';

  @override
  Future<Order> place(OrderRequest request) async {
    if (placeLatency > Duration.zero) await Future<void>.delayed(placeLatency);
    if (failPlace) throw Exception('rejected');
    placed.add(request);
    final order = Order(
      id: 'FH${1000 + orders.length}',
      placedAt: DateTime.now(),
      lines: request.lines,
      bill: request.bill,
      address: request.address,
      addressLabel: request.addressLabel,
      paymentMethod: request.paymentMethod,
      paymentStatus: request.paymentMethod == PaymentMethod.upi
          ? PaymentStatus.verifying
          : PaymentStatus.due,
      instructions: request.instructions,
      paymentProof: request.paymentProof,
      paymentReference: request.paymentReference,
      events: [OrderEvent(status: OrderStatus.confirmed, at: DateTime.now())],
    );
    orders.insert(0, order);
    return order;
  }

  @override
  Future<void> rate(String orderId, {required int stars, String? comment}) async {
    ratings.add((orderId, stars, comment));
  }

  @override
  Future<Order> cancel(String orderId, {required String reason}) async {
    cancels.add((orderId, reason));
    final i = orders.indexWhere((o) => o.id == orderId);
    return orders[i] = orders[i].copyWith(status: OrderStatus.cancelled, cancelReason: reason);
  }
}

const homeAddress = Address(
  id: 'a1',
  label: AddressLabel.home,
  house: 'Flat 503',
  area: 'Sector 62',
  city: 'Noida',
  pincode: '201301',
  name: 'Rahul',
  phone: '9876543210',
  isDefault: true,
);

/// Everything a feature widget needs, wired to in-memory fakes.
class Harness {
  Harness(this.container, this.orders);

  final ProviderContainer container;
  final FakeOrders orders;
}

/// Opens the router at '/', showing [child] with its providers wired to fakes.
/// [routes] adds stub pages, e.g. `/product/:id`, so navigation can be checked.
Future<Harness> pumpFeature(
  WidgetTester t,
  Widget child, {
  List<Product>? products,
  List<Category> categories = const [],
  List<PromoBanner> banners = const [],
  StoreSettings? settings,
  List<Coupon>? coupons,
  List<DeliveryDay>? days,
  List<Address> addresses = const [homeAddress],
  AddressRepository? addressRepo,
  List<Order> orders = const [],
  bool signedIn = true,
  Map<String, Object> prefs = const {},
  List<GoRoute> routes = const [],
  List<Override> overrides = const [],
  Size size = const Size(1080, 2340),
  bool reduceMotion = false,
  bool scaffold = true,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  ignoreLayoutOverflow();
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);

  final fakeOrders = FakeOrders(orders);
  final (container, _) = await makeContainer(
    prefs: prefs,
    signedIn: signedIn,
    overrides: [
      pushServiceProvider.overrideWith(FakePush.new),
      catalogRepositoryProvider.overrideWithValue(
        FakeCatalog(products ?? [product('hen')], categoryList: categories, bannerList: banners),
      ),
      checkoutRepositoryProvider.overrideWithValue(
        FakeCheckout(settings ?? mockStoreSettings, couponList: coupons, days: days),
      ),
      addressRepositoryProvider.overrideWithValue(addressRepo ?? FakeAddresses(addresses)),
      orderRepositoryProvider.overrideWithValue(fakeOrders),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  // The app watches these from its first screens, so they are already loaded by
  // the time a sheet or form needs them.
  container.listen(addressesProvider, (_, _) {});
  container.listen(favoritesProvider, (_, _) {});

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => scaffold ? Scaffold(body: child) : child,
      ),
      ...routes,
    ],
  );
  await t.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        builder: reduceMotion
            ? (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              )
            : null,
      ),
    ),
  );
  await t.pump();
  // Let the stores, catalog and addresses load.
  await t.pump(const Duration(milliseconds: 50));
  await t.pump(const Duration(milliseconds: 50));
  return Harness(container, fakeOrders);
}

/// A stub page that just says where it is, for navigation checks.
GoRoute stubRoute(String path, {String? label}) => GoRoute(
  path: path,
  builder: (context, state) => Scaffold(body: Center(child: Text(label ?? 'PAGE $path'))),
);
