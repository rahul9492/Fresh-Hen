import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../app/theme/app_colors.dart';

/// What the hen is doing.
enum HenMood {
  /// Crouches, hops, lands with a squash and tilts her head at you, blinking (empty cart).
  hello,

  /// Pops in with sparkles, does excited hops and a wiggle, then settles happily (order placed).
  cheer,

  /// Eyes closed, breathing deeply, slowly nodding off with Zzz drifting up (store closed).
  sleep,
}

/// Fresh Hen's mascot. One hen drawing, brought to life in code with classic
/// cartoon motion: anticipation, squash and stretch, follow-through, blinks
/// and a shadow that shrinks when she leaves the ground.
///
/// With animations turned off she stands still (asleep: eyes closed with a "z").
class HenMascot extends StatefulWidget {
  const HenMascot({
    super.key,
    required this.mood,
    required this.height,
    this.delay = Duration.zero,
    this.fallback,
  });

  final HenMood mood;

  /// Height of the hen, hop room included; the width follows.
  final double height;

  /// Waits this long before popping in (e.g. after the order-placed tick).
  final Duration delay;

  /// Shown if the animation file can't load.
  final Widget? fallback;

  static const _asset = 'assets/lottie/hen_mascot.json';

  // The drawing's canvas is 1200 x 1108 with the hen in the middle; this is the
  // part she covers including hop room, as fractions of the canvas.
  static const _canvasAspect = 1108 / 1200;
  static const _henBox = Rect.fromLTRB(0.2953, 0.0972, 0.7047, 0.8892);

  /// Height / width of the box the hen is shown in.
  static double get aspect => _henBox.height * _canvasAspect / _henBox.width;

  @override
  State<HenMascot> createState() => _HenMascotState();
}

class _HenMascotState extends State<HenMascot> with TickerProviderStateMixin {
  // Where her feet touch the ground: squashes and tilts pivot here.
  static const _feet = Offset(0.49, 0.845);

  /// The mood's motion: loops for hello and sleep, plays once for the cheer routine.
  late final _motion = AnimationController(vsync: this);

