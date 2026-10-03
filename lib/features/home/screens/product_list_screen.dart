import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../cart/providers/cart_providers.dart';
import '../../../core/widgets/async_view.dart';
import '../../cart/widgets/view_cart_bar.dart';
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
    final hasCart = !ref.watch(cartSummaryProvider).isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          AsyncView(
            value: ref.watch(filteredProductsProvider(query)),
            onRetry: () => ref.invalidate(filteredProductsProvider(query)),
            data: (products) => ProductGrid(
              products: products,
              bottomPadding: hasCart ? 96 : 16,
              header: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: AppSearchBar.readOnly(
                  hint: 'Search in $title...',
                  onTap: () => context.push(Routes.search, extra: query),
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(top: false, child: ViewCartBar()),
          ),
        ],
      ),
    );
  }
}
