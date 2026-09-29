import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/small_widgets.dart';
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
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: widget.initialQuery == null,
          textInputAction: TextInputAction.search,
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Search chicken, mutton, eggs...',
            border: InputBorder.none,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () => _setSearch(''),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
          ),
          onChanged: (v) => setState(() => _query = _query.copyWith(search: v)),
        ),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: _hasFilters,
              smallSize: 8,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: _hasCriteria
          ? AsyncView(
              value: ref.watch(filteredProductsProvider(_query)),
              onRetry: () => ref.invalidate(filteredProductsProvider(_query)),
              data: (products) => products.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No items found',
                      message: 'Try a different search or adjust filters.',
                    )
                  : ProductGrid(products: products),
            )
          : _Suggestions(onSelected: _setSearch),
    );
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
