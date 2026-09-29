import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/widgets/async_view.dart';
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

    Future<void> refresh() async {
      ref.invalidate(categoriesProvider);
      ref.invalidate(productsProvider);
      ref.invalidate(bannersProvider);
      await ref.read(productsProvider.future);
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const HomeHeader(),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: AsyncView(
                  value: banners,
                  data: (list) => PromoCarousel(banners: list),
                ),
              ),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Categories',
                actionLabel: 'See All',
                onAction: () => context.go(Routes.categories),
              ),
              const SizedBox(height: 12),
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
      padding: const EdgeInsets.only(top: 12),
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
            loading: () => const SizedBox(
              height: 274,
              child: Center(child: CircularProgressIndicator()),
            ),
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
