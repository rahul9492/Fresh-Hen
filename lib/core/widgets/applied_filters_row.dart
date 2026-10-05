import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppliedFilter {
  const AppliedFilter({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;
}

/// Horizontal row of removable chips showing the filters currently applied.
class AppliedFiltersRow extends StatelessWidget {
  const AppliedFiltersRow({super.key, required this.filters});

  final List<AppliedFilter> filters;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => InputChip(
          label: Text(filters[i].label),
          onDeleted: filters[i].onRemove,
          deleteIconColor: AppColors.primary,
          backgroundColor: AppColors.accentSoft,
          side: BorderSide.none,
          labelStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
