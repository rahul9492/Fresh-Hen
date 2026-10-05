import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/choice_chip_group.dart';
import '../../../core/widgets/filter_sheet_scaffold.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';

Future<ProductQuery?> showFilterSheet(BuildContext context, ProductQuery initial) {
  return showAppSheet<ProductQuery>(context, builder: (_) => FilterSheet(initial: initial));
}

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final ProductQuery initial;

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late ProductQuery _query = widget.initial;

  RangeValues get _range => RangeValues(
        (_query.minPrice ?? 0).toDouble(),
        (_query.maxPrice ?? AppConstants.filterPriceMax).toDouble(),
      );

  void _setRange(RangeValues r) {
    final full = r.start == 0 && r.end == AppConstants.filterPriceMax;
    setState(() {
      _query = full
          ? _query.copyWith(minPrice: null, maxPrice: null)
          : _query.copyWith(minPrice: r.start.round(), maxPrice: r.end.round());
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final title = Theme.of(context).textTheme.titleMedium;
    final range = _range;

    return FilterSheetScaffold(
      onReset: () => setState(() => _query = const ProductQuery()),
      onApply: () => Navigator.of(context).pop(_query),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort by', style: title),
          const SizedBox(height: 12),
          ChoiceChipGroup<ProductSort>(
            values: ProductSort.values,
            selected: _query.sort,
            label: (s) => s.label,
            onSelected: (s) => setState(() => _query = _query.copyWith(sort: s)),
          ),
          const SizedBox(height: 24),
          Text('Category', style: title),
          const SizedBox(height: 12),
          ChoiceChipGroup<String?>(
            values: [null, ...categories.map((c) => c.id)],
            selected: _query.categoryId,
            label: (id) => id == null ? 'All' : categories.firstWhere((c) => c.id == id).name,
            onSelected: (id) => setState(() => _query = _query.copyWith(categoryId: id)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Text('Price range', style: title)),
              Text(
                '${rupees(range.start.round())} - ${rupees(range.end.round())}'
                '${range.end == AppConstants.filterPriceMax ? '+' : ''}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          RangeSlider(
            values: range,
            max: AppConstants.filterPriceMax.toDouble(),
            divisions: AppConstants.filterPriceMax ~/ 50,
            activeColor: AppColors.primary,
            onChanged: _setRange,
          ),
        ],
      ),
    );
  }
}
