import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../utils/formatters.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
          ),
          if (actionLabel != null)
            InkWell(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NonVegMark extends StatelessWidget {
  const NonVegMark({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.accent, width: 1.4),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Icon(Icons.change_history_rounded, size: size * 0.7, color: AppColors.accent),
    );
  }
}

class RatingLabel extends StatelessWidget {
  const RatingLabel({super.key, required this.rating, required this.count, this.small = false});

  final double rating;
  final int count;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.star, size: small ? 14 : 16),
        const SizedBox(width: 3),
        Text(
          '$rating',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: small ? 12 : 13),
        ),
        const SizedBox(width: 3),
        Text(
          '(${compactCount(count)})',
          style: TextStyle(color: AppColors.muted, fontSize: small ? 11 : 12),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        // The badge pops in and the text fades up, so the state doesn't just appear.
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (_, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, (1 - t) * 14), child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.elasticOut,
                builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFF3F1)),
                  child: Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.accentSoft,
                      child: Icon(icon, size: 38, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppType.display(size: 19),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.body, height: 1.4),
                  ),
                ),
              ],
              if (action != null) ...[const SizedBox(height: 24), action!],
            ],
          ),
        ),
      ),
    );
  }
}
