import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/design/amounts.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/entitlements/plan_guard.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/features/personal/allocations.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';
import 'package:spendroo/core/ui.dart' show todayIso;
import 'package:spendroo/features/recurring/inbox.dart';
import 'package:spendroo/features/recurring/recurrence.dart';
import 'package:spendroo/features/recurring/recurring_pages.dart';
import 'package:spendroo/features/recurring/recurring_repository.dart';
import 'package:spendroo/features/recurring/schedule_editor.dart';

import 'personal_screens_test.dart' show ScreenHarness, workspace;
import 'plan_test.dart' show answer;
import 'test_support.dart';

const ws = 'ws1';

Entitlements planOf(String plan) => Entitlements(
      answer(plan: plan, features: {
        F.recurringTransactions: {'kind': 'flag', 'enabled': plan != 'free'},
        F.remindersStandalone: {'kind': 'limit', 'limit': plan == 'free' ? 3 : null, 'unlimited': plan != 'free'},
      }),
      fetchedAt: DateTime.utc(2026, 10, 10),
    );

/// A date of a rule as the server would send it.
Future<String> serverOccurrence(LocalStore store, String workspaceId, String ruleId, String dueOn, String status) async {
  final id = newId();
  await store.upsertRow('recurring_occurrences', {
    'id': id, 'workspace_id': workspaceId, 'version': 1, 'server_seq': 1,
    'created_at': '2026-10-13T00:00:00Z', 'updated_at': '2026-10-13T00:00:00Z', 'deleted_at': null,
    'rule_id': ruleId, 'due_on': dueOn, 'status': status, 'snoozed_until': null,
  });
  return id;
}

