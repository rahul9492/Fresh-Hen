import 'package:flutter/material.dart';

import '../../../core/widgets/small_widgets.dart';
import '../models/catalog_models.dart';
import 'product_card.dart';

const _cardExtent = 274.0;

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    this.embedded = false,
    this.header,
    this.bottomPadding = 16,
  });

  /// When true the grid sizes to its content so it can sit inside another scroll view.
  final bool embedded;
  final List<Product> products;

  /// Optional widget shown above the grid that scrolls away with it.
  final Widget? header;

  /// Space under the last row, e.g. to clear a floating bar.
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No items found',
        message: 'Try a different search or category.',
      );
    }
    const delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      mainAxisExtent: _cardExtent,
    );
    if (embedded) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: delegate,
        itemCount: products.length,
        itemBuilder: (_, i) => ProductCard(product: products[i]),
      );
    }
    return CustomScrollView(
      slivers: [
        if (header != null) SliverToBoxAdapter(child: header),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
          sliver: SliverGrid.builder(
            gridDelegate: delegate,
            itemCount: products.length,
            itemBuilder: (_, i) => ProductCard(product: products[i]),
          ),
        ),
      ],
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
