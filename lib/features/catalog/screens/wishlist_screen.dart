import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/add_control.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/product_image.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../cart/models/cart_models.dart';
import '../../cart/providers/cart_providers.dart';
import '../../cart/widgets/view_cart_bar.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../widgets/product_options_sheet.dart';
import '../../../core/constants/spacing.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final hasCart = !ref.watch(cartSummaryProvider).isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(title: const Text('Wishlist'), backgroundColor: const Color(0xFFF8F8F8)),
      body: Stack(
        children: [
          AsyncView(
            value: ref.watch(productsProvider),
            onRetry: () => ref.invalidate(productsProvider),
            data: (products) {
              final saved = products.where((p) => favorites.contains(p.id)).toList();
              if (saved.isEmpty) {
                return EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Your wishlist is empty',
                  message: 'Tap the heart on any item to save it here.',
                  action: OutlinedButton(
                    onPressed: () => context.go(Routes.home),
                    child: const Text('Browse items'),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16, 8, 16, hasCart ? 96 : 24),
                itemCount: saved.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _WishlistCard(product: saved[i]),
              );
            },
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

class _WishlistCard extends ConsumerWidget {
  const _WishlistCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(productQuantityProvider(product.id));
    final cart = ref.read(cartProvider.notifier);
    final variant = product.defaultVariant;

    CartLine? line() => ref
        .read(cartProvider)
        .where((l) => l.productId == product.id && !l.isAddon)
        .firstOrNull;

    return GestureDetector(
      onTap: () => context.push(Routes.productFor(product.id)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImage(asset: product.image, size: 64, radius: 12),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          text: rupees(variant.price),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                          children: [
                            TextSpan(
                              text: ' / ${variant.label}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      RatingLabel(rating: product.rating, count: product.ratingCount, small: true),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => ref.read(favoritesProvider.notifier).toggle(product.id),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.favorite_rounded, color: AppColors.primary, size: 22),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.border),
            Align(
              alignment: Alignment.centerRight,
              child: quantity > 0
                  ? QtyStepper(
                      quantity: quantity,
                      onIncrement: () => product.needsOptions
                          ? showProductOptionsSheet(context, product)
                          : cart.increment(line()!.id),
                      onDecrement: () => product.needsOptions
                          ? showProductOptionsSheet(context, product)
                          : cart.decrement(line()!.id),
                    )
                  : SizedBox(
                      height: 34,
                      child: FilledButton(
                        onPressed: () => product.needsOptions
                            ? showProductOptionsSheet(context, product)
                            : cart.add(CartLine.fromVariant(product, variant)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
