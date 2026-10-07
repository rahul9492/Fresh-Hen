import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/press_scale.dart';

/// "Clear" in the app bar: a soft rose pill with a sweep icon that squishes
/// when pressed, so emptying the cart feels deliberate rather than alarming.
class ClearCartChip extends StatelessWidget {
  const ClearCartChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Clear cart',
      excludeSemantics: true,
      child: PressScale(
        scale: 0.92,
        child: Material(
          color: AppColors.accentSoft,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.accent.withValues(alpha: 0.12),
            highlightColor: AppColors.accent.withValues(alpha: 0.06),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(10, 7, 14, 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_sweep_rounded, size: 18, color: AppColors.primaryDark),
                  SizedBox(width: 6),
                  Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
