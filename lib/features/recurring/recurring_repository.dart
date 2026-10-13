import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/local_store.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/entitlements/plan_guard.dart';
import '../../core/providers.dart';
import '../personal/allocations.dart';
import '../personal/ledger_repository.dart' show isoDate;
import 'recurrence.dart';

const reminderKind = 'reminder';

/// The device setting holding the day weeks start on (Monday as 0); new rules copy it.
const weekStartKey = 'week_start';
const defaultWeekStart = 5;

/// A rule with the names its row shows.
class RuleView {
  RuleView(this.rule, {this.accountName, this.toAccountName, this.categoryName, this.categoryColor});

  final RecurringRule rule;
  final String? accountName;
  final String? toAccountName;
  final String? categoryName;
  final String? categoryColor;

  bool get isReminder => rule.kind == reminderKind;

  /// What to call it: its title, else its note, else its category.
  String get label =>
      rule.title.isNotEmpty ? rule.title : (rule.note.isNotEmpty ? rule.note : (categoryName ?? ''));

  /// When it falls due next: the server's answer, or before the first sync the app's own.
  String? nextDue(DateTime today) {
    if (rule.isPaused) return null;
    if (rule.nextDueOn != null) return rule.nextDueOn;
    if (rule.version > 0) return null; // the server has spoken: nothing more is coming
    final next = nextOnOrAfter(Schedule.of(rule), DateTime.utc(today.year, today.month, today.day));
    return next == null ? null : isoDate(next);
  }
}

/// One date of a rule, with the rule it belongs to.
class OccurrenceView {
  OccurrenceView(this.occurrence, this.rule);

  final RecurringOccurrence occurrence;
  final RuleView rule;

  bool get isDue => occurrence.status == 'due';
}

/// What the rule form holds. Amounts are positive, as typed.
class RuleDraft {
  RuleDraft({
    required this.kind,
    required this.freq,
    required this.startOn,
    this.title = '',
    this.accountId,
    this.toAccountId,
    this.categoryId,
    this.amountMinor,
    this.note = '',
    this.splits = const [],
    this.interval = 1,
    this.weekdayMask = 0,
    this.monthDay,
    this.setPos,
    this.weekStart = defaultWeekStart,
    this.endOn,
    this.maxCount,
    this.mode = 'confirm',
    this.remindDaysBefore = 0,
    this.remindAt,
    this.isPaused = false,
  });

  final String kind;
  final String title;
  final String? accountId;
  final String? toAccountId;
  final String? categoryId;
  final int? amountMinor;
  final String note;
  final List<SplitPart> splits;
  final String freq;
  final int interval;
  final int weekdayMask;
  final int? monthDay;
  final int? setPos;
  final int weekStart;
  final String startOn;
  final String? endOn;
  final int? maxCount;
  final String mode;
  final int remindDaysBefore;

  /// HH:mm:ss, or null for the usual reminder time.
  final String? remindAt;
  final bool isPaused;

  bool get isReminder => kind == reminderKind;

  /// Columns as the server takes them.
  Map<String, Object?> toRow() => {
        'kind': kind,
        'title': title,
        'account_id': accountId,
        'to_account_id': toAccountId,
        // A split has no category of its own
        'category_id': splits.isEmpty ? categoryId : null,
        'amount_minor': amountMinor,
        'note': note,
        'splits': SplitPart.encode(splits),
        'freq': freq,
        'interval': interval,
        'weekday_mask': weekdayMask,
        'month_day': monthDay,
        'set_pos': setPos,
        'week_start': weekStart,
        'start_on': startOn,
        'end_on': endOn,
        'max_count': maxCount,
        // There is nothing for the server to record for a reminder
        'mode': isReminder ? 'confirm' : mode,
        'remind_days_before': remindDaysBefore,
        'remind_at': remindAt,
        'is_paused': isPaused,
      };
}

