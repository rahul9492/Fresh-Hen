import 'package:flutter/material.dart';

/// Gives its child a quick springy "boing" (grows a little, then settles with a
/// small overshoot) every time [value] changes, e.g. a cart count badge.
class PopOnChange extends StatefulWidget {
  const PopOnChange({super.key, required this.value, required this.child, this.amount = 0.28});

  final Object? value;
  final Widget child;

  /// How much bigger it gets at the peak (0.28 = 28%).
  final double amount;

  @override
  State<PopOnChange> createState() => _PopOnChangeState();
}

class _PopOnChangeState extends State<PopOnChange> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );

  // Up fast, then back down past rest and settle: a spring, not a linear blink.
  late final _scale = TweenSequence([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1 + widget.amount).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1 + widget.amount, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 70,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(PopOnChange old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale, child: widget.child);
}
