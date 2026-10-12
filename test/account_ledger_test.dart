import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/features/personal/account_ledger.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';

import 'test_support.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository repo;
  late AccountLedger ledger;
  late Account cash;
  late Account bank;
  late String foodId;
  late String salaryId;

  setUp(() async {
    db = memoryDatabase();
    repo = LedgerRepository(db, LocalStore(db));
    ledger = AccountLedger(db);
    await repo.addAccount('ws1', name: 'Cash', kind: 'cash', currency: 'BDT', openingBalanceMinor: 100000);
    await repo.addAccount('ws1', name: 'Brac Bank', kind: 'bank', currency: 'BDT');
    final accounts = await repo.watchAccounts('ws1').first;
    cash = accounts.firstWhere((a) => a.account.name == 'Cash').account;
    bank = accounts.firstWhere((a) => a.account.name == 'Brac Bank').account;
    foodId = await repo.addCategory('ws1', 'Food', 'expense');
    salaryId = await repo.addCategory('ws1', 'Salary', 'income');
  });
  tearDown(() => db.close());

  Future<void> expense(int amount, String day, {String? category, String note = ''}) =>
      repo.addTransaction(cash, kind: 'expense', amountMinor: amount, occurredOn: day, categoryId: category, note: note);

  Future<void> income(int amount, String day, {String? category, String note = ''}) =>
      repo.addTransaction(cash, kind: 'income', amountMinor: amount, occurredOn: day, categoryId: category, note: note);

  /// Salary, three expenses and a transfer each way across September and October.
  Future<void> seed() async {
    await income(5000000, '2026-09-01', category: salaryId, note: 'September pay');
    await expense(120000, '2026-09-10', category: foodId, note: 'Groceries');
    await repo.addTransfer(cash, bank, amountMinor: 2000000, occurredOn: '2026-09-15');
    await expense(45000, '2026-10-02', category: foodId, note: 'Lunch 50% off');
    await expense(30000, '2026-10-02', note: 'Rickshaw');
    await repo.addTransfer(bank, cash, amountMinor: 500000, occurredOn: '2026-10-05', note: 'ATM');
  }

  Future<List<AccountFeedRow>> all(AccountFilter filter, {int limit = feedPageSize}) async {
    final rows = <AccountFeedRow>[];
    FeedCursor? cursor;
    while (true) {
      final (page, hasMore) = await ledger.page(cash.id, 'BDT', filter, cursor: cursor, limit: limit);
      rows.addAll(page);
      if (!hasMore) return rows;
      expect(page.length, limit);
      final t = page.last.transaction;
      cursor = (t.occurredOn, t.createdAt, t.id);
    }
  }

  test('pages walk every row once, newest first, even when rows share a day and a moment', () async {
    // One timestamp for all: only the id tells them apart
    for (var i = 0; i < 23; i++) {
      await expense(100 + i, i < 12 ? '2026-10-02' : '2026-10-01');
    }
    await db.customStatement("UPDATE transactions SET created_at = '2026-10-02T08:00:00.000Z'");

    final rows = await all(const AccountFilter(), limit: 5);
    expect(rows.length, 23);
    expect(rows.map((r) => r.transaction.id).toSet().length, 23);
    final keys = [for (final r in rows) '${r.transaction.occurredOn} ${r.transaction.id}'];
    expect(keys, [...keys]..sort((a, b) => b.compareTo(a)));

    final (page, hasMore) = await ledger.page(cash.id, 'BDT', const AccountFilter(), limit: 23);
    expect((page.length, hasMore), (23, false));
  });

  test('the page query reads the account in index order, with nothing to sort', () async {
    final plan = await db.customSelect(
      'EXPLAIN QUERY PLAN SELECT t.* FROM transactions t '
      "WHERE t.account_id = 'a' AND t.deleted_at IS NULL AND (t.occurred_on, t.created_at, t.id) < ('d', 'c', 'i') "
      'ORDER BY t.occurred_on DESC, t.created_at DESC, t.id DESC LIMIT 41',
    ).get();
    final detail = plan.map((row) => row.read<String>('detail')).join('\n');
    expect(detail, contains('transactions_account_feed'));
    expect(detail, isNot(contains('TEMP B-TREE')));
  });

  test('only this account, without what was deleted, and a transfer names the other account', () async {
    await seed();
    await repo.addTransaction(bank, kind: 'expense', amountMinor: 999, occurredOn: '2026-10-03');
    final rows = await all(const AccountFilter());
    expect(rows.length, 6);
    expect(rows.every((r) => r.transaction.accountId == cash.id), isTrue);

    final transfers = rows.where((r) => r.transaction.kind == 'transfer').toList();
    expect(transfers.map((r) => (r.transaction.amountMinor, r.otherAccountName)).toList(),
        [(500000, 'Brac Bank'), (-2000000, 'Brac Bank')]);
    expect(rows.firstWhere((r) => r.transaction.note == 'Groceries').view.categoryName, 'Food');

    await repo.deleteTransaction(rows.firstWhere((r) => r.transaction.note == 'Rickshaw').transaction);
    expect((await all(const AccountFilter())).length, 5);
  });

  test('filters: dates, kind, categories, uncategorised and search', () async {
    await seed();
    Future<List<String>> notes(AccountFilter filter) async => [
          for (final r in await all(filter))
            r.transaction.note.isEmpty ? r.transaction.kind : r.transaction.note,
        ];
    const everything = AccountFilter();
    final october = everything.withPeriod(AccountPeriod.thisMonth, now: DateTime(2026, 10, 12));
    expect((october.from, october.to), ('2026-10-01', '2026-10-31'));
    expect(await notes(october), ['ATM', 'Rickshaw', 'Lunch 50% off']);
    expect(await notes(everything.withPeriod(AccountPeriod.lastMonth, now: DateTime(2026, 10, 12))),
        ['transfer', 'Groceries', 'September pay']);
    expect(await notes(everything.withPeriod(AccountPeriod.custom, from: '2026-09-10', to: '2026-10-02')),
        ['Rickshaw', 'Lunch 50% off', 'transfer', 'Groceries']);

    expect(await notes(everything.copyWith(kind: () => 'transfer')), ['ATM', 'transfer']);
    expect(await notes(everything.copyWith(kind: () => 'income')), ['September pay']);
    expect(await notes(everything.copyWith(categoryIds: {foodId})), ['Lunch 50% off', 'Groceries']);
    // Transfers have no category, but they are not "uncategorised"
    expect(await notes(everything.copyWith(uncategorised: true)), ['Rickshaw']);
    expect(await notes(everything.copyWith(categoryIds: {salaryId}, uncategorised: true)),
        ['Rickshaw', 'September pay']);
    expect(await notes(october.copyWith(categoryIds: {foodId})), ['Lunch 50% off']);

    expect(await notes(everything.copyWith(query: 'groc')), ['Groceries']);
    expect(await notes(everything.copyWith(query: 'food')), ['Lunch 50% off', 'Groceries']); // by category
    expect(await notes(everything.copyWith(query: 'brac')), ['ATM', 'transfer']); // by the other account
    expect(await notes(everything.copyWith(query: '1,200')), ['Groceries']); // by amount
    expect(await notes(everything.copyWith(query: '১২০০')), ['Groceries']); // typed in Bangla
    expect(await notes(everything.copyWith(query: '50%')), ['Lunch 50% off']); // % is not a wildcard
    expect(await notes(everything.copyWith(query: 'nothing here')), isEmpty);
  });

  test('the summary adds up, and opening plus in minus out is closing', () async {
    await seed();
    final total = await ledger.watchSummary(cash.id, 'BDT', const AccountFilter()).first;
    expect((total.incomeMinor, total.expenseMinor), (5000000, 195000));
    expect((total.transferInMinor, total.transferOutMinor), (500000, 2000000));
    expect((total.cashInMinor, total.cashOutMinor, total.count), (5500000, 2195000, 6));
    expect((total.openingMinor, total.closingMinor), (100000, 3405000));
    expect(total.openingMinor + total.cashInMinor - total.cashOutMinor, total.closingMinor);
    expect((total.largestExpenseMinor, total.firstDay, total.lastDay), (120000, '2026-09-01', '2026-10-05'));
    expect((await ledger.watchAccount(cash.id).first)!.balanceMinor, total.closingMinor);

    final october = const AccountFilter().withPeriod(AccountPeriod.thisMonth, now: DateTime(2026, 10, 12));
    final month = await ledger.watchSummary(cash.id, 'BDT', october).first;
    expect((month.cashInMinor, month.cashOutMinor), (500000, 75000));
    expect((month.openingMinor, month.closingMinor), (2980000, 3405000));
    expect(month.openingMinor + month.cashInMinor - month.cashOutMinor, month.closingMinor);

    // Narrowing changes what is counted, never the balances around the period
    final food = await ledger.watchSummary(cash.id, 'BDT', october.copyWith(categoryIds: {foodId})).first;
    expect((food.expenseMinor, food.cashInMinor, food.count), (45000, 0, 1));
    expect((food.openingMinor, food.closingMinor), (2980000, 3405000));
    final searched = await ledger.watchSummary(cash.id, 'BDT', const AccountFilter(query: 'brac')).first;
    expect((searched.transferInMinor, searched.transferOutMinor, searched.count), (500000, 2000000, 2));

    final empty = await ledger.watchSummary(bank.id, 'BDT', const AccountFilter(query: 'zzz')).first;
    expect((empty.count, empty.cashInMinor, empty.firstDay), (0, 0, null));
  });

  test('categories: the expense side and the income side', () async {
    await seed();
    final spent = await ledger.watchCategories(cash.id, 'BDT', const AccountFilter()).first;
    expect(spent.map((c) => (c.name, c.amountMinor, c.count, c.largestMinor)).toList(),
        [('Food', 165000, 2, 120000), (null, 30000, 1, 30000)]);
    final earned = await ledger.watchCategories(cash.id, 'BDT', const AccountFilter(), income: true).first;
    expect(earned.map((c) => (c.name, c.amountMinor)).toList(), [('Salary', 5000000)]);
    final october = const AccountFilter().withPeriod(AccountPeriod.thisMonth, now: DateTime(2026, 10, 12));
    expect((await ledger.watchCategories(cash.id, 'BDT', october).first).first.amountMinor, 45000);
  });

  test('the series runs by day, then by month once the span is long', () async {
    await seed();
    final daily = await ledger.watchSeries(cash.id, 'BDT', const AccountFilter()).first;
    expect(daily.monthly, isFalse);
    expect(daily.openingMinor, 100000);
    expect(daily.points.map((p) => (isoDate(p.date), p.inMinor, p.outMinor, p.balanceMinor)).toList(), [
      ('2026-09-01', 5000000, 0, 5100000),
      ('2026-09-10', 0, 120000, 4980000),
      ('2026-09-15', 0, 2000000, 2980000),
      ('2026-10-02', 0, 75000, 2905000),
      ('2026-10-05', 500000, 0, 3405000),
    ]);

    // In and out follow the filter; the balance still counts everything
    final food = await ledger.watchSeries(cash.id, 'BDT', const AccountFilter().copyWith(categoryIds: {foodId})).first;
    expect(food.points.map((p) => (p.inMinor, p.outMinor)).toList(),
        [(0, 0), (0, 120000), (0, 0), (0, 45000), (0, 0)]);
    expect(food.points.last.balanceMinor, 3405000);

    await income(1000, '2026-01-20');
    final monthly = await ledger.watchSeries(cash.id, 'BDT', const AccountFilter()).first;
    expect(monthly.monthly, isTrue);
    expect(monthly.points.map((p) => (isoDate(p.date), p.inMinor, p.outMinor, p.balanceMinor)).toList(), [
      ('2026-01-01', 1000, 0, 101000),
      ('2026-09-01', 5000000, 2120000, 2981000),
      ('2026-10-01', 500000, 75000, 3406000),
    ]);

    final october = const AccountFilter().withPeriod(AccountPeriod.thisMonth, now: DateTime(2026, 10, 12));
    expect((await ledger.watchSeries(cash.id, 'BDT', october).first).openingMinor, 2981000);
  });

  group('feed', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      addTearDown(container.dispose);
    });

    Future<AccountFeed> settled(String accountId) async {
      // Kept alive for the test, as the screen keeps it while open
      container.listen(accountFeedProvider(accountId), (_, _) {});
      for (var i = 0; i < 200; i++) {
        final feed = container.read(accountFeedProvider(accountId));
        if (!feed.loading && !feed.loadingMore) return feed;
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      fail('the feed never loaded');
    }

    test('loads a page at a time and carries the running balance across pages', () async {
      for (var i = 1; i <= 95; i++) {
        await expense(100, '2026-${(1 + i ~/ 28).toString().padLeft(2, '0')}-${(1 + i % 28).toString().padLeft(2, '0')}');
      }
      var feed = await settled(cash.id);
      expect((feed.rows.length, feed.hasMore), (feedPageSize, true));
      // Newest row carries today's balance; each row below adds its expense back
      expect(feed.rows.first.balanceAfterMinor, 100000 - 95 * 100);
      expect(feed.rows[1].balanceAfterMinor, 100000 - 94 * 100);

      final controller = container.read(accountFeedProvider(cash.id).notifier);
      await controller.loadMore();
      await controller.loadMore();
      feed = await settled(cash.id);
      expect((feed.rows.length, feed.hasMore), (95, false));
      expect(feed.rows.map((r) => r.transaction.id).toSet().length, 95);
      // The oldest row leaves the opening balance behind it
      expect(feed.rows.last.balanceAfterMinor! - feed.rows.last.transaction.amountMinor, 100000);
      await controller.loadMore(); // nothing more: a no-op
      expect(container.read(accountFeedProvider(cash.id)).rows.length, 95);
    });

    test('a change to the data shows without losing what is loaded', () async {
      for (var i = 1; i <= 60; i++) {
        await expense(100, '2026-09-${(1 + i % 28).toString().padLeft(2, '0')}');
      }
      await settled(cash.id);
      await container.read(accountFeedProvider(cash.id).notifier).loadMore();
      expect((await settled(cash.id)).rows.length, 60);

      await income(7000, '2026-10-10', note: 'Refund');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final feed = await settled(cash.id);
      expect(feed.rows.first.transaction.note, 'Refund');
      expect(feed.rows.first.balanceAfterMinor, 100000 - 60 * 100 + 7000);
      expect(feed.rows.length, 60); // the window stays as long as it was
      expect(feed.hasMore, isTrue);
    });

    test('a filter starts again from the top, and narrowing drops the running balance', () async {
      await seed();
      expect((await settled(cash.id)).rows.length, 6);
      container.read(accountFilterProvider(cash.id).notifier).set(const AccountFilter(kind: 'expense'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      var feed = await settled(cash.id);
      expect(feed.rows.length, 3);
      expect(feed.rows.every((r) => r.balanceAfterMinor == null), isTrue);

      // A period alone keeps it: the balance at the end of September
      container.read(accountFilterProvider(cash.id).notifier).set(
            const AccountFilter().withPeriod(AccountPeriod.lastMonth, now: DateTime(2026, 10, 12)),
          );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      feed = await settled(cash.id);
      expect(feed.rows.map((r) => r.balanceAfterMinor).toList(), [2980000, 4980000, 5100000]);
    });
  });
}
