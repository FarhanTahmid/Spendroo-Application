import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui.dart';
import '../personal/ledger_repository.dart' show CategorySpend;
import '../personal/spending_breakdown.dart' show localDigits;
import '../plan/plan_text.dart' show LockedTag;
import 'goal_insights.dart';
import 'goal_math.dart';
import 'goal_ring.dart';
import 'goal_style.dart';
import 'goals_repository.dart';

/// What the insights and the cards need of each goal, worked out once.
List<GoalFacts> goalFactsOf(
  List<GoalView> goals,
  Map<String, List<GoalMove>> moves,
  Set<String> autoSaved,
  DateTime today,
) =>
    [
      for (final view in goals)
        GoalFacts(
          id: view.goal.id,
          name: view.goal.name,
          icon: view.goal.icon,
          currency: view.goal.currency,
          progress: view.progressOn(today),
          stats: GoalStats.of(
            moves: moves[view.goal.id] ?? const [],
            targetMinor: view.goal.targetMinor,
            createdOn: view.createdOn,
            today: today,
          ),
          moves: moves[view.goal.id] ?? const [],
          autoSaved: autoSaved.contains(view.goal.id),
          active: !view.isArchived,
        ),
    ];

String goalPaceLabel(BuildContext context, GoalPace pace) {
  final l10n = context.l10n;
  return switch (pace) {
    GoalPace.onTrack => l10n.goalOnTrack,
    GoalPace.ahead => l10n.goalAhead,
    GoalPace.behind => l10n.goalBehind,
    GoalPace.noDate => l10n.goalNoDate,
    GoalPace.reached => l10n.goalReached,
  };
}

Color goalPaceColor(BuildContext context, GoalPace pace) {
  final colors = context.colors;
  return switch (pace) {
    GoalPace.behind => colors.moneyOut,
    GoalPace.reached => colors.gold,
    GoalPace.noDate => colors.muted,
    _ => colors.moneyIn,
  };
}

IconData goalPaceIcon(GoalPace pace) => switch (pace) {
      GoalPace.onTrack => Icons.check_circle_rounded,
      GoalPace.ahead => Icons.rocket_launch_rounded,
      GoalPace.behind => Icons.trending_down_rounded,
      GoalPace.noDate => Icons.event_busy_rounded,
      GoalPace.reached => Icons.emoji_events_rounded,
    };

/// "● On track" as a small coloured pill.
class GoalPacePill extends StatelessWidget {
  const GoalPacePill({super.key, required this.pace});

  final GoalPace pace;

  @override
  Widget build(BuildContext context) {
    final color = goalPaceColor(context, pace);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(goalPaceIcon(pace), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            goalPaceLabel(context, pace),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// A goal in a list: its ring, name, how much is saved of what, how it is
/// keeping pace, and the next quarter of the way. Opens the goal.
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.view, required this.today, this.locked = false});

  final GoalView view;
  final DateTime today;

  /// Read-only since a downgrade: nothing more goes in.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final goal = view.goal;
    final progress = view.progressOn(today);
    final color = goalColor(goal);
    final archived = view.isArchived;
    final next = progress.nextMilestone;

