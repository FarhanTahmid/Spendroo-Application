import 'dart:math' as math;

/// How far a savings goal has come, whether it keeps pace with its date, and
/// what its history says. Plain Dart, so it is tested without a screen.
///
/// [GoalProgress] follows the server's rules exactly (ledger_personal/goals.py
/// in the API): the badge in the app and the push about falling behind must
/// agree. The rest ([GoalStats]) is the app's own.

/// Below this share of where the date says it should be, a goal is behind.
const onTrackShare = 90;

/// Above this share of where the date says it should be, a goal is ahead.
const aheadShare = 110;

/// The quarters of the way that are celebrated, in the order of their bits.
const goalMilestones = [25, 50, 75, 100];

/// Days in an average month, for spreading money over months.
const daysPerMonth = 30.4375;

/// Days of history before a finish date is forecast: one deposit is not yet a pace.
const forecastAfterDays = 30;

enum GoalPace { onTrack, ahead, behind, noDate, reached }

DateTime dayOf(DateTime moment) => DateTime.utc(moment.year, moment.month, moment.day);

int daysBetween(DateTime start, DateTime end) => dayOf(end).difference(dayOf(start)).inDays;

/// Months from [start] to [end], counting a part month as a part.
double monthsBetween(DateTime start, DateTime end) => math.max(daysBetween(start, end), 0) / daysPerMonth;

/// A straight line from nothing on the start day to the target on the date.
int expectedBy(int targetMinor, DateTime start, DateTime targetOn, DateTime today) {
  if (!dayOf(targetOn).isAfter(dayOf(start)) || !dayOf(today).isBefore(dayOf(targetOn))) return targetMinor;
  if (!dayOf(today).isAfter(dayOf(start))) return 0;
  return targetMinor * daysBetween(start, today) ~/ daysBetween(start, targetOn);
}

GoalPace paceOf(int savedMinor, int targetMinor, int? expectedMinor) {
  if (savedMinor >= targetMinor) return GoalPace.reached;
  if (expectedMinor == null) return GoalPace.noDate;
  if (savedMinor * 100 < expectedMinor * onTrackShare) return GoalPace.behind;
  if (savedMinor * 100 > expectedMinor * aheadShare) return GoalPace.ahead;
  return GoalPace.onTrack;
}

/// The bits of `milestones_hit` that [percent] has earned.
int milestonesPassed(int percent) {
  var bits = 0;
  for (final (position, mark) in goalMilestones.indexed) {
    if (percent >= mark) bits |= 1 << position;
  }
  return bits;
}

/// The marks crossed going from [before] to [after] percent, lowest first.
List<int> marksCrossed(int before, int after) => [
      for (final mark in goalMilestones)
        if (before < mark && after >= mark) mark,
    ];

/// Rounded up: paying this each month never falls short.
int? neededPerMonth(int remainingMinor, DateTime today, DateTime? targetOn) {
  if (targetOn == null || remainingMinor <= 0) return null;
  final months = monthsBetween(today, targetOn);
  return months > 0 ? (remainingMinor / months).ceil() : null;
}

class GoalProgress {
  const GoalProgress({
    required this.savedMinor,
    required this.targetMinor,
    required this.percent,
    required this.remainingMinor,
    required this.expectedMinor,
    required this.neededPerMonthMinor,
    required this.pace,
  });

  factory GoalProgress.of({
    required int savedMinor,
    required int targetMinor,
    required DateTime createdOn,
    required DateTime today,
    DateTime? targetOn,
  }) {
    final remaining = math.max(targetMinor - savedMinor, 0);
    final expected = targetOn == null ? null : expectedBy(targetMinor, createdOn, targetOn, today);
    return GoalProgress(
      savedMinor: savedMinor,
      targetMinor: targetMinor,
      percent: targetMinor <= 0 ? 0 : math.max(savedMinor, 0) * 100 ~/ targetMinor,
      remainingMinor: remaining,
      expectedMinor: expected,
      neededPerMonthMinor: neededPerMonth(remaining, today, targetOn),
      pace: paceOf(savedMinor, targetMinor, expected),
    );
  }

  final int savedMinor;
  final int targetMinor;

  /// Whole percent saved, floored; may pass 100.
  final int percent;
  final int remainingMinor;

  /// Where a steady saver would be today; null without a date.
  final int? expectedMinor;
  final int? neededPerMonthMinor;
  final GoalPace pace;

  /// 0 to 1 (more once past the target), for a ring.
  double get fraction => targetMinor <= 0 ? 0 : math.max(savedMinor, 0) / targetMinor;

