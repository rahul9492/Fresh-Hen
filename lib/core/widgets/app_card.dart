import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// White rounded card used on grey pages (cart, checkout, order details).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = Colors.white,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;

  static const radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: onTap == null
            ? content
            : Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap, child: content),
              ),
      ),
    );
  }
}

/// Bold card heading with optional trailing widget.
class CardTitle extends StatelessWidget {
  const CardTitle(this.title, {super.key, this.trailing, this.fontSize = 16});

  final String title;
  final Widget? trailing;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
