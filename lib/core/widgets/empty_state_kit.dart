import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../constants/spacing.dart';

/// Building blocks shared by the premium empty states (wishlist, orders), so a
/// style change happens in one place.

/// Centers and scrolls the content, and fades it up when it first appears.
class EmptyStateEntrance extends StatelessWidget {
  const EmptyStateEntrance({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Center(
      child: SingleChildScrollView(
        // Bottom padding keeps the content clear of the floating View cart bar.
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 96),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
          builder: (_, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: child),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Drifts [child] up and down, offset from its resting position by ([dx], [dy]).
/// [phase] staggers several of them driven by the same [animation].
class FloatingBob extends StatelessWidget {
  const FloatingBob({
    super.key,
    required this.animation,
    required this.child,
    this.dx = 0,
    this.dy = 0,
    this.phase = 0,
  });

  final Animation<double> animation;
  final Widget child;
  final double dx;
  final double dy;
  final double phase;

  @override
  Widget build(BuildContext context) {
    // With "Remove animations" on it sits still at its resting place.
    if (MediaQuery.disableAnimationsOf(context)) {
      return Transform.translate(offset: Offset(dx, dy), child: child);
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        final t = Curves.easeInOut.transform((animation.value + phase) % 1.0);
        return Transform.translate(offset: Offset(dx, dy + (t - 0.5) * 10), child: child);
      },
      child: child,
    );
  }
}

/// A small white badge holding an icon, used for the floating accents.
class EmptyStateChip extends StatelessWidget {
  const EmptyStateChip({super.key, required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppShadow.card,
      ),
      child: Icon(icon, size: size, color: AppColors.primary),
    );
  }
}

/// Headline and supporting message.
class EmptyStateText extends StatelessWidget {
  const EmptyStateText({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppType.display(size: 24, weight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 290),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.body, height: 1.45),
          ),
        ),
      ],
    );
  }
}

/// A row of three short "how it works" steps.
class EmptyStateSteps extends StatelessWidget {
  const EmptyStateSteps({super.key, required this.steps});

  final List<(IconData, String)> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (icon, label) in steps)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppShadow.card,
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.body, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The full-width call-to-action under an empty state.
class EmptyStateAction extends StatelessWidget {
  const EmptyStateAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}
