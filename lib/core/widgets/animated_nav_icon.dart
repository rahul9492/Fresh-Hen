import 'package:flutter/material.dart';

/// Icon for a selected bottom-nav tab. It is built when the tab becomes
/// selected, so it plays a short pop (shrink, overshoot, settle) once.
/// Skipped when the phone has animations turned off.
class AnimatedNavIcon extends StatefulWidget {
  const AnimatedNavIcon(this.icon, {super.key});

  final IconData icon;

  @override
  State<AnimatedNavIcon> createState() => _AnimatedNavIconState();
}

class _AnimatedNavIconState extends State<AnimatedNavIcon> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  late final _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 25),
    TweenSequenceItem(
      tween: Tween(begin: 0.7, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
      weight: 30,
    ),
  ]).animate(_controller);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) &&
        !_controller.isAnimating &&
        _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale, child: Icon(widget.icon));
}
