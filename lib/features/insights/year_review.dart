import 'dart:math' as math;

import '../personal/ledger_repository.dart';

/// How many categories the review ranks.
const reviewTopCategories = 5;

/// The first year the review offers, as the server's (ledger_personal/year_review.py).
const reviewFirstYear = 2000;

/// Whole percent of [whole], rounded half away from zero; null when there is
/// nothing to compare with. The server rounds the same way.
int? reviewPercent(int part, int whole) => whole == 0 ? null : (part * 100 / whole).round();

/// Percentage change from [before] to [now]; null when there was nothing before.
int? reviewChange(int now, int before) => before == 0 ? null : ((now - before) * 100 / before.abs()).round();

/// In January last year is the one worth looking back on; otherwise this one so far.
int defaultReviewYear(DateTime today) => today.month == 1 ? today.year - 1 : today.year;

/// The years there is anything to look back on, newest first: from the year of
/// the first transaction (this year without any) to this year. The default year
/// is always among them.
List<int> reviewYears(DateTime? firstDay, DateTime today) {
  final first = math.max(reviewFirstYear, math.min(firstDay?.year ?? today.year, defaultReviewYear(today)));
  return [for (var year = today.year; year >= first; year--) year];
}

/// One month picked out for an amount: spent, or kept.
class ReviewMonth {
  const ReviewMonth(this.month, this.amountMinor);

  final DateTime month;
  final int amountMinor;

  @override
  bool operator ==(Object other) => other is ReviewMonth && other.month == month && other.amountMinor == amountMinor;

  @override
  int get hashCode => Object.hash(month, amountMinor);

  @override
  String toString() => 'ReviewMonth(${monthKey(month)}, $amountMinor)';
}

/// A year looked back on. Worked out as the server does
/// (ledger_personal/year_review.py); the two must give the same answer:
///
/// - A month is "closed" once it is over. Ranking months and the monthly
///   average look at closed months only, so a month still under way never
///   reads as the smallest.
/// - Closed months are "tracked" from the month of the workspace's first
///   transaction: the average and the months in the green leave out months
///   from before anything was recorded.
/// - Transfers are neither income nor expense; each part of a split counts
///   under its own category.
class YearReview {
  const YearReview({
    required this.year,
    required this.isPartial,
    required this.months,
    required this.closedMonths,
    required this.trackedMonths,
    required this.incomeMinor,
    required this.expenseMinor,
    required this.previousIncomeMinor,
    required this.previousExpenseMinor,
    required this.hasPrevious,
    required this.biggestMonth,
    required this.smallestMonth,
    required this.bestMonth,
    required this.monthsInGreen,
    required this.averageExpenseMinor,
    required this.largestExpenseMinor,
    required this.categories,
    required this.goalsReached,
  });

