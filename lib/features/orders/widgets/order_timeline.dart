import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/widgets/app_card.dart';
import '../models/order_models.dart';

/// Confirmed → Being prepared → Out for delivery → Delivered, with the time
/// each step was reached. A cancelled order shows the steps it got through,
/// then Cancelled.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.order});

  final Order order;

  static const _path = [
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  static String _hint(OrderStatus s) => switch (s) {
        OrderStatus.confirmed => 'We have received your order',
        OrderStatus.preparing => 'Cleaning, cutting and packing it fresh',
        OrderStatus.outForDelivery => 'On the way to you',
        OrderStatus.delivered => 'Enjoy your meal!',
        OrderStatus.cancelled => '',
      };

  @override
  Widget build(BuildContext context) {
    final cancelled = order.status == OrderStatus.cancelled;
    final steps = cancelled
        ? [
            for (final s in _path)
              if (s != OrderStatus.delivered && order.reachedAt(s) != null) s,
            OrderStatus.cancelled,
          ]
        : _path;
    final current = cancelled ? steps.length - 1 : _path.indexOf(order.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('Order status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (order.status.isActive) ...[const SizedBox(width: 8), const _LiveBadge()],
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < steps.length; i++)
          _Step(
            label: steps[i].label,
            hint: i == current ? _hint(steps[i]) : null,
            time: order.reachedAt(steps[i]),
            state: i < current
                ? _StepState.done
                : i == current
                    ? (cancelled ? _StepState.cancelled : _StepState.current)
                    : _StepState.upcoming,
            // The line below a step is filled once the next step is reached.
            lineFilled: i < current,
            // The scooter rides the line below "Out for delivery" while it is on its way.
            traveling: !cancelled && i == current && steps[i] == OrderStatus.outForDelivery,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

enum _StepState { done, current, upcoming, cancelled }

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.hint,
    required this.time,
    required this.state,
    required this.lineFilled,
    required this.traveling,
    required this.isLast,
  });

  final String label;
  final String? hint;
  final DateTime? time;
  final _StepState state;
  final bool lineFilled;
  final bool traveling;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final reached = state != _StepState.upcoming;
    final color = switch (state) {
      _StepState.cancelled => AppColors.accent,
      _StepState.upcoming => AppColors.border,
      _ => AppColors.primary,
    };
    final t = time;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                _PulseRing(
                  active: state == _StepState.current,
                  color: color,
                  child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: reached ? color : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: switch (state) {
                    _StepState.done => const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                    _StepState.cancelled => const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                    _StepState.current => const Center(
                        child: CircleAvatar(radius: 4, backgroundColor: Colors.white),
                      ),
                    _StepState.upcoming => null,
                  },
                ),
                ),
                if (!isLast) Expanded(child: _Connector(filled: lineFilled, traveling: traveling)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: reached ? FontWeight.w700 : FontWeight.w500,
                            color: reached ? AppColors.ink : AppColors.muted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (reached && t != null)
                        Text(
                          formatClock(t),
                          style: const TextStyle(color: AppColors.body, fontSize: 12),
                        ),
                    ],
                  ),
                  if (hint != null && hint!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(hint!, style: const TextStyle(color: AppColors.body, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The delivery partner bringing the order, with a call button.
class RiderCard extends StatelessWidget {
  const RiderCard({super.key, required this.rider});

  final DeliveryRider rider;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.accentSoft,
            child: Icon(Icons.two_wheeler_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rider.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Text(
                  'Your delivery partner',
                  style: TextStyle(color: AppColors.body, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'Call ${rider.name}',
            onPressed: () => openLink(
              context,
              Uri(scheme: 'tel', path: '+${supportDigits(rider.phone)}'),
              error: 'Could not open the dialer.',
            ),
            icon: const Icon(Icons.call_rounded),
            style: IconButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

/// The line between two steps. It fills from the top when the step above is
/// done, and shows a small scooter driving down it while the order is on its way.
class _Connector extends StatelessWidget {
  const _Connector({required this.filled, required this.traveling});

  final bool filled;
  final bool traveling;

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    // Only positioned children, so the line takes the height the step row gives it
    // (a plain Stack child would break the row's IntrinsicHeight).
    return Container(
      width: 22,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(child: SizedBox(width: 2, child: ColoredBox(color: AppColors.border))),
          ),
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: filled ? 1 : 0),
              duration: animate ? const Duration(milliseconds: 600) : Duration.zero,
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  heightFactor: v,
                  child: const SizedBox(width: 2, child: ColoredBox(color: AppColors.primary)),
                ),
              ),
            ),
          ),
          if (traveling && animate) const Positioned.fill(child: _Scooter()),
        ],
      ),
    );
  }
}

/// A small scooter that keeps driving down the connector line.
class _Scooter extends StatefulWidget {
  const _Scooter();

  @override
  State<_Scooter> createState() => _ScooterState();
}

class _ScooterState extends State<_Scooter> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final t = _controller.value;
        // Fades in at the top, drives down, fades out at the bottom.
        final opacity = t < 0.15 ? t / 0.15 : (t > 0.85 ? (1 - t) / 0.15 : 1.0);
        return Align(
          alignment: Alignment(0, -1 + 2 * t),
          child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: const Icon(Icons.two_wheeler_rounded, size: 16, color: AppColors.primary),
      ),
    );
  }
}

/// Soft ring that keeps pulsing around the step the order is on now.
class _PulseRing extends StatefulWidget {
  const _PulseRing({required this.active, required this.color, required this.child});

  final bool active;
  final Color color;
  final Widget child;

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_PulseRing old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = widget.active && !MediaQuery.disableAnimationsOf(context);
    if (run && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!run && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final t = _controller.value;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1 - t) * 0.45,
              child: Container(
                width: 22 + 16 * t,
                height: 22 + 16 * t,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Small red "LIVE" tag with a blinking dot, shown while the order is on its way.
class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.3, end: 1.0).animate(_controller),
            child: const CircleAvatar(radius: 3.5, backgroundColor: AppColors.accent),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