  /// Where the ring should be today, for the ghost arc; null without a date.
  double? get expectedFraction => expectedMinor == null || targetMinor <= 0 ? null : expectedMinor! / targetMinor;

  /// How far below the steady line; zero when level or above it.
  int get behindMinor => expectedMinor == null ? 0 : math.max(expectedMinor! - savedMinor, 0);

  bool get isReached => pace == GoalPace.reached;

  /// The next quarter still to pass, or null once the target is reached.
  int? get nextMilestone {
    for (final mark in goalMilestones) {
      if (percent < mark) return mark;
    }
    return null;
  }

  /// How much more until [nextMilestone].
  int get toNextMilestoneMinor {
    final mark = nextMilestone;
    if (mark == null) return 0;
    return math.max((targetMinor * mark / 100).ceil() - savedMinor, 0);
  }
}

/// Money in or out of a goal: one leg of a transfer, seen from the goal.
class GoalMove {
  const GoalMove({
    required this.id,
    required this.day,
    required this.amountMinor,
    this.otherAccountId,
    this.otherAccountName,
    this.note = '',
    this.source = 'manual',
    this.transferGroupId,
  });

  final String id;
  final DateTime day;

  /// Positive: put in. Negative: taken out.
  final int amountMinor;

  /// The account on the other side of the transfer.
  final String? otherAccountId;
  final String? otherAccountName;
  final String note;

  /// 'recurring' when a schedule put it in.
  final String source;
  final String? transferGroupId;

  bool get isIn => amountMinor > 0;
}

/// One month of a goal: what went in, less what came out.
class GoalMonth {
  const GoalMonth(this.month, this.inMinor, this.outMinor);

  final DateTime month;
  final int inMinor;

  /// Positive.
  final int outMinor;

  int get netMinor => inMinor - outMinor;
}

/// What a goal's history says: the line it drew, its months, its pace and where it is heading.
class GoalStats {
  GoalStats._({
    required this.cumulative,
    required this.months,
    required this.averagePerMonthMinor,
    required this.streak,
    required this.milestoneDays,
    required this.sources,
    required this.sourceIds,
    required this.projectedFinish,
    required this.remainingMinor,
    required this.today,
    required this.startMonth,
    required this.tooEarly,
  });

