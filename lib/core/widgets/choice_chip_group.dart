import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Single-select chip group (sort options, categories, address labels, ...).
class ChoiceChipGroup<T> extends StatelessWidget {
  const ChoiceChipGroup({
    super.key,
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
