import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

/// A Lottie in a soft circle beside a title and a line of text.
class StageCard extends StatelessWidget {
  const StageCard({
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
