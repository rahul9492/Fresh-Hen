import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

/// The UPI screenshot is with the store: an hourglass that keeps flipping over.
class AwaitingPaymentCard extends StatefulWidget {
  const AwaitingPaymentCard({super.key});

  @override
  State<AwaitingPaymentCard> createState() => _AwaitingCardState();
}

class _AwaitingCardState extends State<AwaitingPaymentCard> with SingleTickerProviderStateMixin {
  static const _amber = Color(0xFFB7791F);

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: _amber.withValues(alpha: 0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                // Sand runs for most of the cycle, then the glass flips with a little overshoot.
                final t = _controller.value;
                final flip = t < 0.78 ? 0.0 : Curves.easeInOutBack.transform((t - 0.78) / 0.22);
                return Transform.rotate(angle: flip * math.pi, child: child);
              },
              child: const Icon(Icons.hourglass_top_rounded, color: _amber, size: 32),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Waiting for confirmation', style: AppType.display(size: 17)),
                const SizedBox(height: 3),
                const Text(
                  "We're checking your payment screenshot. We'll confirm your order in a few minutes.",
                  style: TextStyle(color: AppColors.body, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