  /// Pop-in (and the sparkle burst when cheering).
  late final _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  /// One blink.
  late final _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 170));

  /// A small happy bob now and then once the cheer routine is over.
  late final _bob = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  final _random = math.Random();
  Timer? _blinkTimer;
  Timer? _bobTimer;
  Timer? _introTimer;
  bool _still = false;
  bool _started = false;
  bool _loaded = false;

  static const _cheerRoutine = Duration(milliseconds: 3400);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (_started && still == _still) return;
    _still = still;
    _start(fresh: !_started);
    _started = true;
  }

  @override
  void didUpdateWidget(HenMascot old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) _start(fresh: false);
  }

  void _start({required bool fresh}) {
    _blinkTimer?.cancel();
    _bobTimer?.cancel();
    _introTimer?.cancel();
    _motion.stop();
    _bob.stop();

    if (_still) {
      _motion.value = 0;
      _intro.value = 1;
      _blink.value = 0;
      return;
    }

    switch (widget.mood) {
      case HenMood.hello:
        _motion
          ..duration = const Duration(milliseconds: 3000)
          ..repeat();
        _scheduleBlink();
      case HenMood.sleep:
        _motion
          ..duration = const Duration(milliseconds: 8000)
          ..repeat();
      case HenMood.cheer:
        _motion
          ..duration = _cheerRoutine
          ..value = 0;
        _scheduleBlink();
    }

    if (widget.mood == HenMood.sleep || !fresh) {
      _intro.value = 1;
      if (widget.mood == HenMood.cheer) _playCheer();
    } else {
      _intro.value = 0;
      _introTimer = Timer(widget.delay, () {
        if (!mounted) return;
        _intro.forward(from: 0);
        if (widget.mood == HenMood.cheer) _playCheer();
      });
    }
  }

  void _playCheer() {
    _motion.forward(from: 0).whenComplete(() {
      if (mounted && widget.mood == HenMood.cheer && !_still) _scheduleBob();
    });
  }

  /// Blinks every few seconds, sometimes twice in a row, like a real bird.
  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 1800 + _random.nextInt(2600)), () async {
      if (!mounted) return;
      await _blink.forward(from: 0);
      if (mounted && _random.nextDouble() < 0.25) await _blink.forward(from: 0);
      if (mounted) _scheduleBlink();
    });
  }

  void _scheduleBob() {
    _bobTimer = Timer(Duration(milliseconds: 3500 + _random.nextInt(3000)), () async {
      if (!mounted) return;
      await _bob.forward(from: 0);
      if (mounted) _scheduleBob();
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _bobTimer?.cancel();
    _introTimer?.cancel();
    _motion.dispose();
    _intro.dispose();
    _blink.dispose();
    _bob.dispose();
    super.dispose();
  }

  /// Her pose right now, from the mood's choreography.
  _Pose get _pose {
    if (_still) return _Pose.rest;
    final seconds = _motion.value * (_motion.duration?.inMilliseconds ?? 0) / 1000;
    return switch (widget.mood) {
      HenMood.hello => _Choreography.hello(seconds),
      HenMood.cheer => _motion.isCompleted
          ? _Choreography.bob(_bob.value)
          : _Choreography.cheer(seconds),
      HenMood.sleep => _Choreography.sleep(seconds),
    };
  }

  /// How shut her eyes are: 0 open, 1 closed.
  double get _eyesClosed {
    if (widget.mood == HenMood.sleep) return 1;
    final v = _blink.value;
    return v == 0 ? 0 : 1 - (2 * v - 1).abs();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height;
    final width = height / HenMascot.aspect;
    // The full canvas, sized and shifted so just the hen's box shows in width x height.
    final canvasW = width / HenMascot._henBox.width;
    final canvasH = canvasW * HenMascot._canvasAspect;

    // Her drawing, still: all the motion is done here in code.
    final drawing = Lottie.asset(
      HenMascot._asset,
      animate: false,
      // (The file's own shadow was removed; [_Shadow] reacts to her hops instead.)
      onLoaded: (_) => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _loaded = true);
      }),
      // The canvas centre is where she would stand, so the stand-in goes there.
      errorBuilder: (_, _, _) => Center(
        child: widget.fallback ?? Icon(Icons.egg_alt_rounded, color: AppColors.primary, size: height * 0.4),
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: Listenable.merge([_motion, _intro, _blink, _bob]),
        child: drawing,
        builder: (_, drawing) {
          final pose = _pose;
          final intro = _intro.value;
          final grow = Curves.easeOutBack.transform(intro.clamp(0.0, 1.0));
          final eyes = _eyesClosed;
          final sleeping = widget.mood == HenMood.sleep;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.mood == HenMood.cheer && intro > 0 && intro < 1)
                Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _Sparkles(intro)))),
              Positioned(
                left: -HenMascot._henBox.left * canvasW,
                top: -HenMascot._henBox.top * canvasH,
                width: canvasW,
                height: canvasH,
                child: Opacity(
                  opacity: intro.clamp(0.0, 1.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (_loaded)
                        Positioned.fill(child: CustomPaint(painter: _Shadow(pose.lift * grow))),
                      Positioned.fill(
                        child: Transform(
                          alignment: Alignment(_feet.dx * 2 - 1, _feet.dy * 2 - 1),
                          transform: Matrix4.translationValues(0, pose.dy * canvasH, 0)
                            ..rotateZ(pose.rotation)
                            ..scaleByDouble(pose.sx * grow, pose.sy * grow, 1, 1),
                          child: Stack(
                            children: [
                              Positioned.fill(child: drawing!),
                              if (_loaded && eyes > 0)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(painter: _Eyelids(eyes, asleep: sleeping)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (sleeping && _loaded)
                Positioned.fill(
                  child: IgnorePointer(child: _Zzz(t: _still ? 0.55 : _motion.value * 2 % 1)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Where the hen is and how she is squashed at one instant.
class _Pose {
  const _Pose({this.dy = 0, this.sx = 1, this.sy = 1, this.rotation = 0, this.lift = 0});

  /// Up/down shift as a fraction of the canvas height (negative is up).
  final double dy;
  final double sx;
  final double sy;
  final double rotation;

  /// 0 on the ground, 1 at the top of a full hop: shrinks and fades her shadow.
  final double lift;

  static const rest = _Pose();

  _Pose plus({double dy = 0, double sx = 1, double sy = 1, double rotation = 0}) => _Pose(
        dy: this.dy + dy,
        sx: this.sx * sx,
        sy: this.sy * sy,
        rotation: this.rotation + rotation,
        lift: lift,
      );
}

/// The moves, as functions of time in seconds. Each hop has anticipation (a
/// crouch), a stretched take-off, a parabolic arc, a squash on landing and a
/// springy recovery, so she reads as a soft, heavy body rather than a sticker.
abstract final class _Choreography {
  /// Ease used by many of the moves.
  static double _ease(double v) => Curves.easeInOutCubic.transform(v.clamp(0.0, 1.0));

  /// A damped spring: starts at 1, wobbles and settles to 0 by v = 1.
  static double _spring(double v) => math.exp(-5 * v) * math.cos(3 * math.pi * v);

  /// Keeps her area roughly the same when squashed: wider when shorter.
  static double _widthFor(double sy) => math.pow(sy, -0.6).toDouble();

  /// One hop starting at [t] = 0. [height] is the peak, as a canvas fraction.
  static _Pose hop(
    double t, {
    double crouch = 0.22,
    double air = 0.4,
    double land = 0.5,
    double height = 0.06,
    double squash = 0.12,
    double lean = 0,
  }) {
    if (t < 0 || t > crouch + air + land) return _Pose.rest;

    // Anticipation: sink into the legs.
    if (t < crouch) {
      final e = _ease(t / crouch);
      final sy = 1 - 0.1 * e;
      return _Pose(sy: sy, sx: _widthFor(sy), rotation: -lean * 0.5 * e);
    }

    // In the air: a parabola, stretched at take-off and landing, round at the top.
    t -= crouch;
    if (t < air) {
      final u = t / air;
      final h = 4 * u * (1 - u);
      var sy = 1 + 0.07 * (1 - h);
      if (u < 0.15) sy = 0.9 + (sy - 0.9) * Curves.easeOutCubic.transform(u / 0.15);
      return _Pose(
        dy: -height * h,
        sy: sy,
        sx: _widthFor(sy),
        rotation: lean * math.sin(u * math.pi),
        lift: h * (height / 0.06).clamp(0.0, 1.4),
      );
    }

    // Landing: squash flat fast, then spring back to her normal shape.
    final v = (t - air) / land;
    final double sy;
    if (v < 0.12) {
      sy = 1.07 + (1 - squash - 1.07) * Curves.easeOutCubic.transform(v / 0.12);
    } else {
      sy = 1 - squash * _spring((v - 0.12) / 0.88);
    }
    return _Pose(sy: sy, sx: _widthFor(sy));
  }

  /// Saying hello on a 3-second loop: one hop, then a curious head tilt with breathing.
  static _Pose hello(double t) {
    const hopEnd = 1.12;
    if (t < hopEnd) return hop(t, height: 0.055, lean: 0.04);
    // Curious tilt to one side and back, plus two soft breaths.
    final v = (t - hopEnd) / (3 - hopEnd);
    final tilt = 0.075 * math.sin(v * math.pi) * (1 - 0.35 * math.sin(v * 3 * math.pi));
    final breath = math.sin(v * 4 * math.pi);
    final sy = 1 + 0.012 * breath;
    return _Pose(rotation: tilt, sy: sy, sx: _widthFor(sy));
  }

  /// The order-placed routine (3.4 s): two excited hops, a happy wiggle, two more
  /// hops, then she settles with a little spring.
  static _Pose cheer(double t) {
    const quick = (crouch: 0.1, air: 0.32, land: 0.22);
    for (final (start, lean) in [(0.0, 0.06), (0.62, -0.06), (1.94, 0.05), (2.5, -0.05)]) {
      if (t >= start && t < start + quick.crouch + quick.air + quick.land) {
        return hop(
          t - start,
          crouch: quick.crouch,
          air: quick.air,
          land: quick.land,
          height: 0.085,
          squash: 0.14,
          lean: lean,
        );
      }
    }
    // Happy wiggle side to side, quick and fading out, with a tiny bounce.
    if (t >= 1.25 && t < 1.94) {
      final v = (t - 1.25) / 0.69;
      final wiggle = 0.13 * math.sin(v * 5 * math.pi) * (1 - v);
      final sy = 1 + 0.03 * math.sin(v * 10 * math.pi) * (1 - v);
      return _Pose(rotation: wiggle, sy: sy, sx: _widthFor(sy));
    }
    // Settle: a last little spring into a proud pose.
    if (t >= 3.14) {
      final v = ((t - 3.14) / 0.26).clamp(0.0, 1.0);
      final sy = 1 + 0.04 * _spring(v);
      return _Pose(sy: sy, sx: _widthFor(sy));
    }
    return _Pose.rest;
  }

  /// After cheering: a small content bob now and then ([v] 0–1).
  static _Pose bob(double v) {
    if (v == 0 || v == 1) return _Pose.rest;
    return hop(v * 0.9, crouch: 0.15, air: 0.3, land: 0.45, height: 0.025, squash: 0.08);
  }

  /// Asleep, on an 8-second loop: two slow deep breaths while her head slowly
  /// droops, then she catches herself with a little jolt and settles again.
  static _Pose sleep(double t) {
    final breath = (1 - math.cos(t / 4 * 2 * math.pi)) / 2;
    final sy = 1 + 0.035 * breath;
    var rotation = -0.05;
    var dy = 0.0;
    if (t >= 4.4 && t < 7.1) {
      // Nodding off: a slow, heavy droop.
      final v = Curves.easeIn.transform((t - 4.4) / 2.7);
      rotation -= 0.08 * v;
      dy = 0.006 * v;
    } else if (t >= 7.1) {
      // Jolts back up, overshoots a touch and settles.
      final v = ((t - 7.1) / 0.9).clamp(0.0, 1.0);
      rotation -= 0.08 * _spring(v);
      dy = 0.006 * math.max(0, 1 - v * 3);
    }
    return _Pose(dy: dy, rotation: rotation, sy: sy, sx: 1 + 0.012 * breath, lift: -0.06 * breath);
  }
}

/// Her shadow on the ground: smaller and fainter the higher she is.
class _Shadow extends CustomPainter {
  _Shadow(this.lift);

  final double lift;

  // The drawing's own shadow, as canvas fractions.
  static const _center = Offset(0.4868, 0.834);
  static const _size = Size(0.38, 0.1);

  @override
  void paint(Canvas canvas, Size size) {
    final k = (1 - 0.4 * lift).clamp(0.4, 1.2);
    final rect = Rect.fromCenter(
      center: Offset(_center.dx * size.width, _center.dy * size.height),
      width: _size.width * size.width * k,
      height: _size.height * size.height * k,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = const Color(0xFFCBCBCB).withValues(alpha: (1 - 0.45 * lift).clamp(0.3, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
  }

  @override
  bool shouldRepaint(_Shadow old) => old.lift != lift;
}

/// Eyelids over the hen's eyes in her resting pose. [closed] 0–1 lowers them
/// from the top like a real blink; fully closed (or [asleep]) they become a
/// soft closed-eye curve with lashes.
class _Eyelids extends CustomPainter {
  _Eyelids(this.closed, {required this.asleep});

  final double closed;
  final bool asleep;

  // Eye centres and eye-white sizes, as canvas fractions.
  static const _eyes = [
    (Offset(0.4760, 0.3078), Size(0.0525, 0.0542)),
    (Offset(0.5475, 0.3078), Size(0.0500, 0.0542)),
  ];

  static const _skin = [Color(0xFFF59A44), Color(0xFFEE8636)];
  static const _lineColor = Color(0xFF6B2E12);

  @override
  void paint(Canvas canvas, Size size) {
    for (final (c, s) in _eyes) {
      final center = Offset(c.dx * size.width, c.dy * size.height);
      final w = s.width * size.width * 1.18;
      final h = s.height * size.height * 1.18;
      final eye = Rect.fromCenter(center: center, width: w, height: h);
      final skin = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _skin,
        ).createShader(eye);
      final line = Paint()
        ..color = _lineColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (asleep || closed >= 0.85) {
        canvas.drawOval(eye, skin);
        line.strokeWidth = w * 0.11;
        final y = center.dy + h * 0.06;
        canvas.drawPath(
          Path()
            ..moveTo(center.dx - w * 0.36, y)
            ..quadraticBezierTo(center.dx, y + h * 0.42, center.dx + w * 0.36, y),
          line,
        );
        line.strokeWidth = w * 0.07;
        for (final dx in [-0.22, 0.22]) {
          final from = Offset(center.dx + w * dx, y + h * 0.17);
          canvas.drawLine(from, from.translate(w * dx * 0.35, h * 0.2), line);
        }
        continue;
      }

      // Mid-blink: the lid slides down over the eye, its edge curving with it.
      final edge = eye.top + eye.height * closed;
      canvas.save();
      canvas.clipPath(Path()..addOval(eye));
      canvas.drawRect(Rect.fromLTRB(eye.left, eye.top, eye.right, edge + h * 0.08), skin);
      canvas.restore();
      line.strokeWidth = w * 0.08;
      final half = math.sqrt(math.max(0, 1 - math.pow((edge - center.dy) / (h / 2), 2))) * w / 2;
      canvas.drawPath(
        Path()
          ..moveTo(center.dx - half, edge)
          ..quadraticBezierTo(center.dx, edge + h * 0.16, center.dx + half, edge),
        line,
      );
    }
  }

  @override
  bool shouldRepaint(_Eyelids old) => old.closed != closed || old.asleep != asleep;
}

/// Three "z"s drifting up from above her head, swaying and fading, one after another.
class _Zzz extends StatelessWidget {
  const _Zzz({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < 3; i++)
              Builder(
                builder: (_) {
                  final p = (t + i / 3) % 1; // each z is a third of a cycle behind
                  final fade = p < 0.2 ? p / 0.2 : (1 - p) / 0.8;
                  final sway = math.sin(p * 2 * math.pi) * 0.05;
                  return Positioned(
                    left: box.maxWidth * (0.66 + 0.22 * p + sway),
                    top: h * (0.16 - 0.2 * p),
                    child: Opacity(
                      opacity: fade.clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: -0.2 + sway * 3,
                        child: Text(
                          'z',
                          style: TextStyle(
                            fontSize: h * (0.08 + 0.06 * p),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF7C83A6),
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

/// A ring of little confetti dots and strips bursting out once as she pops in.
class _Sparkles extends CustomPainter {
  _Sparkles(this.t);

  final double t;

  static const _colors = [AppColors.primary, AppColors.star, AppColors.success, Color(0xFF4F8EF7)];

  @override
  void paint(Canvas canvas, Size size) {
    final p = Curves.easeOutCubic.transform(t);
    final fade = t < 0.6 ? 1.0 : (1 - t) / 0.4;
    final center = Offset(size.width / 2, size.height * 0.42);
    final reach = size.height * 0.62;
    for (var i = 0; i < 14; i++) {
      final a = i / 14 * 2 * math.pi + 0.3;
      final r = reach * (0.55 + 0.45 * p) * (i.isEven ? 1 : 0.8);
      // A little gravity: pieces drift down as they fly out.
      final pos = center + Offset(math.cos(a), math.sin(a)) * r * p + Offset(0, reach * 0.25 * p * p);
      final paint = Paint()..color = _colors[i % _colors.length].withValues(alpha: fade.clamp(0.0, 1.0));
      final s = size.height * (i.isEven ? 0.022 : 0.016) * (1 - 0.3 * p);
      if (i % 3 == 0) {
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(a + p * 4);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: s * 2.2, height: s * 1.1), paint);
        canvas.restore();
      } else {
        canvas.drawCircle(pos, s, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_Sparkles old) => old.t != t;
}