  /// [months] holds the 24 months from January of the year before to December
  /// of [year], oldest first (watchMonthlyTotals); [summary] is the year by
  /// category, each carrying what it took the year before (watchYear);
  /// [since] is the day of the workspace's first transaction.
  factory YearReview.of({
    required int year,
    required DateTime today,
    required List<MonthTotals> months,
    required MonthSummary summary,
    required DateTime? since,
    int goalsReached = 0,
  }) {
    assert(months.length == 24, 'two years of months');
    final before = months.take(12).toList(), these = months.skip(12).toList();
    int sum(Iterable<int> values) => values.fold(0, (a, b) => a + b);
    final closedCount = year < today.year ? 12 : (year == today.year ? today.month - 1 : 0);
    final closed = these.take(closedCount).toList();
    final start = since == null ? null : DateTime(since.year, since.month);
    final tracked = start == null ? <MonthTotals>[] : closed.where((m) => !m.month.isBefore(start)).toList();

    final spent = closed.where((m) => m.expenseMinor > 0).toList();
    final saving = tracked.where((m) => m.incomeMinor - m.expenseMinor > 0).toList();
    ReviewMonth? ranked(List<MonthTotals> from, int Function(MonthTotals) measure, {required bool largest}) {
      if (from.isEmpty) return null;
      final values = from.map(measure);
      final best = largest ? values.reduce(math.max) : values.reduce(math.min);
      // The earliest wins a tie
      final month = from.firstWhere((m) => measure(m) == best);
      return ReviewMonth(month.month, best);
    }

    final previousIncome = sum(before.map((m) => m.incomeMinor));
    final previousExpense = sum(before.map((m) => m.expenseMinor));
    return YearReview(
      year: year,
      isPartial: year == today.year,
      months: these,
      closedMonths: closedCount,
      trackedMonths: tracked.length,
      incomeMinor: sum(these.map((m) => m.incomeMinor)),
      expenseMinor: sum(these.map((m) => m.expenseMinor)),
      previousIncomeMinor: previousIncome,
      previousExpenseMinor: previousExpense,
      hasPrevious: previousIncome != 0 || previousExpense != 0,
      biggestMonth: ranked(spent, (m) => m.expenseMinor, largest: true),
      smallestMonth: spent.length > 1 ? ranked(spent, (m) => m.expenseMinor, largest: false) : null,
      bestMonth: ranked(saving, (m) => m.incomeMinor - m.expenseMinor, largest: true),
      monthsInGreen: saving.length,
      averageExpenseMinor: tracked.isEmpty ? null : sum(tracked.map((m) => m.expenseMinor)) ~/ tracked.length,
      largestExpenseMinor: summary.byCategory.fold(0, (a, c) => math.max(a, c.largestMinor)),
      categories: summary.byCategory,
      goalsReached: goalsReached,
    );
  }

  final int year;

  /// This year, still under way.
  final bool isPartial;

  /// January to December, empty months included.
  final List<MonthTotals> months;

  /// How many of [months] are over.
  final int closedMonths;

  /// How many of those came after the first transaction.
  final int trackedMonths;

  final int incomeMinor;
  final int expenseMinor;
  final int previousIncomeMinor;
  final int previousExpenseMinor;

  /// Whether the year before has anything to compare with.
  final bool hasPrevious;

  /// The closed month that spent most, and of two or more that spent anything, least.
  final ReviewMonth? biggestMonth;
  final ReviewMonth? smallestMonth;

  /// The closed month that kept most of its income.
  final ReviewMonth? bestMonth;

  /// Tracked months with more in than out.
  final int monthsInGreen;

  /// Spent per tracked month; null before the first is over.
  final int? averageExpenseMinor;

  /// The biggest single expense, or part of a split.
  final int largestExpenseMinor;

  /// Every category spent in, largest first.
  final List<CategorySpend> categories;

  /// Savings goals that reached their target this year.
  final int goalsReached;

  int get netMinor => incomeMinor - expenseMinor;
  int get previousNetMinor => previousIncomeMinor - previousExpenseMinor;

  /// Net as a whole percent of income; null without income.
  int? get savingsRate => incomeMinor > 0 ? reviewPercent(netMinor, incomeMinor) : null;

  List<CategorySpend> get topCategories => categories.take(reviewTopCategories).toList();

  /// Changes on the year before; null each when there is nothing to compare with.
  int? get incomeChange => hasPrevious ? reviewChange(incomeMinor, previousIncomeMinor) : null;
  int? get expenseChange => hasPrevious ? reviewChange(expenseMinor, previousExpenseMinor) : null;
  int? get netChange => hasPrevious ? reviewChange(netMinor, previousNetMinor) : null;

  /// Nothing came in or went out all year.
  bool get isEmpty => incomeMinor == 0 && expenseMinor == 0;

  /// Whether [month] (one of [months]) is still to come or under way.
  bool isOpen(DateTime month) => months.indexWhere((m) => m.month == month) >= closedMonths;
}
