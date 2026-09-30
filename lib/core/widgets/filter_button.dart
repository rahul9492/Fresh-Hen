import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Filter icon with a dot when [isActive]. Use [bordered] for the boxed variant
/// next to a search bar; leave it off inside an AppBar.
class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.onPressed,
    this.isActive = false,
    this.bordered = false,
  });

  final VoidCallback onPressed;
  final bool isActive;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final icon = Badge(
      isLabelVisible: isActive,
      smallSize: 8,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.tune_rounded),
    );
    if (!bordered) return IconButton(onPressed: onPressed, icon: icon);
    return IconButton.outlined(
      onPressed: onPressed,
      icon: icon,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        fixedSize: const Size(48, 48),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
