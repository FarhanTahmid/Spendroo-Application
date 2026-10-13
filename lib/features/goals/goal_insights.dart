import 'dart:math' as math;

import 'goal_math.dart';

/// Short, specific nudges about the user's goals, worked out from their own
/// numbers. Each says one thing the user can act on; the screens word them
/// (goal_insight_card.dart). Plain Dart, so the rules are tested on their own.
sealed class GoalInsight {
  const GoalInsight(this.goalId);

  /// The goal it is about, to open on a tap; null for one about goals in general.
  final String? goalId;
}

/// Below the steady line: how far, and what a week would bring it back.
class BehindInsight extends GoalInsight {
  const BehindInsight(super.goalId, this.goalName, this.behindMinor, this.perWeekMinor, this.currency);

  final String goalName;
  final int behindMinor;
  final int perWeekMinor;
  final String currency;
}

/// Months in a row with more put in than taken out.
class StreakInsight extends GoalInsight {
  const StreakInsight(super.goalId, this.goalName, this.months);

  final String goalName;
  final int months;
}

/// Half of the month's biggest spending would bring the goal this many weeks closer.
class CutBackInsight extends GoalInsight {
  const CutBackInsight(super.goalId, this.goalName, this.category, this.spentMinor, this.weeksSooner, this.currency);

  final String goalName;
  final String category;
  final int spentMinor;
  final int weeksSooner;
  final String currency;
}

/// Money mostly goes in right after income arrives: a schedule could do it.
class PaydayInsight extends GoalInsight {
  const PaydayInsight(super.goalId, this.goalName);

  final String goalName;
}

/// More went into goals this month than in any month before.
class BestMonthInsight extends GoalInsight {
  const BestMonthInsight(this.amountMinor, this.currency) : super(null);

  final int amountMinor;
  final String currency;
}

/// No money is put aside for the unexpected yet.
class EmergencyFundInsight extends GoalInsight {
  const EmergencyFundInsight() : super(null);
}

/// What the insights need to know of one goal.
class GoalFacts {
  const GoalFacts({
    required this.id,
    required this.name,
    required this.icon,
    required this.currency,
    required this.progress,
    required this.stats,
    required this.moves,
    this.autoSaved = false,
    this.active = true,
  });

  final String id;
  final String name;
  final String icon;
  final String currency;
  final GoalProgress progress;
  final GoalStats stats;
  final List<GoalMove> moves;
  final bool autoSaved;
  final bool active;
}

/// Contributions this close after an income day count as "on payday".
const paydayWindowDays = 3;

/// The nudges worth showing now, most useful first.
List<GoalInsight> goalInsights({
  required List<GoalFacts> goals,
  required DateTime today,
  String? topCategory,
  int topCategoryMinor = 0,
  List<DateTime> incomeDays = const [],
  String? currency,
}) {
  final active = goals.where((goal) => goal.active && !goal.progress.isReached).toList();
  final found = <GoalInsight>[];

  // Falling behind matters most: the furthest behind, as a share of its target
  final behind = active.where((goal) => goal.progress.pace == GoalPace.behind).toList()
    ..sort((a, b) => (b.progress.behindMinor / b.progress.targetMinor).compareTo(a.progress.behindMinor / a.progress.targetMinor));
  for (final goal in behind.take(1)) {
    final perMonth = goal.progress.neededPerMonthMinor ?? goal.progress.behindMinor;
    found.add(BehindInsight(goal.id, goal.name, goal.progress.behindMinor, weeklyAndDaily(perMonth).$1, goal.currency));
  }

  // A month of saving beats every one before it
  if (currency != null) {
    final sameCurrency = goals.where((goal) => goal.currency == currency).toList();
    final months = sameCurrency.isEmpty ? 0 : sameCurrency.first.stats.months.length;
    if (months > 1) {
      int netAt(int index) => sameCurrency.fold(0, (sum, goal) => sum + goal.stats.months[index].netMinor);
      final now = netAt(months - 1);
      final before = [for (var i = 0; i < months - 1; i++) netAt(i)];
      if (now > 0 && before.any((value) => value > 0) && before.every((value) => now > value)) {
        found.add(BestMonthInsight(now, currency));
      }
    }
  }

  // Spending one thing a little less, where it would show most
  if (topCategory != null && topCategoryMinor > 0) {
    GoalFacts? best;
    var bestWeeks = 0;
    for (final goal in active.where((goal) => goal.currency == currency)) {
      final pace = goal.stats.averagePerMonthMinor;
      if (pace <= 0) continue;
      final half = math.min(topCategoryMinor ~/ 2, goal.progress.remainingMinor);
      final weeks = (half / pace * daysPerMonth / 7).round();
      if (weeks > bestWeeks) {
        best = goal;
        bestWeeks = weeks;
      }
    }
    if (best != null && bestWeeks >= 1) {
      found.add(CutBackInsight(best.id, best.name, topCategory, topCategoryMinor, bestWeeks, best.currency));
    }
  }

  // Saving straight after payday, by hand: a schedule would do it every time
  if (incomeDays.isNotEmpty) {
    for (final goal in active.where((goal) => !goal.autoSaved)) {
      final ins = goal.moves.where((move) => move.isIn && move.source != 'recurring').toList();
      if (ins.length < 3) continue;
      final afterPay = ins.where((move) => incomeDays.any((pay) {
            final gap = daysBetween(pay, move.day);
            return gap >= 0 && gap <= paydayWindowDays;
          }));
      if (afterPay.length * 100 >= ins.length * 60) {
        found.add(PaydayInsight(goal.id, goal.name));
        break;
      }
    }
  }

  // A habit worth keeping
  final streaks = active.where((goal) => goal.stats.streak >= 2).toList()
    ..sort((a, b) => b.stats.streak.compareTo(a.stats.streak));
  if (streaks.isNotEmpty) {
    final goal = streaks.first;
    found.add(StreakInsight(goal.id, goal.name, goal.stats.streak));
  }

  // Before anything else, a cushion for the unexpected
  if (!goals.any((goal) => goal.icon == 'emergency' && goal.active)) {
    found.add(const EmergencyFundInsight());
  }
  return found;
}