class RecurringRepository {
  RecurringRepository(this.db, this.store, [this.plan]);

  final AppDatabase db;
  final LocalStore store;

  /// Refuses what the plan does not allow before anything is written.
  final PlanGuard? plan;

  static const _ruleNames =
      'a.name AS a_name, ta.name AS ta_name, c.name AS c_name, c.color AS c_color FROM recurring_rules r '
      'LEFT JOIN accounts a ON a.id = r.account_id '
      'LEFT JOIN accounts ta ON ta.id = r.to_account_id '
      'LEFT JOIN categories c ON c.id = r.category_id AND c.deleted_at IS NULL ';

  RuleView _rule(QueryRow row) => RuleView(
        db.recurringRules.map(row.data),
        accountName: row.readNullable<String>('a_name'),
        toAccountName: row.readNullable<String>('ta_name'),
        categoryName: row.readNullable<String>('c_name'),
        categoryColor: row.readNullable<String>('c_color'),
      );

  /// Every rule of the workspace: those still running first, by when they fall due next.
  Stream<List<RuleView>> watchRules(String workspaceId) => db
      .customSelect(
        'SELECT r.*, $_ruleNames'
        'WHERE r.workspace_id = ? AND r.deleted_at IS NULL '
        'ORDER BY r.is_paused, r.next_due_on IS NULL, r.next_due_on, r.created_at',
        variables: [Variable<String>(workspaceId)],
        readsFrom: {db.recurringRules, db.accounts, db.categories},
      )
      .watch()
      .map((rows) => rows.map(_rule).toList());

  /// What is waiting to be answered, and what comes up to [until] (ISO date), soonest first.
  Stream<List<OccurrenceView>> watchOpen(String workspaceId, {String? until}) => db
      .customSelect(
        // The occurrence's columns under an "o." prefix, beside the rule's own
        'SELECT ${[
          for (final column in db.recurringOccurrences.$columns) 'o.${column.name} AS "o.${column.name}"',
        ].join(', ')}, '
        'r.*, $_ruleNames'
        'JOIN recurring_occurrences o ON o.rule_id = r.id AND o.deleted_at IS NULL '
        "WHERE r.workspace_id = ? AND r.deleted_at IS NULL AND (o.status = 'due' "
        "OR (o.status = 'upcoming'${until == null ? '' : ' AND o.due_on <= ?'})) "
        'ORDER BY o.due_on, o.created_at',
        variables: [Variable<String>(workspaceId), if (until != null) Variable<String>(until)],
        readsFrom: {db.recurringRules, db.recurringOccurrences, db.accounts, db.categories},
      )
      .watch()
      .map((rows) => [
            for (final row in rows)
              OccurrenceView(db.recurringOccurrences.map(row.data, tablePrefix: 'o'), _rule(row)),
          ]);

  Future<RecurringRule?> rule(String id) =>
      (db.select(db.recurringRules)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<void> _allowed(String workspaceId, String kind) => kind == reminderKind
      ? Future.value()
      // Recording on a schedule is the plan feature; plain reminders are for everyone
      : plan?.require(F.recurringTransactions, workspaceId) ?? Future.value();

  Future<String> addRule(String workspaceId, RuleDraft draft, {required String currency}) async {
    await _allowed(workspaceId, draft.kind);
    if (draft.isReminder && !draft.isPaused) await plan?.roomFor(F.remindersStandalone, workspaceId);
    return store.create('recurring_rules', workspaceId, draft.toRow(), localOnly: {'currency': currency});
  }

  /// Sends only what differs from [original].
  Future<void> updateRule(RecurringRule original, RuleDraft draft) async {
    await _allowed(original.workspaceId, original.kind);
    if (draft.isReminder) {
      // A paused reminder does not count, so bringing one back needs room like a new one
      if (original.isPaused && !draft.isPaused) await plan?.roomFor(F.remindersStandalone, original.workspaceId);
      // A locked reminder can still be paused, which is one way back under the limit
      if (!draft.isPaused) plan?.writable(F.remindersStandalone, original.id);
    }
    final before = _draftOf(original).toRow(), after = draft.toRow();
    await store.update('recurring_rules', original.id, {
      for (final entry in after.entries)
        if (entry.key != 'kind' && !_same(entry.value, before[entry.key])) entry.key: entry.value,
    });
  }

  Future<void> setPaused(RecurringRule rule, bool paused) async {
    await _allowed(rule.workspaceId, rule.kind);
    if (rule.kind == reminderKind && !paused) await plan?.roomFor(F.remindersStandalone, rule.workspaceId);
    await store.update('recurring_rules', rule.id, {'is_paused': paused});
  }

  /// Always allowed: removing things is how a user gets back under a limit.
  Future<void> deleteRule(RecurringRule rule) => store.remove('recurring_rules', rule.id);

  /// Not this time: the rule moves on to its next date.
  Future<void> skip(RecurringOccurrence occurrence) =>
      store.update('recurring_occurrences', occurrence.id, {'status': 'skipped'});

  /// A reminder has nothing to record, so the user says when it is done.
  Future<void> markDone(RecurringOccurrence occurrence) =>
      store.update('recurring_occurrences', occurrence.id, {'status': 'done'});

  /// Nothing more is said about it before [until].
  Future<void> snooze(RecurringOccurrence occurrence, DateTime until) =>
      store.update('recurring_occurrences', occurrence.id, {'snoozed_until': until.toUtc().toIso8601String()});

  Future<int> weekStart() async => int.tryParse(await db.getSetting(weekStartKey) ?? '') ?? defaultWeekStart;

  /// For rules made from now on; one already written keeps the week it was made with.
  Future<void> setWeekStart(int day) => db.setSetting(weekStartKey, '$day');

  static bool _same(Object? a, Object? b) {
    if (a is List && b is List) {
      return a.length == b.length && [for (var i = 0; i < a.length; i++) '${a[i]}' == '${b[i]}'].every((same) => same);
    }
    return a == b;
  }

  static RuleDraft _draftOf(RecurringRule rule) => draftOf(rule);
}

