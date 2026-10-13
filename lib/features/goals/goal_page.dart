import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../personal/ledger_repository.dart';
import '../personal/personal_pages.dart' show monthSummaryProvider;
import '../personal/spending_breakdown.dart' show localDigits;
import '../plan/plan_text.dart' show LockedTag;
import '../plan/upgrade_sheet.dart';
import '../recurring/recurring_pages.dart';
import '../recurring/recurring_repository.dart';
import 'goal_celebration.dart';
import 'goal_charts.dart';
import 'goal_form_page.dart';
import 'goal_insights.dart';
import 'goal_math.dart';
import 'goal_money.dart';
import 'goal_ring.dart';
import 'goal_style.dart';
import 'goal_widgets.dart';
import 'goals_repository.dart';

/// Sets up a schedule that puts money into the goal. On a plan without
/// recurring transactions this says so instead.
Future<void> openAutoSave(BuildContext context, WidgetRef ref, Workspace workspace, SavingsGoal goal,
    {int? amountMinor}) async {
  final allowed = await guarded(
    context,
    () => ref.read(planGuardProvider).require(F.recurringTransactions, workspace.id),
  );
  if (!allowed || !context.mounted) return;
  final accounts = (ref.read(accountsProvider(workspace.id)).value ?? const <AccountBalance>[])
      .where((a) => !a.account.isArchived && a.account.currency == goal.currency)
      .toList()
    ..sort((a, b) => b.balanceMinor.compareTo(a.balanceMinor));
  Navigator.of(context).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => RuleFormPage(
      workspace: workspace,
      initial: RuleDraft(
        kind: 'transfer',
        title: context.l10n.goalAutoSaveTitle(goal.name),
        freq: 'monthly',
        startOn: todayIso(),
        accountId: accounts.firstOrNull?.account.id,
        toAccountId: goal.accountId,
        amountMinor: amountMinor,
        // Recorded by the server: paying yourself first works because nobody has to remember it
        mode: 'auto',
      ),
    ),
  ));
}

/// One goal in full: the ring, where it is heading, the pace it needs and the
/// pace it has, its months, where its money came from, and every move.
class GoalPage extends ConsumerStatefulWidget {
  const GoalPage({super.key, required this.goalId});

  final String goalId;