  /// [moves] in any order. [months] is how many months the bar chart shows, ending with today's.
  factory GoalStats.of({
    required List<GoalMove> moves,
    required int targetMinor,
    required DateTime createdOn,
    required DateTime today,
    int months = 6,
  }) {
    final sorted = [...moves]..sort((a, b) => a.day.compareTo(b.day));
    final now = dayOf(today);

    // The balance after each day that money moved
    final cumulative = <(DateTime, int)>[];
    final milestoneDays = <int, DateTime>{};
    var running = 0;
    for (final move in sorted) {
      final before = running;
      running += move.amountMinor;
      final day = dayOf(move.day);
      if (cumulative.isNotEmpty && cumulative.last.$1 == day) {
        cumulative[cumulative.length - 1] = (day, running);
      } else {
        cumulative.add((day, running));
      }
      final from = targetMinor <= 0 ? 0 : math.max(before, 0) * 100 ~/ targetMinor;
      final to = targetMinor <= 0 ? 0 : math.max(running, 0) * 100 ~/ targetMinor;
      // A mark passed again after a dip carries the new day; one fallen back below is no longer held
      for (final mark in marksCrossed(from, to)) {
        milestoneDays[mark] = day;
      }
      milestoneDays.removeWhere((mark, _) => to < mark);
    }

    // Month by month, oldest first
    final first = DateTime.utc(now.year, now.month - months + 1);
    final ins = List.filled(months, 0), outs = List.filled(months, 0);
    for (final move in sorted) {
      final index = (move.day.year - first.year) * 12 + move.day.month - first.month;
      if (index < 0 || index >= months) continue;
      if (move.isIn) {
        ins[index] += move.amountMinor;
      } else {
        outs[index] -= move.amountMinor;
      }
    }
    final monthly = [
      for (var i = 0; i < months; i++) GoalMonth(DateTime.utc(first.year, first.month + i), ins[i], outs[i]),
    ];

    // Months in a row with more put in than taken out, counting back from this
    // month; a month just begun with nothing in yet does not break the run
    final byMonth = <int, int>{};
    for (final move in sorted) {
      final key = move.day.year * 12 + move.day.month;
      byMonth[key] = (byMonth[key] ?? 0) + move.amountMinor;
    }
    var key = now.year * 12 + now.month;
    if ((byMonth[key] ?? 0) <= 0) key--;
    var streak = 0;
    while ((byMonth[key] ?? 0) > 0) {
      streak++;
      key--;
    }

    // The pace of the last three months, or of the goal's whole life when younger.
    // Under a month old it is what went in so far: one day's saving is not stretched to a month's.
    final age = daysBetween(createdOn, now) + 1;
    final window = math.min(90, age);
    final since = now.subtract(Duration(days: window - 1));
    final recent = sorted.where((move) => !dayOf(move.day).isBefore(since)).fold<int>(0, (s, m) => s + m.amountMinor);
    final perMonth = (recent * daysPerMonth / math.max(window, daysPerMonth)).round();

    final remaining = math.max(targetMinor - running, 0);
    final tooEarly = age < forecastAfterDays;
    final finish = remaining == 0 || tooEarly ? null : finishAt(remaining, perMonth, now);

    final sources = <String, int>{};
    final byAccount = <String, int>{};
    for (final move in sorted.where((move) => move.isIn)) {
      final name = move.otherAccountName ?? '';
      sources[name] = (sources[name] ?? 0) + move.amountMinor;
      if (move.otherAccountId != null) byAccount[move.otherAccountId!] = (byAccount[move.otherAccountId!] ?? 0) + move.amountMinor;
    }

    return GoalStats._(
      cumulative: cumulative,
      months: monthly,
      averagePerMonthMinor: perMonth,
      streak: streak,
      milestoneDays: milestoneDays,
      sources: Map.fromEntries(sources.entries.toList()..sort((a, b) => b.value.compareTo(a.value))),
      sourceIds: [for (final entry in byAccount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))) entry.key],
      projectedFinish: finish,
      remainingMinor: remaining,
      today: now,
      startMonth: DateTime.utc(createdOn.year, createdOn.month),
      tooEarly: tooEarly,
    );
  }

  /// The day the target is reached putting [perMonthMinor] in each month; null when that is nothing.
  static DateTime? finishAt(int remainingMinor, int perMonthMinor, DateTime today) {
    if (remainingMinor <= 0) return dayOf(today);
    if (perMonthMinor <= 0) return null;
    final days = (remainingMinor / perMonthMinor * daysPerMonth).ceil();
    // Beyond a lifetime is no forecast
    if (days > 365 * 100) return null;
    return dayOf(today).add(Duration(days: days));
  }

  /// The saved amount after each day money moved, oldest first.
  final List<(DateTime, int)> cumulative;
  final List<GoalMonth> months;

  /// Recent pace, net of what was taken out.
  final int averagePerMonthMinor;

  /// Months in a row with more put in than taken out.
  final int streak;

  /// The day each quarter of the way still held was passed; a mark given back by a withdrawal is left out.
  final Map<int, DateTime> milestoneDays;

  /// What each account has put in, biggest first. Keyed by account name.
  final Map<String, int> sources;

  /// The accounts that put money in, the biggest first.
  final List<String> sourceIds;

  /// The month the goal was started in.
  final DateTime startMonth;

  /// Too young for a forecast: [projectedFinish] waits for [forecastAfterDays] of history.
  final bool tooEarly;

  /// [months] from the one the goal was started in: no empty bars from before it existed.
  List<GoalMonth> get monthsSinceStart => [
        for (final month in months)
          if (!month.month.isBefore(startMonth)) month,
      ];

  /// At the recent pace; null when it is reached or nothing is going in.
  final DateTime? projectedFinish;
  final int remainingMinor;
  final DateTime today;

  /// Days the forecast lands before [targetOn]; negative when after it.
  int? daysEarly(DateTime? targetOn) {
    final finish = projectedFinish;
    if (finish == null || targetOn == null) return null;
    return daysBetween(finish, targetOn);
  }

  /// The month that put in the most, net.
  GoalMonth? get bestMonth {
    GoalMonth? best;
    for (final month in months) {
      if (month.netMinor > 0 && (best == null || month.netMinor > best.netMinor)) best = month;
    }
    return best;
  }
}

/// Splits a monthly amount into weekly and daily, for "≈ ৳2,800/month · ৳650/week · ৳95/day".
(int, int) weeklyAndDaily(int perMonthMinor) =>
    ((perMonthMinor * 7 / daysPerMonth).ceil(), (perMonthMinor / daysPerMonth).ceil());
