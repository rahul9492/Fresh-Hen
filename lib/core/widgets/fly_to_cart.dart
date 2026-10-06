import 'package:flutter/material.dart';

import 'product_image.dart';

/// A cart bar on some page: its own context, and the key on its thumbnails
/// (which only exist while the cart has items).
typedef CartFlyTarget = ({BuildContext bar, GlobalKey thumbs});

/// Several pages show a cart bar (tabs, wishlist, product lists) and can be
/// stacked, so each bar registers itself; the one on the current page is the target.
final _cartFlyTargets = <CartFlyTarget>[];

/// Registers a cart bar as a landing spot; [unregisterCartFlyTarget] on dispose.
void registerCartFlyTarget(CartFlyTarget target) => _cartFlyTargets.add(target);

void unregisterCartFlyTarget(CartFlyTarget target) => _cartFlyTargets.remove(target);

/// Flies a small copy of [image] from the widget behind [context] (the Add
/// button) to the "View cart" bar. Does nothing when the bar isn't on screen,
/// e.g. when another page covers it, or when animations are turned off.
void flyToCart(BuildContext context, String image) {
  if (MediaQuery.disableAnimationsOf(context)) return;
  final overlay = Overlay.maybeOf(context);
  final source = context.findRenderObject();
  if (overlay == null || source is! RenderBox || !source.attached) return;

  // Land on the bar of the add button's own page; pages without one get no fly.
  final route = ModalRoute.of(context);
  if (route == null || !route.isCurrent) return;
  final target = _cartFlyTargets
      .where((t) => t.bar.mounted && ModalRoute.of(t.bar) == route)
      .lastOrNull;
  if (target == null) return;

  final Offset end;
  if (target.thumbs.currentContext?.findRenderObject() case final RenderBox box
      when box.attached) {
    end = box.localToGlobal(box.size.center(Offset.zero));
  } else {
    // The bar is about to slide in (first item): aim where its thumbnails will be.
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    end = Offset(46, size.height - padding.bottom - 80 - 40);
  }

  final start = source.localToGlobal(source.size.center(Offset.zero));
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _FlyingImage(
      image: image,
      from: start,
      to: end,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _FlyingImage extends StatefulWidget {
  const _FlyingImage({
    required this.image,
    required this.from,
    required this.to,
    required this.onDone,
  });

  final String image;
  final Offset from;
  final Offset to;
  final VoidCallback onDone;

  @override
  State<_FlyingImage> createState() => _FlyingImageState();
}

class _FlyingImageState extends State<_FlyingImage> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward().whenComplete(widget.onDone);

  static const _size = 44.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final t = Curves.easeInOutCubic.transform(_controller.value);
          // Straight line plus an arc, so it lifts up and drops into the bar.
          final pos = Offset.lerp(widget.from, widget.to, t)!;
          final lift = -90 * (1 - (2 * t - 1) * (2 * t - 1));
          final scale = 1 - 0.65 * t;
          final opacity = _controller.value > 0.85 ? (1 - _controller.value) / 0.15 : 1.0;
          return Stack(
            children: [
              Positioned(
                left: pos.dx - _size / 2,
                top: pos.dy - _size / 2 + lift,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: _size,
                      height: _size,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8),
                        ],
                      ),
                      child: ClipOval(child: ProductImage(asset: widget.image, radius: 0)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
