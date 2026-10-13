import 'dart:convert';

import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/design/category_color.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';
import 'package:spendroo/features/personal/allocations.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

void main() {
  late AppDatabase db;
  late LocalStore store;
  var changes = 0;

  setUp(() {
    db = memoryDatabase();
    changes = 0;
    store = LocalStore(db, onChange: () => changes++);
  });
  tearDown(() => db.close());

  Future<List<OutboxData>> outbox() => db.select(db.outbox).get();

  group('cashbook', () {
    late CashbookRepository repo;
    setUp(() => repo = CashbookRepository(db, store));

    test('a new book is usable at once and queued with its defaults', () async {
      final bookId = await repo.createCashbook('ws1', 'Till', 'BDT');

      final books = await repo.watchCashbooks('ws1').first;
      expect(books.single.book.bookName, 'Till');
      expect(books.single.balanceMinor, 0);
      expect((await repo.watchCategories(bookId).first).length, defaultEntryCategories.length);
      expect((await repo.watchPaymentMethods(bookId).first).length, defaultPaymentMethods.length);

      final queued = await outbox();
      // The book goes first: the server applies mutations in order
      expect(queued.first.tableName_, 'cashbooks');
      expect(queued.length, 1 + defaultEntryCategories.length + defaultPaymentMethods.length);
      expect(changes, greaterThan(0));
    });

    test('entries change the balance and edits queue only changed fields', () async {
      final bookId = await repo.createCashbook('ws1', 'Till', 'BDT');
      final book = (await repo.watchCashbook(bookId).first)!.book;
      final entryId = await repo.addEntry(book, entryType: 'cash_in', amountMinor: 10000, entryDate: '2026-10-01');
      await repo.addEntry(book, entryType: 'cash_out', amountMinor: 2500, entryDate: '2026-10-02', title: 'Tea');

      var summary = (await repo.watchCashbook(bookId).first)!;
      expect((summary.cashInMinor, summary.cashOutMinor, summary.balanceMinor, summary.entryCount),
          (10000, 2500, 7500, 2));

      final entries = await repo.watchEntries(bookId).first;
      expect(entries.first.entry.title, 'Tea'); // newest date first
      expect(entries.first.entry.currency, 'BDT'); // known locally before any sync

      final original = entries.firstWhere((e) => e.entry.id == entryId).entry;
      await repo.updateEntry(original, amountMinor: 12000, entryDate: original.entryDate);
      final edit = (await outbox()).last;
      expect((edit.op, edit.rowId), ('upsert', entryId));
      expect(jsonDecode(edit.data), {'amount_minor': 12000});

      await repo.deleteEntry(entryId);
      summary = (await repo.watchCashbook(bookId).first)!;
      expect((summary.balanceMinor, summary.entryCount), (-2500, 1));
      expect((await outbox()).last.op, 'delete');
    });

    test('an edit that changes nothing queues nothing', () async {
      final bookId = await repo.createCashbook('ws1', 'Till', 'BDT');
      final book = (await repo.watchCashbook(bookId).first)!.book;
      await repo.addEntry(book, entryType: 'cash_in', amountMinor: 100, entryDate: '2026-10-01');
      final entry = (await repo.watchEntries(bookId).first).single.entry;
      final before = (await outbox()).length;
      await repo.updateEntry(entry, amountMinor: 100, entryDate: '2026-10-01');
      expect((await outbox()).length, before);
    });

    test('breakdown totals per category', () async {
      final bookId = await repo.createCashbook('ws1', 'Till', 'BDT');
      final book = (await repo.watchCashbook(bookId).first)!.book;
      final food = (await repo.watchCategories(bookId).first).firstWhere((c) => c.categoryName == 'Food');
      await repo.addEntry(book, entryType: 'cash_out', amountMinor: 300, entryDate: '2026-10-01', categoryId: food.id);
      await repo.addEntry(book, entryType: 'cash_out', amountMinor: 200, entryDate: '2026-10-01', categoryId: food.id);
      await repo.addEntry(book, entryType: 'cash_in', amountMinor: 900, entryDate: '2026-10-01');

      final rows = await repo.watchBreakdown(bookId, byCategory: true).first;
      expect(rows.firstWhere((r) => r.name == 'Food').cashOutMinor, 500);
      expect(rows.firstWhere((r) => r.name == null).cashInMinor, 900);
    });

    test('a category colour reaches its entries and the breakdown, and only the change is queued', () async {
      final bookId = await repo.createCashbook('ws1', 'Till', 'BDT');
      final book = (await repo.watchCashbook(bookId).first)!.book;
      final food = (await repo.watchCategories(bookId).first).firstWhere((c) => c.categoryName == 'Food');
      await repo.addEntry(book, entryType: 'cash_out', amountMinor: 300, entryDate: '2026-10-01', categoryId: food.id);
      final rentId = await repo.addCategory(book, 'Rent', color: '#3B9EE5');

      await repo.updateCategory(food, name: 'Food', color: '#E8705F');
      expect((await repo.watchEntries(bookId).first).single.categoryColor, '#E8705F');
      final row = (await repo.watchBreakdown(bookId, byCategory: true).first).single;
      expect((row.id, row.color), (food.id, '#E8705F'));
      expect((await repo.watchBreakdown(bookId, byCategory: false).first).single.color, isNull);

      final queued = (await outbox()).map((o) => '${o.rowId} ${o.data}').toList();
      expect(queued.last, '${food.id} {"color":"#E8705F"}');
      expect(queued[queued.length - 2], contains('$rentId {"cashbook_id":"$bookId","category_name":"Rent"'));
      expect(queued[queued.length - 2], contains('"color":"#3B9EE5"'));
    });
  });

  test('category colours: stored as #RRGGBB, and the same automatic one for the same id', () {
    expect(toHexColor(parseHexColor('#e8705f')!), '#E8705F');
    expect(parseHexColor('red'), isNull);
    expect(categoryFill('#E8705F', 'a'), const Color(0xFFE8705F));
    expect(categoryFill(null, 'a'), categoryFill('nonsense', 'a'));
    expect(categoryPalette, contains(categoryFill(null, '0199c2f4-0000-7000-8000-000000000001')));
    expect(categoryPalette, isNot(contains(categoryFill(null, null)))); // uncategorised has its own grey
  });

  group('cashbook delete', () {
    test('deleting a book hides its rows at once and queues only the book', () async {
      final repo = CashbookRepository(db, store);
      final bookId = await repo.createCashbook('ws1', 'Till', 'BDT');
      final book = (await repo.watchCashbook(bookId).first)!.book;
      await repo.addEntry(book, entryType: 'cash_in', amountMinor: 500, entryDate: '2026-10-01');
      await db.delete(db.outbox).go();

      await repo.deleteCashbook(bookId);
      expect(await repo.watchCashbooks('ws1').first, isEmpty);
      expect(await repo.watchEntries(bookId).first, isEmpty);
      expect(await repo.watchCategories(bookId).first, isEmpty);
      expect((await outbox()).map((o) => (o.tableName_, o.op)).toList(), [('cashbooks', 'delete')]);
    });
  });

  group('personal ledger', () {
    late LedgerRepository repo;
    late Account cash;
    late Account bank;

    setUp(() async {
      repo = LedgerRepository(db, store);
      await repo.addAccount('ws1', name: 'Cash', kind: 'cash', currency: 'BDT', openingBalanceMinor: 100000);
      await repo.addAccount('ws1', name: 'Bank', kind: 'bank', currency: 'BDT');
      final accounts = await repo.watchAccounts('ws1').first;
      cash = accounts.firstWhere((a) => a.account.name == 'Cash').account;
      bank = accounts.firstWhere((a) => a.account.name == 'Bank').account;
    });

    Future<Map<String, int>> balances() async =>
        {for (final a in await repo.watchAccounts('ws1').first) a.account.name: a.balanceMinor};

    test('expenses subtract, income adds, transfers move money between accounts', () async {
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 2500, occurredOn: '2026-10-01');
      await repo.addTransaction(bank, kind: 'income', amountMinor: 500000, occurredOn: '2026-10-01');
      await repo.addTransfer(bank, cash, amountMinor: 30000, occurredOn: '2026-10-02');
      expect(await balances(), {'Cash': 127500, 'Bank': 470000});

      // Removing one leg of the transfer removes both
      final transfer = (await repo.watchTransactions('ws1').first)
          .firstWhere((t) => t.transaction.kind == 'transfer')
          .transaction;
      await repo.deleteTransaction(transfer);
      expect(await balances(), {'Cash': 97500, 'Bank': 500000});
    });

    test('month summary and budget progress', () async {
      final foodId = await repo.addCategory('ws1', 'Food', 'expense');
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 4000, occurredOn: '2026-10-05', categoryId: foodId);
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 1000, occurredOn: '2026-10-20', categoryId: foodId);
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 700, occurredOn: '2026-10-21');
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 9999, occurredOn: '2026-09-30', categoryId: foodId);
      await repo.addTransaction(cash, kind: 'income', amountMinor: 80000, occurredOn: '2026-10-01');
      await repo.addTransfer(cash, bank, amountMinor: 5000, occurredOn: '2026-10-03');

      final month = await repo.watchMonth('ws1', DateTime(2026, 10, 15), 'BDT').first;
      expect((month.incomeMinor, month.expenseMinor), (80000, 5700)); // transfers are neither
      expect(month.byCategory.map((e) => (e.name, e.amountMinor)).toList(), [('Food', 5000), (null, 700)]);
      // Food: two expenses this month, the bigger 4,000, against 9,999 the month before
      final food = month.byCategory.first;
      expect((food.count, food.largestMinor, food.previousMinor, food.changePercent), (2, 4000, 9999, -50));
      expect(month.byCategory.last.changePercent, isNull);

      await repo.setBudget('ws1', foodId, 4500, 'BDT');
      await repo.setBudget('ws1', foodId, 4800, 'BDT'); // same category: updates, does not duplicate
      final budgets = await repo.watchBudgets('ws1', DateTime(2026, 10, 15)).first;
      expect(budgets.single.budget.amountMinor, 4800);
      expect((budgets.single.spentMinor, budgets.single.isOver), (5000, true));
    });

    test('a split is counted part by part, and its parts travel with the amount', () async {
      final foodId = await repo.addCategory('ws1', 'Food', 'expense');
      final transportId = await repo.addCategory('ws1', 'Transport', 'expense');
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 45000, occurredOn: '2026-10-02', categoryId: foodId);
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 30000, occurredOn: '2026-10-02', note: 'Rickshaw');
      // Cash taken out and spent on several things
      final atmId = await repo.addTransaction(cash,
          kind: 'expense',
          amountMinor: 50000,
          occurredOn: '2026-10-06',
          note: 'ATM cash',
          categoryId: foodId,
          splits: [SplitPart(foodId, 20000), SplitPart(transportId, 10000), const SplitPart(null, 20000)]);
      Future<Transaction> atm() async =>
          (await repo.watchTransactions('ws1').first).firstWhere((t) => t.transaction.id == atmId).transaction;

      // The whole amount left the account, and a split has no category of its own
      expect((await balances())['Cash'], 100000 - 125000);
      expect(((await atm()).categoryId, (await atm()).parts.length), (null, 3));
      final created = jsonDecode((await outbox()).last.data) as Map<String, dynamic>;
      expect((created['amount_minor'], created['category_id']), (-50000, null));
      expect(created['splits'], [
        {'category_id': foodId, 'amount_minor': 20000, 'note': ''},
        {'category_id': transportId, 'amount_minor': 10000, 'note': ''},
        {'category_id': null, 'amount_minor': 20000, 'note': ''},
      ]);

      final month = DateTime(2026, 10, 15);
      final summary = await repo.watchMonth('ws1', month, 'BDT').first;
      expect(summary.expenseMinor, 125000);
      expect(summary.byCategory.map((e) => (e.name, e.amountMinor, e.count, e.largestMinor)).toList(),
          [('Food', 65000, 2, 45000), (null, 50000, 2, 30000), ('Transport', 10000, 1, 10000)]);

      await repo.setBudget('ws1', foodId, 60000, 'BDT');
      final budget = (await repo.watchBudgets('ws1', month).first).single;
      expect((budget.spentMinor, budget.isOver), (65000, true));
      expect(await repo.watchDailySpend('ws1', month, 'BDT').first, {2: 75000, 6: 50000});
      expect(await repo.watchDailySpend('ws1', month, 'BDT', categoryId: foodId).first, {2: 45000, 6: 20000});

      Future<List<String>> listed({String? categoryId, bool uncategorised = false}) async => [
            for (final t in await repo.watchTransactions('ws1', categoryId: categoryId, uncategorised: uncategorised).first)
              t.transaction.note,
          ];
      expect(await listed(categoryId: transportId), ['ATM cash']);
      expect(await listed(uncategorised: true), ['ATM cash', 'Rickshaw']);
      expect(await repo.transactionCount(foodId), 2);

      // A new amount goes with its parts, in one change; a note goes alone
      await repo.updateTransaction(await atm(),
          amountMinor: 40000,
          occurredOn: '2026-10-06',
          note: 'ATM cash',
          splits: [SplitPart(foodId, 30000), SplitPart(transportId, 10000)]);
      expect((jsonDecode((await outbox()).last.data) as Map).keys.toSet(), {'amount_minor', 'splits'});
      final same = (await atm()).parts;
      await repo.updateTransaction(await atm(), amountMinor: 40000, occurredOn: '2026-10-06', note: 'Bazar', splits: same);
      expect((jsonDecode((await outbox()).last.data) as Map).keys.toSet(), {'note'});

      // A deleted category leaves its part behind, uncategorised
      final transport = (await repo.watchCategories('ws1').first).firstWhere((c) => c.id == transportId);
      await repo.deleteCategory(transport);
      expect((await atm()).parts, [SplitPart(foodId, 30000), const SplitPart(null, 10000)]);

      // Back to one category
      await repo.updateTransaction(await atm(), amountMinor: 40000, occurredOn: '2026-10-06', note: 'Bazar', categoryId: foodId);
      expect(((await atm()).isSplit, (await atm()).categoryId), (false, foodId));
      expect(jsonDecode((await outbox()).last.data), {'category_id': foodId, 'splits': []});
    });

    test('a category colour follows the category everywhere, and clearing it is queued', () async {
      final foodId = await repo.addCategory('ws1', 'Food', 'expense', color: '#E8705F');
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 4000, occurredOn: '2026-10-05', categoryId: foodId);
      await repo.setBudget('ws1', foodId, 4500, 'BDT');
      final month = DateTime(2026, 10, 15);

      final slice = (await repo.watchMonth('ws1', month, 'BDT').first).byCategory.single;
      expect((slice.categoryId, slice.color), (foodId, '#E8705F'));
      expect((await repo.watchBudgets('ws1', month).first).single.categoryColor, '#E8705F');
      expect((await repo.watchTransactions('ws1').first).single.categoryColor, '#E8705F');

      final food = (await repo.watchCategories('ws1').first).single;
      final before = (await outbox()).length;
      await repo.updateCategory(food, name: 'Food', color: '#E8705F'); // nothing changed
      expect((await outbox()).length, before);
      await repo.updateCategory(food, name: 'Food', color: null);
      expect((await outbox()).last.data, '{"color":null}');
      expect((await repo.watchCategories('ws1').first).single.color, isNull);
    });

    test('a one-month override replaces the recurring budget for that month only', () async {
      final foodId = await repo.addCategory('ws1', 'Food', 'expense');
      await repo.setBudget('ws1', foodId, 5000, 'BDT');
      await repo.setBudget('ws1', foodId, 9000, 'BDT', month: '2026-12-01');
      await repo.setBudget('ws1', foodId, 9500, 'BDT', month: '2026-12-01'); // same month: updates

      final december = await repo.watchBudgets('ws1', DateTime(2026, 12, 10)).first;
      expect(december.single.budget.amountMinor, 9500);
      expect((december.single.isOverride, december.single.recurring?.amountMinor), (true, 5000));
      final november = await repo.watchBudgets('ws1', DateTime(2026, 11, 10)).first;
      expect((november.single.budget.amountMinor, november.single.isOverride), (5000, false));

      final queued = (await outbox()).where((o) => o.tableName_ == 'budgets').toList();
      expect(queued.map((o) => jsonDecode(o.data)['month']).toList(), [null, '2026-12-01', null]);

      // Removing the override brings the usual limit back
      await repo.deleteBudget(december.single.budget.id);
      expect((await repo.watchBudgets('ws1', DateTime(2026, 12, 10)).first).single.budget.amountMinor, 5000);
    });

    test('daily spend, six-month totals and change on the month before', () async {
      final foodId = await repo.addCategory('ws1', 'Food', 'expense');
      final rentId = await repo.addCategory('ws1', 'Rent', 'expense');
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 1000, occurredOn: '2026-10-03', categoryId: foodId);
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 500, occurredOn: '2026-10-03', categoryId: foodId);
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 20000, occurredOn: '2026-10-01', categoryId: rentId);
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 1000, occurredOn: '2026-09-12', categoryId: foodId);
      await repo.addTransaction(cash, kind: 'income', amountMinor: 50000, occurredOn: '2026-08-31');
      await repo.addTransfer(cash, bank, amountMinor: 3000, occurredOn: '2026-10-03');

      expect(await repo.watchDailySpend('ws1', DateTime(2026, 10), 'BDT').first, {1: 20000, 3: 1500});

      final trend = await repo.watchMonthlyTotals('ws1', DateTime(2026, 10), 'BDT').first;
      expect(trend.map((m) => m.month.month).toList(), [5, 6, 7, 8, 9, 10]);
      expect(trend.map((m) => (m.incomeMinor, m.expenseMinor)).toList().sublist(3),
          [(50000, 0), (0, 1000), (0, 21500)]);

      final october = await repo.watchMonth('ws1', DateTime(2026, 10), 'BDT').first;
      expect(october.byCategory.map((c) => (c.name, c.amountMinor, c.changePercent)).toList(),
          [('Rent', 20000, null), ('Food', 1500, 50)]);

      expect((await repo.watchTransactions('ws1', day: '2026-10-03').first).length, 4); // 2 expenses + 2 legs
      expect((await repo.watchTransactions('ws1', month: DateTime(2026, 9)).first).length, 1);
    });

    test('deleting a category keeps its transactions, uncategorised, and drops its budgets', () async {
      final foodId = await repo.addCategory('ws1', 'Food', 'expense');
      await repo.addTransaction(cash, kind: 'expense', amountMinor: 1000, occurredOn: '2026-10-03', categoryId: foodId);
      await repo.setBudget('ws1', foodId, 5000, 'BDT');
      final food = (await repo.watchCategories('ws1').first).single;
      expect(await repo.transactionCount(foodId), 1);

      await repo.updateCategory(food, name: 'Groceries', color: food.color);
      expect((await repo.watchCategories('ws1').first).single.name, 'Groceries');

      await repo.deleteCategory(food);
      expect(await repo.watchCategories('ws1').first, isEmpty);
      final remaining = await repo.watchTransactions('ws1').first;
      expect((remaining.single.transaction.categoryId, remaining.single.categoryName), (null, null));
      expect(await repo.watchBudgets('ws1', DateTime(2026, 10)).first, isEmpty);

      final queued = (await outbox()).map((o) => '${o.tableName_} ${o.op} ${o.data}').toList();
      expect(queued.sublist(queued.length - 3), [
        'transactions upsert {"category_id":null}',
        'budgets delete {}',
        'categories delete {}',
      ]);
    });
  });
}
