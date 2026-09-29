import '../../../core/constants/app_constants.dart';
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
