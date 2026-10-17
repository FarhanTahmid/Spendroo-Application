import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../goals/goals_repository.dart';
import '../personal/ledger_repository.dart';
import 'year_review.dart';

/// Today, for the review. Tests fix it.
final reviewTodayProvider = Provider<DateTime>((ref) => DateTime.now());

/// The year the review shows; null shows [defaultReviewYear].
class ReviewYearController extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int year) => state = year;
}

final reviewYearProvider = NotifierProvider<ReviewYearController, int?>(ReviewYearController.new);

/// The years a workspace can look back on, newest first.
final reviewYearsProvider = StreamProvider.family<List<int>, String>((ref, workspaceId) {
  final today = ref.watch(reviewTodayProvider);
  return ref
      .watch(ledgerRepositoryProvider)
      .watchFirstTransactionDay(workspaceId)
      .map((first) => reviewYears(first, today));
});

/// Workspace, currency and year.
typedef ReviewKey = (String, String, int);

/// January of the year before to December of the year.
final _reviewMonthsProvider = StreamProvider.family<List<MonthTotals>, ReviewKey>(
  (ref, key) => ref.watch(ledgerRepositoryProvider).watchMonthlyTotals(key.$1, DateTime(key.$3, 12), key.$2, count: 24),
);

final _reviewSummaryProvider = StreamProvider.family<MonthSummary, ReviewKey>(
  (ref, key) => ref.watch(ledgerRepositoryProvider).watchYear(key.$1, key.$3, key.$2),
);

/// The year looked back on, worked out from the phone's own copy of the data.
final yearReviewProvider = Provider.family<AsyncValue<YearReview>, ReviewKey>((ref, key) {
  final months = ref.watch(_reviewMonthsProvider(key));
  final summary = ref.watch(_reviewSummaryProvider(key));
  final goals = ref.watch(goalsProvider(key.$1)).value ?? const <GoalView>[];
  if (months.hasError) return AsyncError(months.error!, months.stackTrace ?? StackTrace.current);
  if (summary.hasError) return AsyncError(summary.error!, summary.stackTrace ?? StackTrace.current);
  final (monthly, total) = (months.value, summary.value);
  if (monthly == null || total == null) return const AsyncLoading();
  // The server stamps reached_at in the workspace's day, so its year leads the text
  final reached = goals.where((g) => g.goal.reachedAt?.startsWith('${key.$3}') ?? false).length;
  return AsyncData(
    YearReview.of(
      year: key.$3,
      today: ref.watch(reviewTodayProvider),
      months: monthly,
      summary: total,
      goalsReached: reached,
    ),
  );
});
