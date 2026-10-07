import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../../catalog/widgets/product_grid.dart';
import '../providers/cart_providers.dart';

class CartRecommended extends ConsumerWidget {
  const CartRecommended({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(cartProvider).map((l) => l.productId).toSet();
    final products = ref.watch(productsProvider).value ?? const [];
    final picks = products.where((p) => p.isRecommended && !inCart.contains(p.id)).toList();
    if (picks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Recommended', style: AppType.display(size: 19)),
        ),
        const SizedBox(height: 12),
        ProductRail(products: picks),
      ],
    );
  }
}
