import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/errors/app_exception.dart';
import 'package:fresh_hen/core/push/push_service.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:fresh_hen/features/auth/models/app_user.dart';
import 'package:fresh_hen/features/auth/providers/auth_provider.dart';
import 'package:fresh_hen/features/auth/repositories/mock_auth_repository.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/providers/order_providers.dart';
import 'package:fresh_hen/features/orders/repositories/order_repository.dart';
import 'package:fresh_hen/features/orders/widgets/order_status_style.dart';
import 'package:fresh_hen/features/orders/widgets/order_timeline.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _user = AppUser(phone: '9876543210', name: 'Rahul Kumar');

class _SignedIn extends AuthSession {
  @override
  AppUser? build() => _user;
}

/// Fires "push arrived" without Firebase.
class _FakePush extends PushService {
  _FakePush(super.ref);

  final controller = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get received => controller.stream;

  @override
  Future<void> unregister() async {}
}

/// Mock orders whose status the "store" can change behind the app's back.
class _Store extends MockOrderRepository {
  OrderStatus? forcedStatus;

  @override
  Future<List<Order>> fetch() async {
    final all = await super.fetch();
    final s = forcedStatus;
    return s == null ? all : [for (final o in all) o.copyWith(status: s)];
  }
}

Order _confirmed() => Order(
      id: 'FH1',
      placedAt: DateTime(2026, 10, 4),
      lines: const [],
      bill: const OrderBill(itemTotal: 0, mrpTotal: 0, deliveryFee: 0),
      address: 'x',
    );

