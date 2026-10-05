import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// A rupee amount that counts up or down to its new value when it changes.
/// The first time it is shown it just appears, so lists of old orders don't animate.
class AnimatedRupees extends StatelessWidget {
  const AnimatedRupees(this.amount, {super.key, this.style, this.prefix = '', this.textAlign});

  final int amount;
  final TextStyle? style;

  /// Text before the amount, e.g. a minus sign for a discount.
  final String prefix;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: amount.toDouble()),
      duration: animate ? const Duration(milliseconds: 450) : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (_, value, _) => Text(
        '$prefix${rupees(value.round())}',
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
