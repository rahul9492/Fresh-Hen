import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../catalog/models/catalog_models.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../../catalog/widgets/product_grid.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key, required this.title, this.categoryId, this.section});

  final String title;
  final String? categoryId;
  final String? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ProductQuery(
      categoryId: categoryId,
      popularOnly: section == 'popular',
      recommendedOnly: section == 'recommended',
    );
    final favorites = ref.watch(favoritesProvider);
    final isWishlist = section == 'wishlist';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AsyncView(
        value: ref.watch(filteredProductsProvider(query)),
        onRetry: () => ref.invalidate(filteredProductsProvider(query)),
        data: (products) {
          final shown = isWishlist ? products.where((p) => favorites.contains(p.id)).toList() : products;
          return shown.isEmpty && isWishlist
              ? const EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Your wishlist is empty',
                  message: 'Tap the heart on any item to save it here.',
                )
              : ProductGrid(products: shown);
        },
      ),
    );
  }
}
