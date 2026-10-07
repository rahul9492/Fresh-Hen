import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_state_kit.dart';

class EmptyWishlist extends StatefulWidget {
  const EmptyWishlist({super.key, required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  State<EmptyWishlist> createState() => _EmptyWishlistState();
}

class _EmptyWishlistState extends State<EmptyWishlist> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  /// Loops the hero only while the phone allows animation; with "Remove
  /// animations" on, everything stays at rest.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 0;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Widget _accent(IconData icon, double size, double dx, double dy, double phase) {
    return FloatingBob(
      animation: _pulse,
      dx: dx,
      dy: dy,
      phase: phase,
      child: Icon(icon, size: size, color: AppColors.primary.withValues(alpha: 0.35)),
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
            width: 220,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft pulsing halo rings behind the heart.
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, _) {
                    final t = Curves.easeInOut.transform(_pulse.value);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 190 + t * 10,
                          height: 190 + t * 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.05),
                          ),
                        ),
                        Container(
                          width: 144 + t * 6,
                          height: 144 + t * 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.09),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: reduceMotion ? 1 : 0.5, end: 1),
                  duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 750),
                  curve: Curves.elasticOut,
                  builder: (_, s, child) => Transform.scale(scale: s, child: child),
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, child) => Transform.scale(
                      scale: 1 + Curves.easeInOut.transform(_pulse.value) * 0.06,
                      child: child,
                    ),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary.withValues(alpha: 0.85), AppColors.primary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.favorite_rounded, size: 46, color: Colors.white),
                    ),
                  ),
                ),
                _accent(Icons.favorite_rounded, 16, -84, -52, 0),
                _accent(Icons.auto_awesome_rounded, 18, 84, -64, 0.35),
                _accent(Icons.favorite_rounded, 12, 78, 56, 0.6),
                _accent(Icons.auto_awesome_rounded, 12, -78, 60, 0.85),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const EmptyStateText(
            title: 'Nothing saved yet',
            message: 'Keep your favourites one tap away. Save the fresh picks you love and reorder them in seconds.',
          ),
          const SizedBox(height: 28),
          const EmptyStateSteps(
            steps: [
              (Icons.search_rounded, 'Find something fresh'),
              (Icons.favorite_border_rounded, 'Tap the heart'),
              (Icons.bolt_rounded, 'Reorder anytime'),
            ],
          ),
          const SizedBox(height: 32),
          EmptyStateAction(
            label: 'Start exploring',
            icon: Icons.storefront_rounded,
            onPressed: widget.onBrowse,
          ),
        ],
      ),
    );
  }
}
