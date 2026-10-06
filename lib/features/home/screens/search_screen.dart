import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/applied_filters_row.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/filter_button.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../cart/providers/cart_providers.dart';
import '../../cart/widgets/view_cart_bar.dart';
import '../../catalog/models/catalog_models.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../../catalog/widgets/filter_sheet.dart';
import '../../catalog/widgets/product_grid.dart';

const _popularSearches = [
  'Chicken curry cut',
  'Boneless',
  'Drumstick',
  'Mutton',
  'Eggs',
  'Country hen',
  'Fish',
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final ProductQuery? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  late ProductQuery _query = widget.initialQuery ?? const ProductQuery();

  @override
  void initState() {
    super.initState();
    _controller.text = _query.search;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasCriteria => _query != const ProductQuery();

  bool get _hasFilters => _query.copyWith(search: '') != const ProductQuery();

  void _setSearch(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() => _query = _query.copyWith(search: value));
  }

  Future<void> _openFilters() async {
    final result = await showFilterSheet(context, _query);
    if (result != null) setState(() => _query = result.copyWith(search: _query.search));
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final categoryName =
        categories.where((c) => c.id == _query.categoryId).firstOrNull?.name;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppSearchBar(
          controller: _controller,
          hint: categoryName == null
              ? 'Search chicken, mutton, eggs...'
              : 'Search in $categoryName...',
          autofocus: widget.initialQuery == null,
          bordered: false,
          debounce: const Duration(milliseconds: 300),
          onChanged: (v) => setState(() => _query = _query.copyWith(search: v)),
        ),
        actions: [FilterButton(onPressed: _openFilters, isActive: _hasFilters)],
      ),
      // The View cart bar floats over the results (and above the keyboard while typing).
      body: Stack(
        children: [
          _hasCriteria
              ? Column(
                  children: [
                    AppliedFiltersRow(filters: _appliedFilters(categories)),
                    Expanded(child: _results()),
                  ],
                )
              : _Suggestions(onSelected: _setSearch),
          const Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(top: false, child: ViewCartBar()),
          ),
        ],
      ),
    );
  }

  Widget _results() {
    final hasCart = !ref.watch(cartSummaryProvider).isEmpty;
    return AsyncView(
      value: ref.watch(filteredProductsProvider(_query)),
      onRetry: () => ref.invalidate(filteredProductsProvider(_query)),
      data: (products) => products.isEmpty
          ? const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No items found',
              message: 'Try a different search or adjust filters.',
            )
          // Room at the bottom so the last row isn't hidden behind the cart bar.
          : ProductGrid(products: products, bottomPadding: hasCart ? 96 : 16),
    );
  }

  List<AppliedFilter> _appliedFilters(List<Category> categories) {
    const defaults = ProductQuery();
    return [
      if (_query.sort != defaults.sort)
        AppliedFilter(
          label: _query.sort.label,
          onRemove: () => setState(() => _query = _query.copyWith(sort: defaults.sort)),
        ),
      if (_query.categoryId != null)
        AppliedFilter(
          label: categories.where((c) => c.id == _query.categoryId).firstOrNull?.name ?? 'Category',
          onRemove: () => setState(() => _query = _query.copyWith(categoryId: null)),
        ),
      if (_query.minPrice != null || _query.maxPrice != null)
        AppliedFilter(
          label:
              '${rupees(_query.minPrice ?? 0)} - ${rupees(_query.maxPrice ?? AppConstants.filterPriceMax)}',
          onRemove: () => setState(() => _query = _query.copyWith(minPrice: null, maxPrice: null)),
        ),
    ];
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Popular searches', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final term in _popularSearches)
              ActionChip(
                avatar: const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.primary),
                label: Text(term),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                onPressed: () => onSelected(term),
              ),
          ],
        ),
      ],
    );
  }
}
