import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/spacing.dart';

enum AddControlStyle { pill, round }

class AddControl extends StatelessWidget {
  const AddControl({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.style = AddControlStyle.pill,
    this.available = true,
  });

  final int quantity;

  /// False shows a disabled "Sold out" instead of Add.
  final bool available;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final AddControlStyle style;

  @override
  Widget build(BuildContext context) {
    // Add <-> stepper swap with a small pop, so adding an item feels responsive.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: KeyedSubtree(key: ValueKey(quantity > 0), child: _content()),
    );
  }

  Widget _content() {
    if (quantity > 0) {
      return QtyStepper(quantity: quantity, onIncrement: onIncrement, onDecrement: onDecrement);
    }
    if (style == AddControlStyle.round) {
      return Material(
        color: available ? AppColors.primary : AppColors.border,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: available ? onAdd : null,
          child: const SizedBox.square(
            dimension: 34,
            child: Icon(Icons.add_rounded, color: Colors.white, size: 22),
          ),
        ),
      );
    }
    return SizedBox(
      height: 34,
      child: OutlinedButton(
        onPressed: available ? onAdd : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          disabledForegroundColor: AppColors.muted,
          side: BorderSide(color: available ? AppColors.primaryDark : AppColors.border),
          padding: EdgeInsets.symmetric(horizontal: available ? 22 : 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        child: Text(available ? 'Add' : 'Sold out'),
      ),
    );
  }
}

class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.height = 34,
    this.light = false,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final double height;

  /// Quieter look for lists: white with a red outline instead of a solid red block.
  final bool light;

  @override
  Widget build(BuildContext context) {
    final fg = light ? AppColors.primaryDark : Colors.white;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: light ? Colors.white : AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: light ? Border.all(color: AppColors.primaryDark.withValues(alpha: 0.6)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove_rounded, onTap: onDecrement, color: fg),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 24),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
          _StepButton(icon: Icons.add_rounded, onTap: onIncrement, color: fg),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap, required this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
