import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'animated_nav_icon.dart';

/// Selected bottom-nav icon drawn by a Lottie file. It is built when the tab
/// becomes selected, so it plays once and rests on its last frame. If the file
/// can't be loaded, the simple [AnimatedNavIcon] pop is shown instead.
class LottieNavIcon extends StatefulWidget {
  const LottieNavIcon(this.asset, {super.key, required this.fallback});

  final String asset;
  final IconData fallback;

  static const size = 28.0;

  @override
  State<LottieNavIcon> createState() => _LottieNavIconState();
}

class _LottieNavIconState extends State<LottieNavIcon> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Lottie.asset(
      widget.asset,
      controller: _controller,
      width: LottieNavIcon.size,
      height: LottieNavIcon.size,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        if (reduceMotion) {
          _controller.value = 1;
        } else {
          _controller.forward();
        }
      },
      errorBuilder: (_, _, _) => AnimatedNavIcon(widget.fallback),
    );
  }
}
