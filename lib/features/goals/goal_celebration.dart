import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/ui.dart';
import '../personal/spending_breakdown.dart' show localDigits;
import 'goal_math.dart';
import 'goal_ring.dart';
import 'goal_style.dart';

/// What the user chose on the "goal reached" screen.
enum ReachedChoice { useMoney, keepSaving, archive }

/// Says a quarter of the way was passed: a buzz, a short fall of confetti over
/// the screen and a gold message. Reaching the whole target gets a screen of
/// its own ([showGoalReached]).
void celebrateMilestone(BuildContext context, SavingsGoal goal, int mark) {
  HapticFeedback.mediumImpact();
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay != null && !context.reduceMotion) {
    late final OverlayEntry burst;
    burst = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: Confetti(pieces: 45, duration: const Duration(milliseconds: 2600), onDone: () => burst.remove()),
        ),
      ),
    );
    overlay.insert(burst);
  }
  final l10n = context.l10n;
  final colors = context.colors;
  final message = switch (mark) {
    50 => l10n.goalHalfway(goal.name),
    _ => l10n.goalMilestoneReached(localDigits(context, '$mark'), goal.name),
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: colors.header,
      content: Row(
        children: [
          Icon(Icons.stars_rounded, color: colors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: colors.onHeader, fontWeight: FontWeight.w600))),
        ],
      ),
    ));
}

/// The target is reached: confetti, what it took, and what to do with the money.
Future<ReachedChoice?> showGoalReached(
  BuildContext context, {
  required SavingsGoal goal,
  required GoalProgress progress,
  required int contributions,
  required int days,
}) {
  HapticFeedback.heavyImpact();
  return showGeneralDialog<ReachedChoice>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: context.motion(AppMotion.emphasised),
    transitionBuilder: (context, animation, _, child) => ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: AppMotion.spring),
      child: FadeTransition(opacity: animation, child: child),
    ),
    pageBuilder: (context, _, _) => _GoalReached(goal: goal, progress: progress, contributions: contributions, days: days),
  );
}

class _GoalReached extends StatelessWidget {
  const _GoalReached({required this.goal, required this.progress, required this.contributions, required this.days});

  final SavingsGoal goal;
  final GoalProgress progress;
  final int contributions;
  final int days;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final color = goalColor(goal);
    return Stack(
      children: [
        const Positioned.fill(child: IgnorePointer(child: Confetti())),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.xl),
            child: Material(
              color: colors.sheet,
              borderRadius: BorderRadius.circular(AppRadius.sheet),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.xxl, AppSpace.xl, AppSpace.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GoalRing(
                      fraction: 1,
                      color: color,
                      size: 120,
                      stroke: 11,
                      child: Icon(Icons.emoji_events_rounded, color: colors.gold, size: 48),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    Text(l10n.goalReachedTitle, style: text.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      l10n.goalReachedBody(goal.name, context.money(progress.savedMinor, goal.currency)),
                      style: text.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpace.lg),
                    FactRow(children: [
                      FactTile(label: l10n.goalReachedDays, value: localDigits(context, '$days')),
                      const SizedBox(width: 8),
                      FactTile(label: l10n.goalReachedTimes, value: localDigits(context, '$contributions')),
                    ]),
                    const SizedBox(height: AppSpace.xl),
                    BusyButton(
                      label: l10n.goalUseMoney,
                      icon: Icons.shopping_bag_rounded,
                      onPressed: () => Navigator.pop(context, ReachedChoice.useMoney),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, ReachedChoice.keepSaving),
                            child: Text(l10n.goalKeepSaving),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, ReachedChoice.archive),
                            child: Text(l10n.archive),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paper falling in the brand's colours, for a few seconds.
class Confetti extends StatefulWidget {
  const Confetti({super.key, this.pieces = 90, this.duration = const Duration(seconds: 4), this.onDone});

  final int pieces;
  final Duration duration;

  /// Called once the last piece has fallen.
  final VoidCallback? onDone;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: widget.duration);
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    const palette = [Color(0xFFF5B530), Color(0xFF2DB86F), Color(0xFF5BE3A0), Color(0xFF3B9EE5), Color(0xFFE05C9A)];
    _pieces = [
      for (var i = 0; i < widget.pieces; i++)
        _Piece(
          x: random.nextDouble(),
          delay: random.nextDouble() * 0.35,
          speed: 0.55 + random.nextDouble() * 0.6,
          drift: (random.nextDouble() - 0.5) * 0.25,
          spin: (random.nextDouble() - 0.5) * 14,
          size: 5 + random.nextDouble() * 6,
          color: palette[i % palette.length],
          round: random.nextBool(),
        ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.reduceMotion) return widget.onDone?.call();
      _clock.forward().whenComplete(() => widget.onDone?.call());
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => CustomPaint(painter: _ConfettiPainter(_pieces, _clock.value)),
      );
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.spin,
    required this.size,
    required this.color,
    required this.round,
  });

  final double x, delay, speed, drift, spin, size;
  final Color color;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0) return;
    for (final piece in pieces) {
      final local = ((t - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      if (local == 0) continue;
      final y = -20 + local * piece.speed * (size.height + 60);
      final x = (piece.x + piece.drift * local + math.sin(local * 9 + piece.spin) * 0.02) * size.width;
      final fade = local > 0.8 ? (1 - local) / 0.2 : 1.0;
      final paint = Paint()..color = piece.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.spin * local);
      if (piece.round) {
        canvas.drawCircle(Offset.zero, piece.size / 2.4, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.5),
              const Radius.circular(1.5)),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
