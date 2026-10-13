import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/ui.dart';
import '../personal/spending_breakdown.dart' show localDigits;
import 'goal_math.dart';

/// The goal's ring. It fills in the goal's colour; notches at each quarter
/// turn gold once passed, so the next one is never far off; and a faint mint
/// arc shows where a steady saver would be today, so ahead or behind can be
/// seen without reading a word. It fills from where it last stood.
class GoalRing extends StatelessWidget {
  const GoalRing({
    super.key,
    required this.fraction,
    required this.color,
    this.expected,
    this.size = 56,
    this.stroke = 6,
    this.child,
    this.faded = false,
  });

  /// Saved over target; past 1 the ring is full.
  final double fraction;
  final Color color;

  /// Where the ring should be today (0 to 1); null without a date.
  final double? expected;
  final double size;
  final double stroke;
  final Widget? child;

  /// Drawn without colour: what a withdrawal would leave, or an archived goal.
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final fill = fraction.isFinite ? fraction.clamp(0.0, 1.0) : 0.0;
    final tone = faded ? colors.muted : color;
    return Semantics(
      label: '${(fraction * 100).floor()}%',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: fill),
        duration: context.motion(const Duration(milliseconds: 900)),
        curve: AppMotion.ease,
        builder: (context, value, child) => CustomPaint(
          painter: _GoalRingPainter(
            fill: value,
            expected: faded ? null : expected,
            stroke: stroke,
            color: tone,
            track: scheme.surfaceContainerHighest,
            ghost: colors.mint.withValues(alpha: 0.45),
            gold: colors.gold,
            notch: colors.sheet,
          ),
          child: child,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: child == null
              ? null
              : Center(
                  child: Padding(
                    padding: EdgeInsets.all(stroke + 4),
                    child: FittedBox(fit: BoxFit.scaleDown, child: child),
                  ),
                ),
        ),
      ),
    );
  }
}

class _GoalRingPainter extends CustomPainter {
  _GoalRingPainter({
    required this.fill,
    required this.expected,
    required this.stroke,
    required this.color,
    required this.track,
    required this.ghost,
    required this.gold,
    required this.notch,
  });

  final double fill;
  final double? expected;
  final double stroke;
  final Color color;
  final Color track;
  final Color ghost;
  final Color gold;
  final Color notch;

  static const _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - stroke / 2;
    final centre = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: centre, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);

    // Where a steady saver would be: under the real fill, so only the gap shows
    final due = expected;
    if (due != null && due > 0) {
      canvas.drawArc(rect, _start, 2 * math.pi * due.clamp(0.0, 1.0), false, paint..color = ghost);
    }
    if (fill > 0) {
      final sweep = 2 * math.pi * fill;
      final gradient = SweepGradient(
        startAngle: 0,
        endAngle: math.max(sweep, 0.01),
        colors: [color.withValues(alpha: 0.75), color],
        transform: const GradientRotation(_start),
      );
      canvas.drawArc(rect, _start, sweep, false, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(rect));
    }

    // A notch at each quarter: gold once passed, a quiet dot before
    for (final mark in goalMilestones) {
      final angle = _start + 2 * math.pi * (mark % 100) / 100;
      final at = centre + Offset(math.cos(angle), math.sin(angle)) * radius;
      final passed = fill * 100 >= mark - 0.001;
      final dot = stroke * (mark == 100 ? 0.42 : 0.32);
      canvas.drawCircle(at, dot + 1.2, Paint()..color = notch);
      canvas.drawCircle(at, dot, Paint()..color = passed ? gold : track);
    }
  }

  @override
  bool shouldRepaint(_GoalRingPainter old) =>
      old.fill != fill || old.expected != expected || old.color != color || old.track != track || old.notch != notch;
}

/// The ring with the percentage in its middle.
class GoalRingPercent extends StatelessWidget {
  const GoalRingPercent({
    super.key,
    required this.progress,
    required this.color,
    this.size = 56,
    this.stroke = 6,
    this.faded = false,
  });

  final GoalProgress progress;
  final Color color;
  final double size;
  final double stroke;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final big = size >= 120;
    return GoalRing(
      fraction: progress.fraction,
      expected: progress.isReached ? null : progress.expectedFraction,
      color: color,
      size: size,
      stroke: stroke,
      faded: faded,
      child: progress.isReached && !big
          ? Icon(Icons.check_rounded, color: color)
          : Text(
              localDigits(context, '${progress.percent}%'),
              style: (big ? text.headlineMedium : text.labelLarge)
                  ?.copyWith(fontWeight: FontWeight.w700, fontFeatures: tabularFigures),
            ),
    );
  }
}
