import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/widgets/empty_state_kit.dart';

/// Shown on the Orders tab before the first order is placed.
class EmptyOrders extends StatefulWidget {
  const EmptyOrders({super.key, required this.onShop});

  final VoidCallback onShop;

  @override
  State<EmptyOrders> createState() => _EmptyOrdersState();
}

class _EmptyOrdersState extends State<EmptyOrders> with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  /// Loops the hero only while the phone allows animation; with "Remove
  /// animations" on, everything stays at rest.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _float
        ..stop()
        ..value = 0;
    } else if (!_float.isAnimating) {
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Widget _line(double width, {bool strong = false}) => Container(
    width: width,
    height: 8,
    decoration: BoxDecoration(
      color: strong ? AppColors.primary.withValues(alpha: 0.25) : AppColors.border,
      borderRadius: BorderRadius.circular(4),
    ),
  );

  Widget _receipt() {
    return Container(
      width: 112,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 6),
              _line(34, strong: true),
            ],
          ),
          const SizedBox(height: 14),
          _line(84),
          const SizedBox(height: 8),
          _line(64),
          const SizedBox(height: 8),
          _line(76),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_line(30), _line(30, strong: true)],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return EmptyStateEntrance(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 230,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 184,
                  height: 184,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.06),
                  ),
                ),
                Container(
                  width: 138,
                  height: 138,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.09),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: reduceMotion ? 1 : 0.6, end: 1),
                  duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 750),
                  curve: Curves.elasticOut,
                  builder: (_, s, child) => Transform.scale(scale: s, child: child),
                  child: FloatingBob(
                    animation: _float,
                    child: Transform.rotate(angle: -math.pi / 36, child: _receipt()),
                  ),
                ),
                FloatingBob(
                  animation: _float,
                  dx: 78,
                  dy: 54,
                  phase: 0.3,
                  child: const EmptyStateChip(icon: Icons.local_shipping_rounded, size: 18),
                ),
                FloatingBob(
                  animation: _float,
                  dx: -82,
                  dy: -48,
                  phase: 0.65,
                  child: const EmptyStateChip(icon: Icons.egg_alt_rounded, size: 16),
                ),
                FloatingBob(
                  animation: _float,
                  dx: 82,
                  dy: -62,
                  phase: 0.9,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const EmptyStateText(
            title: 'No orders yet',
            message: 'Your first fresh order is just a few taps away. Once you place it, you can track it live right here.',
          ),
          const SizedBox(height: 28),
          const EmptyStateSteps(
            steps: [
              (Icons.shopping_basket_rounded, 'Pick your items'),
              (Icons.local_shipping_rounded, 'We deliver fresh'),
              (Icons.my_location_rounded, 'Track it live'),
            ],
          ),
          const SizedBox(height: 32),
          EmptyStateAction(
            label: 'Start shopping',
            icon: Icons.shopping_bag_rounded,
            onPressed: widget.onShop,
          ),
        ],
      ),
    );
  }
}
