import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';
import 'package:spendroo/features/cashbook/insights/insights_repository.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';

import 'test_support.dart';

void main() {
  late AppDatabase db;
  late CashbookRepository books;
  late InsightsRepository insights;

  setUp(() {
    db = memoryDatabase();
    books = CashbookRepository(db, LocalStore(db));
    insights = InsightsRepository(db);
  });
  tearDown(() => db.close());

  Future<Cashbook> book(String name, {String currency = 'BDT', String workspace = 'ws1'}) async {
    final id = await books.createCashbook(workspace, name, currency);
    return (await books.watchCashbook(id).first)!.book;
  }

  Future<String> add(Cashbook book, String type, int amount, String date, {String? category, String? method}) =>
      books.addEntry(book,
          entryType: type, amountMinor: amount, entryDate: date, categoryId: category, paymentMethodId: method);

  final october = InsightsPeriod.month(DateTime(2026, 10));

  test('a month: opening balance, the month before, and each day', () async {
    final till = await book('Till');
    await add(till, 'cash_in', 5000, '2026-08-20'); // before the month before: opening only
    await add(till, 'cash_in', 3000, '2026-09-10');
    await add(till, 'cash_out', 1000, '2026-09-12');
    await add(till, 'cash_in', 4000, '2026-10-01');
    await add(till, 'cash_out', 500, '2026-10-01');
    await add(till, 'cash_out', 1500, '2026-10-05');
    await add(till, 'cash_out', 9999, '2026-11-01'); // after the month: not counted

    final flow = await insights.watchFlow(InsightsScope.book(till.id), october, today: DateTime(2026, 10, 10)).first;
    expect(flow.openingMinor, 7000);
    expect((flow.previous.inMinor, flow.previous.outMinor), (3000, 1000));
    expect((flow.total.inMinor, flow.total.outMinor, flow.total.count), (4000, 2000, 3));
    expect(flow.closingMinor, 9000);
    expect(flow.netChange, 0); // 2000 net, as in September
    expect(flow.on(DateTime(2026, 10, 1)).netMinor, 3500);
    expect(flow.activeDays, 2);
    // Ten days gone by: the balance each of them, and the cash out spread over them
    expect(flow.runningBalance.length, 10);
    expect(flow.runningBalance.first, 10500);
    expect(flow.runningBalance.last, 9000);
    expect(flow.averageDailyOutMinor, 200);
    expect(flow.busiestWeekday, DateTime(2026, 10, 5).weekday);
    expect(flow.runwayDays, isNull); // more came in than went out
  });

  test('runway: how long the balance lasts while more goes out than comes in', () async {
    final till = await book('Till');
    await add(till, 'cash_in', 10000, '2026-09-01');
    await add(till, 'cash_out', 1000, '2026-10-01');
    final flow = await insights.watchFlow(InsightsScope.book(till.id), october, today: DateTime(2026, 10, 10)).first;
    // 100 a day lost, 9000 left
    expect(flow.runwayDays, 90);
    expect(flow.outRatio, isNull);
  });

  test('a business adds up its books in its currency and leaves the others out', () async {
    final till = await book('Till');
    final safe = await book('Safe');
    final dollars = await book('Dollars', currency: 'USD');
    final elsewhere = await book('Other shop', workspace: 'ws2');
    await add(till, 'cash_in', 1000, '2026-10-02');
    await add(safe, 'cash_out', 300, '2026-10-03');
    await add(dollars, 'cash_in', 777, '2026-10-03');
    await add(elsewhere, 'cash_in', 555, '2026-10-03');

    final scope = const InsightsScope.business('ws1', 'BDT');
    final flow = await insights.watchFlow(scope, october).first;
    expect((flow.total.inMinor, flow.total.outMinor), (1000, 300));
    expect(await insights.watchOtherCurrencyBooks('ws1', 'BDT').first, 1);

    final standings = await insights.watchBooks('ws1', 'BDT', october).first;
    expect([for (final s in standings) s.book.bookName], ['Till', 'Safe']);
    expect(standings.first.months.last, 1000);
    expect(standings.last.flow.netMinor, -300);
  });

  test('categories merge by name across books, with what they took the month before', () async {
    final till = await book('Till');
    final safe = await book('Safe');
    String food(List<EntryCategory> all) => all.firstWhere((c) => c.categoryName == 'Food').id;
    final tillFood = food(await books.watchCategories(till.id).first);
    final safeFood = food(await books.watchCategories(safe.id).first);
    await add(till, 'cash_out', 200, '2026-10-02', category: tillFood);
    await add(safe, 'cash_out', 300, '2026-10-04', category: safeFood);
    await add(safe, 'cash_out', 100, '2026-09-04', category: safeFood);
    await add(till, 'cash_in', 900, '2026-10-04');

    final rows = await insights.watchSplit(const InsightsScope.business('ws1', 'BDT'), october, byCategory: true).first;
    final foodRow = rows.firstWhere((r) => r.name == 'Food');
    expect((foodRow.outMinor, foodRow.outCount, foodRow.largestOutMinor, foodRow.previousOutMinor), (500, 2, 300, 100));
    expect(rows.firstWhere((r) => r.name == null).inMinor, 900);

    final summary = spendSummary(rows);
    expect((summary.incomeMinor, summary.expenseMinor), (900, 500));
    expect(summary.byCategory.single.changePercent, 400);
  });

  test('the monthly trend runs oldest first, months without entries included', () async {
    final till = await book('Till');
    await add(till, 'cash_in', 100, '2026-08-15');
    await add(till, 'cash_out', 40, '2026-10-15');
    final trend = await insights.watchMonthly(InsightsScope.book(till.id), DateTime(2026, 10), count: 3).first;
    expect([for (final m in trend) (m.month.month, m.incomeMinor, m.expenseMinor)], [(8, 100, 0), (9, 0, 0), (10, 0, 40)]);
  });

  test('biggest entries, who recorded them, and the bills they keep', () async {
    final till = await book('Till');
    await add(till, 'cash_out', 100, '2026-10-01');
    await add(till, 'cash_out', 900, '2026-10-02');
    await add(till, 'cash_out', 500, '2026-10-03');
    final top = await insights.watchTopEntries(InsightsScope.book(till.id), october, 'cash_out', limit: 2).first;
    expect([for (final t in top) t.entry.amountMinor], [900, 500]);

    final members = await insights.watchByMember(InsightsScope.book(till.id), october).first;
    expect(members.single.flow.count, 3);

    final coverage = await insights.watchBillCoverage(InsightsScope.book(till.id), october).first;
    expect((coverage.withBill, coverage.total, coverage.missingMinor), (0, 3, 1500));
  });

  test("a custom field's values are grouped, and a number field's added up", () async {
    final till = await book('Till');
    await books.addEntry(till, entryType: 'cash_out', amountMinor: 100, entryDate: '2026-10-01', customValues: {'party': 'Rahim'});
    await books.addEntry(till, entryType: 'cash_out', amountMinor: 300, entryDate: '2026-10-02', customValues: {'party': 'Rahim'});
    await books.addEntry(till, entryType: 'cash_in', amountMinor: 50, entryDate: '2026-10-03', customValues: {'party': 'Karim', 'kg': '2.5'});
    await books.addEntry(till, entryType: 'cash_out', amountMinor: 70, entryDate: '2026-10-03', customValues: {'kg': '1.5'});

    final rows = await insights.watchFieldSplit(till.id, 'party', october).first;
    final rahim = rows.firstWhere((r) => r.key == 'Rahim');
    expect((rahim.outMinor, rahim.outCount), (400, 2));
    expect(rows.firstWhere((r) => r.key == 'Karim').inMinor, 50);

    final sum = await insights.watchFieldSum(till.id, 'kg', october).first;
    expect((sum.inSum, sum.outSum, sum.count), (2.5, 1.5, 2));
  });

  test('a chosen range is compared with as many days before it', () {
    final range = InsightsPeriod.range(const InsightsRange('2026-10-11', '2026-10-20'), DateTime(2026, 10));
    expect((range.previousFrom, range.days), ('2026-10-01', 10));
    expect(range.daysElapsed(DateTime(2026, 10, 15)), 5);
    expect(range.daysElapsed(DateTime(2026, 9, 1)), 0);
    expect(october.previousFrom, '2026-09-01');
  });
}
