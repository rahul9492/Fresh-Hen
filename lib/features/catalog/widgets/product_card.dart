import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/press_scale.dart';
import '../../../core/widgets/product_image.dart';
import '../../../core/widgets/small_widgets.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import 'product_add_control.dart';
import '../../../core/constants/spacing.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider.select((f) => f.contains(product.id)));

    // Unique per card, so the same product shown twice on a screen never shares a tag.
    final heroTag = 'product-${product.id}-${context.hashCode}';

    return PressScale(
      child: GestureDetector(
      onTap: () => context.push(Routes.productFor(product.id), extra: heroTag),
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(tag: heroTag, child: ProductImage(asset: product.image)),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => ref.read(favoritesProvider.notifier).toggle(product.id),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            product.defaultVariant.label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          RatingLabel(rating: product.rating, count: product.ratingCount, small: true),
          const Spacer(),
          const Divider(height: 16, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Shrinks rather than overflowing on very narrow cards.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    rupees(product.defaultVariant.price),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ProductAddControl(product: product),
            ],
          ),
        ],
      ),
    ),
    ),
    );
  }
}