  @override
  ConsumerState<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends ConsumerState<GoalPage> {
  /// The monthly amount on the what-if slider; null until the user moves it.
  double? _whatIf;

  Future<void> _contribute(Workspace workspace, GoalView view, List<GoalMove> moves) async {
    final crossed = await showContributeSheet(context, view);
    if (crossed == null || crossed.isEmpty || !mounted) return;
    if (crossed.last < 100) return celebrateMilestone(context, view.goal, crossed.last);
    final progress = GoalProgress.of(
      savedMinor: view.goal.targetMinor,
      targetMinor: view.goal.targetMinor,
      createdOn: view.createdOn,
      today: DateTime.now(),
    );
    final choice = await showGoalReached(
      context,
      goal: view.goal,
      progress: progress,
      contributions: moves.where((move) => move.isIn).length + 1,
      days: math.max(daysBetween(view.createdOn, DateTime.now()), 1),
    );
    if (!mounted) return;
    switch (choice) {
      case ReachedChoice.useMoney:
        final latest = ref.read(goalProvider(view.goal.id)).value ?? view;
        _withdraw(latest, moves);
      case ReachedChoice.archive:
        await ref.read(goalsRepositoryProvider).setArchived(view.goal, true);
      case ReachedChoice.keepSaving || null:
        break;
    }
  }

  void _withdraw(GoalView view, List<GoalMove> moves) {
    final stats = GoalStats.of(
      moves: moves,
      targetMinor: view.goal.targetMinor,
      createdOn: view.createdOn,
      today: DateTime.now(),
    );
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => WithdrawPage(view: view, stats: stats),
    ));
  }

  Future<void> _menu(String action, Workspace workspace, GoalView view) async {
    final l10n = context.l10n;
    final repo = ref.read(goalsRepositoryProvider);
    switch (action) {
      case 'edit':
        openGoalForm(context, workspace, existing: view.goal);
      case 'archive':
        await repo.setArchived(view.goal, true);
      case 'restore':
        await guarded(context, () => repo.setArchived(view.goal, false));
      case 'delete':
        if (view.savedMinor != 0) {
          context.showMessage(l10n.goalDeleteHasMoney);
          return;
        }
        if (await confirm(context, l10n.goalDeleteConfirm(view.goal.name))) {
          await repo.deleteGoal(view);
          if (!mounted) return;
          showEventBurst(context, AppEvent.deleted);
          Navigator.pop(context);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final loaded = ref.watch(goalProvider(widget.goalId));
    final view = loaded.value;
    if (view == null) {
      return Scaffold(
        appBar: AppBar(),
        body: loaded.isLoading
            ? const Center(child: AppLoader())
            : EmptyState(icon: Icons.savings_outlined, message: l10n.goalGone),
      );
    }
    final goal = view.goal;
    final workspace = (ref.watch(workspacesProvider).value ?? const <Workspace>[])
        .where((w) => w.id == goal.workspaceId)
        .firstOrNull;
    final moves = ref.watch(goalMovesProvider(goal.id)).value ?? const <GoalMove>[];
    final autoSaved = ref.watch(autoSavedGoalsProvider(goal.workspaceId)).value ?? const <String>{};
    final locked = !view.isArchived && (ref.watch(entitlementsProvider).value?.isLocked(goal.id) ?? false);
    final today = DateTime.now();
    final progress = view.progressOn(today);
    final stats = GoalStats.of(moves: moves, targetMinor: goal.targetMinor, createdOn: view.createdOn, today: today);
    final color = goalColor(goal);
    final currency = goal.currency;
    final targetOn = view.targetOn;
    final early = stats.daysEarly(targetOn);
    String day(DateTime date) => formatDay(context, date);

    // The money this goal knows of, for its own insights
    final month = ref.watch(monthSummaryProvider((goal.workspaceId, currency))).value;
    final top = everydaySpending(month?.byCategory);
    final facts = GoalFacts(
      id: goal.id,
      name: goal.name,
      icon: goal.icon,
      currency: currency,
      progress: progress,
      stats: stats,
      moves: moves,
      autoSaved: autoSaved.contains(goal.id),
      active: !view.isArchived,
    );
    final insights = goalInsights(
      goals: [facts],
      today: today,
      topCategory: top?.name,
      topCategoryMinor: top?.amountMinor ?? 0,
      incomeDays: ref.watch(incomeDaysProvider(goal.workspaceId)).value ?? const [],
      currency: currency,
    ).where((insight) => insight.goalId == goal.id).toList();

    final header = Column(
      children: [
        Row(
          children: [
            GoalRingPercent(progress: progress, color: color, size: 128, stroke: 12, faded: view.isArchived),
            const SizedBox(width: AppSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: MoneyText(view.savedMinor, currency,
                        style: text.headlineMedium?.copyWith(color: colors.onHeader)),
                  ),
                  Text(l10n.goalOfTarget(context.money(goal.targetMinor, currency)),
                      style: text.bodyMedium?.copyWith(color: colors.onHeaderMuted)),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    [
                      if (progress.remainingMinor > 0) l10n.goalToGo(context.money(progress.remainingMinor, currency)),
                      if (targetOn != null) l10n.goalBy(day(targetOn)),
                    ].join(' · '),
                    style: text.bodySmall?.copyWith(color: colors.onHeaderMuted),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  if (!view.isArchived)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.onHeader.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(goalPaceIcon(progress.pace), size: 14,
                              color: progress.pace == GoalPace.behind ? colors.moneyOut : colors.mint),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              [
                                goalPaceLabel(context, progress.pace),
                                if (early != null && early > 0 && !progress.isReached)
                                  l10n.goalDaysEarly(localDigits(context, '$early')),
                                if (early != null && early < 0 && !progress.isReached)
                                  l10n.goalDaysLate(localDigits(context, '${-early}')),
                              ].join(' · '),
                              style: text.labelMedium?.copyWith(color: colors.onHeader),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );

    final actions = Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
            onPressed: workspace == null || view.isArchived || locked
                ? null
                : () => _contribute(workspace, view, moves),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.goalAddMoney),
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: view.savedMinor <= 0 ? null : () => _withdraw(view, moves),
            icon: Icon(progress.isReached ? Icons.shopping_bag_rounded : Icons.remove_rounded),
            label: Text(progress.isReached ? l10n.goalUseMoney : l10n.goalWithdraw),
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        IconButton.filledTonal(
          tooltip: l10n.goalAutoSave,
          onPressed: workspace == null || view.isArchived || locked
              ? null
              : () => openAutoSave(context, ref, workspace, goal, amountMinor: progress.neededPerMonthMinor),
          icon: Icon(autoSaved.contains(goal.id) ? Icons.event_available_rounded : Icons.event_repeat_rounded),
        ),
      ],
    );

    // What-if: a monthly amount, and the day it would bring
    final suggested = progress.neededPerMonthMinor ?? math.max(stats.averagePerMonthMinor, 0);
    final sliderMax = math.max(
      math.max(suggested * 2, stats.averagePerMonthMinor * 2),
      math.max(progress.remainingMinor ~/ 6, Money.parse('1000', currency) ?? 100000),
    ).toDouble();
    final whatIf = (_whatIf ?? (suggested > 0 ? suggested.toDouble() : sliderMax / 4)).clamp(0.0, sliderMax);
    final whatIfFinish = GoalStats.finishAt(progress.remainingMinor, whatIf.round(), today);

    return PassbookScaffold(
      title: Row(
        children: [
          Icon(goalIcon(goal), size: 22),
          const SizedBox(width: 8),
          Flexible(child: Text(goal.name, overflow: TextOverflow.ellipsis)),
        ],
      ),
      actions: [
        if (workspace != null)
          PopupMenuButton<String>(
            onSelected: (action) => _menu(action, workspace, view),
            itemBuilder: (_) => [
              if (!view.isArchived) PopupMenuItem(value: 'edit', child: Text(l10n.goalEdit)),
              PopupMenuItem(value: view.isArchived ? 'restore' : 'archive', child: Text(view.isArchived ? l10n.goalRestore : l10n.archive)),
              PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
            ],
          ),
      ],
      header: header,
      body: RefreshIndicator(
        onRefresh: ref.read(syncControllerProvider.notifier).syncNow,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.xl),
          children: [
            if (locked)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.md),
                child: Row(children: [
                  const LockedTag(),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.goalLockedNote, style: text.bodySmall)),
                ]),
              ),
            actions,
            const SizedBox(height: AppSpace.lg),
            for (final insight in insights.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.md),
                child: GoalInsightCard(
                  insight: insight,
                  onAutoSave: workspace == null
                      ? null
                      : (_) => openAutoSave(context, ref, workspace, goal, amountMinor: progress.neededPerMonthMinor),
                ),
              ),
            Entrance(
              child: SectionCard(
                title: l10n.goalTrajectory,
                children: [
                  GoalTrajectoryChart(
                    stats: stats,
                    moves: moves,
                    targetMinor: goal.targetMinor,
                    currency: currency,
                    createdOn: view.createdOn,
                    targetOn: targetOn,
                    color: color,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      LegendKey(color: color, label: l10n.goalLegendSaved),
                      if (targetOn != null)
                        LegendKey(color: Theme.of(context).colorScheme.primary, label: l10n.goalLegendSteady, dashed: true),
                      if (stats.projectedFinish != null) LegendKey(color: colors.mint, label: l10n.goalLegendForecast, dashed: true),
                      if (stats.milestoneDays.isNotEmpty) LegendKey(color: colors.gold, label: l10n.goalLegendMilestone),
                    ],
                  ),
                ],
              ),
            ),
            if (!progress.isReached && !view.isArchived)
              Entrance(
                index: 1,
                child: SectionCard(
                  title: l10n.goalPace,
                  children: [
                    FactRow(children: [
                      FactTile(
                        label: l10n.goalNeededMonthly,
                        value: progress.neededPerMonthMinor == null
                            ? '—'
                            : context.money(progress.neededPerMonthMinor!, currency),
                      ),
                      const SizedBox(width: 8),
                      FactTile(
                        label: stats.tooEarly ? l10n.goalSoFar : l10n.goalYourAverage,
                        value: context.money(stats.averagePerMonthMinor, currency),
                        color: !stats.tooEarly &&
                                progress.neededPerMonthMinor != null &&
                                stats.averagePerMonthMinor < progress.neededPerMonthMinor!
                            ? colors.moneyOut
                            : colors.moneyIn,
                      ),
                      const SizedBox(width: 8),
                      FactTile(
                        label: l10n.goalForecast,
                        value: stats.projectedFinish == null ? '—' : day(stats.projectedFinish!),
                      ),
                    ]),
                    const SizedBox(height: AppSpace.md),
                    Text(
                      stats.projectedFinish == null
                          ? (stats.tooEarly && view.savedMinor > 0 ? l10n.goalPaceTooEarly : l10n.goalPaceNothingYet)
                          : targetOn == null
                              ? l10n.goalPaceNoDate(context.money(stats.averagePerMonthMinor, currency), day(stats.projectedFinish!))
                              : (early ?? 0) >= 0
                                  ? l10n.goalPaceEarly(day(stats.projectedFinish!))
                                  : l10n.goalPaceLate(day(stats.projectedFinish!),
                                      context.money(progress.neededPerMonthMinor ?? 0, currency)),
                      style: text.bodyMedium,
                    ),
                    const Divider(height: AppSpace.xl),
                    Row(
                      children: [
                        Icon(Icons.tune_rounded, size: 18, color: colors.gold),
                        const SizedBox(width: 6),
                        Text(l10n.goalWhatIf, style: text.titleSmall),
                      ],
                    ),
                    Slider(
                      value: whatIf,
                      max: sliderMax,
                      divisions: 40,
                      activeColor: color,
                      label: context.money(whatIf.round(), currency),
                      onChanged: (value) => setState(() => _whatIf = value),
                    ),
                    Text(
                      whatIfFinish == null
                          ? l10n.goalWhatIfNever
                          : l10n.goalWhatIfResult(context.money(whatIf.round(), currency), day(whatIfFinish)),
                      style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (workspace != null && whatIf > 0)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: locked
                              ? null
                              : () => openAutoSave(context, ref, workspace, goal, amountMinor: whatIf.round()),
                          icon: const Icon(Icons.event_repeat_rounded, size: 18),
                          label: Text(l10n.goalWhatIfAutoSave),
                        ),
                      ),
                  ],
                ),
              ),
            Entrance(
              index: 2,
              child: SectionCard(
                title: l10n.goalMonthly,
                trailing: stats.streak >= 2
                    ? Text('🔥 ${l10n.goalStreak(localDigits(context, '${stats.streak}'))}',
                        style: text.labelMedium?.copyWith(color: colors.gold, fontWeight: FontWeight.w700))
                    : null,
                children: [
                  if (moves.isEmpty)
                    Text(l10n.goalNoMoves, style: text.bodyMedium?.copyWith(color: colors.muted))
                  else
                    GoalMonthsChart(months: stats.monthsSinceStart, currency: currency, color: color),
                ],
              ),
            ),
            Entrance(
              index: 3,
              child: SectionCard(
                title: l10n.goalMilestones,
                children: [
                  Row(
                    children: [
                      for (final mark in goalMilestones)
                        Expanded(
                          child: _MilestoneChip(
                            mark: mark,
                            reachedOn: stats.milestoneDays[mark],
                            passed: progress.percent >= mark,
                          ),
                        ),
                    ],
                  ),
                  if (progress.nextMilestone != null) ...[
                    const SizedBox(height: AppSpace.md),
                    Text(
                      l10n.goalNextMilestone(localDigits(context, '${progress.nextMilestone}'),
                          context.money(progress.toNextMilestoneMinor, currency)),
                      style: text.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (stats.sources.isNotEmpty)
              SectionCard(
                title: l10n.goalSources,
                children: [GoalSourcesDonut(sources: stats.sources, currency: currency)],
              ),
            SectionCard(
              title: l10n.goalHistory,
              padding: const EdgeInsets.fromLTRB(0, AppSpace.lg, 0, AppSpace.sm),
              children: [
                if (moves.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
                    child: Text(l10n.goalNoMoves, style: text.bodyMedium?.copyWith(color: colors.muted)),
                  ),
                for (final move in moves.take(50))
                  MoneyRow(
                    icon: move.isIn ? Icons.south_west_rounded : Icons.north_east_rounded,
                    tint: move.isIn ? color : colors.moneyOut,
                    title: move.note.isNotEmpty
                        ? move.note
                        : (move.isIn
                            ? l10n.goalMoveIn(move.otherAccountName ?? '—')
                            : l10n.goalMoveOut(move.otherAccountName ?? '—')),
                    detail: [
                      formatDate(context, isoDate(move.day)),
                      if (move.source == 'recurring') l10n.goalAuto,
                    ].join(' · '),
                    amount: '${move.isIn ? '+' : '−'}${context.money(move.amountMinor.abs(), currency)}',
                    amountColor: move.isIn ? context.amountColor(true) : context.amountColor(false),
                    onTap: () => _openMove(move),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A move can be taken back: both legs of its transfer go.
  Future<void> _openMove(GoalMove move) async {
    final l10n = context.l10n;
    if (!await confirm(context, l10n.goalUndoMove, action: l10n.delete)) return;
    final leg = await (ref.read(databaseProvider).select(ref.read(databaseProvider).transactions)
          ..where((t) => t.id.equals(move.id)))
        .getSingleOrNull();
    if (leg == null) return;
    await ref.read(ledgerRepositoryProvider).deleteTransaction(leg);
    if (mounted) showEventBurst(context, AppEvent.deleted);
  }
}

/// A quarter of the way: gold with its date once passed, quiet before.
class _MilestoneChip extends StatelessWidget {
  const _MilestoneChip({required this.mark, required this.reachedOn, required this.passed});

  final int mark;
  final DateTime? reachedOn;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final on = reachedOn;
    return Column(
      children: [
        AnimatedContainer(
          duration: context.motion(AppMotion.emphasised),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: passed ? colors.gold : colors.field,
            boxShadow: passed ? [BoxShadow(color: colors.gold.withValues(alpha: 0.4), blurRadius: 10)] : null,
          ),
          child: Icon(
            mark == 100 ? Icons.emoji_events_rounded : Icons.star_rounded,
            size: 20,
            color: passed ? colors.onGold : colors.muted,
          ),
        ),
        const SizedBox(height: 4),
        Text(localDigits(context, '$mark%'), style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
        Text(
          on == null ? ' ' : MaterialLocalizations.of(context).formatShortMonthDay(on),
          style: text.labelSmall?.copyWith(color: colors.muted),
        ),
      ],
    );
  }
}
