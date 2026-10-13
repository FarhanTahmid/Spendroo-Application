import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../personal/personal_pages.dart' show monthSummaryProvider;
import '../personal/spending_breakdown.dart' show localDigits;
import '../plan/plan_page.dart' show LimitHint;
import '../plan/upgrade_sheet.dart';
import 'goal_form_page.dart';
import 'goal_insights.dart';
import 'goal_math.dart';
import 'goal_page.dart';
import 'goal_ring.dart';
import 'goal_style.dart';
import 'goal_widgets.dart';
import 'goals_repository.dart';

/// The order goals are listed in: the one whose date is nearest and that is
/// furthest behind first; goals with no date after those with one.
List<GoalView> byUrgency(List<GoalView> goals, DateTime today) => [...goals]..sort((a, b) {
    final aDate = a.targetOn, bDate = b.targetOn;
    if ((aDate == null) != (bDate == null)) return aDate == null ? 1 : -1;
    final aBehind = a.progressOn(today).pace == GoalPace.behind;
    final bBehind = b.progressOn(today).pace == GoalPace.behind;
    if (aBehind != bBehind) return aBehind ? -1 : 1;
    if (aDate != null && bDate != null && aDate != bDate) return aDate.compareTo(bDate);
    return b.progressOn(today).fraction.compareTo(a.progressOn(today).fraction);
  });

/// The goals screen opened on its own (from a push, a link or "See all"):
/// the same as the Planner tab's goals, with a back button.
class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final workspace = ref.watch(currentWorkspaceProvider);
    if (workspace == null) return Scaffold(appBar: AppBar(), body: const Center(child: AppLoader()));
    return Scaffold(
      appBar: headerAppBar(context, title: Text(l10n.goals), actions: [
        IconButton(
          tooltip: l10n.goalsHowTitle,
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: () => showHowGoalsWork(context),
        ),
      ]),
      body: GoalsBody(workspace: workspace),
      floatingActionButton: AddButton(tooltip: l10n.goalNew, onPressed: () => newGoal(context, ref, workspace)),
    );
  }
}

/// Every savings goal: how much is in them together, nudges from the user's
/// own numbers, the goals still going (most urgent first), the ones reached
/// and the archived ones. With [header] false it leaves the navy field to
/// whoever holds it (the Planner tab puts its own above).
class GoalsBody extends ConsumerWidget {
  const GoalsBody({super.key, required this.workspace, this.showHowButton = false});

  final Workspace workspace;

  /// In the Planner tab there is no app bar to hold the "how goals work" button.
  final bool showHowButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final currency = workspace.defaultCurrency;
    final value = ref.watch(goalsProvider(workspace.id));
    final moves = ref.watch(allGoalMovesProvider(workspace.id)).value ?? const <String, List<GoalMove>>{};
    final autoSaved = ref.watch(autoSavedGoalsProvider(workspace.id)).value ?? const <String>{};
    final plan = ref.watch(entitlementsProvider).value;
    final month = ref.watch(monthSummaryProvider((workspace.id, currency))).value;
    final today = DateTime.now();

