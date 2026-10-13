import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../personal/spending_breakdown.dart' show localDigits;
import 'goal_math.dart';
import 'goal_ring.dart';
import 'goal_style.dart';
import 'goal_widgets.dart';
import 'goals_page.dart';
import 'goals_repository.dart';

/// The first thing on the overview: every goal as a ring in a row the thumb
/// can swipe, the way stories sit at the top of a feed, so goals are seen
/// each time the app opens. A ring opens its goal; the first bubble starts a
/// new one. With no goal yet, one short line invites the first.
class GoalsStrip extends ConsumerWidget {
  const GoalsStrip({super.key, required this.workspace, this.onOpenGoals});

  final Workspace workspace;

  /// Opens all the goals; without it the goals screen is pushed.
  final VoidCallback? onOpenGoals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final goals = ref.watch(goalsProvider(workspace.id)).value;
    if (goals == null) return const SizedBox.shrink();
    final today = DateTime.now();
    final open = goals.where((view) => !view.isArchived).toList();
    void openAll() => onOpenGoals != null ? onOpenGoals!() : context.push('/goals');

    if (open.isEmpty) {
      return ref.watch(goalInviteDismissedProvider) ? const SizedBox.shrink() : _FirstGoalInvite(workspace: workspace);
    }

    final going = byUrgency(open.where((view) => !view.progressOn(today).isReached).toList(), today);
    final shown = [...going, ...open.where((view) => view.progressOn(today).isReached)];
    final saved = open
        .where((view) => view.goal.currency == workspace.defaultCurrency)
        .fold<int>(0, (sum, view) => sum + view.savedMinor);
    final behind = going.where((view) => view.progressOn(today).pace == GoalPace.behind).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Pressable(
            scale: 0.99,
            onTap: openAll,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 0, AppSpace.sm),
              child: Row(
                children: [
                  Text(l10n.goals, style: text.titleMedium),
                  const SizedBox(width: 8),
                  if (behind > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: colors.moneyOut.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        l10n.goalsBehindCount(localDigits(context, '$behind')),
                        style: text.labelSmall?.copyWith(color: colors.moneyOut, fontWeight: FontWeight.w700),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Gives way first on a narrow phone
                  Expanded(
                    child: Text(
                      l10n.goalsSavedTotal(context.money(saved, workspace.defaultCurrency)),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(fontFeatures: tabularFigures),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 18, color: colors.muted),
                ],
              ),
            ),
          ),
          SizedBox(
            key: const ValueKey('goals-strip'),
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: shown.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpace.md),
              itemBuilder: (context, index) => index == 0
                  ? _NewGoalBubble(onTap: () => newGoal(context, ref, workspace))
                  : _GoalBubble(view: shown[index - 1], today: today),
            ),
          ),
        ],
      ),
    );
  }
}

/// A goal as a ring with its icon inside and its name under it. A dot on the
/// ring's edge says, in colour, how it keeps pace.
class _GoalBubble extends StatelessWidget {
  const _GoalBubble({required this.view, required this.today});

