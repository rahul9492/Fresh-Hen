import '../../../core/constants/app_constants.dart';
import '../../cart/models/cart_models.dart';
import '../models/order_models.dart';

abstract interface class OrderRepository {
  Future<Order> place({
    required List<CartLine> lines,
    required int total,
    required String address,
  });
}

class MockOrderRepository implements OrderRepository {
  var _sequence = 1000;

  @override
  Future<Order> place({
    required List<CartLine> lines,
    required int total,
    required String address,
  }) async {
    await Future.delayed(AppConstants.mockLatency * 2);
    return Order(
      id: 'FH${++_sequence}',
      placedAt: DateTime.now(),
      lines: lines,
      total: total,
      address: address,
    );
  }
}
