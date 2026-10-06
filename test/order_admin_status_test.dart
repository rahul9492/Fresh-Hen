import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/push/push_service.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:fresh_hen/features/auth/models/app_user.dart';
import 'package:fresh_hen/features/auth/providers/auth_provider.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';
import 'package:fresh_hen/features/orders/providers/order_providers.dart';
import 'package:fresh_hen/features/orders/repositories/order_repository.dart';
import 'package:fresh_hen/features/orders/widgets/live_order_refresh.dart';
import 'package:fresh_hen/features/orders/widgets/order_status_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How the customer app reacts to the admin app accepting, rejecting and
/// moving orders along.

class _SignedIn extends AuthSession {
  @override
  AppUser? build() => const AppUser(phone: '9876543210', name: 'Rahul Kumar');
}

class _NoPush extends PushService {
  _NoPush(super.ref);

  @override
  Stream<Map<String, dynamic>> get received => const Stream.empty();

  @override
  Future<void> unregister() async {}
}

/// Counts how often the app asks the server for orders.
class _CountingStore extends MockOrderRepository {
  int fetches = 0;

  @override
  Future<List<Order>> fetch() {
    fetches++;
    return super.fetch();
  }
}

Order _upi({
  OrderStatus status = OrderStatus.confirmed,
  PaymentStatus payment = PaymentStatus.verifying,
  PaymentMethod method = PaymentMethod.upi,
}) =>
    Order(
      id: 'FH1',
      placedAt: DateTime(2026, 10, 6),
      lines: const [],
      bill: const OrderBill(itemTotal: 0, mrpTotal: 0, deliveryFee: 0),
      address: 'x',
      status: status,
      paymentMethod: method,
      paymentStatus: payment,
    );

void main() {
  group('waiting for the store to accept a UPI order', () {
    test('a fresh UPI order is awaiting confirmation, not "Confirmed"', () {
      final o = _upi();
      expect(o.awaitingConfirmation, isTrue);
      expect(o.statusLabel, 'Awaiting confirmation');
      expect(o.statusDetail(eta: '45 min'), isNot(contains('45 min')));
    });

    test('once the admin accepts (payment paid) it is a normal confirmed order', () {
      final o = _upi(payment: PaymentStatus.paid);
      expect(o.awaitingConfirmation, isFalse);
      expect(o.statusLabel, 'Confirmed');
      expect(o.statusDetail(eta: '45 min'), 'Arriving in 45 min');
    });

    test('cash orders never wait for payment checks', () {
      expect(_upi(method: PaymentMethod.cash, payment: PaymentStatus.due).awaitingConfirmation, isFalse);
    });

    test('later stages are never "awaiting", whatever the payment flag says', () {
      expect(_upi(status: OrderStatus.preparing).awaitingConfirmation, isFalse);
    });
  });

  group('rejected payment', () {
    test('an open order with a rejected payment is a payment issue', () {
      final o = _upi(payment: PaymentStatus.rejected);
      expect(o.paymentIssue, isTrue);
      expect(o.statusLabel, 'Payment issue');
      expect(o.statusDetail(eta: ''), contains("couldn't verify"));
    });

    test('a cancelled order shows as cancelled, not as a payment issue', () {
      final o = _upi(status: OrderStatus.cancelled, payment: PaymentStatus.rejected);
      expect(o.paymentIssue, isFalse);
      expect(o.statusLabel, 'Cancelled');
    });
  });

  group('live refresh without push', () {
    Future<_CountingStore> pumpScreen(WidgetTester tester, {required bool active}) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = _CountingStore();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          authSessionProvider.overrideWith(_SignedIn.new),
          orderRepositoryProvider.overrideWithValue(store),
          pushServiceProvider.overrideWith(_NoPush.new),
        ],
        child: MaterialApp(home: LiveOrderRefresh(active: active, child: const SizedBox())),
      ));
      return store;
    }

    testWidgets('re-checks every 20 seconds while an order is on its way', (tester) async {
      final store = await pumpScreen(tester, active: true);
      await tester.pump(const Duration(seconds: 21)); // first check (also loads the list)
      final afterFirst = store.fetches;
      expect(afterFirst, greaterThan(0));
      await tester.pump(const Duration(seconds: 20));
      expect(store.fetches, afterFirst + 1);
      await tester.pump(const Duration(seconds: 20));
      expect(store.fetches, afterFirst + 2);
    });

    testWidgets('stays quiet when no order is active', (tester) async {
      final store = await pumpScreen(tester, active: false);
      await tester.pump(const Duration(seconds: 61));
      expect(store.fetches, 0);
    });
  });
}
