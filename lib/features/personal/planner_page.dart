import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/ui.dart';
import '../goals/goals_page.dart';
import '../goals/goals_repository.dart';
import 'budget_calendar_page.dart';
import 'ledger_repository.dart';
import 'spending_breakdown.dart' show localDigits;

/// The two halves of the Planner tab.
enum PlannerView { budgets, goals }

/// Which half the Planner tab shows. Null until the user picks one: then it
/// opens on budgets for someone who has them and on goals for everyone else,
/// so a new user meets goals first.
class PlannerViewController extends Notifier<PlannerView?> {
  @override
  PlannerView? build() => null;

  void show(PlannerView view) => state = view;
}

final plannerViewProvider = NotifierProvider<PlannerViewController, PlannerView?>(PlannerViewController.new);

/// Planning money, both ways: how much may go out (budgets) and what it is
/// being kept for (goals), side by side on one tab.
class PlannerPage extends ConsumerWidget {
  const PlannerPage({super.key, required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final chosen = ref.watch(plannerViewProvider);
    final hasBudgets = (ref.watch(budgetsProvider(workspace.id)).value ?? const []).isNotEmpty;
    final goals = (ref.watch(goalsProvider(workspace.id)).value ?? const <GoalView>[])
        .where((view) => !view.isArchived)
        .length;
    final view = chosen ?? (hasBudgets ? PlannerView.budgets : PlannerView.goals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // On the navy field, so it reads as part of the header of whichever half is shown
        ColoredBox(
          color: colors.header,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, 0),
            child: SlidingSegmented<PlannerView>(
              key: const ValueKey('planner-switch'),
              onHeader: true,
              segments: {
                PlannerView.budgets: l10n.budgets,
                PlannerView.goals: goals == 0 ? l10n.goalsShort : '${l10n.goalsShort} · ${localDigits(context, '$goals')}',
              },
              value: view,
              onChanged: (next) {
                HapticFeedback.selectionClick();
                ref.read(plannerViewProvider.notifier).show(next);
              },
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: context.motion(AppMotion.standard),
            child: switch (view) {
              PlannerView.budgets => BudgetCalendarPage(key: const ValueKey('budgets'), workspace: workspace),
              PlannerView.goals => GoalsBody(key: const ValueKey('goals'), workspace: workspace, showHowButton: true),
            },
          ),
        ),
      ],
    );
  }
}
