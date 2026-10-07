import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// A red dot with a ring that keeps rippling out of it, meaning "happening now".
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
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
    return SizedBox(
      width: 22,
      height: 22,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final t = Curves.easeOut.transform(_controller.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              if (_controller.isAnimating)
                Container(
                  width: 10 + 12 * t,
                  height: 10 + 12 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.35 * (1 - t)),
                  ),
                ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
              ),
            ],
          );
        },
      ),
    );
  }
}
