import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/brand_refresh.dart';
import '../../../core/widgets/scroll_fade_away.dart';
import '../../cart/providers/cart_providers.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../catalog/models/catalog_models.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../../catalog/widgets/product_grid.dart';
import '../widgets/category_strip.dart';
import '../widgets/home_header.dart';
import '../widgets/promo_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    final categories = ref.watch(categoriesProvider);
    final banners = ref.watch(bannersProvider);
    final hasCart = !ref.watch(cartSummaryProvider).isEmpty;

    Future<void> refresh() async {
      ref.invalidate(categoriesProvider);
      ref.invalidate(productsProvider);
      ref.invalidate(bannersProvider);
      await ref.read(productsProvider.future);
    }

    return Scaffold(
      body: SafeArea(
        child: BrandRefresh(
          onRefresh: refresh,
          child: CustomScrollView(
            slivers: [
              // The logo and address scroll away; the search bar stays pinned.
              const SliverToBoxAdapter(child: HomeHeader()),
              const SliverPersistentHeader(pinned: true, delegate: HomeSearchPinnedDelegate()),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  // Drifts, shrinks and fades as it slides under the pinned search bar.
                  ScrollFadeAway(
                    child: SizedBox(
                      height: 194,
                      child: AsyncView(
                        value: banners,
                        data: (list) => PromoCarousel(banners: list),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Categories',
                    actionLabel: 'See All',
                    onAction: () => context.go(Routes.categories),
                  ),
                  const SizedBox(height: 14),
                  categories.maybeWhen(
                    data: (list) => CategoryStrip(
                      categories: list,
                      selectedId: selected,
                      onSelected: ref.read(selectedCategoryProvider.notifier).select,
                    ),
                    orElse: () => const SizedBox(height: 108),
                  ),
                  const SizedBox(height: 8),
                  if (selected == null) ...[
                    _Section(
                      title: 'Popular Picks',
                      query: const ProductQuery(popularOnly: true),
                      route: Routes.productsFor(title: 'Popular Picks', section: 'popular'),
                    ),
                    _Section(
                      title: 'Recommended',
                      query: const ProductQuery(recommendedOnly: true),
                      route: Routes.productsFor(title: 'Recommended', section: 'recommended'),
                    ),
                  ] else
                    _CategoryProducts(categoryId: selected),
                ]),
              ),
              // Keeps the last row clear of the floating View cart bar.
              SliverToBoxAdapter(child: SizedBox(height: hasCart ? 96 : 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({required this.title, required this.query, required this.route});

  final String title;
  final ProductQuery query;
  final String route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider(query));
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        children: [
          SectionHeader(
            title: title,
            actionLabel: 'View all →',
            onAction: () => context.push(route),
          ),
          const SizedBox(height: 12),
          products.when(
            data: (list) => ProductRail(products: list),
            loading: () =>
                const SizedBox(height: 274, child: Center(child: CircularProgressIndicator())),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CategoryProducts extends ConsumerWidget {
  const _CategoryProducts({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider(ProductQuery(categoryId: categoryId)));
    return products.when(
      data: (list) => ProductGrid(products: list, embedded: true),
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
