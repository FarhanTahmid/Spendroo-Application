import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spendroo/core/auth/auth_repository.dart';
import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/entitlements/entitlements_controller.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/core/push/push_controller.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';
import 'package:spendroo/features/cashbook/cashbook_pages.dart';
import 'package:spendroo/features/home_widget/business/biz_queries.dart';
import 'package:spendroo/features/home_widget/business/biz_quick_add.dart';
import 'package:spendroo/features/home_widget/business/biz_snapshot.dart';
import 'package:spendroo/features/home_widget/business/biz_snapshot_builder.dart';
import 'package:spendroo/features/home_widget/business/biz_widget_controller.dart';
import 'package:spendroo/features/home_widget/home_widget_providers.dart';
import 'package:spendroo/features/home_widget/widget_launch.dart';
import 'package:spendroo/l10n/app_localizations.dart';

import 'home_widget_controller_test.dart' show FakeAuth, FixedDay;
import 'personal_screens_test.dart' show FixedEntitlements, ScreenHarness, workspace;
import 'plan_test.dart' show answer, entitlements;
import 'test_support.dart';

final en = lookupAppLocalizations(const Locale('en'));
final bn = lookupAppLocalizations(const Locale('bn'));

/// Saturday 17 October 2026, as in the personal widget's tests.
final today = DateTime(2026, 10, 17);

const shop = Workspace(
  id: '00000000-0000-0000-0000-0000000000b1',
  name: 'Rahman Traders',
  kind: 'business',
  defaultCurrency: 'BDT',
  isDemo: false,
  role: 'owner',
);

Cashbook book(String id, String name, {String currency = 'BDT', String workspaceId = 'w'}) => Cashbook(
  id: id,
  workspaceId: workspaceId,
  version: 1,
  serverSeq: 0,
  createdAt: '2026-09-01T00:00:00Z',
  updatedAt: '2026-09-01T00:00:00Z',
  bookName: name,
  currency: currency,
);

BookFacts facts(
  Cashbook cashbook, {
  int balance = 0,
  int entries = 1,
  Map<String, DayFlow> daily = const {},
  bool canAdd = true,
  String? lastEntry = '2026-10-17',
  Map<String, int> categories = const {},
  BigOut? biggest,
  List<RecentEntry> recent = const [],
}) => BookFacts(
  book: cashbook,
  balanceMinor: balance,
  entryCount: entries,
  daily: daily,
  canAdd: canAdd,
  lastEntry: lastEntry,
  monthCategories: categories,
  weekBiggest: biggest,
  recent: recent,
);

/// Plus with the business widgets, as the server's catalogue gives it.
Entitlements plusWithBizWidget() => Entitlements(
  answer(
    plan: 'plus',
    features: {
      F.businessWidget: {'kind': 'flag', 'enabled': true},
    },
  ),
  fetchedAt: DateTime.utc(2026, 10, 10),
);

/// A September and October for one book: money in most days, a heavy Rent day.
final till = book('b1', 'Till');
final tillDaily = {
  '2026-09-03': const DayFlow(0, 400000),
  '2026-09-10': const DayFlow(100000, 100000),
  '2026-10-02': const DayFlow(300000, 50000),
  '2026-10-14': const DayFlow(20000, 10000),
  '2026-10-15': const DayFlow(20000, 10000),
  '2026-10-16': const DayFlow(1000, 3000),
  '2026-10-17': const DayFlow(5000, 2000),
};

BizSnapshot tillSnapshot({AppLocalizations? l10n, int balance = 281000, bool canAdd = true}) => buildBookSnapshot(
  workspace: shop,
  facts: facts(
    till,
    balance: balance,
    entries: 7,
    daily: tillDaily,
    canAdd: canAdd,
    categories: const {'Rent': 50000, 'Food': 20000, '': 5000},
    biggest: const BigOut('Rent', 50000),
    recent: const [
      RecentEntry(title: 'Sales', cashIn: true, amountMinor: 5000, entryDate: '2026-10-17'),
      RecentEntry(title: null, cashIn: false, amountMinor: 2000, entryDate: '2026-10-17'),
    ],
  ),
  l10n: l10n ?? en,
  today: today,
);

