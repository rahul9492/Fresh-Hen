import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'app_image.dart';

/// A product photo that flies between screens (card or thumbnail → detail
/// gallery). Both ends use the same [tag]; in flight the corners morph from
/// one end's [radius] to the other's, so there is no snap when it lands.
class ProductHero extends StatelessWidget {
  const ProductHero({
    super.key,
    required this.tag,
    required this.source,
    this.radius = 12,
    this.width,
    this.height,
  });

  final Object tag;

  /// Asset path or remote URL.
  final String source;
  final double radius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (begin, end) => MaterialRectArcTween(begin: begin, end: end),
      flightShuttleBuilder: _shuttle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AppImage(source: source, width: width, height: height),
      ),
    );
  }

  Widget _shuttle(
    BuildContext _,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    double radiusOf(BuildContext c) =>
        c.findAncestorWidgetOfExactType<ProductHero>()?.radius ?? radius;

    // The route animation runs 0 → 1 from the source screen to the pushed one,
    // and backwards on pop, so pick the radii by which side is which.
    final push = direction == HeroFlightDirection.push;
    final start = radiusOf(push ? fromContext : toContext);
    final end = radiusOf(push ? toContext : fromContext);
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

    return AnimatedBuilder(
      animation: curved,
      builder: (_, child) => ClipRRect(
        borderRadius: BorderRadius.circular(lerpDouble(start, end, curved.value)!),
        child: child,
      ),
      child: SizedBox.expand(child: AppImage(source: source)),
    );
  }
}