  final GoalView view;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final goal = view.goal;
    final progress = view.progressOn(today);
    final reached = progress.isReached;
    return Semantics(
      button: true,
      label: '${goal.name}, ${progress.percent}%, ${goalPaceLabel(context, progress.pace)}',
      child: Pressable(
        onTap: () => context.push('/goal/${goal.id}'),
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GoalRing(
                    fraction: progress.fraction,
                    expected: reached ? null : progress.expectedFraction,
                    color: goalColor(goal),
                    size: 64,
                    stroke: 6,
                    child: Icon(reached ? Icons.emoji_events_rounded : goalIcon(goal),
                        color: reached ? colors.gold : context.goalTint(goal)),
                  ),
                  PositionedDirectional(
                    end: -2,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: reached ? colors.gold : goalPaceColor(context, progress.pace),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: colors.paper, width: 2),
                      ),
                      child: Text(
                        localDigits(context, '${progress.percent.clamp(0, 999)}%'),
                        style: text.labelSmall?.copyWith(
                          color: reached ? colors.onGold : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(goal.name, style: text.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// The first bubble: a dashed ring with a plus, to start one more goal.
class _NewGoalBubble extends StatelessWidget {
  const _NewGoalBubble({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    return Pressable(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            CustomPaint(
              painter: _DashedRing(colors.gold),
              child: SizedBox(
                width: 64,
                height: 64,
                child: Icon(Icons.add_rounded, color: colors.gold, size: 30),
              ),
            ),
            const SizedBox(height: 6),
            Text(context.l10n.goalNewShort, style: text.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _DashedRing extends CustomPainter {
  _DashedRing(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 2);
    const dashes = 16;
    const sweep = 2 * 3.141592653589793 / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRing old) => old.color != color;
}

/// Whether the user closed the first-goal card. Kept on this phone; goals stay
/// one tap away on the Planner tab and in "Save" on the add form.
class GoalInviteDismissed extends Notifier<bool> {
  @override
  bool build() {
    ref.read(databaseProvider).getSetting(goalInviteDismissedSettingKey).then((value) {
      if (value != null) state = true;
    });
    return false;
  }

  Future<void> dismiss() async {
    state = true;
    await ref.read(databaseProvider).setSetting(goalInviteDismissedSettingKey, DateTime.now().toUtc().toIso8601String());
  }
}

final goalInviteDismissedProvider = NotifierProvider<GoalInviteDismissed, bool>(GoalInviteDismissed.new);

/// No goal yet: one line and one button, small enough not to push the month away.
class _FirstGoalInvite extends ConsumerWidget {
  const _FirstGoalInvite({required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.lg),
      child: Pressable(
        scale: 0.98,
        onTap: () => newGoal(context, ref, workspace),
        child: Container(
          key: const ValueKey('first-goal-invite'),
          padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.md, 0, AppSpace.md),
          decoration: BoxDecoration(
            color: colors.gold.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: colors.gold.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              GoalRing(
                fraction: 0.25,
                color: AppTheme.successColor,
                size: 44,
                stroke: 5,
                child: const Icon(Icons.savings_rounded, color: AppTheme.successColor),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.goalsEmptyTitle, style: text.titleSmall),
                    Text(l10n.goalsInviteBody, style: text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.gold),
              IconButton(
                key: const ValueKey('first-goal-invite-close'),
                tooltip: l10n.dismiss,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close_rounded, size: 18, color: colors.muted),
                onPressed: () => ref.read(goalInviteDismissedProvider.notifier).dismiss(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// On the accounts screen, under the accounts: one line saying how much sits
/// in goals, which opens them. The goals themselves live in the Planner tab.
class GoalsAccountsLink extends ConsumerWidget {
  const GoalsAccountsLink({super.key, required this.workspace, this.onOpenGoals});

  final Workspace workspace;
  final VoidCallback? onOpenGoals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final goals = (ref.watch(goalsProvider(workspace.id)).value ?? const <GoalView>[])
        .where((view) => !view.isArchived)
        .toList();
    final saved = goals
        .where((view) => view.goal.currency == workspace.defaultCurrency)
        .fold<int>(0, (sum, view) => sum + view.savedMinor);
    return Card(
      margin: const EdgeInsets.only(top: AppSpace.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenGoals ?? () => context.push('/goals'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Row(
            children: [
              const IconBadge(Icons.flag_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.goals, style: text.titleMedium),
                    Text(
                      goals.isEmpty ? l10n.goalsEmptyTitle : l10n.goalsKeptAside(goals.length, localDigits(context, '${goals.length}')),
                      style: text.bodySmall?.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (goals.isNotEmpty) MoneyText(saved, workspace.defaultCurrency, style: text.titleMedium),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// Under the big "available" figure on the navy header: what sits in goals and
/// what the user owns in all, side by side on one soft panel, with a bar that
/// shows how much of it is set aside.
class GoalsWorthPanel extends StatelessWidget {
  const GoalsWorthPanel({
    super.key,
    required this.availableMinor,
    required this.inGoalsMinor,
    required this.currency,
    required this.onOpenGoals,
  });

  final int availableMinor;
  final int inGoalsMinor;
  final String currency;
  final VoidCallback onOpenGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    // An overdrawn account owns nothing of the bar
    final whole = math.max(availableMinor, 0) + math.max(inGoalsMinor, 0);
    final share = whole <= 0 ? 0.0 : math.max(inGoalsMinor, 0) / whole;
    final percent = (share * 100).round();

    return Container(
      key: const ValueKey('goals-worth-panel'),
      padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.md, AppSpace.md, AppSpace.sm + 2),
      decoration: BoxDecoration(
        color: colors.onHeader.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: colors.onHeader.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Pressable(
                    onTap: onOpenGoals,
                    child: _WorthFigure(
                      icon: Icons.savings_rounded,
                      tint: colors.mint,
                      label: l10n.inGoals,
                      amountMinor: inGoalsMinor,
                      currency: currency,
                      amountColor: colors.mint,
                      opens: true,
                    ),
                  ),
                ),
                VerticalDivider(width: AppSpace.lg + 1, thickness: 1, color: colors.onHeader.withValues(alpha: 0.12)),
                Expanded(
                  child: _WorthFigure(
                    icon: Icons.diamond_rounded,
                    tint: colors.gold,
                    label: l10n.netWorth,
                    amountMinor: availableMinor + inGoalsMinor,
                    currency: currency,
                    amountColor: colors.onHeader,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          // The whole is what the user owns; the mint part is set aside
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: SizedBox(
              height: 6,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: share),
                duration: context.motion(AppMotion.count),
                curve: AppMotion.ease,
                builder: (context, value, _) => Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: colors.onHeader.withValues(alpha: 0.16)),
                    FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: value.clamp(0.0, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [colors.mint, AppTheme.successColor]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.goalsShareOfWorth(localDigits(context, '$percent%')),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall?.copyWith(color: colors.onHeaderMuted),
          ),
        ],
      ),
    );
  }
}

/// One figure of [GoalsWorthPanel]: a round icon, the label, the amount.
class _WorthFigure extends StatelessWidget {
  const _WorthFigure({
    required this.icon,
    required this.tint,
    required this.label,
    required this.amountMinor,
    required this.currency,
    required this.amountColor,
    this.opens = false,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final int amountMinor;
  final String currency;
  final Color amountColor;

  /// Tapping opens what the figure is made of: a chevron says so.
  final bool opens;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: tint.withValues(alpha: 0.16), shape: BoxShape.circle),
          child: Icon(icon, size: 17, color: tint),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(color: colors.onHeaderMuted)),
                  ),
                  if (opens) Icon(Icons.chevron_right_rounded, size: 16, color: colors.onHeaderMuted),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: MoneyText(amountMinor, currency,
                    style: text.titleMedium?.copyWith(color: amountColor, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
