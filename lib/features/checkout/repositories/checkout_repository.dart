import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_call.dart';
import '../../../core/network/endpoints.dart';
import '../data/mock_checkout_data.dart';
import '../models/checkout_models.dart';

abstract interface class CheckoutRepository {
  /// Admin-managed rules: schedule switch, UPI QR, fees, ETA, invoice details.
  Future<StoreSettings> settings();

  /// Bookable days starting today.
  Future<List<DeliveryDay>> deliveryDays();

  Future<List<Coupon>> coupons();

  /// Looks up a typed code. Throws an [AppException] when it doesn't exist.
  Future<Coupon> findCoupon(String code);
}

class MockCheckoutRepository implements CheckoutRepository {
  @override
  Future<StoreSettings> settings() async {
    await Future<void>.delayed(AppConstants.mockLatency);
    return mockStoreSettings;
  }

  @override
  Future<List<DeliveryDay>> deliveryDays() async {
    await Future<void>.delayed(AppConstants.mockLatency);
    return mockDeliveryDays(DateTime.now());
  }

  @override
  Future<List<Coupon>> coupons() async {
    await Future<void>.delayed(AppConstants.mockLatency);
    return mockCoupons(DateTime.now());
  }

  @override
  Future<Coupon> findCoupon(String code) async {
    await Future<void>.delayed(AppConstants.mockLatency);
    final wanted = code.trim().toUpperCase();
    return mockCoupons(DateTime.now()).firstWhere(
      (c) => c.code == wanted,
      orElse: () => throw const AppException('This coupon code is not valid'),
    );
  }
}

/// Assumed API shape (adjust when the contract lands):
/// * `GET /store/settings` -> `{ "data": StoreSettings }`
/// * `GET /delivery/slots?from=yyyy-MM-dd&days=4` -> `{ "data": [ { date, closedReason, slots: [ { id, start, end, available } ] } ] }`
/// * `GET /coupons` -> `{ "data": [ Coupon ] }`
/// * `POST /coupons/validate { code }` -> `{ "data": Coupon }`, or 4xx with `{ "message" }`
class RemoteCheckoutRepository implements CheckoutRepository {
  RemoteCheckoutRepository(this._dio);

  final Dio _dio;

  @override
  Future<StoreSettings> settings() => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>(Endpoints.storeSettings);
        return StoreSettings.fromJson(res.data?['data'] as Map<String, dynamic>? ?? const {});
      });

  @override
  Future<List<DeliveryDay>> deliveryDays() => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          Endpoints.deliverySlots,
          queryParameters: {'from': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'days': 4},
        );
        return _list(res.data).map(DeliveryDay.fromJson).toList();
      });

  @override
  Future<List<Coupon>> coupons() => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>(Endpoints.coupons);
        return _list(res.data).map(Coupon.fromJson).toList();
      });

  @override
  Future<Coupon> findCoupon(String code) => apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          Endpoints.couponValidate,
          data: {'code': code.trim().toUpperCase()},
        );
        return Coupon.fromJson(res.data?['data'] as Map<String, dynamic>? ?? const {});
      });

  static Iterable<Map<String, dynamic>> _list(Map<String, dynamic>? body) =>
      (body?['data'] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>();
}
