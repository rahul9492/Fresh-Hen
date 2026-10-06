import 'package:flutter/material.dart';

/// Shrinks its child slightly while a finger is pressed on it, then springs back.
/// It only watches the pointer, so the child's own tap, ink and scrolling work as
/// before. Releases early if the finger starts dragging (scrolling a list).
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.scale = 0.97, this.enabled = true});

  final Widget child;
  final double scale;
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  static const _dragSlop = 12.0;

  var _pressed = false;
  Offset? _down;

  void _set(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || MediaQuery.disableAnimationsOf(context)) return widget.child;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        _down = e.position;
        _set(true);
      },
      onPointerMove: (e) {
        final down = _down;
        if (down != null && (e.position - down).distance > _dragSlop) _set(false);
      },
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      // Quick squash in; a springier, slightly longer release that overshoots and settles.
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: Duration(milliseconds: _pressed ? 90 : 320),
        curve: _pressed ? Curves.easeOut : const ElasticOutCurve(0.55),
        child: widget.child,
      ),
    );
  }
}