/// The rule as the form would hold it.
RuleDraft draftOf(RecurringRule rule) => RuleDraft(
      kind: rule.kind,
      title: rule.title,
      accountId: rule.accountId,
      toAccountId: rule.toAccountId,
      categoryId: rule.categoryId,
      amountMinor: rule.amountMinor,
      note: rule.note,
      splits: SplitPart.decode(rule.splits),
      freq: rule.freq,
      interval: rule.interval,
      weekdayMask: rule.weekdayMask,
      monthDay: rule.monthDay,
      setPos: rule.setPos,
      weekStart: rule.weekStart,
      startOn: rule.startOn,
      endOn: rule.endOn,
      maxCount: rule.maxCount,
      mode: rule.mode,
      remindDaysBefore: rule.remindDaysBefore,
      remindAt: rule.remindAt,
      isPaused: rule.isPaused,
    );

final recurringRepositoryProvider = Provider<RecurringRepository>(
  (ref) =>
      RecurringRepository(ref.watch(databaseProvider), ref.watch(localStoreProvider), ref.watch(planGuardProvider)),
);

final weekStartProvider = FutureProvider<int>((ref) => ref.watch(recurringRepositoryProvider).weekStart());

final rulesProvider = StreamProvider.family<List<RuleView>, String>(
  (ref, workspaceId) => ref.watch(recurringRepositoryProvider).watchRules(workspaceId),
);

/// What waits to be answered and what comes in the next week.
final openOccurrencesProvider = StreamProvider.family<List<OccurrenceView>, String>((ref, workspaceId) {
  final soon = DateTime.now().add(const Duration(days: 7));
  return ref.watch(recurringRepositoryProvider).watchOpen(workspaceId, until: isoDate(soon));
});
