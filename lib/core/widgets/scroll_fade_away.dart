import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// As the page scrolls this widget up and away, it drifts a little slower than
/// the page (parallax), shrinks back and fades, instead of just sliding off.
/// Used on the Home banner.
class ScrollFadeAway extends StatelessWidget {
  const ScrollFadeAway({super.key, required this.child, this.startBefore = 56});

  final Widget child;

  /// Starts the effect this many pixels before the widget reaches the top
  /// (e.g. the height of a pinned bar it slides under).
  final double startBefore;

  @override
  Widget build(BuildContext context) {
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null || MediaQuery.disableAnimationsOf(context)) return child;

    return AnimatedBuilder(
      animation: position,
      child: child,
      builder: (context, child) {
        final t = _progress(context, position);
        // Always the same wrappers, even at rest, so the child's state (e.g. the
        // carousel's page and timer) survives crossing in and out of the effect.
        return Opacity(
          opacity: (1 - t * 1.15).clamp(0.0, 1.0),
          child: Transform.translate(
            // Lags behind the scroll by 35%: the parallax.
            offset: Offset(0, t * _height(context) * 0.35),
            child: Transform.scale(scale: 1 - 0.1 * t, child: child),
          ),
        );
      },
    );
  }

  /// 0 while fully below the top edge, 1 once scrolled a whole height past it.
  double _progress(BuildContext context, ScrollPosition position) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return 0;
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return 0;
    // The scroll offset at which this widget's top touches the top of the list.
    final top = viewport.getOffsetToReveal(box, 0).offset;
    final past = position.pixels - top + startBefore;
    return (past / box.size.height).clamp(0.0, 1.0);
  }

  double _height(BuildContext context) {
    final box = context.findRenderObject();
    return box is RenderBox && box.hasSize ? box.size.height : 0;
  }
}