    return PassbookBody(
      header: Stack(
        children: [
          _GoalsHeader(goals: value.value ?? const [], moves: moves, currency: currency, incomeMinor: month?.incomeMinor ?? 0),
          if (showHowButton)
            PositionedDirectional(
              top: -8,
              end: -12,
              child: IconButton(
                tooltip: l10n.goalsHowTitle,
                icon: Icon(Icons.info_outline_rounded, color: colors.onHeaderMuted),
                onPressed: () => showHowGoalsWork(context),
              ),
            ),
        ],
      ),
      child: AsyncView(
        value: value,
        builder: (goals) {
          if (goals.isEmpty) return GoalsEmptyState(workspace: workspace);
          final active = byUrgency(
            goals.where((view) => !view.isArchived && !view.progressOn(today).isReached).toList(),
            today,
          );
          final reached = goals.where((view) => !view.isArchived && view.progressOn(today).isReached).toList();
          final archived = goals.where((view) => view.isArchived).toList();
          final top = everydaySpending(month?.byCategory);
          final insights = goalInsights(
            goals: goalFactsOf(goals, moves, autoSaved, today),
            today: today,
            topCategory: top?.name,
            topCategoryMinor: top?.amountMinor ?? 0,
            incomeDays: ref.watch(incomeDaysProvider(workspace.id)).value ?? const [],
            currency: currency,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, 96),
            children: [
              if (goals.any((view) => !view.isArchived))
                Entrance(child: SectionCard(children: [GoalsSummaryBar(goals: goals, currency: currency)])),
              if (insights.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.lg),
                  child: GoalInsightCarousel(
                    insights: insights,
                    onCreateEmergency: () => newGoal(context, ref, workspace, template: 'emergency'),
                    onAutoSave: (goalId) {
                      final view = goals.firstWhere((view) => view.goal.id == goalId);
                      openAutoSave(context, ref, workspace, view.goal,
                          amountMinor: view.progressOn(today).neededPerMonthMinor);
                    },
                  ),
                ),
              for (final (index, view) in active.indexed)
                Entrance(
                  index: index,
                  child: GoalCard(view: view, today: today, locked: plan?.isLocked(view.goal.id) ?? false),
                ),
              if (reached.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, AppSpace.md, 4, AppSpace.sm),
                  child: Row(children: [
                    Icon(Icons.emoji_events_rounded, color: colors.gold, size: 20),
                    const SizedBox(width: 6),
                    Text(l10n.goalsReachedSection, style: text.titleSmall),
                  ]),
                ),
                _TrophyShelf(goals: reached),
              ],
              AddRowButton(label: l10n.goalNew, onPressed: () => newGoal(context, ref, workspace)),
              LimitHint(feature: F.savingsGoals, workspace: workspace),
              if (archived.isNotEmpty)
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Text(l10n.goalsArchivedSection(localDigits(context, '${archived.length}')), style: text.titleSmall),
                    children: [for (final view in archived) GoalCard(view: view, today: today)],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Starts a new goal. The plan is asked before the form opens, so a user with
/// no room left hears it before typing everything in.
Future<void> newGoal(BuildContext context, WidgetRef ref, Workspace workspace, {String? template}) async {
  final allowed = await guarded(context, () => ref.read(planGuardProvider).roomFor(F.savingsGoals, workspace.id));
  if (allowed && context.mounted) openGoalForm(context, workspace, template: template);
}

/// On the navy field: everything in goals, and what share of the month's income went into them.
class _GoalsHeader extends StatelessWidget {
  const _GoalsHeader({required this.goals, required this.moves, required this.currency, required this.incomeMinor});

  final List<GoalView> goals;
  final Map<String, List<GoalMove>> moves;
  final String currency;
  final int incomeMinor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final now = DateTime.now();
    final inGoals = goals.where((view) => view.goal.currency == currency).fold<int>(0, (sum, view) => sum + view.savedMinor);
    // Put in this month, less taken out, across the goals
    final thisMonth = goals.where((view) => view.goal.currency == currency).fold<int>(0, (sum, view) {
      return sum +
          (moves[view.goal.id] ?? const <GoalMove>[])
              .where((move) => move.day.year == now.year && move.day.month == now.month)
              .fold<int>(0, (s, move) => s + move.amountMinor);
    });
    final rate = incomeMinor <= 0 || thisMonth <= 0 ? null : (thisMonth * 100 / incomeMinor).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderFigure(label: l10n.inGoals, amountMinor: inGoals, currency: currency),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _HeaderChip(
              icon: Icons.south_west_rounded,
              label: l10n.goalsThisMonth(context.money(thisMonth, currency)),
            ),
            if (rate != null)
              _HeaderChip(icon: Icons.percent_rounded, label: l10n.goalsSavingRate(localDigits(context, '$rate'))),
          ],
        ),
        if (goals.isEmpty) Text(l10n.goalsHeaderEmpty, style: text.bodySmall?.copyWith(color: colors.onHeaderMuted)),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.onHeader.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.mint),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.onHeader)),
        ],
      ),
    );
  }
}

/// Reached goals side by side, each a full gold-notched ring with a trophy.
class _TrophyShelf extends StatelessWidget {
  const _TrophyShelf({required this.goals});

  final List<GoalView> goals;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: goals.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpace.md),
        itemBuilder: (context, index) {
          final view = goals[index];
          return Pressable(
            onTap: () => context.push('/goal/${view.goal.id}'),
            child: SizedBox(
              width: 96,
              child: Column(
                children: [
                  GoalRing(
                    fraction: 1,
                    color: goalColor(view.goal),
                    size: 72,
                    stroke: 7,
                    child: Icon(goalIcon(view.goal), color: context.goalTint(view.goal)),
                  ),
                  const SizedBox(height: 6),
                  Text(view.goal.name, style: text.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(context.money(view.savedMinor, view.goal.currency),
                      style: text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// No goal yet: what a goal does, and three to start from with one tap.
class GoalsEmptyState extends ConsumerWidget {
  const GoalsEmptyState({super.key, required this.workspace, this.compact = false});

  final Workspace workspace;

  /// On the overview: no big ring, just the words and the three starts.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final starts = goalTemplates.where((template) => ['emergency', 'gadget', 'trip'].contains(template.key));
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact) ...[
          GoalRing(
            fraction: 0.25,
            color: AppTheme.successColor,
            size: 120,
            stroke: 11,
            child: const Icon(Icons.savings_rounded, size: 44, color: AppTheme.successColor),
          ),
          const SizedBox(height: AppSpace.lg),
        ],
        Text(l10n.goalsEmptyTitle, style: compact ? text.titleMedium : text.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: AppSpace.xs),
        Text(l10n.goalsEmptyBody, style: text.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: AppSpace.lg),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final template in starts)
              ActionChip(
                avatar: Icon(template.icon, size: 18, color: template.color),
                label: Text(template.label(context)),
                onPressed: () => newGoal(context, ref, workspace, template: template.key),
              ),
            ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.goalTemplateCustom),
              onPressed: () => newGoal(context, ref, workspace),
            ),
          ],
        ),
      ],
    );
    if (compact) return content;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.xxl, AppSpace.xl, AppSpace.xl),
      children: [content],
    );
  }
}
