import 'dart:math';
import 'dart:typed_data';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../cart/models/cart_models.dart';
import '../data/mock_order_data.dart';
import '../models/order_models.dart';

/// Everything the store needs to create an order.
class OrderRequest {
  const OrderRequest({
    required this.lines,
    required this.bill,
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
  final String address;
  final String addressLabel;
  final PaymentMethod paymentMethod;
  final DeliverySlot? slot;
  final String? instructions;

  /// Storage key of the uploaded UPI screenshot (see [OrderRepository.uploadPaymentProof]).
  final String? paymentProof;
  final String? paymentReference;
}

abstract interface class OrderRepository {
  /// Newest first.
  Future<List<Order>> fetch();

  /// Uploads the customer's UPI payment screenshot and returns its storage key.
  Future<String> uploadPaymentProof(Uint8List bytes, String fileName);

  Future<Order> place(OrderRequest request);

  Future<void> rate(String orderId, {required int stars, String? comment});
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
}
