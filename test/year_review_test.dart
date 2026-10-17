import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/features/insights/year_review.dart';
import 'package:spendroo/features/personal/allocations.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';

import 'test_support.dart';

/// Two years of months, from January of the year before [year]; [these] and
/// [before] give (month, income, expense) for the months that have any.
List<MonthTotals> twoYears(int year, {Map<int, (int, int)> these = const {}, Map<int, (int, int)> before = const {}}) => [
      for (var i = 1; i <= 12; i++) MonthTotals(DateTime(year - 1, i), before[i]?.$1 ?? 0, before[i]?.$2 ?? 0),
      for (var i = 1; i <= 12; i++) MonthTotals(DateTime(year, i), these[i]?.$1 ?? 0, these[i]?.$2 ?? 0),
    ];

final noCategories = MonthSummary(0, 0, const []);

void main() {
  group('the rules', () {
    test('percentages round half away from zero, as the server does', () {
      expect(reviewPercent(1, 8), 13);
      expect(reviewPercent(-1, 8), -13);
      expect(reviewPercent(2, 3), 67);
      expect(reviewPercent(-155, 1000), -16);
      expect(reviewPercent(5, 0), isNull);
      expect(reviewChange(150, 100), 50);
      expect(reviewChange(-50, 100), -150);
      expect(reviewChange(50, -100), 150);
      expect(reviewChange(5, 0), isNull);
    });

    test('January looks back on last year; the years run from the first transaction', () {
      expect(defaultReviewYear(DateTime(2026, 1, 31)), 2025);
      expect(defaultReviewYear(DateTime(2026, 2, 1)), 2026);
      expect(reviewYears(DateTime(2023, 6, 1), DateTime(2026, 10, 17)), [2026, 2025, 2024, 2023]);
      expect(reviewYears(null, DateTime(2026, 10, 17)), [2026]);
      // In January last year is offered even before anything was recorded in it
      expect(reviewYears(DateTime(2026, 1, 3), DateTime(2026, 1, 20)), [2026, 2025]);
      expect(reviewYears(DateTime(1990, 1, 1), DateTime(2001, 5, 1)), [2001, 2000]);
    });

    test('a year under way ranks only the months that are over', () {
      final review = YearReview.of(
        year: 2026,
        today: DateTime(2026, 3, 15),
        months: twoYears(2026, these: {1: (0, 50000), 2: (0, 40000), 3: (100000, 1)}),
        summary: noCategories,
      );
      expect((review.isPartial, review.closedMonths), (true, 2));
      expect(review.biggestMonth, ReviewMonth(DateTime(2026, 1), 50000));
      // March is still under way, so it is neither the smallest nor the best
      expect(review.smallestMonth, ReviewMonth(DateTime(2026, 2), 40000));
      expect(review.bestMonth, isNull);
      expect((review.monthsInGreen, review.averageExpenseMinor, review.expenseMinor), (0, 45000, 90001));
      expect((review.hasPrevious, review.incomeChange), (false, null));
      expect((review.isOpen(DateTime(2026, 2)), review.isOpen(DateTime(2026, 3))), (false, true));

      final january = YearReview.of(year: 2026, today: DateTime(2026, 1, 20), months: twoYears(2026), summary: noCategories);
      expect((january.biggestMonth, january.averageExpenseMinor, january.closedMonths), (null, null, 0));
    });

    test('an empty year, and one that spent more than came in', () {
      final empty = YearReview.of(year: 2024, today: DateTime(2026, 10, 17), months: twoYears(2024), summary: noCategories);
      expect((empty.isEmpty, empty.savingsRate, empty.biggestMonth, empty.smallestMonth), (true, null, null, null));

      final over = YearReview.of(
        year: 2024,
        today: DateTime(2026, 10, 17),
        months: twoYears(2024, these: {1: (1000, 1155)}, before: {5: (2000, 1000)}),
        summary: noCategories,
      );
      expect((over.netMinor, over.savingsRate), (-155, -16));
      // One month that spent anything has no smallest beside the biggest
      expect((over.biggestMonth?.month, over.smallestMonth), (DateTime(2024, 1), null));
      expect((over.incomeChange, over.expenseChange, over.netChange), (-50, 16, -116));
    });

    test('ties go to the earlier month, and leap years have twelve months like any other', () {
      final review = YearReview.of(
        year: 2024,
        today: DateTime(2026, 10, 17),
        months: twoYears(2024, these: {2: (0, 500), 7: (0, 500), 9: (0, 100), 11: (0, 100)}),
        summary: noCategories,
      );
      expect((review.biggestMonth?.month, review.smallestMonth?.month), (DateTime(2024, 2), DateTime(2024, 9)));
      expect(review.averageExpenseMinor, 1200 ~/ 12);
    });
  });

  group('from the ledger', () {
    late AppDatabase db;
    late LedgerRepository repo;
    late Account cash;
    late Account bank;

    setUp(() async {
      db = memoryDatabase();
      repo = LedgerRepository(db, LocalStore(db));
      await repo.addAccount('ws1', name: 'Cash', kind: 'cash', currency: 'BDT', openingBalanceMinor: 100000);
      await repo.addAccount('ws1', name: 'Bank', kind: 'bank', currency: 'BDT');
      await repo.addAccount('ws1', name: 'Payoneer', kind: 'bank', currency: 'USD');
      final accounts = {for (final a in await repo.watchAccounts('ws1').first) a.account.name: a.account};
      (cash, bank) = (accounts['Cash']!, accounts['Bank']!);
    });
    tearDown(() => db.close());

    /// The figures the server's own tests use (ledger_personal/tests.py, YearReviewTestCase).
    Future<void> seedYear() async {
      final salary = await repo.addCategory('ws1', 'Salary', 'income');
      final food = await repo.addCategory('ws1', 'Food', 'expense');
      final home = await repo.addCategory('ws1', 'Home', 'expense');
      Future<void> add(String kind, int amount, String day, [String? category]) =>
          repo.addTransaction(cash, kind: kind, amountMinor: amount, occurredOn: day, categoryId: category);
      await add('income', 300000, '2024-03-10', salary);
      await add('expense', 100000, '2024-03-12', food);
      await add('income', 500000, '2025-01-05', salary);
      await add('expense', 120000, '2025-01-20', food);
      await add('expense', 30000, '2025-02-14');
      await repo.addTransaction(cash,
          kind: 'expense',
          amountMinor: 200000,
          occurredOn: '2025-03-03',
          splits: [SplitPart(food, 40000), SplitPart(home, 160000)]);
      await add('income', 100000, '2025-03-25', salary);
      await add('expense', 10000, '2025-12-31', food);
      await repo.addTransfer(cash, bank, amountMinor: 50000, occurredOn: '2025-06-01');
      final dollars = (await repo.watchAccounts('ws1').first).firstWhere((a) => a.account.currency == 'USD').account;
      await repo.addTransaction(dollars, kind: 'income', amountMinor: 900, occurredOn: '2025-06-02');
    }

    Future<YearReview> review(int year) async => YearReview.of(
          year: year,
          today: DateTime(2026, 10, 17),
          months: await repo.watchMonthlyTotals('ws1', DateTime(year, 12), 'BDT', count: 24).first,
          summary: await repo.watchYear('ws1', year, 'BDT').first,
        );

    test('a closed year gives the same review as the server', () async {
      await seedYear();
      final data = await review(2025);
      expect((data.incomeMinor, data.expenseMinor, data.netMinor, data.savingsRate, data.isPartial),
          (600000, 360000, 240000, 40, false));
      expect((data.previousIncomeMinor, data.previousExpenseMinor, data.previousNetMinor), (300000, 100000, 200000));
      expect(data.biggestMonth, ReviewMonth(DateTime(2025, 3), 200000));
      expect(data.smallestMonth, ReviewMonth(DateTime(2025, 12), 10000));
      expect(data.bestMonth, ReviewMonth(DateTime(2025, 1), 380000));
      expect((data.monthsInGreen, data.averageExpenseMinor, data.largestExpenseMinor), (1, 30000, 160000));
      expect(data.topCategories.map((c) => (c.name, c.amountMinor, c.count, c.largestMinor, c.previousMinor)), [
        ('Food', 170000, 3, 120000, 100000),
        ('Home', 160000, 1, 160000, 0),
        (null, 30000, 1, 30000, 0),
      ]);
      expect((data.incomeChange, data.expenseChange, data.netChange), (100, 260, 20));
    });

    test('the year before is a whole calendar year, leap day included', () async {
      final food = await repo.addCategory('ws1', 'Food', 'expense');
      // A leap year has 366 days: counting days back from 2025 would start on 31 December 2023
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 700, occurredOn: '2023-12-31', categoryId: food);
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 300, occurredOn: '2024-01-01', categoryId: food);
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 200, occurredOn: '2024-02-29', categoryId: food);
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 1000, occurredOn: '2025-01-01', categoryId: food);
      final year = await repo.watchYear('ws1', 2025, 'BDT').first;
      expect(year.byCategory.single.previousMinor, 500);
      expect(year.expenseMinor, 1000);
    });

    test('the first transaction day follows deletes', () async {
      expect(await repo.watchFirstTransactionDay('ws1').first, isNull);
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 1, occurredOn: '2024-05-06');
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 1, occurredOn: '2023-02-03');
      expect(await repo.watchFirstTransactionDay('ws1').first, DateTime(2023, 2, 3));
      final oldest = (await repo.watchTransactions('ws1').first).last.transaction;
      await repo.deleteTransaction(oldest);
      expect(await repo.watchFirstTransactionDay('ws1').first, DateTime(2024, 5, 6));
    });
  });
}