    return Opacity(
      opacity: archived ? 0.6 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpace.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/goal/${goal.id}'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Row(
              children: [
                GoalRingPercent(progress: progress, color: color, size: 64, stroke: 7, faded: archived),
                const SizedBox(width: AppSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(goalIcon(goal), size: 18, color: context.goalTint(goal)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(goal.name, style: text.titleMedium, overflow: TextOverflow.ellipsis),
                          ),
                          if (locked) const LockedTag(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.goalSavedOf(context.money(view.savedMinor, goal.currency),
                            context.money(goal.targetMinor, goal.currency)),
                        style: text.bodySmall?.copyWith(fontFeatures: tabularFigures),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (archived)
                            Text(l10n.archived, style: text.labelSmall)
                          else
                            GoalPacePill(pace: progress.pace),
                          if (!archived && next != null)
                            Text(
                              l10n.goalNextMilestone(localDigits(context, '$next'),
                                  context.money(progress.toNextMilestoneMinor, goal.currency)),
                              style: text.labelSmall?.copyWith(color: colors.muted),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Everything saved across the goals as one bar, each goal its own colour,
/// against what they add up to.
class GoalsSummaryBar extends StatelessWidget {
  const GoalsSummaryBar({super.key, required this.goals, required this.currency});

  final List<GoalView> goals;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final shown = goals.where((view) => view.goal.currency == currency && !view.isArchived).toList();
    final saved = shown.fold<int>(0, (sum, view) => sum + view.savedMinor.clamp(0, view.goal.targetMinor));
    final target = shown.fold<int>(0, (sum, view) => sum + view.goal.targetMinor);
    if (target <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.goalsSummary(
            context.money(saved, currency),
            context.money(target, currency),
            localDigits(context, '${shown.length}'),
          ),
          style: text.bodyMedium,
        ),
        const SizedBox(height: AppSpace.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                for (final view in shown)
                  if (view.savedMinor > 0)
                    Expanded(
                      flex: (view.savedMinor.clamp(0, view.goal.targetMinor) * 1000 ~/ target).clamp(1, 1000),
                      child: Container(
                        margin: const EdgeInsets.only(right: 1.5),
                        color: goalColor(view.goal),
                      ),
                    ),
                if (target - saved > 0)
                  Expanded(
                    flex: ((target - saved) * 1000 ~/ target).clamp(1, 1000),
                    child: Container(color: colors.field),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final view in shown) LegendKey(color: goalColor(view.goal), label: view.goal.name),
          ],
        ),
      ],
    );
  }
}

/// One insight, worded, with a light bulb or whatever suits it. Tapping it opens its goal.
class GoalInsightCard extends StatelessWidget {
  const GoalInsightCard({super.key, required this.insight, this.onCreateEmergency, this.onAutoSave});

  final GoalInsight insight;

  /// For the emergency fund nudge: start that goal.
  final VoidCallback? onCreateEmergency;

  /// For the payday nudge: set up a schedule for its goal.
  final void Function(String goalId)? onAutoSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final insight = this.insight;
    final (icon, color, sentence) = switch (insight) {
      BehindInsight() => (
          Icons.trending_down_rounded,
          colors.moneyOut,
          l10n.insightBehind(insight.goalName, context.money(insight.behindMinor, insight.currency),
              context.money(insight.perWeekMinor, insight.currency)),
        ),
      StreakInsight() => (
          Icons.local_fire_department_rounded,
          colors.gold,
          l10n.insightStreak(localDigits(context, '${insight.months}'), insight.goalName),
        ),
      CutBackInsight() => (
          Icons.lightbulb_rounded,
          colors.gold,
          l10n.insightCutBack(insight.category, context.money(insight.spentMinor, insight.currency),
              insight.goalName, insight.weeksSooner, localDigits(context, '${insight.weeksSooner}')),
        ),
      PaydayInsight() => (Icons.event_repeat_rounded, colors.moneyIn, l10n.insightPayday(insight.goalName)),
      BestMonthInsight() => (
          Icons.emoji_events_rounded,
          colors.gold,
          l10n.insightBestMonth(context.money(insight.amountMinor, insight.currency)),
        ),
      EmergencyFundInsight() => (Icons.health_and_safety_rounded, colors.moneyIn, l10n.insightEmergency),
    };
    final action = switch (insight) {
      EmergencyFundInsight() when onCreateEmergency != null => (l10n.insightEmergencyAction, onCreateEmergency!),
      PaydayInsight() when onAutoSave != null => (l10n.goalAutoSave, () => onAutoSave!(insight.goalId!)),
      _ => null,
    };
    final goalId = insight.goalId;

    return Pressable(
      scale: 0.98,
      onTap: goalId == null ? null : () => context.push('/goal/$goalId'),
      child: Container(
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sentence, style: text.bodyMedium),
                  if (action != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                        onPressed: action.$2,
                        child: Text(action.$1),
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

/// A few insights one after another, swiped through.
class GoalInsightCarousel extends StatefulWidget {
  const GoalInsightCarousel({super.key, required this.insights, this.onCreateEmergency, this.onAutoSave});

  final List<GoalInsight> insights;
  final VoidCallback? onCreateEmergency;
  final void Function(String goalId)? onAutoSave;

  @override
  State<GoalInsightCarousel> createState() => _GoalInsightCarouselState();
}

class _GoalInsightCarouselState extends State<GoalInsightCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final insights = widget.insights;
    if (insights.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    return Column(
      children: [
        SizedBox(
          height: 112,
          child: PageView(
            onPageChanged: (page) => setState(() => _page = page),
            children: [
              for (final insight in insights)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GoalInsightCard(
                    insight: insight,
                    onCreateEmergency: widget.onCreateEmergency,
                    onAutoSave: widget.onAutoSave,
                  ),
                ),
            ],
          ),
        ),
        if (insights.length > 1) ...[
          const SizedBox(height: AppSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < insights.length; i++)
                AnimatedContainer(
                  duration: context.motion(AppMotion.standard),
                  width: i == _page ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _page ? colors.gold : colors.hairline,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// What goals are for and how they work, in four short points.
Future<void> showHowGoalsWork(BuildContext context) => showAppSheet<void>(
      context,
      title: context.l10n.goalsHowTitle,
      builder: (context) {
        final l10n = context.l10n;
        final text = Theme.of(context).textTheme;
        final points = [
          (Icons.savings_rounded, l10n.goalsHowSetAside, l10n.goalsHowSetAsideBody),
          (Icons.event_rounded, l10n.goalsHowDate, l10n.goalsHowDateBody),
          (Icons.event_repeat_rounded, l10n.goalsHowFirst, l10n.goalsHowFirstBody),
          (Icons.lock_open_rounded, l10n.goalsHowWithdraw, l10n.goalsHowWithdrawBody),
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (icon, title, body) in points)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBadge(icon, size: 40),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: text.titleSmall),
                          const SizedBox(height: 2),
                          Text(body, style: text.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );

/// The month's biggest spending that could be trimmed: several expenses, none
/// of them most of it. Rent paid in one go is not something to "spend a little
/// less" on; food, transport and shopping are.
CategorySpend? everydaySpending(List<CategorySpend>? byCategory) => byCategory
    ?.where((c) => c.name != null && c.count >= 3 && c.largestMinor * 2 < c.amountMinor)
    .firstOrNull;
