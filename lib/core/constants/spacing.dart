import 'package:flutter/material.dart';

/// Spacing and radius tokens so screens and shared widgets avoid magic numbers.
///
/// Typography (sizes are plain numbers in the widgets; keep to this scale):
/// * Sizes: 11 caption badge, 12 caption, 13 small, 14 body, 15 emphasis,
///   16 title / button, 18 heading, 20 large heading, 22 and up for display.
/// * Weights: w400 body, w500 secondary, w600 labels and buttons,
///   w700 titles and prices. Nothing heavier (no w800).
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

/// Soft shadows so surfaces lift off the page. Keep them this light.
abstract final class AppShadow {
  /// Cards sitting on a grey page.
  static final card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.035),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Bars pinned to the bottom edge, so the shadow falls upwards.
  static final bar = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 14,
      offset: const Offset(0, -4),
    ),
  ];
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;

  /// Bottom sheets and big containers.
  static const xl = 24.0;
  static const pill = 30.0;
}
