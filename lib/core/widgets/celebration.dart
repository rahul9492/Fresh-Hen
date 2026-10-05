import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/spacing.dart';

/// A short celebration: confetti falls over the screen and a green banner drops
/// in from the top. Used when a coupon is applied. With animations turned off
/// nothing is shown, so callers should fall back to a snackbar.
bool showCelebration(BuildContext context, {required String title, String? subtitle}) {
  if (MediaQuery.disableAnimationsOf(context)) return false;
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return false;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Celebration(title: title, subtitle: subtitle, onDone: () => entry.remove()),
  );
  overlay.insert(entry);
  return true;
}

class _Celebration extends StatefulWidget {
  const _Celebration({required this.title, required this.subtitle, required this.onDone});

  final String title;
  final String? subtitle;
  final VoidCallback onDone;

  @override
  State<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<_Celebration> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..forward().whenComplete(widget.onDone);

  static final _pieces = _makePieces();

  static List<_Piece> _makePieces() {
    final random = math.Random(11);
    const colors = [
      Color(0xFF1E9E55),
      AppColors.primary,
      Color(0xFFF5B301),
      Color(0xFF3B82F6),
      Color(0xFFEC4899),
    ];
    return [
      for (var i = 0; i < 70; i++)
        _Piece(
          x: random.nextDouble(),
          delay: random.nextDouble() * 0.25,
          speed: 0.55 + random.nextDouble() * 0.5,
          sway: (random.nextDouble() - 0.5) * 0.12,
          spin: (random.nextDouble() - 0.5) * 14,
          size: 6 + random.nextDouble() * 6,
          color: colors[i % colors.length],
          round: i % 3 == 0,
        ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 12;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final t = _controller.value;
          // Banner: slides in over the first 12%, slides out over the last 15%.
          final inT = Curves.easeOutBack.transform((t / 0.12).clamp(0.0, 1.0));
          final outT = ((t - 0.85) / 0.15).clamp(0.0, 1.0);
          final shown = inT * (1 - outT);
          return Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _ConfettiPainter(_pieces, t))),
              Positioned(
                top: top - (1 - shown) * 90,
                left: 16,
                right: 16,
                child: Opacity(
                  opacity: shown.clamp(0.0, 1.0),
                  child: _Banner(title: widget.title, subtitle: widget.subtitle),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.title, required this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: const LinearGradient(colors: [Color(0xFF2CC46B), Color(0xFF1E9E55)]),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.celebration_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.sway,
    required this.spin,
    required this.size,
    required this.color,
    required this.round,
  });

  final double x;
  final double delay;
  final double speed;
  final double sway;
  final double spin;
  final double size;
  final Color color;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final fall = local * p.speed * 1.15; // fraction of the screen height
      final y = -20 + fall * size.height;
      final x = p.x * size.width + math.sin(local * 9 + p.x * 6) * p.sway * size.width;
      final fade = local > 0.75 ? (1 - local) / 0.25 : 1.0;
      final paint = Paint()..color = p.color.withValues(alpha: fade.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(local * p.spin);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
