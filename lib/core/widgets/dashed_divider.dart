import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Horizontal dashed line, as used above totals on bills and invoices.
class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.height = 1,
    this.dash = 5,
    this.gap = 4,
    this.color = AppColors.border,
  });

  final double height;
  final double dash;
  final double gap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter(dash: dash, gap: gap, color: color)),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter({required this.dash, required this.gap, required this.color});

  final double dash;
  final double gap;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset((x + dash).clamp(0, size.width), y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.dash != dash || old.gap != gap || old.color != color;
}
