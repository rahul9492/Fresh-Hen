import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../catalog/models/catalog_models.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../../catalog/widgets/product_grid.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  var _query = const ProductQuery();

  Future<void> _pickSort() async {
    final sort = await showModalBottomSheet<ProductSort>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in ProductSort.values)
              ListTile(
                title: Text(s.label),
                trailing: s == _query.sort
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, s),
              ),
          ],
        ),
      ),
    );
    if (sort != null) setState(() => _query = _query.copyWith(sort: sort));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          cursorColor: AppColors.primary,
          decoration: const InputDecoration(
            hintText: 'Search chicken, mutton, eggs...',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = _query.copyWith(search: v)),
        ),
        actions: [IconButton(onPressed: _pickSort, icon: const Icon(Icons.tune_rounded))],
      ),
      body: AsyncView(
        value: ref.watch(filteredProductsProvider(_query)),
        onRetry: () => ref.invalidate(filteredProductsProvider(_query)),
        data: (products) => products.isEmpty
            ? const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No items found',
                message: 'Try a different search.',
              )
            : ProductGrid(products: products),
      ),
    );
  }
}
