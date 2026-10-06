import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/order_models.dart';

/// Animated header for an order in progress: an hourglass while a UPI payment
/// is being checked, a cleaver chopping while it is being prepared, a scooter
/// riding from the store to your home while it is on its way, and a tick once
/// it is delivered. A rejected payment shows a help card instead. Nothing for
/// other statuses.
///
/// Purely visual: there is no live rider tracking, so the scooter just loops
/// along the route rather than showing real progress or an ETA.
class OrderStatusScene extends StatelessWidget {
  const OrderStatusScene({super.key, required this.order});

  final Order order;

  static const _preparing = 'assets/lottie/order_preparing.json';
  static const _scooter = 'assets/lottie/delivery_scooter.json';
  static const _delivered = 'assets/lottie/order_delivered.json';

  @override
  Widget build(BuildContext context) {
    final scene = switch (order.status) {
      // Payment problems come first: nothing else moves until they are sorted.
      _ when order.paymentIssue => const _PaymentIssueCard(key: ValueKey('paymentIssue')),
      _ when order.awaitingConfirmation => const _AwaitingCard(key: ValueKey('awaiting')),
      OrderStatus.preparing => const _StageCard(
          key: ValueKey('preparing'),
          lottie: _preparing,
          fallbackIcon: Icons.restaurant_rounded,
          title: 'Your order is being prepared',
          subtitle: 'Cleaning, cutting and packing it fresh',
        ),
      OrderStatus.outForDelivery => _OnTheWayCard(key: const ValueKey('onTheWay'), rider: order.rider),
      OrderStatus.delivered => const _StageCard(
          key: ValueKey('delivered'),
          lottie: _delivered,
          fallbackIcon: Icons.check_circle_rounded,
          title: 'Order delivered',
          subtitle: 'Enjoy your fresh meal!',
          playOnce: true,
          tint: AppColors.success,
        ),
      _ => null,
    };

    // Grows, shrinks and cross-fades as the order moves from one stage to the next.
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: scene == null
            ? const SizedBox(width: double.infinity, key: ValueKey('none'))
            : Padding(key: scene.key, padding: const EdgeInsets.only(bottom: 16), child: scene),
      ),
    );
  }
}

/// The UPI screenshot is with the store: an hourglass that keeps flipping over.
class _AwaitingCard extends StatefulWidget {
  const _AwaitingCard({super.key});

  @override
  State<_AwaitingCard> createState() => _AwaitingCardState();
}

class _AwaitingCardState extends State<_AwaitingCard> with SingleTickerProviderStateMixin {
  static const _amber = Color(0xFFB7791F);

  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: _amber.withValues(alpha: 0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                // Sand runs for most of the cycle, then the glass flips with a little overshoot.
                final t = _controller.value;
                final flip = t < 0.78 ? 0.0 : Curves.easeInOutBack.transform((t - 0.78) / 0.22);
                return Transform.rotate(angle: flip * math.pi, child: child);
              },
              child: const Icon(Icons.hourglass_top_rounded, color: _amber, size: 32),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Waiting for confirmation', style: AppType.display(size: 17)),
                const SizedBox(height: 3),
                const Text(
                  "We're checking your payment screenshot. We'll confirm your order in a few minutes.",
                  style: TextStyle(color: AppColors.body, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The store couldn't verify the UPI payment: say so plainly and offer help.
class _PaymentIssueCard extends StatelessWidget {
  const _PaymentIssueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppCard.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.accent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "We couldn't verify your payment",
                      style: AppType.display(size: 17, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "The payment screenshot didn't match our records. Please contact us and we'll sort it out with you.",
                      style: TextStyle(color: AppColors.ink, fontSize: 13, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.push(Routes.help),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            icon: const Icon(Icons.support_agent_rounded, size: 20),
            label: const Text('Contact support'),
          ),
        ],
      ),
    );
  }
}

/// A Lottie in a soft circle beside a title and a line of text.
class _StageCard extends StatelessWidget {
  const _StageCard({
    super.key,
    required this.lottie,
    required this.fallbackIcon,
    required this.title,
    required this.subtitle,
    this.playOnce = false,
    this.tint = AppColors.primary,
  });

  final String lottie;
  final IconData fallbackIcon;
  final String title;
  final String subtitle;

  /// Plays through once and holds the last frame (the tick), instead of looping.
  final bool playOnce;
  final Color tint;

  static const _size = 64.0;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(fallbackIcon, color: tint, size: 34);
    return AppCard(
      child: Row(
        children: [
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(color: tint.withValues(alpha: 0.08), shape: BoxShape.circle),
            alignment: Alignment.center,
            // A still first frame would be blank for the tick, so show the icon instead.
            child: MediaQuery.disableAnimationsOf(context)
                ? fallback
                : Lottie.asset(
                    lottie,
                    width: _size,
                    height: _size,
                    repeat: !playOnce,
                    errorBuilder: (_, _, _) => fallback,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppType.display(size: 17)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: AppColors.body, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Your order is on the way": a scooter riding a curved road from the store
/// to your home, over a soft tinted background.
class _OnTheWayCard extends StatelessWidget {
  const _OnTheWayCard({super.key, required this.rider});

  final DeliveryRider? rider;

  @override
  Widget build(BuildContext context) {
    final name = rider?.name;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppCard.radius),
        boxShadow: AppShadow.card,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFFF3F1)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const _PulsingDot(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your order is on the way',
                        style: AppType.display(size: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name == null || name.isEmpty
                            ? 'Fresh from our store to your door'
                            : '$name is bringing it fresh to your door',
                        style: const TextStyle(color: AppColors.body, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const SizedBox(height: 118, child: _RouteScene()),
          ],
        ),
      ),
    );
  }
}

/// The road with its two end markers and the scooter riding it on a loop.
class _RouteScene extends StatefulWidget {
  const _RouteScene();

  @override
  State<_RouteScene> createState() => _RouteSceneState();
}

class _RouteSceneState extends State<_RouteScene> with SingleTickerProviderStateMixin {
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
      s.width * 0.66, s.height * 0.30,
      s.width * 0.36, s.height * 1.02,
      30, s.height * 0.66,
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
                OrderStatusScene._scooter,
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
            style: const TextStyle(color: AppColors.body, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// A red dot with a ring that keeps rippling out of it, meaning "happening now".
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final t = Curves.easeOut.transform(_controller.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              if (_controller.isAnimating)
                Container(
                  width: 10 + 12 * t,
                  height: 10 + 12 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.35 * (1 - t)),
                  ),
                ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
              ),
            ],
          );
        },
      ),
    );
  }
}
