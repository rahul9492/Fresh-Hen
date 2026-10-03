import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/add_control.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../cart/models/cart_models.dart';
import '../../cart/providers/cart_providers.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../widgets/product_grid.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productByIdProvider(productId));
    return Scaffold(
      backgroundColor: Colors.white,
      body: AsyncView(
        value: product,
        onRetry: () => ref.invalidate(productByIdProvider(productId)),
        data: (p) => p == null
            ? const EmptyState(icon: Icons.search_off_rounded, title: 'Item not available')
            : _Detail(product: p),
      ),
    );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.product});

  final Product product;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  late ProductVariant _variant = _initialVariant();

  Product get _product => widget.product;

  ProductVariant _initialVariant() {
    final inCart = ref.read(cartProvider).map((l) => l.id).toSet();
    return _product.variants.firstWhere(
      (v) => inCart.contains(CartLine.fromVariant(_product, v).id),
      orElse: () => _product.defaultVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final line = CartLine.fromVariant(_product, _variant);
    final quantity = ref.watch(lineQuantityProvider(line.id));
    final cart = ref.read(cartProvider.notifier);
    final inCartIds = ref.watch(cartProvider).map((l) => l.id).toSet();
    final similar = ref
            .watch(filteredProductsProvider(ProductQuery(categoryId: _product.categoryId)))
            .value
            ?.where((p) => p.id != _product.id)
            .toList() ??
        const <Product>[];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Gallery(product: _product),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            i < _product.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.star,
                            size: 18,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          '${_product.rating} (${compactCount(_product.ratingCount)})',
                          style: const TextStyle(fontSize: 13, color: AppColors.body),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _product.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 18),
                    const Text('Select unit(s)', style: TextStyle(fontSize: 15)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final v in _product.variants)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: v == _product.variants.last ? 0 : 10,
                              ),
                              child: _UnitTile(
                                variant: v,
                                selected: v == _variant,
                                inCart: inCartIds.contains(CartLine.fromVariant(_product, v).id),
                                onTap: () => setState(() => _variant = v),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (similar.isNotEmpty) ...[
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Similar meat',
                  actionLabel: 'View all →',
                  onAction: () => context.push(
                    Routes.productsFor(title: 'Similar meat', category: _product.categoryId),
                  ),
                ),
                const SizedBox(height: 12),
                ProductRail(products: similar),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
        _BottomBar(
          variant: _variant,
          quantity: quantity,
          onAdd: () => cart.add(line),
          onIncrement: () => cart.increment(line.id),
          onDecrement: () => cart.decrement(line.id),
        ),
      ],
    );
  }
}

class _Gallery extends ConsumerStatefulWidget {
  const _Gallery({required this.product});

  final Product product;

  @override
  ConsumerState<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends ConsumerState<_Gallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images;
    final isFavorite = ref.watch(favoritesProvider.select((f) => f.contains(widget.product.id)));

    Widget circle(IconData icon, VoidCallback onTap, {Color? color}) => IconButton.outlined(
          onPressed: onTap,
          icon: Icon(icon, size: 20, color: color),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border),
          ),
        );

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              children: [
                circle(Icons.keyboard_arrow_down_rounded, () => Navigator.of(context).maybePop()),
                const Spacer(),
                circle(Icons.search_rounded, () => context.push(Routes.search)),
                const SizedBox(width: 8),
                circle(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  () => ref.read(favoritesProvider.notifier).toggle(widget.product.id),
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(images[i], fit: BoxFit.cover, width: double.infinity),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < images.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 8 : 6,
                height: i == _index ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _index ? AppColors.primary : const Color(0xFFCFCFCF),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({
    required this.variant,
    required this.selected,
    required this.inCart,
    required this.onTap,
  });

  final ProductVariant variant;
  final bool selected;
  final bool inCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    variant.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (inCart)
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text('MRP ', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                Text(
                  rupees(variant.price),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.variant,
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ProductVariant variant;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(variant.label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                Text(
                  rupees(variant.price),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: quantity == 0
                  ? AppButton(label: 'Add to cart', onPressed: onAdd, height: 54)
                  : Row(
                      children: [
                        QtyStepper(
                          quantity: quantity,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                          height: 54,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            label: 'View cart',
                            height: 54,
                            onPressed: () => context.push(Routes.cart),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
