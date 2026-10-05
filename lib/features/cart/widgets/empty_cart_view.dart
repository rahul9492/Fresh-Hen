import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/spacing.dart';

/// Illustrated empty state for the cart. Everything scales with the screen, and
/// the illustration, text and button sit together in the vertical centre.
class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key, required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, box) {
          final art = (box.maxWidth * 0.62).clamp(150.0, 280.0);
          final fit = box.maxHeight * 0.36;
          final artWidth = art < fit * 1.1 ? art : fit * 1.1;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: artWidth,
                      height: artWidth * _BoxScene.aspect,
                      child: const CustomPaint(painter: _BoxScene()),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Add your favorite products to get started.',
                          maxLines: 1,
                          style: TextStyle(color: AppColors.body, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: onBrowse,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Browse Products'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Open yellow box with an orange floating above it, drawn on the 983 x 788
/// grid of the reference artwork and scaled to fit.
class _BoxScene extends CustomPainter {
  const _BoxScene();

  static const _w = 983.0;
  static const _h = 788.0;
  static const aspect = _h / _w;

  static Paint _fill(Color c) => Paint()..color = c;

  static Path _poly(List<Offset> p) => Path()..addPolygon(p, true);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _w, size.height / _h);

    // Soft glow and ground shadow.
    const glow = Offset(491, 380);
    canvas.drawCircle(
      glow,
      400,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE5E7EB).withValues(alpha: 0.55),
            const Color(0xFFE5E7EB).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: glow, radius: 400)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(466, 704), width: 534, height: 90),
      _fill(const Color(0xFFE5E7EB)),
    );

    // Floating tan panel above the box.
    canvas.drawPath(
      _poly(const [Offset(262, 221), Offset(466, 130), Offset(668, 221), Offset(466, 310)]),
      _fill(const Color(0xFFEDD6BA)),
    );

    // Lemon pieces.
    canvas.drawPath(
      _poly(const [
        Offset(385, 218),
        Offset(402, 196),
        Offset(422, 204),
        Offset(434, 232),
        Offset(420, 250),
        Offset(390, 246),
      ]),
      _fill(const Color(0xFFFEF08A)),
    );
    canvas.drawCircle(const Offset(389, 246), 16, _fill(const Color(0xFFFDE047)));
    canvas.drawCircle(const Offset(414, 259), 16, _fill(const Color(0xFFFDE047)));

    // Orange with highlight lobe and leaves.
    canvas.save();
    canvas.translate(466, 158);
    canvas.rotate(-0.38);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 190, height: 130),
      _fill(const Color(0xFFEA580C)),
    );
    canvas.restore();
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(517, 120), width: 104, height: 90),
      _fill(const Color(0xFFF97316)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(447, 70)
        ..quadraticBezierTo(470, 58, 500, 80)
        ..quadraticBezierTo(488, 100, 462, 97)
        ..quadraticBezierTo(447, 90, 447, 70),
      _fill(const Color(0xFF16A34A)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(520, 78)
        ..quadraticBezierTo(540, 40, 580, 42)
        ..quadraticBezierTo(574, 82, 540, 86)
        ..quadraticBezierTo(526, 86, 520, 78),
      _fill(const Color(0xFF22C55E)),
    );
    _sparkle(canvas, const Offset(593, 154), 36);

    // Box body.
    canvas.drawPath(
      _poly(const [Offset(224, 380), Offset(466, 400), Offset(466, 653), Offset(224, 532)]),
      _fill(const Color(0xFFF8B31C)),
    );
    canvas.drawPath(
      _poly(const [Offset(466, 400), Offset(708, 380), Offset(708, 532), Offset(466, 653)]),
      _fill(const Color(0xFFF49E0E)),
    );
    // Open flaps.
    canvas.drawPath(
      _poly(const [Offset(224, 285), Offset(123, 323), Offset(350, 450), Offset(466, 400)]),
      _fill(const Color(0xFFFCD34D)),
    );
    canvas.drawPath(
      _poly(const [Offset(708, 285), Offset(809, 323), Offset(580, 450), Offset(466, 400)]),
      _fill(const Color(0xFFFBBF24)),
    );

    _badge(canvas, const Offset(466, 507));
  }

  void _badge(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 75, _fill(const Color(0xFFD97706)));
    canvas.drawCircle(c, 65, _fill(const Color(0xFFFEF3C7)));

    final brown = _fill(const Color(0xFFB45309));
    canvas.drawOval(Rect.fromCenter(center: c.translate(-4, -2), width: 66, height: 46), brown);
    canvas.drawCircle(c.translate(22, -13), 15, brown);
    canvas.drawCircle(c.translate(10, -17), 12, brown);
    canvas.drawRect(Rect.fromLTWH(c.dx - 20, c.dy + 14, 28, 9), brown);
    canvas.drawCircle(c.translate(-3, -32), 6, _fill(const Color(0xFFDC2626)));
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 41, c.dy + 3)
        ..lineTo(c.dx - 27, c.dy - 4)
        ..lineTo(c.dx - 27, c.dy + 10)
        ..close(),
      _fill(const Color(0xFFD97706)),
    );
  }

  void _sparkle(Canvas canvas, Offset c, double s) {
    final k = s * 0.12;
    final path = Path()
      ..moveTo(c.dx, c.dy - s)
      ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + s, c.dy)
      ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + s)
      ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - s, c.dy)
      ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - s);
    canvas.drawPath(path, _fill(const Color(0xFFF5B94F)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
