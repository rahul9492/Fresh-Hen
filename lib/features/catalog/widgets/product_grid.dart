import '../../../core/widgets/staggered_fade_in.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/small_widgets.dart';
import '../models/catalog_models.dart';
import 'product_card.dart';

const _gridPadding = 16.0;
const _gridSpacing = 12.0;

/// Extra columns are added (tablets, web) only while every card stays at least
/// this wide, so the price and the Add button always fit side by side.
const _minCardWidth = 170.0;

/// Height of a [ProductCard] [cardWidth] wide. Its image keeps a 1.4 ratio, so
/// wider cards need taller rows or the price row overflows.
double _cardExtentFor(double cardWidth) => (cardWidth - 20) / 1.4 + 170;

SliverGridDelegate _gridDelegateFor(double width) {
  final available = width - 2 * _gridPadding;
  final columns =
      ((available + _gridSpacing) / (_minCardWidth + _gridSpacing)).floor().clamp(2, 6);
  final cardWidth = (available - _gridSpacing * (columns - 1)) / columns;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    mainAxisSpacing: _gridSpacing,
    crossAxisSpacing: _gridSpacing,
    mainAxisExtent: _cardExtentFor(cardWidth),
  );
}

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
    return LayoutBuilder(
      builder: (_, constraints) {
        final delegate = _gridDelegateFor(constraints.maxWidth);
        if (embedded) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(_gridPadding),
            gridDelegate: delegate,
            itemCount: products.length,
            itemBuilder: (_, i) => StaggeredFadeIn(index: i, child: ProductCard(product: products[i])),
          );
        }
        return CustomScrollView(
          slivers: [
            if (header != null) SliverToBoxAdapter(child: header),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(_gridPadding, _gridPadding, _gridPadding, bottomPadding),
              sliver: SliverGrid.builder(
                gridDelegate: delegate,
                itemCount: products.length,
                itemBuilder: (_, i) => StaggeredFadeIn(index: i, child: ProductCard(product: products[i])),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProductRail extends StatelessWidget {
  const ProductRail({super.key, required this.products});

  final List<Product> products;

  static const _cardWidth = 165.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cardExtentFor(_cardWidth),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(width: _cardWidth, child: ProductCard(product: products[i])),
      ),
    );
  }
}
