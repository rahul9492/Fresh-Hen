import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_call.dart';
import '../../../core/network/endpoints.dart';

/// Ids of the products the customer saved to their wishlist.
abstract interface class WishlistRepository {
  Future<Set<String>> fetch();

  Future<void> add(String productId);

  Future<void> remove(String productId);
}

/// Stands in for the server: keeps the wishlist on the device per phone number.
class MockWishlistRepository implements WishlistRepository {
  MockWishlistRepository(this._prefs, this._phone);

  final SharedPreferences _prefs;
  final String? Function() _phone;

  String get _key => 'wishlist.${_phone() ?? 'guest'}';

  @override
  Future<Set<String>> fetch() async => (_prefs.getStringList(_key) ?? const []).toSet();

  @override
  Future<void> add(String productId) async =>
      _prefs.setStringList(_key, {...await fetch(), productId}.toList());

  @override
  Future<void> remove(String productId) async =>
      _prefs.setStringList(_key, ((await fetch())..remove(productId)).toList());
}

/// Assumed API shape (adjust when the contract lands). Both writes are
/// idempotent, so a retried tap never fails:
/// * `GET /wishlist` -> `{ "data": [ "productId", ... ] }`
/// * `PUT /wishlist/{productId}`
/// * `DELETE /wishlist/{productId}`
class RemoteWishlistRepository implements WishlistRepository {
  RemoteWishlistRepository(this._dio);

  final Dio _dio;

  @override
  Future<Set<String>> fetch() => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>(Endpoints.wishlist);
        return (res.data?['data'] as List<dynamic>? ?? const []).whereType<String>().toSet();
      });

  @override
  Future<void> add(String productId) => apiCall(() async {
        await _dio.put<void>(Endpoints.wishlistItem(productId));
      });

  @override
  Future<void> remove(String productId) => apiCall(() async {
        await _dio.delete<void>(Endpoints.wishlistItem(productId));
      });
}
