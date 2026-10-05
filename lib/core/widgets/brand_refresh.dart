import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Pull-to-refresh with the app's own look: an egg in a ring that fills as you
/// pull, then wobbles while it loads. Wrap a scrollable list; [onRefresh] runs
/// once when you let go past the pull distance and the indicator stays until it
/// finishes. The list bounces at the top (that is the pull itself).
class BrandRefresh extends StatefulWidget {
  const BrandRefresh({super.key, required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  /// How far (in logical pixels) the list must be pulled before letting go refreshes.
  static const triggerDistance = 80.0;

  /// Room the indicator keeps while loading.
  static const loadingExtent = 64.0;

  @override
  State<BrandRefresh> createState() => _BrandRefreshState();
}

class _BrandRefreshState extends State<BrandRefresh> {
  var _pull = 0.0;
  var _dragging = false;
  var _refreshing = false;

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (n is ScrollUpdateNotification || n is ScrollStartNotification) {
      final pull = math.max(0.0, -n.metrics.pixels);
      final dragging = n is ScrollUpdateNotification
          ? n.dragDetails != null
          : (n as ScrollStartNotification).dragDetails != null;
      // The finger just lifted after a long enough pull: refresh.
      if (_dragging && !dragging && _pull >= BrandRefresh.triggerDistance && !_refreshing) {
        _start();
      }
      if (pull != _pull || dragging != _dragging) {
        setState(() {
          _pull = pull;
          _dragging = dragging;
        });
      }
    } else if (n is ScrollEndNotification && _pull != 0) {
      setState(() {
        _pull = 0;
        _dragging = false;
      });
    }
    return false;
  }

  Future<void> _start() async {
    setState(() => _refreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extent = _refreshing ? BrandRefresh.loadingExtent : 0.0;
    final shown = math.max(_pull, extent);
    final progress = (_pull / BrandRefresh.triggerDistance).clamp(0.0, 1.0);

    return Stack(
      children: [
        // The indicator sits behind the list, in the gap the pull opens up.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: shown,
          child: ClipRect(
            child: _Indicator(progress: _refreshing ? 1 : progress, refreshing: _refreshing),
          ),
        ),
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: extent,
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: ScrollConfiguration(
                  behavior: const _BouncingBehavior(),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BouncingBehavior extends MaterialScrollBehavior {
  const _BouncingBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  // The bounce is the feedback; no glow or stretch on top of it.
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}

class _Indicator extends StatefulWidget {
  const _Indicator({required this.progress, required this.refreshing});

  final double progress;
  final bool refreshing;

  @override
  State<_Indicator> createState() => _IndicatorState();
}

class _IndicatorState extends State<_Indicator> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_Indicator old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = widget.refreshing && !MediaQuery.disableAnimationsOf(context);
    if (run && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!run && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: widget.progress.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.6 + 0.4 * widget.progress,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    // Fills as you pull; spins on its own while loading.
                    value: widget.refreshing ? null : widget.progress,
                    strokeWidth: 3,
                    color: AppColors.primary,
                    backgroundColor: AppColors.accentSoft,
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) => Transform.rotate(
                    angle: widget.refreshing
                        ? (_controller.value - 0.5) * 0.7
                        : widget.progress * 0.8,
                    child: child,
                  ),
                  child: const Icon(Icons.egg_alt_rounded, size: 20, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
