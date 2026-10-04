import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/errors/app_exception.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:fresh_hen/features/address/models/address.dart';
import 'package:fresh_hen/features/address/providers/address_providers.dart';
import 'package:fresh_hen/features/address/repositories/address_repository.dart';
import 'package:fresh_hen/features/cart/models/cart_models.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';
import 'package:fresh_hen/features/catalog/providers/catalog_providers.dart';
import 'package:fresh_hen/features/catalog/repositories/catalog_repository.dart';
import 'package:fresh_hen/features/catalog/repositories/wishlist_repository.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/repositories/order_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers every request with [body] and remembers what was sent, so each
/// test checks both the path/payload and how the response is parsed.
class _FakeApi implements HttpClientAdapter {
  _FakeApi([this.body = const {}]);

  Object body;
  final requests = <RequestOptions>[];

  RequestOptions get last => requests.last;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? _, Future<void>? _) async {
    requests.add(options);
    return ResponseBody.fromString(jsonEncode(body), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_FakeApi api) => Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = api;

const _productJson = {
  'id': 'p1',
  'name': 'Chicken Curry Cut',
  'categoryId': 'chicken',
  'image': 'https://cdn.test/p1.jpg',
  'rating': 4.5,
  'ratingCount': 120,
  'variants': [
    {'id': 'v1', 'label': '500 g', 'price': 180, 'mrp': 200, 'inStock': false},
    {'id': 'v2', 'label': '1 kg', 'price': 340},
  ],
};

final _orderJson = {
  'id': 'FH1',
  'placedAt': '2026-10-04T10:00:00.000',
  'lines': [
    {
      'id': 'p1:v2',
      'productId': 'p1',
      'variantId': 'v2',
      'name': 'Chicken Curry Cut',
      'unitLabel': '1 kg',
      'image': 'https://cdn.test/p1.jpg',
      'unitPrice': 340,
      'quantity': 2,
    },
  ],
  'bill': {'itemTotal': 680, 'mrpTotal': 700, 'deliveryFee': 0},
  'address': 'Flat 2, Sector 63, Noida - 201301',
  'status': 'outForDelivery',
  'paymentMethod': 'upi',
  'paymentStatus': 'verifying',
};

const _address = Address(
  id: 'a1',
  label: AddressLabel.home,
  house: 'Flat 2',
  area: 'Sector 63',
  city: 'Noida',
  pincode: '201301',
  name: 'Rahul',
  phone: '9876543210',
);

class _FailingAddresses implements AddressRepository {
  @override
  Future<List<Address>> fetch() async => const [];
  @override
  Future<Address> create(Address address) => throw const AppException('Not deliverable');
  @override
  Future<Address> update(Address address) => throw const AppException('Not deliverable');
  @override
  Future<void> remove(String id) => throw const AppException('Offline');
  @override
  Future<void> makeDefault(String id) => throw const AppException('Offline');
}

class _FailingWishlist implements WishlistRepository {
  @override
  Future<Set<String>> fetch() async => const {};
  @override
  Future<void> add(String productId) => throw const AppException('Offline');
  @override
  Future<void> remove(String productId) => throw const AppException('Offline');
}

void main() {
  group('catalog', () {
    test('parses products and skips ones with nothing to buy', () async {
      final api = _FakeApi({
        'data': [
          _productJson,
          {..._productJson, 'id': 'p2', 'variants': <Object>[]},
        ],
      });
      final products = await RemoteCatalogRepository(_dio(api)).products();

      expect(api.last.path, '/products');
      final p = products.single;
      expect(p.variants.first.inStock, isFalse);
      expect(p.variants.last.inStock, isTrue); // defaults to in stock
      expect(p.defaultVariant.id, 'v2'); // quick-add skips the sold-out pack
      expect(p.inStock, isTrue);
      expect(p.gallery, isEmpty);
    });

    test('a product is out of stock only when every pack is', () {
      final p = Product.fromJson({
        ..._productJson,
        'variants': [
          {'id': 'v1', 'label': '500 g', 'price': 180, 'inStock': false},
        ],
      });
      expect(p.inStock, isFalse);
    });

    test('parses categories and banners', () async {
      final api = _FakeApi({
        'data': [
          {'id': 'chicken', 'name': 'Chicken', 'image': 'https://cdn.test/c.jpg'},
        ],
      });
      final repo = RemoteCatalogRepository(_dio(api));
      expect((await repo.categories()).single.name, 'Chicken');
      expect(api.last.path, '/categories');

      api.body = {
        'data': [
          {
            'eyebrow': 'New',
            'title': 'Fresh',
            'highlight': '20% off',
            'description': 'd',
            'image': 'https://cdn.test/b.jpg',
            'categoryId': 'chicken',
          },
        ],
      };
      expect((await repo.banners()).single.highlight, '20% off');
      expect(api.last.path, '/banners');
    });
  });

  group('orders', () {
    test('parses the history, newest first', () async {
      final api = _FakeApi({
        'data': [
          _orderJson,
          {..._orderJson, 'id': 'FH2', 'placedAt': '2026-10-05T10:00:00.000'},
        ],
      });
      final orders = await RemoteOrderRepository(_dio(api)).fetch();

      expect(orders.map((o) => o.id), ['FH2', 'FH1']);
      final o = orders.last;
      expect(o.status, OrderStatus.outForDelivery);
      expect(o.paymentMethod, PaymentMethod.upi);
      expect(o.paymentStatus, PaymentStatus.verifying);
      expect(o.lines.single.variantId, 'v2');
      expect(o.total, 680);
      expect(o.addressLabel, 'Home');
    });

    test('a status this app does not know yet still parses', () {
      final o = Order.fromJson({..._orderJson, 'status': 'packed', 'paymentStatus': 'refunded'});
      expect(o.status, OrderStatus.confirmed);
      expect(o.paymentStatus, PaymentStatus.verifying);
    });

    test('placing sends ids and quantities, not prices', () async {
      final api = _FakeApi({'data': _orderJson});
      final request = OrderRequest(
        lines: [
          const CartLine(
            id: 'p1:v2',
            productId: 'p1',
            variantId: 'v2',
            name: 'n',
            unitLabel: '1 kg',
            image: 'i',
            unitPrice: 340,
            quantity: 2,
          ),
          const CartLine(
            id: 'addon:masala',
            productId: 'masala',
            name: 'n',
            unitLabel: '50 g',
            image: 'i',
            unitPrice: 30,
            isAddon: true,
          ),
        ],
        bill: const OrderBill(itemTotal: 710, mrpTotal: 730, deliveryFee: 0, couponCode: 'FRESH20'),
        addressId: 'a1',
        address: 'x',
        addressLabel: 'Home',
        paymentMethod: PaymentMethod.cash,
      );
      final order = await RemoteOrderRepository(_dio(api)).place(request);

      expect(api.last.method, 'POST');
      expect(api.last.path, '/orders');
      expect(api.last.data, {
        'items': [
          {'productId': 'p1', 'variantId': 'v2', 'quantity': 2, 'isAddon': false},
          {'productId': 'masala', 'quantity': 1, 'isAddon': true},
        ],
        'addressId': 'a1',
        'paymentMethod': 'cash',
        'couponCode': 'FRESH20',
        'expectedTotal': 710,
      });
      expect(order.id, 'FH1');
    });

    test('uploads the payment screenshot as a file and returns its key', () async {
      final api = _FakeApi({
        'data': {'key': 'proofs/1.jpg'},
      });
      final key = await RemoteOrderRepository(_dio(api))
          .uploadPaymentProof(Uint8List.fromList([1, 2, 3]), 'shot.jpg');

      expect(key, 'proofs/1.jpg');
      expect(api.last.path, '/orders/payment-proofs');
      expect(api.last.data, isA<FormData>());
      expect((api.last.data as FormData).files.single.value.filename, 'shot.jpg');
    });

    test('a missing upload key is an error, not a silent order without proof', () async {
      final api = _FakeApi({'data': <String, Object>{}});
      expect(
        RemoteOrderRepository(_dio(api)).uploadPaymentProof(Uint8List(1), 'a.jpg'),
        throwsA(isA<AppException>()),
      );
    });

    test('rating posts stars and comment', () async {
      final api = _FakeApi();
      await RemoteOrderRepository(_dio(api)).rate('FH 1', stars: 5, comment: 'Great');
      expect(api.last.path, '/orders/FH%201/rating');
      expect(api.last.data, {'stars': 5, 'comment': 'Great'});
    });
  });

  group('addresses', () {
    test('create sends no id and returns the server one', () async {
      final api = _FakeApi({
        'data': {..._address.toJson(), 'id': 'srv-9'},
      });
      final saved = await RemoteAddressRepository(_dio(api)).create(_address);

      expect(api.last.method, 'POST');
      expect(api.last.path, '/addresses');
      expect((api.last.data as Map).containsKey('id'), isFalse);
      expect(saved.id, 'srv-9');
    });

    test('update, delete and default hit their paths', () async {
      final api = _FakeApi({'data': _address.toJson()});
      final repo = RemoteAddressRepository(_dio(api));

      await repo.update(_address);
      expect((api.last.method, api.last.path), ('PUT', '/addresses/a1'));
      await repo.remove('a1');
      expect((api.last.method, api.last.path), ('DELETE', '/addresses/a1'));
      await repo.makeDefault('a1');
      expect((api.last.method, api.last.path), ('POST', '/addresses/a1/default'));

      api.body = {
        'data': [_address.toJson()],
      };
      expect((await repo.fetch()).single.city, 'Noida');
    });

    test('a rejected save rolls back and surfaces the message', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        addressRepositoryProvider.overrideWithValue(_FailingAddresses()),
      ]);
      addTearDown(c.dispose);

      await expectLater(
        c.read(addressesProvider.notifier).save(_address),
        throwsA(isA<AppException>().having((e) => e.message, 'message', 'Not deliverable')),
      );
      expect(c.read(addressesProvider), isEmpty);
    });
  });

  group('wishlist', () {
    test('reads ids and writes idempotently', () async {
      final api = _FakeApi({
        'data': ['p1', 'p2'],
      });
      final repo = RemoteWishlistRepository(_dio(api));

      expect(await repo.fetch(), {'p1', 'p2'});
      await repo.add('p3');
      expect((api.last.method, api.last.path), ('PUT', '/wishlist/p3'));
      await repo.remove('p3');
      expect((api.last.method, api.last.path), ('DELETE', '/wishlist/p3'));
    });

    test('a failed toggle flips the heart back', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        wishlistRepositoryProvider.overrideWithValue(_FailingWishlist()),
      ]);
      addTearDown(c.dispose);

      expect(await c.read(favoritesProvider.notifier).toggle('p1'), isFalse);
      expect(c.read(favoritesProvider), isEmpty);
    });
  });
}
