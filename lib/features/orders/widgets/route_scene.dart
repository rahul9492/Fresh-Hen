import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../app/theme/app_colors.dart';

/// The road with its two end markers and the scooter riding it on a loop.
class RouteScene extends StatefulWidget {
  const RouteScene({super.key});

  @override
  State<RouteScene> createState() => _RouteSceneState();
}

class _RouteSceneState extends State<RouteScene> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      // Parked midway, so the still scene still reads as "on the way".
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The scooter art faces left, so it rides from the store (right) to home (left)
  // instead of being mirrored, which would flip the text on its box.
  static Path _road(Size s) => Path()
    ..moveTo(s.width - 30, s.height * 0.74)
    ..cubicTo(
      s.width * 0.66,
      s.height * 0.30,
      s.width * 0.36,
      s.height * 1.02,
      30,
      s.height * 0.66,
    );

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final road = _road(size);
        final metric = road.computeMetrics().first;
        final start = metric.getTangentForOffset(0)!.position;
        final end = metric.getTangentForOffset(metric.length)!.position;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => CustomPaint(
                  painter: _RoadPainter(
                    road: metric,
                    traveled: _travel(_controller.value),
                    trailOpacity: _fade(_controller.value),
                  ),
                ),
              ),
            ),
            _Marker(at: end, icon: Icons.home_rounded, label: 'Home', filled: true),
            _Marker(at: start, icon: Icons.storefront_rounded, label: 'Store'),
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) => _Scooter(
                metric: metric,
                distance: _travel(_controller.value) * metric.length,
                opacity: still ? 1 : _fade(_controller.value),
                child: child!,
              ),
              child: Lottie.asset(
                _Scooter.asset,
                width: _Scooter.size,
                height: _Scooter.size,
                animate: !still,
                errorBuilder: (_, _, _) => const Align(
                  alignment: Alignment(0.13, 0.55),
                  child: Icon(Icons.two_wheeler_rounded, color: AppColors.primary, size: 40),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// How far along the road (0–1) the scooter is in this lap; it eases off
  /// the start and into the finish, and waits a moment at each end. It rides
  /// the middle stretch only, so it never covers the store or home pin.
  static double _travel(double t) =>
      0.2 + 0.6 * Curves.easeInOutSine.transform(((t - 0.04) / 0.88).clamp(0.0, 1.0));

  /// Fades the scooter in as it leaves the store and out as it reaches home.
  static double _fade(double t) {
    if (t < 0.08) return t / 0.08;
    if (t > 0.9) return ((1 - t) / 0.1).clamp(0.0, 1.0);
    return 1;
  }
}

/// The scooter Lottie, placed so its wheels sit on the road and tilted with its slope.
class _Scooter extends StatelessWidget {
  const _Scooter({
    required this.metric,
    required this.distance,
    required this.opacity,
    required this.child,
  });

  final PathMetric metric;
  final double distance;
  final double opacity;
  final Widget child;

  static const asset = 'assets/lottie/delivery_scooter.json';
  static const size = 112.0;

  /// Where the wheels touch the ground in the Lottie's square canvas
  /// (the art only fills its lower middle).
  static const _wheels = Offset(0.566, 0.80);

  @override
  Widget build(BuildContext context) {
    final tangent = metric.getTangentForOffset(distance.clamp(0.0, metric.length))!;
    final p = tangent.position;
    // Riding leftwards: the art's "forward" is -x, so turn it by the road's angle
    // minus a half turn, softened so it leans into slopes without tipping over.
    var angle = math.atan2(tangent.vector.dy, tangent.vector.dx) - math.pi;
    angle = math.atan2(math.sin(angle), math.cos(angle)); // wrap to -π..π
    angle = (angle * 0.7).clamp(-0.3, 0.3);

    return Positioned(
      left: p.dx - _wheels.dx * size,
      top: p.dy - _wheels.dy * size,
      width: size,
      height: size,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: angle,
            alignment: Alignment(_wheels.dx * 2 - 1, _wheels.dy * 2 - 1),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A dashed road, with the stretch already ridden this lap drawn solid behind the scooter.
class _RoadPainter extends CustomPainter {
  _RoadPainter({required this.road, required this.traveled, required this.trailOpacity});

  final PathMetric road;
  final double traveled;
  final double trailOpacity;

  static const _dash = 7.0;
  static const _gap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..color = const Color(0xFFF0CFC9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (double d = 0; d < road.length; d += _dash + _gap) {
      canvas.drawPath(road.extractPath(d, math.min(d + _dash, road.length)), base);
    }

    if (traveled > 0) {
      final trail = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.55 * trailOpacity)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(road.extractPath(0, road.length * traveled), trail);
    }
  }

  @override
  bool shouldRepaint(_RoadPainter old) =>
      old.traveled != traveled || old.trailOpacity != trailOpacity || old.road != road;
}

/// A round pin at one end of the road, with a small label under it.
class _Marker extends StatelessWidget {
  const _Marker({required this.at, required this.icon, required this.label, this.filled = false});

  final Offset at;
  final IconData icon;
  final String label;
  final bool filled;

  static const _size = 34.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: at.dx - 30,
      top: at.dy - _size / 2,
      width: 60,
      child: Column(
        children: [
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? AppColors.primary : Colors.white,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: filled ? Colors.white : AppColors.primary),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.body,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