void main() {
  group('rules on the device', () {
    late AppDatabase db;
    late LocalStore store;
    late LedgerRepository ledger;
    late RecurringRepository repo;
    late Account cash;
    late Account bank;
    late String foodId;
    Entitlements? plan;

    setUp(() async {
      db = memoryDatabase();
      store = LocalStore(db);
      plan = null;
      await db.into(db.workspaces).insert(
          const Workspace(id: ws, name: 'Personal', kind: 'personal', defaultCurrency: 'BDT', isDemo: false, role: 'owner'));
      final guard = PlanGuard(db, () => plan);
      ledger = LedgerRepository(db, store, guard);
      repo = RecurringRepository(db, store, guard);
      await ledger.addAccount(ws, name: 'Cash', kind: 'cash', currency: 'BDT');
      await ledger.addAccount(ws, name: 'Bank', kind: 'bank', currency: 'BDT');
      final accounts = await ledger.watchAccounts(ws).first;
      cash = accounts.firstWhere((a) => a.account.name == 'Cash').account;
      bank = accounts.firstWhere((a) => a.account.name == 'Bank').account;
      foodId = await ledger.addCategory(ws, 'Food', 'expense');
    });
    tearDown(() => db.close());

    Future<Map<String, dynamic>> lastQueued() async =>
        jsonDecode((await db.select(db.outbox).get()).last.data) as Map<String, dynamic>;

    RuleDraft rent({String title = 'Rent', int? monthDay = 31, String mode = 'confirm', bool paused = false}) => RuleDraft(
          kind: 'expense', title: title, accountId: cash.id, categoryId: foodId, amountMinor: 150000,
          freq: 'monthly', monthDay: monthDay, startOn: '2026-10-13', mode: mode, isPaused: paused,
        );

    RuleDraft reminder(String title, {bool paused = false}) =>
        RuleDraft(kind: reminderKind, title: title, freq: 'monthly', startOn: '2026-10-20', isPaused: paused);

    test('a rule is usable at once, says when it falls next, and edits queue only what changed', () async {
      final id = await repo.addRule(ws, rent(), currency: 'BDT');
      final created = await lastQueued();
      expect((created['kind'], created['amount_minor'], created['month_day']), ('expense', 150000, 31));
      expect(created['splits'], isEmpty);
      expect(created.containsKey('currency'), isFalse); // the server's to say

      var view = (await repo.watchRules(ws).first).single;
      expect((view.label, view.accountName, view.categoryName, view.rule.currency), ('Rent', 'Cash', 'Food', 'BDT'));
      // Before the server has answered, the app works the date out itself
      expect(view.nextDue(DateTime(2026, 10, 13)), '2026-10-31');
      expect(view.nextDue(DateTime(2026, 11, 1)), '2026-11-30');

      await repo.updateRule(view.rule, rent(title: 'Flat', monthDay: 5));
      expect(await lastQueued(), {'title': 'Flat', 'month_day': 5});
      await repo.setPaused((await repo.rule(id))!, true);
      view = (await repo.watchRules(ws).first).single;
      expect((view.rule.isPaused, view.nextDue(DateTime(2026, 10, 13))), (true, null));

      // A deleted category leaves what the rule records next uncategorised
      await ledger.deleteCategory((await ledger.watchCategories(ws).first).single);
      expect((await repo.rule(id))!.categoryId, isNull);
    });

    test('what waits and what is coming, and what can be done about each', () async {
      final rentId = await repo.addRule(ws, rent(), currency: 'BDT');
      final cardId = await repo.addRule(ws, reminder('Pay the credit card'), currency: 'BDT');
      final due = await serverOccurrence(store, ws, rentId, '2026-10-13', 'due');
      await serverOccurrence(store, ws, rentId, '2026-11-30', 'upcoming');
      final card = await serverOccurrence(store, ws, cardId, '2026-10-20', 'due');
      await serverOccurrence(store, ws, rentId, '2026-09-30', 'done');

      var open = await repo.watchOpen(ws, until: '2026-10-25').first;
      expect(open.map((o) => (o.rule.label, o.occurrence.dueOn, o.isDue)).toList(),
          [('Rent', '2026-10-13', true), ('Pay the credit card', '2026-10-20', true)]);
      expect((await repo.watchOpen(ws).first).length, 3);

      // Recording it is a transaction that names the date it settles
      await ledger.addTransaction(cash,
          kind: 'expense', amountMinor: 152000, occurredOn: '2026-10-14', categoryId: foodId, occurrenceId: due);
      expect((await lastQueued())['occurrence_id'], due);
      await ledger.addTransfer(cash, bank, amountMinor: 500, occurredOn: '2026-10-14', occurrenceId: due);
      final legs = (await db.select(db.outbox).get()).reversed.take(2).map((o) => jsonDecode(o.data) as Map).toList();
      expect(legs.map((leg) => leg['occurrence_id']).toSet(), {due});

      final cardRow = open.last.occurrence;
      await repo.snooze(cardRow, DateTime.utc(2026, 10, 21, 3));
      expect(await lastQueued(), {'snoozed_until': '2026-10-21T03:00:00.000Z'});
      await repo.markDone(cardRow);
      expect(await lastQueued(), {'status': 'done'});
      await repo.skip(open.first.occurrence);
      open = await repo.watchOpen(ws).first;
      expect(open.map((o) => o.occurrence.dueOn).toList(), ['2026-11-30']);
      expect(card, isNotEmpty);
    });

    test('on Free: recurring transactions are refused, three reminders are not', () async {
      plan = planOf('free');
      final before = (await db.select(db.outbox).get()).length;
      await expectLater(
        repo.addRule(ws, rent(), currency: 'BDT'),
        throwsA(isA<PlanLimitException>()
            .having((e) => e.feature, 'feature', F.recurringTransactions)
            .having((e) => e.reason, 'reason', PlanLimitException.reasonFeature)),
      );
      expect((await db.select(db.outbox).get()).length, before);

      final ids = [for (var i = 0; i < 3; i++) await repo.addRule(ws, reminder('Reminder $i'), currency: 'BDT')];
      final fourth = throwsA(isA<PlanLimitException>()
          .having((e) => e.feature, 'feature', F.remindersStandalone)
          .having((e) => e.limit, 'limit', 3));
      await expectLater(repo.addRule(ws, reminder('One more'), currency: 'BDT'), fourth);
      // A paused one does not count, so pausing makes room; bringing it back needs room again
      await repo.setPaused((await repo.rule(ids.first))!, true);
      await repo.addRule(ws, reminder('One more'), currency: 'BDT');
      await expectLater(repo.setPaused((await repo.rule(ids.first))!, false), fourth);

      plan = planOf('plus');
      await repo.addRule(ws, rent(), currency: 'BDT');
      await repo.setPaused((await repo.rule(ids.first))!, false);
    });
  });

  testWidgets('a schedule reads as a sentence, in English and Bangla', (tester) async {
    final app = ScreenHarness(tester);
    final schedules = {
      Schedule(freq: 'once', startOn: parseDay('2026-10-13')): 'Once',
      Schedule(freq: 'daily', interval: 3, startOn: parseDay('2026-10-13')): 'Every 3 days',
      Schedule(freq: 'weekly', interval: 2, weekdayMask: 0x22, startOn: parseDay('2026-10-13')): 'Every 2 weeks · Tue, Sat',
      Schedule(freq: 'monthly', monthDay: 31, startOn: parseDay('2026-10-13')): 'Every month · Day 31',
      Schedule(freq: 'monthly', monthDay: -1, startOn: parseDay('2026-10-13')): 'Every month · The last day',
      Schedule(freq: 'monthly', weekdayMask: 1 << 4, setPos: 1, startOn: parseDay('2026-10-13')):
          'Every month · The first Friday',
      Schedule(freq: 'yearly', startOn: parseDay('2026-03-26')): 'Every year · Day 26, March',
    };
    late BuildContext context;
    await app.show(Builder(builder: (found) {
      context = found;
      return const SizedBox();
    }));
    for (final MapEntry(key: schedule, value: said) in schedules.entries) {
      expect(describeSchedule(context, schedule), said);
    }
    await app.stop();

    final bangla = ScreenHarness(tester);
    await bangla.show(Builder(builder: (found) {
      context = found;
      return const SizedBox();
    }), locale: 'bn');
    expect(describeSchedule(context, schedules.keys.elementAt(1)), 'প্রতি ৩ দিনে');
    await bangla.stop();
  });

  testWidgets('the inbox says what the server sent, counts what is unseen and marks it seen', (tester) async {
    final app = ScreenHarness(tester);
    final repo = RecurringRepository(app.db, app.store);
    final inbox = InboxRepository(app.db, app.store);
    Future<void> item(String type, Map<String, Object?> params, {String? subjectId, String? resolvedAt, int age = 0}) =>
        app.store.upsertRow('inbox_items', {
          'id': newId(), 'workspace_id': workspace.id, 'version': 1, 'server_seq': 1, 'deleted_at': null,
          'created_at': DateTime.now().subtract(Duration(days: age)).toUtc().toIso8601String(),
          'updated_at': '2026-10-13T00:00:00Z',
          'type': type, 'params': params, 'subject_table': 'recurring_occurrences', 'subject_id': subjectId,
          'dedupe_key': '$type-$age', 'read_at': null, 'resolved_at': resolvedAt,
          // Sent by the server, not kept by this version: must not get in the way
          'notify_at': '2026-10-13T03:00:00Z',
        });
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.container.read(currentWorkspaceIdProvider.notifier).select(workspace.id);
      await app.db.delete(app.db.workspaces).go();
      final accountId = await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
      final rentId = await repo.addRule(
        workspace.id,
        RuleDraft(kind: 'expense', title: 'Rent', accountId: accountId, amountMinor: 150000, freq: 'monthly',
            startOn: '2026-10-13'),
        currency: 'BDT',
      );
      final due = await serverOccurrence(app.store, workspace.id, rentId, todayIso(), 'due');
      const rent = {'title': 'Rent', 'kind': 'expense', 'amount_minor': 150000, 'currency': 'BDT'};
      await item('due', rent, subjectId: due);
      await item('upcoming', {...rent, 'title': 'Internet', 'days': 3}, age: 1);
      await item('posted', {...rent, 'title': 'Netflix'}, resolvedAt: '2026-10-12T00:00:00Z', age: 2);
      await item('budget_80', {'category': 'Food', 'percent': 85, 'amount_minor': 100000, 'spent_minor': 85000,
          'currency': 'BDT'}, resolvedAt: '2026-10-12T00:00:00Z', age: 3);
      await item('income_expected', {...rent, 'title': 'Salary', 'kind': 'income'}, age: 4);
      await item('something_new', {'title': 'From a newer server'}, age: 5);
    });
    expect(await app.run(() => inbox.watchUnread(workspace.id).first), 6);

    await app.show(const InboxPage());
    for (final said in [
      'Rent is due today', 'Internet is due in 3 days', 'Netflix was recorded', 'Food: 85% of the budget is spent',
      'Has Salary come in?', 'From a newer server',
    ]) {
      await tester.scrollUntilVisible(find.text(said), 200);
      expect(find.text(said), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.text('Rent is due today'), -200);
    // Only what still waits for an answer carries buttons
    expect(find.widgetWithText(FilledButton, 'Record'), findsOneWidget);

    // Looking at them is what marks them seen, and that is queued for the server
    await app.settle();
    expect(await app.run(() => inbox.watchUnread(workspace.id).first), 0);
    final queued = await app.run(() => app.db.select(app.db.outbox).get());
    expect(queued.where((o) => o.tableName_ == 'inbox_items').length, 6);
    await app.stop();
  });

  testWidgets('a reminder is written, and a due rule is recorded from the list', (tester) async {
    final app = ScreenHarness(tester);
    final repo = RecurringRepository(app.db, app.store);
    late String due;
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.container.read(currentWorkspaceIdProvider.notifier).select(workspace.id);
      await app.db.delete(app.db.workspaces).go();
      final accountId = await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
      final rentId = await repo.addRule(
        workspace.id,
        RuleDraft(kind: 'expense', title: 'Rent', accountId: accountId, amountMinor: 150000, freq: 'monthly',
            startOn: '2026-10-13', splits: const [SplitPart(null, 100000), SplitPart(null, 50000)]),
        currency: 'BDT',
      );
      due = await serverOccurrence(app.store, workspace.id, rentId, '2026-10-13', 'due');
    });
    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pump();
      await tester.tap(finder);
      // A page takes most of a second to slide in or out
      await app.settle();
      await app.settle();
    }

    await app.show(const RecurringPage());
    expect(find.text('Waiting for you'), findsOneWidget);
    expect(find.textContaining('Every month · Day 13'), findsOneWidget);

    // A reminder: a title and a schedule, nothing to record
    await tap(find.text('Add'));
    await tap(find.text('Reminder'));
    await tap(find.widgetWithText(FilledButton, 'Save'));
    expect(find.text('Give it a title.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('rule-title')), 'Pay the credit card');
    await tester.enterText(find.byKey(const Key('schedule-interval')), '2');
    await app.settle();
    expect(tester.widget<Text>(find.byKey(const Key('schedule-preview'))).data, startsWith('Next: '));
    await tap(find.widgetWithText(FilledButton, 'Save'));
    final card = (await app.run(() => repo.watchRules(workspace.id).first)).firstWhere((r) => r.isReminder).rule;
    expect((card.title, card.freq, card.interval, card.mode, card.accountId), ('Pay the credit card', 'monthly', 2, 'confirm', null));
    expect(find.text('Pay the credit card'), findsOneWidget);

    // Recording the rent opens the form filled in from the rule, split included; the amount can be changed
    await tap(find.widgetWithText(FilledButton, 'Record'));
    expect(find.text('Split'), findsOneWidget);
    final amount = find.descendant(of: find.byType(AmountField).first, matching: find.byType(EditableText));
    expect(tester.widget<EditableText>(amount).controller.text, '1500.00');
    await tap(find.widgetWithText(FilledButton, 'Save'));
    final recorded = (await app.run(() => app.ledger.watchTransactions(workspace.id).first)).single.transaction;
    expect((recorded.amountMinor, recorded.occurrenceId, recorded.note, recorded.parts.length), (-150000, due, 'Rent', 2));
    await app.stop();
  });
}