/// What the business widgets would be handed, kept for the test to read.
class RecordingBizBridge implements BizWidgetBridge {
  final writes = <Map<String, String?>>[];
  final stored = <String, String>{};

  @override
  Future<void> publish(Map<String, String?> values) async {
    writes.add(Map.of(values));
    values.forEach((key, value) => value == null ? stored.remove(key) : stored[key] = value);
  }

  @override
  Future<String?> read(String key) async => stored[key];

  @override
  Future<bool> canPin() async => false;

  @override
  Future<void> requestPin(BizWidgetKind kind) async {}

  Map<String, dynamic>? json(String key) =>
      stored[key] == null ? null : (jsonDecode(stored[key]!) as Map).cast<String, dynamic>();
}

void main() {
  setUpAll(() => initializeDateFormatting('bn'));

  group('a cashbook snapshot', () {
    test('today, 7 days and the month, each against the stretch before', () {
      final s = tillSnapshot();
      expect(s.kind, 'book');
      expect(s.name, 'Till');
      expect(s.subtitle, 'Rahman Traders');
      expect(s.date, '2026-10-17');
      expect(s.balance, '৳2,810');
      expect(s.canAdd, isTrue);

      expect(s.today.label, 'Today');
      expect(s.today.inText, '৳50');
      expect(s.today.outText, '৳20');
      expect(s.today.netText, '+৳30');
      // 50 in against yesterday's 10; 20 out against 30
      expect(s.today.inChange, '▲400%');
      expect(s.today.inChangeGood, isTrue);
      expect(s.today.outChange, '▼33%');
      expect(s.today.outChangeGood, isTrue);

      // The 11th to the 17th, against the 4th to the 10th (nothing then)
      expect(s.week.inText, '৳460');
      expect(s.week.outText, '৳250');
      expect(s.week.inChange, isNull);

      expect(s.month.label, 'October');
      expect(s.month.inText, '৳3,460');
      expect(s.month.outText, '৳750');
      // The same days of September: 1,000 in, 5,000 out
      expect(s.month.inChange, '▲246%');
      expect(s.month.outChange, '▼85%');
      expect(s.month.compare, 'vs last month');
    });

    test('a fortnight of bars ending today, and labels for the week after', () {
      final s = tillSnapshot();
      expect(s.dailyIn, hasLength(14));
      expect(s.dailyIn.last, 5000);
      expect(s.dailyOut[12], 3000);
      expect(s.dayLabels, hasLength(20));
      expect(s.dayLabels.first, '4');
      expect(s.dayLabels[13], '17');
      expect(s.dayLabels.last, '23');
      // What "7 days" reads on each of the next six days if nothing more comes in
      expect(s.weekRoll, hasLength(6));
      expect(s.weekRoll.first.inText, '৳460');
      expect(s.weekRoll.last.inText, '৳50');
    });

    test('a negative net reads as such', () {
      final s = buildBookSnapshot(
        workspace: shop,
        facts: facts(till, daily: {'2026-10-17': const DayFlow(100, 900)}),
        l10n: en,
        today: today,
      );
      expect(s.today.netText, '-৳8');
      expect(s.today.netNegative, isTrue);
    });

    test('latest entries, with a title or what kind they are', () {
      final rows = tillSnapshot().rows;
      expect(rows.map((r) => r.title), ['Sales', 'Cash out']);
      expect(rows.map((r) => r.amount), ['+৳50', '-৳20']);
      expect(rows.map((r) => r.negative), [false, true]);
      expect(rows.first.detail, '17 Oct');
      expect(rows.first.link, 'spendroo://book?id=b1&ws=${shop.id}');
    });

    test('in Bangla, with Bangla digits', () {
      final s = tillSnapshot(l10n: bn);
      expect(s.today.inText, '৳৫০');
      expect(s.today.inChange, '▲৪০০%');
      expect(s.dayLabels[13], '১৭');
      final business = buildBusinessSnapshot(workspace: shop, books: [facts(till, entries: 7)], l10n: bn, today: today);
      expect(business.subtitle, '১টি ক্যাশবুক');
      expect(business.rows.single.detail, '৭টি এন্ট্রি');
    });
  });

  group('insights', () {
    test('ranked, most useful first, and only those worth saying', () {
      final kinds = tillSnapshot().insights.map((i) => i.kind).toList();
      expect(kinds, hasLength(4));
      // In up 246% on last month just beats out down 85% (each change counts up to 100%)
      expect(kinds.take(2), ['inChange', 'outChange']);
      expect(kinds, contains('projection'));
      expect(kinds, isNot(contains('idle')));
    });

    test('below zero comes first, with and without the amount', () {
      final insight = tillSnapshot(balance: -12000).insights.first;
      expect(insight.kind, 'negative');
      expect(insight.text, 'Balance is ৳120 below zero');
      expect(insight.masked, 'Balance is below zero');
      expect(insight.tone, BizTone.warn);
      expect(insight.until, '9999-12-31');
    });

    test('a quiet book says since when, so it stays true while the app is closed', () {
      final s = buildBookSnapshot(
        workspace: shop,
        facts: facts(till, balance: 100, lastEntry: '2026-10-09', daily: {'2026-10-09': const DayFlow(100, 0)}),
        l10n: en,
        today: today,
      );
      final idle = s.insights.firstWhere((i) => i.kind == 'idle');
      expect(idle.text, 'No entries since 9 Oct');
    });

    test('the top category, and the week\'s biggest cash out without its amount when hidden', () {
      final s = buildBookSnapshot(
        workspace: shop,
        facts: facts(
          till,
          balance: 100,
          daily: {'2026-10-17': const DayFlow(0, 75000)},
          categories: const {'Rent': 50000, 'Food': 25000},
          biggest: const BigOut('Rent', 50000),
        ),
        l10n: en,
        today: today,
      );
      final top = s.insights.firstWhere((i) => i.kind == 'topCategory');
      expect(top.text, "Rent is 67% of this month's cash out");
      final biggest = s.insights.firstWhere((i) => i.kind == 'biggestOut');
      expect(biggest.text, 'Biggest cash out this week: Rent, ৳500');
      expect(biggest.masked, 'Biggest cash out this week: Rent');
      expect(biggest.until, '2026-10-17');
    });

    test('a streak of days with more in than out', () {
      final s = buildBookSnapshot(
        workspace: shop,
        facts: facts(
          till,
          balance: 100,
          daily: {for (var day = 13; day <= 17; day++) '2026-10-$day': const DayFlow(500, 100)},
        ),
        l10n: en,
        today: today,
      );
      expect(s.insights.map((i) => i.text), contains('Cash in beat cash out 5 days running'));
    });

    test('an empty book says how to start', () {
      final s = buildBookSnapshot(
        workspace: shop,
        facts: facts(till, entries: 0, lastEntry: null),
        l10n: en,
        today: today,
      );
      expect(s.insights.single.text, 'Add the first entry to see insights here');
    });
  });

  group('a business snapshot', () {
    final cash = facts(
      book('b1', 'Shop cash', workspaceId: shop.id),
      balance: 50000,
      entries: 12,
      daily: {'2026-10-17': const DayFlow(30000, 10000)},
      canAdd: false,
    );
    final bank = facts(
      book('b2', 'Bank', workspaceId: shop.id),
      balance: -20000,
      entries: 4,
      daily: {'2026-10-16': const DayFlow(0, 40000)},
      canAdd: true,
    );
    final dollars = facts(book('b3', 'Export', currency: 'USD', workspaceId: shop.id), balance: 99900);

    BizSnapshot business() =>
        buildBusinessSnapshot(workspace: shop, books: [cash, bank, dollars], l10n: en, today: today);

    test('adds up the books in the main currency and notes the rest', () {
      final s = business();
      expect(s.kind, 'business');
      expect(s.name, 'Rahman Traders');
      expect(s.balance, '৳300');
      expect(s.subtitle, '3 cashbooks · +1 in USD');
      expect(s.today.inText, '৳300');
      expect(s.month.outText, '৳500');
      // One book is enough to add from
      expect(s.canAdd, isTrue);
    });

    test('lists the books by balance, each opening in its business', () {
      final rows = business().rows;
      expect(rows.map((r) => r.title), ['Export', 'Shop cash', 'Bank']);
      expect(rows.first.amount, r'$999');
      expect(rows.first.detail, '1 entry · USD');
      expect(rows.last.negative, isTrue);
      expect(rows[1].link, 'spendroo://book?id=b1&ws=${shop.id}');
    });

    test('names the book below zero, and the best and worst this month', () {
      final insights = business().insights;
      expect(insights.first.text, 'Bank is ৳200 below zero');
      expect(insights.first.masked, 'Bank is below zero');
      expect(insights.map((i) => i.kind), containsAll(['losingBook', 'leadBook']));
      expect(insights.firstWhere((i) => i.kind == 'leadBook').text, 'Shop cash leads this month at +৳200');
    });
  });

  group('the catalog', () {
    test('lists businesses with their books, and the words', () {
      final catalog = buildBizCatalog(
        businesses: [
          (shop, [facts(till, balance: 281000, entries: 7)]),
        ],
        plan: plusWithBizWidget(),
        l10n: en,
        today: today,
      );
      expect(catalog.signedIn, isTrue);
      expect(catalog.unlocked, isTrue);
      expect(catalog.businesses.single.detail, '1 cashbook');
      expect(catalog.businesses.single.books.single.detail, '৳2,810 · 7 entries');
      expect(catalog.strings['cashIn'], 'Cash in');
      expect(catalog.strings['chooseBook'], 'Choose a cashbook');
    });

    test('the plan decides the big sizes; an unknown or unenforced plan locks nothing', () {
      expect(bizWidgetLocked(entitlements(), now: today), isTrue);
      expect(bizWidgetLocked(plusWithBizWidget(), now: today), isFalse);
      expect(bizWidgetLocked(null, now: today), isFalse);
    });
  });

  group('links', () {
    const ws = '00000000-0000-0000-0000-0000000000b1';
    test('the business widgets\' links open their screens in their business', () {
      expect(widgetRoute(Uri.parse('spendroo://business?ws=$ws')), '/?ws=$ws');
      expect(widgetRoute(Uri.parse('spendroo://book?id=b1&ws=$ws')), '/cashbook/b1?ws=$ws');
      expect(
        widgetRoute(Uri.parse('spendroo://book-add?id=b1&ws=$ws&type=cash_in')),
        '/cashbook/b1/entry?type=cash_in&ws=$ws',
      );
      expect(
        widgetRoute(Uri.parse('spendroo://business-add?ws=$ws&type=cash_out')),
        '/business/$ws/add?type=cash_out&ws=$ws',
      );
      // An unknown kind of entry opens on cash out
      expect(
        widgetRoute(Uri.parse('spendroo://book-add?id=b1&ws=$ws&type=refund')),
        '/cashbook/b1/entry?type=cash_out&ws=$ws',
      );
    });

    test('links without their ids, or with odd ones, are not followed', () {
      expect(widgetRoute(Uri.parse('spendroo://book?id=b1')), isNull);
      expect(widgetRoute(Uri.parse('spendroo://business')), isNull);
      expect(widgetRoute(Uri.parse('spendroo://book?id=../plan&ws=$ws')), isNull);
    });

    test('the app opens those screens from a widget', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final route = container.read(pushRouteProvider.notifier);
      for (final path in ['/cashbook/b1?ws=$ws', '/cashbook/b1/entry?type=cash_in', '/business/$ws/add', '/?ws=$ws']) {
        route.openFromWidget(path);
        expect(container.read(pushRouteProvider), path);
        route.done();
      }
      route.openFromWidget('/settings');
      expect(container.read(pushRouteProvider), isNull);
      route.openFromWidget('/cashbook/b1/report');
      expect(container.read(pushRouteProvider), isNull);
    });
  });

  group('the widgets follow the books', () {
    late AppDatabase db;
    late LocalStore store;
    late CashbookRepository books;
    late RecordingBizBridge bridge;
    late FakeAuth auth;
    late ProviderContainer container;
    late String tillId;

    setUp(() async {
      db = memoryDatabase();
      store = LocalStore(db);
      books = CashbookRepository(db, store);
      bridge = RecordingBizBridge();
      auth = FakeAuth(const AuthState(AuthStep.signedIn));
      await db.into(db.workspaces).insert(workspace);
      await db.into(db.workspaces).insert(shop);
      tillId = await books.createCashbook(shop.id, 'Till', 'BDT');
      final cashbook = (await books.watchCashbook(tillId).first)!.book;
      await books.addEntry(
        cashbook,
        entryType: 'cash_in',
        amountMinor: 120000,
        entryDate: '2026-10-17',
        title: 'Sales',
      );
      await books.addEntry(cashbook, entryType: 'cash_out', amountMinor: 20000, entryDate: '2026-10-16');
      // A deleted entry counts for nothing
      final mistake = await books.addEntry(
        cashbook,
        entryType: 'cash_out',
        amountMinor: 99900,
        entryDate: '2026-10-17',
      );
      await books.deleteEntry(mistake);
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          localStoreProvider.overrideWithValue(store),
          tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
          authControllerProvider.overrideWith(() => auth),
          entitlementsProvider.overrideWith(() => FixedEntitlements(plusWithBizWidget())),
          widgetDayProvider.overrideWith(FixedDay.new),
          bizWidgetBridgeProvider.overrideWithValue(bridge),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    Future<Map<String, String?>> next() async {
      final seen = bridge.writes.length;
      for (var i = 0; i < 100 && bridge.writes.length == seen; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(bridge.writes.length, greaterThan(seen), reason: 'the widgets were sent nothing');
      return bridge.writes.last;
    }

    test('the catalog, the business and each book are stored, then only what changes', () async {
      container.listen(bizWidgetControllerProvider, (_, _) {});
      final first = await next();
      expect(
        first.keys,
        containsAll([BizKeys.catalog, BizKeys.business(shop.id), BizKeys.book(tillId), BizKeys.published]),
      );

      final catalog = bridge.json(BizKeys.catalog)!;
      expect(catalog['signedIn'], isTrue);
      expect(catalog['unlocked'], isTrue);
      expect((catalog['businesses'] as List).single['name'], 'Rahman Traders');

      final tillJson = bridge.json(BizKeys.book(tillId))!;
      expect(tillJson['balance'], '৳1,000');
      expect(tillJson['today']['in'], '৳1,200');
      expect(tillJson['today']['out'], '৳0');
      expect(tillJson['week']['out'], '৳200');
      expect(tillJson['canAdd'], isTrue);
      expect(tillJson['updated'], startsWith('Updated '));
      expect((tillJson['rows'] as List).first['title'], 'Sales');
      expect(bridge.json(BizKeys.business(shop.id))!['balance'], '৳1,000');

      // A new entry rewrites the book and its business, not the catalog's unchanged words
      final cashbook = (await books.watchCashbook(tillId).first)!.book;
      await books.addEntry(cashbook, entryType: 'cash_out', amountMinor: 5000, entryDate: '2026-10-17');
      final second = await next();
      expect(second.keys, containsAll([BizKeys.book(tillId), BizKeys.business(shop.id)]));
      expect(bridge.json(BizKeys.book(tillId))!['today']['out'], '৳50');
    });

    test('a deleted book leaves the home screen', () async {
      container.listen(bizWidgetControllerProvider, (_, _) {});
      await next();
      await books.deleteCashbook(tillId);
      final write = await next();
      expect(write.containsKey(BizKeys.book(tillId)), isTrue);
      expect(write[BizKeys.book(tillId)], isNull);
      expect(bridge.stored.containsKey(BizKeys.book(tillId)), isFalse);
      expect(jsonDecode(bridge.stored[BizKeys.published]!), [BizKeys.business(shop.id)]);
    });

    test('signing out takes every figure off the home screen', () async {
      container.listen(bizWidgetControllerProvider, (_, _) {});
      await next();
      auth.set(const AuthState(AuthStep.signedOut));
      await next();
      expect(bridge.json(BizKeys.catalog)!['signedIn'], isFalse);
      expect(bridge.stored.keys.where((k) => k.startsWith('book_') || k.startsWith('biz_${shop.id}')), isEmpty);
    });

    test('a viewer cannot add, and the free plan keeps the big sizes', () async {
      await db.update(db.workspaces).replace(shop.copyWith(role: 'viewer'));
      final plan = FixedEntitlements(entitlements());
      final free = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          localStoreProvider.overrideWithValue(store),
          tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
          authControllerProvider.overrideWith(() => auth),
          entitlementsProvider.overrideWith(() => plan),
          widgetDayProvider.overrideWith(FixedDay.new),
          bizWidgetBridgeProvider.overrideWithValue(bridge),
        ],
      );
      addTearDown(free.dispose);
      free.listen(bizWidgetControllerProvider, (_, _) {});
      await next();
      expect(bridge.json(BizKeys.catalog)!['unlocked'], isFalse);
      expect(bridge.json(BizKeys.book(tillId))!['canAdd'], isFalse);
      expect(bridge.json(BizKeys.business(shop.id))!['canAdd'], isFalse);
    });
  });

  test('the grouped queries read each book on its own', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final store = LocalStore(db);
    final repo = CashbookRepository(db, store);
    await db.into(db.workspaces).insert(shop);
    final a = await repo.createCashbook(shop.id, 'A', 'BDT');
    final b = await repo.createCashbook(shop.id, 'B', 'BDT');
    final bookA = (await repo.watchCashbook(a).first)!.book;
    final bookB = (await repo.watchCashbook(b).first)!.book;
    for (final (amount, day) in [(100, '2026-10-15'), (300, '2026-10-16'), (200, '2026-10-17'), (900, '2026-10-20')]) {
      await repo.addEntry(bookA, entryType: 'cash_out', amountMinor: amount, entryDate: day, title: 'out $amount');
    }
    await repo.addEntry(bookB, entryType: 'cash_in', amountMinor: 50, entryDate: '2026-10-01');

    final queries = BizWidgetQueries(db);
    final daily = await queries.watchDaily(shop.id, '2026-09-01', '2026-10-17').first;
    expect(daily[a]!['2026-10-16']!.outMinor, 300);
    expect(daily[a]!.containsKey('2026-10-20'), isFalse);
    expect(daily[b]!['2026-10-01']!.inMinor, 50);

    final last = await queries.watchLastEntry(shop.id, '2026-10-17').first;
    expect(last, {a: '2026-10-17', b: '2026-10-01'});

    final biggest = await queries.watchBiggestOut(shop.id, '2026-10-11', '2026-10-17').first;
    expect(biggest[a]!.amountMinor, 300);
    expect(biggest[a]!.label, 'out 300');
    expect(biggest.containsKey(b), isFalse);

    final recent = await queries.watchRecent(shop.id, '2026-10-17', limit: 2).first;
    expect(recent[a]!.map((e) => e.amountMinor), [200, 300]);
    expect(recent[b]!.single.cashIn, isTrue);

    final categories = await queries.watchCategoryOut(shop.id, '2026-10-01', '2026-10-17').first;
    expect(categories[a], {'': 600});
  });

  group("a business widget's Cash in / Cash out", () {
    Future<ScreenHarness> open(WidgetTester tester, {required String role, String? grant}) async {
      final h = ScreenHarness(tester, plan: plusWithBizWidget());
      await h.run(() async {
        await h.db.into(h.db.workspaces).insert(shop.copyWith(role: role));
        final repo = CashbookRepository(h.db, h.store);
        final till = await repo.createCashbook(shop.id, 'Till', 'BDT');
        await repo.createCashbook(shop.id, 'Bank', 'BDT');
        if (grant != null) {
          await h.store.create('cashbook_members', shop.id, {'cashbook_id': till, 'member_id': 'me', 'role': grant});
        }
      });
      await h.show(BusinessQuickAddPage(workspaceId: shop.id, type: 'cash_in'));
      return h;
    }

    testWidgets('asks which book when there are several to add to', (tester) async {
      final h = await open(tester, role: 'owner');
      expect(find.text('Add to which cashbook?'), findsOneWidget);
      expect(find.text('Till'), findsOneWidget);
      expect(find.text('Bank'), findsOneWidget);
      await h.stop();
    });

    testWidgets('goes straight to the form for the one book staff may add to', (tester) async {
      final h = await open(tester, role: 'staff', grant: 'editor');
      expect(find.byType(EntryFormPage), findsOneWidget);
      expect(find.text('Cash in'), findsWidgets);
      await h.stop();
    });

    testWidgets('says so when the user may only look', (tester) async {
      final h = await open(tester, role: 'viewer');
      expect(find.text("You can only view this business's cashbooks."), findsOneWidget);
      await h.stop();
    });
  });
}