class _FakeApi implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? _, Future<void>? _) async {
    last = options;
    final body = {
      'data': {
        ..._confirmed().toJson()..remove('lines')..remove('bill'),
        'lines': <Object>[],
        'bill': {'itemTotal': 0, 'mrpTotal': 0, 'deliveryFee': 0},
        'status': 'cancelled',
        'cancelReason': 'Ordered by mistake',
      },
    };
    return ResponseBody.fromString(jsonEncode(body), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Future<(ProviderContainer, _FakePush, _Store)> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final store = _Store();
  late _FakePush push;
  final c = ProviderContainer(overrides: [
    sharedPrefsProvider.overrideWithValue(prefs),
    authSessionProvider.overrideWith(_SignedIn.new),
    orderRepositoryProvider.overrideWithValue(store),
    pushServiceProvider.overrideWith((ref) => push = _FakePush(ref)),
  ]);
  addTearDown(c.dispose);
  c.listen(ordersProvider, (_, _) {});
  await c.read(ordersProvider.future);
  return (c, push, store);
}

void main() {
  group('live order status', () {
    test('an order push refreshes the list in place', () async {
      final (c, push, store) = await _container();
      store.forcedStatus = OrderStatus.delivered;

      push.controller.add({'type': 'offer', 'productId': 'p1'});
      await pumpEventQueue();
      expect(c.read(ordersProvider).value!.first.status, isNot(OrderStatus.delivered));

      push.controller.add({'type': 'order', 'orderId': 'FH1'});
      await Future<void>.delayed(const Duration(seconds: 1)); // mock latency
      expect(c.read(ordersProvider).value!.every((o) => o.status == OrderStatus.delivered), isTrue);
    });
  });

  group('cancel', () {
    test('only before the store starts preparing', () {
      expect(_confirmed().canCancel, isTrue);
      for (final s in OrderStatus.values.where((s) => s != OrderStatus.confirmed)) {
        expect(_confirmed().copyWith(status: s).canCancel, isFalse, reason: s.name);
      }
    });

    test('a confirmed order is cancelled with the reason', () async {
      final (c, _, store) = await _container();
      final placed = await store.place(OrderRequest(
        lines: const [],
        bill: const OrderBill(itemTotal: 100, mrpTotal: 100, deliveryFee: 0),
        addressId: 'a1',
        address: 'x',
        addressLabel: 'Home',
        paymentMethod: PaymentMethod.cash,
      ));
      await c.read(ordersProvider.notifier).refreshQuietly();

      await c.read(ordersProvider.notifier).cancel(placed.id, reason: 'Ordered by mistake');
      final o = c.read(ordersProvider).value!.firstWhere((o) => o.id == placed.id);
      expect(o.status, OrderStatus.cancelled);
      expect(o.cancelReason, 'Ordered by mistake');
      expect(o.statusDetail(eta: ''), 'Cancelled: Ordered by mistake');
    });

    test('too late once it is being prepared', () async {
      final (c, _, _) = await _container();
      final preparing = c.read(ordersProvider).value!.firstWhere((o) => !o.canCancel);
      expect(
        c.read(ordersProvider.notifier).cancel(preparing.id, reason: 'x'),
        throwsA(isA<AppException>().having((e) => e.message, 'message', tooLateToCancel)),
      );
    });

    test('the API call sends the reason and reads back the order', () async {
      final api = _FakeApi();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = api;
      final o = await RemoteOrderRepository(dio).cancel('FH1', reason: 'Ordered by mistake');
      expect((api.last!.method, api.last!.path), ('POST', '/orders/FH1/cancel'));
      expect(api.last!.data, {'reason': 'Ordered by mistake'});
      expect(o.status, OrderStatus.cancelled);
      expect(o.cancelReason, 'Ordered by mistake');
    });
  });

  test('deleting the account removes the user and everything kept for them', () async {
    SharedPreferences.setMockInitialValues({
      'auth.users': jsonEncode({_user.phone: _user.toJson()}),
      'auth.session_phone': _user.phone,
      'cart.${_user.phone}': '[]',
      'addresses.cache.${_user.phone}': '[]',
      'wishlist.cache.${_user.phone}': <String>['p1'],
      'cart.1111111111': '[]', // someone else on this phone
      'onboarding.seen': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      pushServiceProvider.overrideWith(_FakePush.new),
    ]);
    addTearDown(c.dispose);
    expect(c.read(authSessionProvider)?.phone, _user.phone);

    await c.read(authSessionProvider.notifier).deleteAccount();

    expect(c.read(authSessionProvider), isNull);
    expect(prefs.getKeys().where((k) => k.endsWith(_user.phone)), isEmpty);
    expect(prefs.getKeys(), containsAll(['cart.1111111111', 'onboarding.seen']));
    expect(MockAuthRepository(prefs).currentUser(), isNull);
    expect(prefs.getString('auth.users'), isNot(contains(_user.phone)));
  });

  group('tracking timeline', () {
    test('reads events and the rider from the API', () {
      final o = Order.fromJson({
        'id': 'FH1',
        'placedAt': '2026-10-04T10:00:00.000',
        'lines': <Object>[],
        'bill': {'itemTotal': 0, 'mrpTotal': 0, 'deliveryFee': 0},
        'address': 'x',
        'status': 'outForDelivery',
        'events': [
          {'status': 'confirmed', 'at': '2026-10-04T10:00:00.000'},
          {'status': 'preparing', 'at': '2026-10-04T10:07:00.000'},
          {'status': 'outForDelivery', 'at': '2026-10-04T10:31:00.000'},
          {'status': 'somethingNew', 'at': '2026-10-04T10:32:00.000'},
        ],
        'rider': {'name': 'Ravi', 'phone': '9811122233'},
      });
      expect(o.reachedAt(OrderStatus.preparing), DateTime(2026, 10, 4, 10, 7));
      expect(o.reachedAt(OrderStatus.delivered), isNull);
      expect(o.rider?.name, 'Ravi');
    });

    test('older orders without events still know placed and delivered times', () {
      final placed = DateTime(2026, 10, 4, 10);
      final delivered = DateTime(2026, 10, 4, 11);
      final o = _confirmed().copyWith(placedAt: placed, deliveredAt: delivered);
      expect(o.reachedAt(OrderStatus.confirmed), placed);
      expect(o.reachedAt(OrderStatus.delivered), delivered);
    });

    test('placing and cancelling record their steps', () async {
      final (_, _, store) = await _container();
      final placed = await store.place(OrderRequest(
        lines: const [],
        bill: const OrderBill(itemTotal: 100, mrpTotal: 100, deliveryFee: 0),
        addressId: 'a1',
        address: 'x',
        addressLabel: 'Home',
        paymentMethod: PaymentMethod.cash,
      ));
      expect(placed.events.map((e) => e.status), [OrderStatus.confirmed]);
      final cancelled = await store.cancel(placed.id, reason: 'x');
      expect(cancelled.events.map((e) => e.status), [OrderStatus.confirmed, OrderStatus.cancelled]);
    });

    Future<void> pump(WidgetTester t, Order order) => t.pumpWidget(
          MaterialApp(home: Scaffold(body: SingleChildScrollView(child: OrderTimeline(order: order)))),
        );

    testWidgets('shows every step, with times for the ones reached', (t) async {
      final placed = DateTime(2026, 10, 4, 10);
      await pump(
        t,
        _confirmed().copyWith(
          status: OrderStatus.preparing,
          events: [
            OrderEvent(status: OrderStatus.confirmed, at: placed),
            OrderEvent(status: OrderStatus.preparing, at: placed.add(const Duration(minutes: 7))),
          ],
        ),
      );
      for (final s in ['Confirmed', 'Being prepared', 'Out for delivery', 'Delivered']) {
        expect(find.text(s), findsOneWidget);
      }
      expect(find.text('10:00 AM'), findsOneWidget);
      expect(find.text('10:07 AM'), findsOneWidget);
      expect(find.text('Cleaning, cutting and packing it fresh'), findsOneWidget);
    });

    testWidgets('a cancelled order ends at Cancelled', (t) async {
      await pump(t, _confirmed().copyWith(status: OrderStatus.cancelled));
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Delivered'), findsNothing);
      expect(find.text('Being prepared'), findsNothing);
    });
  });
}
