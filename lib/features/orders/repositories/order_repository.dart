import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_call.dart';
import '../../../core/network/endpoints.dart';
import '../../cart/models/cart_models.dart';
import '../data/mock_order_data.dart';
import '../models/order_models.dart';

/// Everything the store needs to create an order.
class OrderRequest {
  const OrderRequest({
    required this.lines,
    required this.bill,
    required this.addressId,
    required this.address,
    required this.addressLabel,
    required this.paymentMethod,
    this.slot,
    this.instructions,
    this.paymentProof,
    this.paymentReference,
  });

  final List<CartLine> lines;
  final OrderBill bill;
  final String addressId;

  /// Printable address, used by the mock; the API looks it up by [addressId].
  final String address;
  final String addressLabel;
  final PaymentMethod paymentMethod;
  final DeliverySlot? slot;
  final String? instructions;

  /// Storage key of the uploaded UPI screenshot (see [OrderRepository.uploadPaymentProof]).
  final String? paymentProof;
  final String? paymentReference;

  /// Body of `POST /orders`. Only ids and quantities: the server prices the
  /// order itself and rejects it if the total no longer matches what the
  /// customer saw (e.g. a price changed while the cart sat saved).
  Map<String, dynamic> toJson() => {
        'items': [
          for (final l in lines)
            {
              'productId': l.productId,
              'variantId': ?l.variantId,
              'quantity': l.quantity,
              'isAddon': l.isAddon,
            },
        ],
        'addressId': addressId,
        'paymentMethod': paymentMethod.name,
        'slotId': ?slot?.id,
        'instructions': ?instructions,
        'couponCode': ?bill.couponCode,
        'paymentProof': ?paymentProof,
        'paymentReference': ?paymentReference,
        'expectedTotal': bill.total,
      };
}

abstract interface class OrderRepository {
  /// Newest first.
  Future<List<Order>> fetch();

  /// Uploads the customer's UPI payment screenshot and returns its storage key.
  Future<String> uploadPaymentProof(Uint8List bytes, String fileName);

  Future<Order> place(OrderRequest request);

  Future<void> rate(String orderId, {required int stars, String? comment});

  /// Cancels an order the store has not started preparing, and returns it.
  /// Throws an [AppException] once it is too late.
  Future<Order> cancel(String orderId, {required String reason});
}

/// Keeps orders in memory, starting from a sample history, so placed and rated
/// orders survive a pull-to-refresh.
class MockOrderRepository implements OrderRepository {
  late final _orders = mockOrders(DateTime.now());
  final _random = Random();

  @override
  Future<List<Order>> fetch() async {
    await Future.delayed(AppConstants.mockLatency);
    return List.unmodifiable(_orders);
  }

  @override
  Future<String> uploadPaymentProof(Uint8List bytes, String fileName) async {
    await Future.delayed(AppConstants.mockLatency * 3);
    if (bytes.lengthInBytes > 10 * 1024 * 1024) {
      throw const AppException('That screenshot is too large. Please pick one under 10 MB.');
    }
    return 'payment-proofs/${DateTime.now().millisecondsSinceEpoch}-$fileName';
  }

  @override
  Future<Order> place(OrderRequest request) async {
    await Future.delayed(AppConstants.mockLatency * 2);
    final slot = request.slot;
    if (slot != null && slot.start.isBefore(DateTime.now().add(const Duration(minutes: 30)))) {
      throw const AppException('That delivery slot is no longer available. Please pick another.');
    }
    final order = Order(
      id: 'FH${284500 + _orders.length * 7 + _random.nextInt(7)}',
      placedAt: DateTime.now(),
      lines: request.lines,
      bill: request.bill,
      address: request.address,
      addressLabel: request.addressLabel,
      paymentMethod: request.paymentMethod,
      paymentStatus: request.paymentMethod == PaymentMethod.upi
          ? PaymentStatus.verifying
          : PaymentStatus.due,
      slot: slot,
      instructions: request.instructions,
      paymentProof: request.paymentProof,
      paymentReference: request.paymentReference,
      events: [OrderEvent(status: OrderStatus.confirmed, at: DateTime.now())],
    );
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<void> rate(String orderId, {required int stars, String? comment}) async {
    await Future.delayed(AppConstants.mockLatency);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(rating: stars, review: comment);
    }
  }

  @override
  Future<Order> cancel(String orderId, {required String reason}) async {
    await Future.delayed(AppConstants.mockLatency);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) throw const AppException('We could not find this order.');
    if (!_orders[index].canCancel) throw const AppException(tooLateToCancel);
    final order = _orders[index];
    return _orders[index] = order.copyWith(
      status: OrderStatus.cancelled,
      cancelReason: reason,
      events: [...order.events, OrderEvent(status: OrderStatus.cancelled, at: DateTime.now())],
    );
  }
}

/// Shown when the store has already started on the order.
const tooLateToCancel =
    'This order is already being prepared, so it can no longer be cancelled. '
    'Please call us if you need help.';

/// Assumed API shape (adjust when the contract lands):
/// * `GET /orders` -> `{ "data": [ Order ] }`, newest first. An order is
///   `{ id, placedAt, lines: [ CartLine ], bill: { itemTotal, mrpTotal, deliveryFee,
///   discount, taxes, couponCode }, address, addressLabel, status, paymentMethod,
///   paymentStatus, slot, instructions, deliveredAt, paymentReference, paymentProof,
///   rating, review, cancelReason, events: [ { status, at } ], rider: { name, phone } }`.
///   `events` drives the tracking timeline (one per status reached, oldest
///   first); `rider` is the assigned delivery partner, sent once it is out. Enums use the names in order_models.dart
///   (e.g. `outForDelivery`, `upi`, `verifying`); dates are ISO 8601.
/// * `POST /orders/payment-proofs` (multipart, field `file`) -> `{ "data": { "key": "..." } }`
/// * `POST /orders` [OrderRequest.toJson] -> `{ "data": Order }`, or 4xx with
///   `{ "message" }` (slot taken, price changed, out of stock...), shown as is.
/// * `POST /orders/{id}/rating` `{ stars, comment }`
/// * `POST /orders/{id}/cancel` `{ reason }` -> `{ "data": Order }` with status
///   `cancelled`; 409 `{ "message" }` once the store started preparing it.
///   Cancelled UPI orders are refunded by the store.
class RemoteOrderRepository implements OrderRepository {
  RemoteOrderRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Order>> fetch() => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>(Endpoints.orders);
        return (res.data?['data'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(Order.fromJson)
            .toList()
          ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
      });

  @override
  Future<String> uploadPaymentProof(Uint8List bytes, String fileName) => apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          Endpoints.paymentProofs,
          data: FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: fileName)}),
        );
        final key = (res.data?['data'] as Map<String, dynamic>?)?['key'];
        if (key is! String || key.isEmpty) {
          throw const AppException('Could not upload the screenshot. Please try again.');
        }
        return key;
      });

  @override
  Future<Order> place(OrderRequest request) => apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(Endpoints.orders, data: request.toJson());
        return Order.fromJson(res.data?['data'] as Map<String, dynamic>);
      });

  @override
  Future<void> rate(String orderId, {required int stars, String? comment}) => apiCall(() async {
        await _dio.post<void>(
          Endpoints.orderRating(orderId),
          data: {'stars': stars, 'comment': ?comment},
        );
      });

  @override
  Future<Order> cancel(String orderId, {required String reason}) => apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          Endpoints.orderCancel(orderId),
          data: {'reason': reason},
        );
        return Order.fromJson(res.data?['data'] as Map<String, dynamic>);
      });
}
