import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
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
        const Text('Order status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
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
    required this.isLast,
  });

  final String label;
  final String? hint;
  final DateTime? time;
  final _StepState state;
  final bool lineFilled;
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
                Container(
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
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: lineFilled ? AppColors.primary : AppColors.border,
                    ),
                  ),
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
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      if (reached && t != null)
                        Text(
                          formatClock(t),
                          style: const TextStyle(color: AppColors.body, fontSize: 12.5),
                        ),
                    ],
                  ),
                  if (hint != null && hint!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(hint!, style: const TextStyle(color: AppColors.body, fontSize: 12.5)),
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
                  style: TextStyle(color: AppColors.body, fontSize: 12.5),
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
