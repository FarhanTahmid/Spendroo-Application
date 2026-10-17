import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/db/database.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../personal/ledger_repository.dart';
import 'widget_snapshot.dart';
import 'widget_snapshot_builder.dart';

/// Today's date, moving on at midnight while the app is open. The widget's
/// figures are always for the real today, whatever month the app is browsing.
class WidgetDayController extends Notifier<DateTime> {
  Timer? _midnight;

  @override
  DateTime build() {
    ref.onDispose(() => _midnight?.cancel());
    _arm();
    return _today();
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void _arm() {
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight?.cancel();
    // A second late, so the new day has surely begun
    _midnight = Timer(next.difference(now) + const Duration(seconds: 1), () {
      state = _today();
      _arm();
    });
  }
}

final widgetDayProvider = NotifierProvider<WidgetDayController, DateTime>(WidgetDayController.new);

/// The widget always shows the personal workspace, even while a business is open.
final widgetWorkspaceProvider = Provider<Workspace?>((ref) {
  final workspaces = ref.watch(workspacesProvider).value ?? const <Workspace>[];
  for (final workspace in workspaces) {
    if (workspace.kind == 'personal') return workspace;
  }
  return null;
});

/// Spent per day of the month: (workspace, currency, month).
final widgetDailySpendProvider = StreamProvider.family<Map<int, int>, (String, String, DateTime)>(
  (ref, key) => ref.watch(ledgerRepositoryProvider).watchDailySpend(key.$1, key.$3, key.$2),
);

/// The month's income and spending: (workspace, currency, month).
final widgetMonthProvider = StreamProvider.family<MonthSummary, (String, String, DateTime)>(
  (ref, key) => ref.watch(ledgerRepositoryProvider).watchMonth(key.$1, key.$3, key.$2),
);

/// Budgets in force in a month: (workspace, month).
final widgetBudgetsProvider = StreamProvider.family<List<BudgetProgress>, (String, DateTime)>(
  (ref, key) => ref.watch(ledgerRepositoryProvider).watchBudgets(key.$1, key.$2),
);

/// What the widget should show now; null while something is still loading,
/// so a half-read ledger never reaches the home screen.
final homeWidgetSnapshotProvider = Provider<HomeWidgetSnapshot?>((ref) {
  final l10n = lookupAppLocalizations(ref.watch(localeProvider));
  final auth = ref.watch(authControllerProvider);
  if (!auth.ready) return null;
  if (auth.step != AuthStep.signedIn) return signedOutSnapshot(l10n);

  final workspace = ref.watch(widgetWorkspaceProvider);
  if (workspace == null) return null;
  final day = ref.watch(widgetDayProvider);
  final month = DateTime(day.year, day.month);
  final currency = workspace.defaultCurrency;

  final plan = ref.watch(entitlementsProvider);
  final daily = ref.watch(widgetDailySpendProvider((workspace.id, currency, month)));
  final summary = ref.watch(widgetMonthProvider((workspace.id, currency, month)));
  final budgets = ref.watch(widgetBudgetsProvider((workspace.id, month)));
  // A plan that failed to load locks nothing, as everywhere else in the app
  if (plan.isLoading && !plan.hasValue) return null;
  if (!daily.hasValue || !summary.hasValue || !budgets.hasValue) return null;

  return buildWidgetSnapshot(
    inputs: WidgetInputs(
      currency: currency,
      dailySpend: daily.value!,
      incomeMinor: summary.value!.incomeMinor,
      budgets: budgets.value!,
    ),
    plan: plan.value,
    l10n: l10n,
    now: day,
  );
});
