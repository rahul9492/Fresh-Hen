import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_call.dart';
import '../../../core/network/endpoints.dart';
import '../data/mock_catalog_data.dart';
import '../models/catalog_models.dart';

abstract interface class CatalogRepository {
  Future<List<Category>> categories();

  Future<List<Product>> products();

  Future<List<PromoBanner>> banners();
}

class MockCatalogRepository implements CatalogRepository {
  Future<T> _delayed<T>(T value) => Future.delayed(AppConstants.mockLatency, () => value);

  @override
  Future<List<Category>> categories() => _delayed(mockCategories);

  @override
  Future<List<Product>> products() => _delayed(mockProducts);

  @override
  Future<List<PromoBanner>> banners() => _delayed(mockBanners);
}

/// Assumed API shape (adjust when the contract lands). The whole catalog is
/// small (one shop), so it is fetched once and filtered on the phone.
/// * `GET /categories` -> `{ "data": [ { id, name, image } ] }`
/// * `GET /products` -> `{ "data": [ { id, name, categoryId, image, gallery: [url],
///   rating, ratingCount, isPopular, isRecommended,
///   variants: [ { id, label, price, mrp, inStock } ],
///   accompaniments: [ { id, name, weight, price, rating, ratingCount, image, inStock } ] } ] }`
/// * `GET /banners` -> `{ "data": [ { eyebrow, title, highlight, description, image, categoryId } ] }`
///
/// Prices are whole rupees. Products with no variants are skipped, since they
/// cannot be added to the cart.
///
/// Stock comes from the admin app: a pack is `inStock` when the product is
/// marked "Selling" there and its stock covers at least one pack of that
/// weight. Products marked "Not selling" can be sent with every pack
/// `inStock: false` (shown as sold out) or left out.
class RemoteCatalogRepository implements CatalogRepository {
  RemoteCatalogRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Category>> categories() => _list(Endpoints.categories, Category.fromJson);

  @override
  Future<List<Product>> products() async {
    final all = await _list(Endpoints.products, Product.fromJson);
    return all.where((p) => p.variants.isNotEmpty).toList();
  }

  @override
  Future<List<PromoBanner>> banners() => _list(Endpoints.banners, PromoBanner.fromJson);

  Future<List<T>> _list<T>(String path, T Function(Map<String, dynamic>) fromJson) =>
      apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>(path);
        return (res.data?['data'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList();
      });
}
