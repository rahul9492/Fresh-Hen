import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/order_models.dart';
import 'pulsing_dot.dart';
import 'route_scene.dart';

/// "Your order is on the way": a scooter riding a curved road from the store
/// to your home, over a soft tinted background.
class OnTheWayCard extends StatelessWidget {
  const OnTheWayCard({super.key, required this.rider});

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
                const PulsingDot(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your order is on the way', style: AppType.display(size: 17)),
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
            const SizedBox(height: 118, child: RouteScene()),
          ],
        ),
      ),
    );
  }
}
