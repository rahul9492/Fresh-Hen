import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/add_control.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/press_scale.dart';
import '../../../core/widgets/product_hero.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../cart/models/cart_models.dart';
import '../../cart/providers/cart_providers.dart';
import '../../cart/widgets/view_cart_bar.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../widgets/product_grid.dart';
import '../../../core/constants/spacing.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId, this.heroTag});

  final String productId;

  /// Tag of the product card image that opened this page, so it can grow into the gallery.
  final String? heroTag;

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
            : _Detail(product: p, heroTag: heroTag),
      ),
    );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.product, this.heroTag});

  final Product product;
  final String? heroTag;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  late ProductVariant _variant = _initialVariant();

  /// How far the page is pulled down past its top; the photo zooms in with it.
  final _pull = ValueNotifier(0.0);
  late final ScrollController _scroll = ScrollController()
    ..addListener(() => _pull.value = _scroll.offset < 0 ? -_scroll.offset : 0);

  @override
  void dispose() {
    _scroll.dispose();
    _pull.dispose();
    super.dispose();
  }

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

    final hasCart = !ref.watch(cartSummaryProvider).isEmpty;

    return Column(
      children: [
        Expanded(
          // The View cart button floats over the page, just above the bottom bar.
          child: Stack(
            children: [
              ListView(
                controller: _scroll,
                // Lets the top be pulled down, so the photo can zoom with the pull.
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.zero,
                children: [
                  _Gallery(product: _product, heroTag: widget.heroTag, pull: _pull),
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
                        const SizedBox(height: 16),
                        const Text('Select unit(s)', style: TextStyle(fontSize: 15)),
                        const SizedBox(height: 12),
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
                  // Room so the last row can scroll clear of the floating cart button.
                  SizedBox(height: hasCart ? 88 : 16),
                ],
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: ViewCartBar(compact: true),
              ),
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
  const _Gallery({required this.product, this.heroTag, required this.pull});

  final Product product;
  final String? heroTag;

  /// Pixels the page is pulled down past its top.
  final ValueListenable<double> pull;

  @override
  ConsumerState<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends ConsumerState<_Gallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images;
    final isFavorite = ref.watch(favoritesProvider.select((f) => f.contains(widget.product.id)));

    Widget circle(IconData icon, VoidCallback onTap, {Color? color}) => IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 20, color: color),
          style: IconButton.styleFrom(backgroundColor: AppColors.shell),
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
              // Pulling the page down zooms the photo inside its frame.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: ValueListenableBuilder(
                  valueListenable: widget.pull,
                  builder: (_, pull, child) =>
                      Transform.scale(scale: 1 + (pull / 260).clamp(0.0, 0.35), child: child),
                  child: i == 0 && widget.heroTag != null
                      ? ProductHero(
                          tag: widget.heroTag!,
                          source: images[i],
                          radius: AppRadius.lg,
                          width: double.infinity,
                        )
                      : AppImage(source: images[i], width: double.infinity),
                ),
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
          borderRadius: BorderRadius.circular(AppRadius.md),
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
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary)
                else if (!variant.inStock)
                  const Text('Sold out', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text('MRP ', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                Text(
                  rupees(variant.price),
                  style: AppType.display(size: 16, weight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The bar's quantity stepper: a compact pill on the right with roomy tap
/// targets at each end and the count in the middle (rolling and popping like
/// the small steppers).
class _WideStepper extends StatelessWidget {
  const _WideStepper({required this.quantity, required this.onIncrement, required this.onDecrement});

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
        child: SizedBox(
        width: 150,
        height: 54,
        child: Material(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(AppRadius.md),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              _WideStepButton(icon: Icons.remove_rounded, onTap: onDecrement, label: 'Remove one'),
              Expanded(
                child: Center(
                  child: QtyCount(
                    quantity: quantity,
                    style: AppType.display(size: 20, weight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              _WideStepButton(icon: Icons.add_rounded, onTap: onIncrement, label: 'Add one more'),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideStepButton extends StatelessWidget {
  const _WideStepButton({required this.icon, required this.onTap, required this.label});

  final IconData icon;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: PressScale(
        scale: 0.85,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(width: 48, height: 54, child: Icon(icon, color: Colors.white, size: 22)),
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
                  style: AppType.display(size: 22, weight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              // Add, then a full-width stepper; "View cart" floats above the bar.
              child: quantity == 0
                  ? AppButton(
                      label: variant.inStock ? 'Add to cart' : 'Out of stock',
                      onPressed: variant.inStock ? onAdd : null,
                      height: 54,
                    )
                  : _WideStepper(
                      quantity: quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
