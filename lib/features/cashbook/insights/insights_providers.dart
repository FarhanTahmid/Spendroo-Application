import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/entitlements/entitlements.dart';
import '../../../core/ui.dart';
import '../../personal/ledger_repository.dart';
import '../../plan/upgrade_sheet.dart';
import '../../team/team_roles.dart';
import 'insights_repository.dart';

/// The period a book's or a business's insights show, kept for each of them
/// (keyed by the book's or the business's id) while the app runs.
class InsightsPeriodController extends Notifier<InsightsPeriod> {
  InsightsPeriodController(this.scopeId);

  final String scopeId;

  @override
  InsightsPeriod build() {
    final now = DateTime.now();
    return InsightsPeriod.month(DateTime(now.year, now.month));
  }

  void month(DateTime month) => state = InsightsPeriod.month(DateTime(month.year, month.month));

  void range(InsightsRange range) => state = InsightsPeriod.range(range, state.month);

  /// Back to the month the range was chosen from.
  void clearRange() => state = InsightsPeriod.month(state.month);
}

final insightsPeriodProvider =
    NotifierProvider.family<InsightsPeriodController, InsightsPeriod, String>(InsightsPeriodController.new);

typedef ScopedPeriod = (InsightsScope, InsightsPeriod);

final periodFlowProvider = StreamProvider.autoDispose.family<PeriodFlow, ScopedPeriod>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchFlow(key.$1, key.$2),
);

/// Keyed by scope, the month the trend ends with, and how many months.
final insightsMonthlyProvider = StreamProvider.autoDispose.family<List<MonthTotals>, (InsightsScope, DateTime, int)>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchMonthly(key.$1, key.$2, count: key.$3),
);

final categorySplitProvider = StreamProvider.autoDispose.family<List<SplitRow>, ScopedPeriod>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchSplit(key.$1, key.$2, byCategory: true),
);

final paymentSplitProvider = StreamProvider.autoDispose.family<List<SplitRow>, ScopedPeriod>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchSplit(key.$1, key.$2, byCategory: false),
);

/// Keyed by scope, period and entry type.
final topEntriesProvider = StreamProvider.autoDispose.family<List<TopEntry>, (InsightsScope, InsightsPeriod, String)>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchTopEntries(key.$1, key.$2, key.$3),
);

final memberFlowProvider = StreamProvider.autoDispose.family<List<MemberFlow>, ScopedPeriod>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchByMember(key.$1, key.$2),
);

final billCoverageProvider = StreamProvider.autoDispose.family<BillCoverage, ScopedPeriod>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchBillCoverage(key.$1, key.$2),
);

/// Keyed by book, field and period.
final fieldSplitProvider = StreamProvider.autoDispose.family<List<SplitRow>, (String, String, InsightsPeriod)>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchFieldSplit(key.$1, key.$2, key.$3),
);

final fieldSumProvider =
    StreamProvider.autoDispose.family<({double inSum, double outSum, int count}), (String, String, InsightsPeriod)>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchFieldSum(key.$1, key.$2, key.$3),
);

/// Keyed by business, currency and period.
final bookStandingsProvider = StreamProvider.autoDispose.family<List<BookStanding>, (String, String, InsightsPeriod)>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchBooks(key.$1, key.$2, key.$3),
);

final otherCurrencyBooksProvider = StreamProvider.autoDispose.family<int, (String, String)>(
  (ref, key) => ref.watch(insightsRepositoryProvider).watchOtherCurrencyBooks(key.$1, key.$2),
);

/// The charts beyond the basics wait for the Business plan ([F.insightsBusinessAdvanced]).
bool advancedLocked(WidgetRef ref, Workspace workspace) => featureLocked(ref, workspace, F.insightsBusinessAdvanced);

/// Who did what is the owner's and the admins' to see.
bool seesTeam(Workspace workspace) => !workspace.isDemo && TeamRole.isManager(workspace.role);

/// Asks for days in place of a month. A plan feature: without it the upgrade sheet says so.
Future<void> pickInsightsRange(BuildContext context, WidgetRef ref, Workspace workspace, String scopeId) async {
  HapticFeedback.selectionClick();
  if (!await unlockFeature(context, ref, workspace, F.insightsCustomRange) || !context.mounted) return;
  final period = ref.read(insightsPeriodProvider(scopeId));
  final now = DateTime.now();
  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: now.add(const Duration(days: 365)),
    initialDateRange: DateTimeRange(start: period.start, end: period.end),
  );
  if (picked != null) ref.read(insightsPeriodProvider(scopeId).notifier).range(InsightsRange.of(picked.start, picked.end));
}
