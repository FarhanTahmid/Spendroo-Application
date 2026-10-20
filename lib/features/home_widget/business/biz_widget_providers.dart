import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_repository.dart';
import '../../../core/db/database.dart';
import '../../../core/entitlements/entitlements_controller.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../cashbook/cashbook_repository.dart';
import '../../personal/ledger_repository.dart' show isoDate;
import '../home_widget_providers.dart' show widgetDayProvider;
import 'biz_queries.dart';
import 'biz_snapshot.dart';
import 'biz_snapshot_builder.dart';

/// (workspace, from, to) -> book -> day -> money in and out.
final bizDailyProvider = StreamProvider.family<Map<String, Map<String, DayFlow>>, (String, String, String)>(
  (ref, key) => ref.watch(bizWidgetQueriesProvider).watchDaily(key.$1, key.$2, key.$3),
);

/// (workspace, today) -> book -> its latest entry date.
final bizLastEntryProvider = StreamProvider.family<Map<String, String>, (String, String)>(
  (ref, key) => ref.watch(bizWidgetQueriesProvider).watchLastEntry(key.$1, key.$2),
);

/// (workspace, from, to) -> book -> category -> cash out.
final bizCategoryOutProvider = StreamProvider.family<Map<String, Map<String, int>>, (String, String, String)>(
  (ref, key) => ref.watch(bizWidgetQueriesProvider).watchCategoryOut(key.$1, key.$2, key.$3),
);

/// (workspace, from, to) -> book -> its largest cash out.
final bizBiggestOutProvider = StreamProvider.family<Map<String, BigOut>, (String, String, String)>(
  (ref, key) => ref.watch(bizWidgetQueriesProvider).watchBiggestOut(key.$1, key.$2, key.$3),
);

/// (workspace, today) -> book -> its latest entries.
final bizRecentProvider = StreamProvider.family<Map<String, List<RecentEntry>>, (String, String)>(
  (ref, key) => ref.watch(bizWidgetQueriesProvider).watchRecent(key.$1, key.$2),
);

/// Book -> the signed-in member's grant role on it.
final bizGrantsProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(bizWidgetQueriesProvider).watchGrants(),
);

/// The facts for every book of [workspace]; null while any of them is still loading.
List<BookFacts>? _booksOf(Ref ref, Workspace workspace, DateTime today, Map<String, String> grants) {
  final plan = ref.watch(entitlementsProvider).value;
  final todayIso = isoDate(today);
  final from = isoDate(bizWindowStart(today));
  final monthStart = isoDate(DateTime(today.year, today.month));
  final weekStart = isoDate(DateTime(today.year, today.month, today.day - 6));

  final books = ref.watch(cashbooksProvider(workspace.id));
  final daily = ref.watch(bizDailyProvider((workspace.id, from, todayIso)));
  final last = ref.watch(bizLastEntryProvider((workspace.id, todayIso)));
  final categories = ref.watch(bizCategoryOutProvider((workspace.id, monthStart, todayIso)));
  final biggest = ref.watch(bizBiggestOutProvider((workspace.id, weekStart, todayIso)));
  final recent = ref.watch(bizRecentProvider((workspace.id, todayIso)));
  if (!books.hasValue ||
      !daily.hasValue ||
      !last.hasValue ||
      !categories.hasValue ||
      !biggest.hasValue ||
      !recent.hasValue) {
    return null;
  }
  return [
    for (final summary in books.value!)
      BookFacts(
        book: summary.book,
        balanceMinor: summary.balanceMinor,
        entryCount: summary.entryCount,
        daily: daily.value![summary.book.id] ?? const {},
        // A book locked after a downgrade is read-only, as in the app
        canAdd:
            bookPermission(workspace.role, grants[summary.book.id]) != 'view' &&
            !(plan?.isLocked(summary.book.id) ?? false),
        lastEntry: last.value![summary.book.id],
        monthCategories: categories.value![summary.book.id] ?? const {},
        weekBiggest: biggest.value![summary.book.id],
        recent: recent.value![summary.book.id] ?? const [],
      ),
  ];
}

/// Everything the business and cashbook widgets should show now, or null while
/// something is still loading, so a half-read ledger never reaches the home screen.
final bizWidgetPublicationProvider = Provider<BizPublication?>((ref) {
  final l10n = lookupAppLocalizations(ref.watch(localeProvider));
  final auth = ref.watch(authControllerProvider);
  if (!auth.ready) return null;
  if (auth.step != AuthStep.signedIn) return BizPublication(signedOutBizCatalog(l10n), const {});

  final workspaces = ref.watch(workspacesProvider);
  final plan = ref.watch(entitlementsProvider);
  final grants = ref.watch(bizGrantsProvider);
  // A plan that failed to load locks nothing, as everywhere else in the app
  if (!workspaces.hasValue || !grants.hasValue || (plan.isLoading && !plan.hasValue)) return null;
  final today = ref.watch(widgetDayProvider);

  final businesses = <(Workspace, List<BookFacts>)>[];
  for (final workspace in workspaces.value!.where((w) => w.kind == 'business')) {
    final books = _booksOf(ref, workspace, today, grants.value!);
    if (books == null) return null;
    businesses.add((workspace, books));
  }

  final snapshots = <String, BizSnapshot>{};
  for (final (workspace, books) in businesses) {
    snapshots[BizKeys.business(workspace.id)] = buildBusinessSnapshot(
      workspace: workspace,
      books: books,
      l10n: l10n,
      today: today,
    );
    for (final book in books) {
      snapshots[BizKeys.book(book.book.id)] = buildBookSnapshot(
        workspace: workspace,
        facts: book,
        l10n: l10n,
        today: today,
      );
    }
  }
  return BizPublication(buildBizCatalog(businesses: businesses, plan: plan.value, l10n: l10n, today: today), snapshots);
});
