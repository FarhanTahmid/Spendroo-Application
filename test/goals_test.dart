import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/entitlements/plan_guard.dart';
import 'package:spendroo/features/goals/goal_insights.dart';
import 'package:spendroo/features/goals/goal_math.dart';
import 'package:spendroo/features/goals/goals_repository.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';

import 'app_flow_test.dart' show personalId;
import 'plan_test.dart' show entitlements;
import 'test_support.dart';

DateTime d(int year, int month, int day) => DateTime.utc(year, month, day);

GoalMove move(DateTime day, int amount, {String account = 'Cash', String source = 'manual'}) =>
    GoalMove(id: '$day$amount', day: day, amountMinor: amount, otherAccountName: account, source: source);

void main() {
  group('goal maths, as the server does it (ledger_personal/goals.py)', () {
    test('the steady line, pace and milestones', () {
      final start = d(2026, 1, 1), end = d(2027, 1, 1);
      expect(expectedBy(36500, start, end, d(2026, 7, 2)), 18200);
      expect(expectedBy(36500, start, end, d(2028, 1, 1)), 36500);
      expect(expectedBy(36500, start, end, d(2025, 1, 1)), 0);
      expect(paceOf(100, 100, null), GoalPace.reached);
      expect(paceOf(10, 100, null), GoalPace.noDate);
      expect(paceOf(89, 100, 100), GoalPace.behind);
      expect(paceOf(90, 100, 100), GoalPace.onTrack);
      expect(paceOf(111, 200, 100), GoalPace.ahead);
      expect(milestonesPassed(74), 0x3);
      expect(milestonesPassed(130), 0xF);
      expect(marksCrossed(20, 80), [25, 50, 75]);
      expect(marksCrossed(80, 80), isEmpty);
    });

    test('what each month needs, rounded up so it never falls short', () {
      // 365 days are 11.99 average months: a little over 10,000 each
      expect(neededPerMonth(120000, d(2026, 10, 13), d(2027, 10, 13)), 10007);
      expect(neededPerMonth(0, d(2026, 10, 13), d(2027, 10, 13)), isNull);
      expect(neededPerMonth(5000, d(2026, 10, 13), null), isNull);
      expect(neededPerMonth(5000, d(2026, 10, 13), d(2026, 10, 1)), isNull);
    });

    test('progress keeps saved, remaining and the next quarter', () {
      final progress = GoalProgress.of(
        savedMinor: 36000,
        targetMinor: 50000,
        createdOn: d(2026, 1, 1),
        today: d(2026, 10, 1),
        targetOn: d(2027, 3, 15),
      );
      expect((progress.percent, progress.remainingMinor, progress.nextMilestone), (72, 14000, 75));
      expect(progress.toNextMilestoneMinor, 1500);
      expect(progress.pace, GoalPace.ahead);
    });
  });

  group('a goal\'s history', () {
    final moves = [
      move(d(2026, 6, 1), 10000),
      move(d(2026, 7, 1), 10000, account: 'Bank'),
      move(d(2026, 8, 1), 10000),
      move(d(2026, 8, 20), -4000),
      move(d(2026, 9, 1), 10000),
      move(d(2026, 10, 1), 10000, source: 'recurring'),
    ];
    final stats = GoalStats.of(moves: moves, targetMinor: 60000, createdOn: d(2026, 6, 1), today: d(2026, 10, 13));

    test('draws the balance after each day, and when each quarter was passed', () {
      expect(stats.cumulative.map((point) => point.$2), [10000, 20000, 30000, 26000, 36000, 46000]);
      // Half was passed on 1 Aug, given back on 20 Aug, and passed again on 1 Sep
      expect(stats.milestoneDays, {25: d(2026, 7, 1), 50: d(2026, 9, 1), 75: d(2026, 10, 1)});
    });

    test('taking money out below a mark takes its marker away', () {
      final down = GoalStats.of(
        moves: [move(d(2026, 10, 1), 33000), move(d(2026, 10, 5), -21000)],
        targetMinor: 60000,
        createdOn: d(2026, 10, 1),
        today: d(2026, 10, 13),
      );
      // 55% then 20%: neither the quarter nor the half is held any more
      expect(down.milestoneDays, isEmpty);
    });

    test('counts months in a row with more in than out, and splits what came from where', () {
      expect(stats.streak, 5);
      expect(stats.months.map((month) => month.netMinor), [0, 10000, 10000, 6000, 10000, 10000]);
      expect(stats.sources, {'Cash': 40000, 'Bank': 10000});
    });

    test('forecasts the finish at the recent pace', () {
      // The last 90 days put in 26,000 net: about 8,793 a month, with 14,000 still to go: 49 days
      expect(stats.averagePerMonthMinor, 8793);
      expect(stats.projectedFinish, d(2026, 12, 1));
      expect(GoalStats.finishAt(14000, 0, d(2026, 10, 13)), isNull);
      expect(GoalStats.finishAt(0, 0, d(2026, 10, 13)), d(2026, 10, 13));
    });

    test('a month just begun with nothing in yet does not break the run', () {
      final early = GoalStats.of(moves: moves.take(5).toList(), targetMinor: 60000, createdOn: d(2026, 6, 1), today: d(2026, 10, 2));
      expect(early.streak, 4);
    });

    test('the bars start with the month the goal was made', () {
      expect(stats.monthsSinceStart.map((month) => month.month.month), [6, 7, 8, 9, 10]);
    });

    test('a goal started today: its pace is what went in, and nothing is forecast from one deposit', () {
      final today = d(2026, 10, 13);
      final young = GoalStats.of(
        moves: [move(today, 3500000), move(today, -100)],
        targetMinor: 12292200,
        createdOn: today,
        today: today,
      );
      // Not one day's saving stretched over a month (that read ৳35,510 with ৳34,999 saved)
      expect(young.averagePerMonthMinor, 3499900);
      expect(young.tooEarly, isTrue);
      expect(young.projectedFinish, isNull);
      expect(young.monthsSinceStart.map((month) => month.month.month), [10]);

      final month = GoalStats.of(moves: [move(today, 3500000)], targetMinor: 12292200, createdOn: d(2026, 9, 13), today: today);
      expect(month.tooEarly, isFalse);
      expect(month.projectedFinish, isNotNull);
    });
  });

  group('insights', () {
    GoalFacts facts({
      String id = 'g1',
      String icon = '',
      int saved = 10000,
      int target = 100000,
      DateTime? targetOn,
      List<GoalMove> moves = const [],
      bool autoSaved = false,
    }) {
      final today = d(2026, 10, 13);
      return GoalFacts(
        id: id,
        name: 'Laptop',
        icon: icon,
        currency: 'BDT',
        progress: GoalProgress.of(
            savedMinor: saved, targetMinor: target, createdOn: d(2026, 1, 1), today: today, targetOn: targetOn),
        stats: GoalStats.of(moves: moves, targetMinor: target, createdOn: d(2026, 1, 1), today: today),
        moves: moves,
        autoSaved: autoSaved,
      );
    }

    test('behind a date comes first, with what a week would mend', () {
      final found = goalInsights(goals: [facts(targetOn: d(2026, 12, 31))], today: d(2026, 10, 13), currency: 'BDT');
      expect(found.first, isA<BehindInsight>());
      expect((found.first as BehindInsight).behindMinor, greaterThan(0));
      // No emergency fund yet: said last
      expect(found.last, isA<EmergencyFundInsight>());
    });

    test('an emergency fund silences that nudge; a streak and cutting back are noticed', () {
      final moves = [for (var m = 6; m <= 10; m++) move(d(2026, m, 2), 5000)];
      final found = goalInsights(
        goals: [facts(icon: 'emergency', saved: 25000, moves: moves)],
        today: d(2026, 10, 13),
        topCategory: 'Food',
        topCategoryMinor: 20000,
        currency: 'BDT',
      );
      expect(found.whereType<EmergencyFundInsight>(), isEmpty);
      expect(found.whereType<StreakInsight>().single.months, 5);
      expect(found.whereType<CutBackInsight>().single.weeksSooner, greaterThanOrEqualTo(1));
    });

    test('saving by hand right after payday suggests a schedule, unless there is one', () {
      final moves = [for (var m = 7; m <= 10; m++) move(d(2026, m, 2), 5000)];
      final paydays = [for (var m = 7; m <= 10; m++) d(2026, m, 1)];
      expect(
        goalInsights(goals: [facts(moves: moves)], today: d(2026, 10, 13), incomeDays: paydays).whereType<PaydayInsight>(),
        hasLength(1),
      );
      expect(
        goalInsights(goals: [facts(moves: moves, autoSaved: true)], today: d(2026, 10, 13), incomeDays: paydays)
            .whereType<PaydayInsight>(),
        isEmpty,
      );
    });
  });

  group('the repository', () {
    late AppDatabase db;
    late LocalStore store;
    late Entitlements? plan;
    late LedgerRepository ledger;
    late GoalsRepository goals;
    late PlanGuard guard;

    setUp(() async {
      db = memoryDatabase();
      store = LocalStore(db);
      plan = entitlements();
      guard = PlanGuard(db, () => plan);
      ledger = LedgerRepository(db, store, guard);
      goals = GoalsRepository(db, store, ledger, guard);
      await db.into(db.workspaces).insert(
          const Workspace(id: personalId, name: 'Me', kind: 'personal', defaultCurrency: 'BDT', isDemo: false, role: 'owner'));
    });
    tearDown(() => db.close());

    Future<Account> cash() async {
      final id = await ledger.addAccount(personalId, name: 'Cash', kind: 'cash', currency: 'BDT', openingBalanceMinor: 100000);
      return (await ledger.watchAccounts(personalId).first).firstWhere((a) => a.account.id == id).account;
    }

    test('a goal brings its own account, which is no account to spend from', () async {
      await cash();
      final id = await goals.createGoal(personalId, name: 'Laptop', targetMinor: 50000, currency: 'BDT');
      final view = (await goals.watchGoal(id).first)!;
      final account = await goals.accountOf(view.goal);
      expect((account.kind, account.name, view.savedMinor), ('goal', 'Laptop', 0));
      expect((await ledger.watchAccounts(personalId).first).map((a) => a.account.name), ['Cash']);
      expect(await guard.count(F.personalAccounts, personalId), 1);
      expect(await guard.count(F.savingsGoals, personalId), 1);
      // The account goes to the server before the goal that points at it
      final outbox = await (db.select(db.outbox)..orderBy([(o) => OrderingTerm.asc(o.seq)])).get();
      expect(outbox.map((o) => o.tableName_).toList().sublist(outbox.length - 2), ['accounts', 'savings_goals']);
    });

    test('money put in leaves the account; taken out, it comes back; the list names the goal once', () async {
      final from = await cash();
      final id = await goals.createGoal(personalId, name: 'Laptop', targetMinor: 50000, currency: 'BDT');
      var view = (await goals.watchGoal(id).first)!;
      await goals.contribute(view.goal, from, amountMinor: 30000, occurredOn: '2026-10-01');
      await goals.withdraw(view.goal, from, amountMinor: 5000, occurredOn: '2026-10-02');

      view = (await goals.watchGoal(id).first)!;
      expect(view.savedMinor, 25000);
      expect((await ledger.watchAccounts(personalId).first).single.balanceMinor, 75000);
      final rows = await ledger.watchTransactions(personalId).first;
      expect(rows.map((r) => (r.transaction.amountMinor, r.goalName)), [(5000, 'Laptop'), (-30000, 'Laptop')]);
      final moves = await goals.watchMoves(id).first;
      expect(moves.map((m) => (m.amountMinor, m.otherAccountName)), [(-5000, 'Cash'), (30000, 'Cash')]);
    });

    test('Free has room for one goal; an archived one makes room', () async {
      final first = await goals.createGoal(personalId, name: 'Laptop', targetMinor: 50000, currency: 'BDT');
      await expectLater(
        goals.createGoal(personalId, name: 'Trip', targetMinor: 50000, currency: 'BDT'),
        throwsA(isA<PlanLimitException>().having((e) => e.feature, 'feature', F.savingsGoals)),
      );
      await goals.setArchived((await goals.watchGoal(first).first)!.goal, true);
      await goals.createGoal(personalId, name: 'Trip', targetMinor: 50000, currency: 'BDT');
    });

    test('a locked goal takes nothing more, and always gives its money back', () async {
      final from = await cash();
      plan = entitlements(plan: 'plus');
      final id = await goals.createGoal(personalId, name: 'Trip', targetMinor: 50000, currency: 'BDT');
      final goal = (await goals.watchGoal(id).first)!.goal;
      await goals.contribute(goal, from, amountMinor: 1000, occurredOn: '2026-10-01');
      plan = entitlements(locks: [
        {'feature': F.savingsGoals, 'scope': personalId, 'limit': 1, 'kept': <String>[], 'locked': [id],
         'pending': true, 'can_change_at': null},
      ]);
      await expectLater(
        goals.contribute(goal, from, amountMinor: 1000, occurredOn: '2026-10-02'),
        throwsA(isA<PlanLimitException>().having((e) => e.reason, 'reason', PlanLimitException.reasonLocked)),
      );
      await goals.withdraw(goal, from, amountMinor: 1000, occurredOn: '2026-10-02');
      expect((await goals.watchGoal(id).first)!.savedMinor, 0);
    });

    test('only an empty goal is deleted, its account with it', () async {
      final from = await cash();
      final id = await goals.createGoal(personalId, name: 'Laptop', targetMinor: 50000, currency: 'BDT');
      var view = (await goals.watchGoal(id).first)!;
      await goals.contribute(view.goal, from, amountMinor: 100, occurredOn: '2026-10-01');
      view = (await goals.watchGoal(id).first)!;
      expect(() => goals.deleteGoal(view), throwsStateError);
      await goals.withdraw(view.goal, from, amountMinor: 100, occurredOn: '2026-10-02');
      view = (await goals.watchGoal(id).first)!;
      await goals.deleteGoal(view);
      expect(await goals.watchGoal(id).first, isNull);
      expect(await guard.count(F.savingsGoals, personalId), 0);
    });
  });
}
