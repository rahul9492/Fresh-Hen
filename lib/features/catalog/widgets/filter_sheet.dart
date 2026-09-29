import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';

Future<ProductQuery?> showFilterSheet(BuildContext context, ProductQuery initial) {
  return showModalBottomSheet<ProductQuery>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FilterSheet(initial: initial),
  );
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            children: [
              Row(
                children: [
                  Expanded(child: Text('Filters', style: Theme.of(context).textTheme.titleLarge)),
                  TextButton(
                    onPressed: () => setState(() => _query = const ProductQuery()),
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Sort by', style: title),
              const SizedBox(height: 10),
              _Chips<ProductSort>(
                values: ProductSort.values,
                selected: _query.sort,
                label: (s) => s.label,
                onSelected: (s) => setState(() => _query = _query.copyWith(sort: s)),
              ),
              const SizedBox(height: 22),
              Text('Category', style: title),
              const SizedBox(height: 10),
              _Chips<String?>(
                values: [null, ...categories.map((c) => c.id)],
                selected: _query.categoryId,
                label: (id) => id == null ? 'All' : categories.firstWhere((c) => c.id == id).name,
                onSelected: (id) => setState(() => _query = _query.copyWith(categoryId: id)),
              ),
              const SizedBox(height: 22),
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
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: AppButton(
            label: 'Show results',
            onPressed: () => Navigator.of(context).pop(_query),
          ),
        ),
      ],
    );
  }
}

class _Chips<T> extends StatelessWidget {
  const _Chips({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(label(v)),
            selected: v == selected,
            showCheckmark: false,
            selectedColor: AppColors.accentSoft,
            backgroundColor: Colors.white,
            side: BorderSide(color: v == selected ? AppColors.primary : AppColors.border),
            labelStyle: TextStyle(
              color: v == selected ? AppColors.primary : AppColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            onSelected: (_) => onSelected(v),
          ),
      ],
    );
  }
}
