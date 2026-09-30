import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../utils/formatters.dart';

/// Price with an optional struck-through MRP and discount percentage.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.mrp,
    this.fontSize = 14.5,
    this.showDiscount = false,
  });

  final int price;
  final int? mrp;
  final double fontSize;
  final bool showDiscount;

  @override
  Widget build(BuildContext context) {
    final hasMrp = mrp != null && mrp! > price;
    return Text.rich(
      TextSpan(
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize),
        children: [
          TextSpan(text: rupees(price)),
          if (hasMrp)
            TextSpan(
              text: '  ${rupees(mrp!)}',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: fontSize * 0.85,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          if (hasMrp && showDiscount)
            TextSpan(
              text: '  ${(100 - price * 100 / mrp!).round()}% off',
              style: TextStyle(
                color: AppColors.success,
                fontSize: fontSize * 0.85,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
