import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'press_scale.dart';
import '../constants/spacing.dart';

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
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        // Shadow only: a border on top of it just adds noise.
        boxShadow: AppShadow.card,
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
    // Only cards you can tap shrink a little when pressed.
    return onTap == null ? card : PressScale(scale: 0.985, child: card);
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
            style: AppType.display(size: fontSize + 1),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
