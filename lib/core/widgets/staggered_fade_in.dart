import 'package:flutter/material.dart';

/// Fades and slides a list item up when it first appears, each one a little
/// after the one before. Only the first few items animate; the rest (and
/// everything scrolled into view later) appear normally, so long lists stay calm.
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.maxAnimated = 8,
  });

  final int index;
  final Widget child;
  final int maxAnimated;

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn> with SingleTickerProviderStateMixin {
  static const _step = 55; // ms between items
  static const _duration = 380; // ms for one item

  late final _delay = widget.index * _step;
  late final _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _delay + _duration),
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Interval(_delay / (_delay + _duration), 1, curve: Curves.easeOutCubic),
  );
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.index >= widget.maxAnimated || MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (_, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(offset: Offset(0, (1 - _curve.value) * 18), child: child),
      ),
      child: widget.child,
    );
  }
}
