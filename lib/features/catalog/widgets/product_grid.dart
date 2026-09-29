import 'package:flutter/material.dart';

import '../../../core/widgets/small_widgets.dart';
import '../models/catalog_models.dart';
import 'product_card.dart';

const _cardExtent = 274.0;

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products, this.embedded = false});

  /// When true the grid sizes to its content so it can sit inside another scroll view.
  final bool embedded;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No items found',
        message: 'Try a different search or category.',
      );
    }
    return GridView.builder(
      shrinkWrap: embedded,
      physics: embedded ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: _cardExtent,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    );
  }
}

class ProductRail extends StatelessWidget {
  const ProductRail({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cardExtent,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(width: 165, child: ProductCard(product: products[i])),
      ),
    );
  }
}
