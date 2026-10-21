import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/testing.dart';
import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/design/amounts.dart';
import 'package:spendroo/core/design/select_field.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/features/cashbook/cashbook_pages.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';
import 'package:spendroo/features/history/history_repository.dart';
import 'package:spendroo/features/history/history_text.dart';
import 'package:spendroo/features/home_widget/business/biz_queries.dart';
import 'package:spendroo/features/personal/account_ledger.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';
import 'package:spendroo/features/personal/personal_pages.dart';
import 'package:spendroo/features/profile/profile_repository.dart';
import 'package:spendroo/features/settings/settings_page.dart';
import 'package:spendroo/features/tags/merchants.dart';
import 'package:spendroo/features/tags/tag_ids.dart';
import 'package:spendroo/features/tags/tag_repository.dart';
import 'package:spendroo/features/tags/tags_page.dart';
import 'package:spendroo/l10n/app_localizations.dart';

import 'cashbook_access_test.dart' show shop, shopId;
import 'history_test.dart' show FakeHistory;
import 'personal_screens_test.dart' show ScreenHarness, workspace;
import 'team_test.dart' show FixedProfile;
import 'test_support.dart';

void main() {
  group('tag ids and merchant names', () {
    test('a tag_ids column reads as the ids it holds', () {
      expect(decodeTagIds('["a","b"]'), ['a', 'b']);
      expect(decodeTagIds('[]'), isEmpty);
      expect(decodeTagIds(''), isEmpty);
      expect(decodeTagIds('not json'), isEmpty);
      expect(decodeTagIds('{"a":1}'), isEmpty);
      // Only text ids count
      expect(decodeTagIds('["a",3,null]'), ['a']);
      expect(sameTagIds(['a', 'b'], ['a', 'b']), isTrue);
      expect(sameTagIds(['a', 'b'], ['b', 'a']), isFalse);
      expect(sameTagIds(['a'], ['a', 'b']), isFalse);
    });

    test('merchants are tidied, and keyed the way the server keys them', () {
      expect(tidyMerchant('  Star   Kabab \n'), 'Star Kabab');
      expect(normaliseMerchant(' FOODPANDA. '), 'foodpanda');
      expect(normaliseMerchant('Food-Panda!'), 'food panda');
      expect(normaliseMerchant('H&M'), 'h&m');
      expect(normaliseMerchant('৳ Aarong, Dhanmondi'), 'aarong dhanmondi');
      expect(normaliseMerchant('স্বপ্ন'), 'স্বপ্ন');
    });

    test('names used most come first, each once in its latest spelling', () {
      final ranked = rankMerchants(['Agora', 'star kabab', 'Star Kabab.', 'Daraz', 'Star Kabab', '  ', 'agora']);
      expect(ranked, ['star kabab', 'Agora', 'Daraz']);
    });

    test('suggestions start with what is typed, then contain it, never the name as typed', () {
      const known = ['Star Kabab', 'Kabab Factory', 'Agora', 'Starbucks'];
      expect(suggestMerchants(known, 'kab'), ['Kabab Factory', 'Star Kabab']);
      expect(suggestMerchants(known, 'star'), ['Star Kabab', 'Starbucks']);
      expect(suggestMerchants(known, 'Agora'), isEmpty);
      // The same name in another spelling is still offered
      expect(suggestMerchants(known, 'agora'), ['Agora']);
      expect(suggestMerchants(known, '  '), isEmpty);
      expect(suggestMerchants(known, 'a', limit: 2).length, 2);
    });
  });

  group('repositories', () {
    late AppDatabase db;
    late LocalStore store;
    late TagRepository tags;
    late LedgerRepository ledger;
    late CashbookRepository books;

    setUp(() {
      db = memoryDatabase();
      store = LocalStore(db);
      tags = TagRepository(db, store);
      ledger = LedgerRepository(db, store);
      books = CashbookRepository(db, store);
    });
    tearDown(() => db.close());

    Future<List<Map<String, dynamic>>> sent({String? table}) async => [
          for (final m in await (db.select(db.outbox)..orderBy([(o) => OrderingTerm.asc(o.seq)])).get())
            if (table == null || m.tableName_ == table) {'op': m.op, 'row': m.rowId, ...jsonDecode(m.data) as Map<String, dynamic>},
        ];

    Future<Account> cash() async {
      await ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
      return (await ledger.watchAccounts(workspace.id).first).single.account;
    }

    test('a tag of the same name is used, not made twice', () async {
      final food = await tags.addTag(workspace.id, '  Food ', color: '#F08A3C');
      expect(await tags.addTag(workspace.id, 'FOOD'), food);
      final trip = await tags.addTag(workspace.id, 'cox trip');
      // Another workspace has its own
      expect(await tags.addTag(shopId, 'Food'), isNot(food));
      final listed = await tags.watchTags(workspace.id).first;
      expect([for (final t in listed) (t.name, t.color)], [('cox trip', null), ('Food', '#F08A3C')]);
      expect((await sent(table: 'tags')).first, {'op': 'upsert', 'row': food, 'name': 'Food', 'color': '#F08A3C'});

      // A deleted one is not brought back by its name
      await tags.deleteTag(listed.firstWhere((t) => t.id == trip));
      expect(await tags.addTag(workspace.id, 'Cox trip'), isNot(trip));
      expect((await sent(table: 'tags')).where((m) => m['op'] == 'delete').single['row'], trip);
    });

    test('an edit sends only what changed', () async {
      await tags.addTag(workspace.id, 'Food');
      var food = (await tags.watchTags(workspace.id).first).single;
      await db.delete(db.outbox).go();
      await tags.updateTag(food, name: ' Food ', color: null);
      expect(await sent(), isEmpty);
      await tags.updateTag(food, name: 'Meals', color: '#3B9EE5');
      food = (await tags.watchTags(workspace.id).first).single;
      await tags.updateTag(food, name: 'Meals', color: null);
      expect(await sent(), [
        {'op': 'upsert', 'row': food.id, 'name': 'Meals', 'color': '#3B9EE5'},
        {'op': 'upsert', 'row': food.id, 'color': null},
      ]);
    });

    test('a transaction carries its merchant and tags, and an edit sends only what changed', () async {
      final account = await cash();
      final trip = await tags.addTag(workspace.id, 'Trip');
      await db.delete(db.outbox).go();
      await ledger.addTransaction(account,
          kind: 'expense', amountMinor: 500, occurredOn: '2026-10-05', merchant: ' Star  Kabab ', tagIds: [trip]);
      final created = (await sent()).single;
      expect(created['merchant'], 'Star Kabab');
      expect(created['tag_ids'], [trip]);

      final saved = (await ledger.watchTransactions(workspace.id, month: DateTime(2026, 10)).first).single.transaction;
      expect(saved.merchant, 'Star Kabab');
      expect(decodeTagIds(saved.tagIds), [trip]);
      await db.delete(db.outbox).go();
      await ledger.updateTransaction(saved, amountMinor: 500, occurredOn: '2026-10-05', merchant: 'Star Kabab', tagIds: [trip]);
      expect(await sent(), isEmpty);
      await ledger.updateTransaction(saved, amountMinor: 500, occurredOn: '2026-10-05', merchant: 'Star Kabab & Sweets');
      expect((await sent()).single, {'op': 'upsert', 'row': saved.id, 'merchant': 'Star Kabab & Sweets', 'tag_ids': []});
    });

    test('an entry carries its party and tags; an edit that leaves them out keeps them', () async {
      final id = await books.createCashbook(shopId, 'Till', 'BDT');
      final book = (await books.watchCashbook(id).first)!.book;
      final stock = await tags.addTag(shopId, 'Stock');
      await db.delete(db.outbox).go();
      final entryId = await books.addEntry(book,
          entryType: 'cash_out', amountMinor: 900, entryDate: '2026-10-01', merchant: 'Rahim  Traders', tagIds: [stock]);
      final created = (await sent()).single;
      expect(created['merchant'], 'Rahim Traders');
      expect(created['tag_ids'], [stock]);

      final entry = (await books.watchEntries(book.id).first).single.entry;
      expect(entry.id, entryId);
      await db.delete(db.outbox).go();
      await books.updateEntry(entry, amountMinor: 900, entryDate: '2026-10-01');
      await books.updateEntry(entry, amountMinor: 900, entryDate: '2026-10-01', merchant: 'Rahim Traders', tagIds: [stock]);
      expect(await sent(), isEmpty);
      await books.updateEntry(entry, amountMinor: 900, entryDate: '2026-10-01', merchant: 'Karim', tagIds: const []);
      expect((await sent()).single, {'op': 'upsert', 'row': entryId, 'merchant': 'Karim', 'tag_ids': []});
    });

    test('merchants are suggested from the workspace, parties from its books', () async {
      final account = await cash();
      for (final (name, day) in [('Agora', '2026-10-01'), ('Star Kabab', '2026-10-02'), ('agora.', '2026-10-03'), ('', '2026-10-04')]) {
        await ledger.addTransaction(account, kind: 'expense', amountMinor: 100, occurredOn: day, merchant: name);
      }
      final gone = (await ledger.watchTransactions(workspace.id, month: DateTime(2026, 10)).first)
          .firstWhere((v) => v.transaction.merchant == 'Star Kabab');
      expect(await tags.watchMerchants(workspace.id).first, ['agora.', 'Star Kabab']);
      await ledger.deleteTransaction(gone.transaction);
      expect(await tags.watchMerchants(workspace.id).first, ['agora.']);

      final id = await books.createCashbook(shopId, 'Till', 'BDT');
      final book = (await books.watchCashbook(id).first)!.book;
      await books.addEntry(book, entryType: 'cash_out', amountMinor: 1, entryDate: '2026-10-01', merchant: 'Rahim');
      expect(await tags.watchMerchants(shopId, entries: true).first, ['Rahim']);
      expect(await tags.watchMerchants(shopId).first, isEmpty);
    });

    test('a tag counts the live transactions and entries carrying it', () async {
      final account = await cash();
      final stock = await tags.addTag(workspace.id, 'Stock');
      await ledger.addTransaction(account, kind: 'expense', amountMinor: 1, occurredOn: '2026-10-01', tagIds: [stock]);
      await ledger.addTransaction(account, kind: 'expense', amountMinor: 2, occurredOn: '2026-10-01', tagIds: [stock]);
      final id = await books.createCashbook(workspace.id, 'Till', 'BDT');
      final book = (await books.watchCashbook(id).first)!.book;
      await books.addEntry(book, entryType: 'cash_in', amountMinor: 1, entryDate: '2026-10-01', tagIds: [stock]);
      expect(await tags.useCount(stock), 3);
      final first = (await ledger.watchTransactions(workspace.id, month: DateTime(2026, 10)).first).first.transaction;
      await ledger.deleteTransaction(first);
      expect(await tags.useCount(stock), 2);
      expect(await tags.useCount('nothing'), 0);
    });

    test("an account's search finds a merchant or a live tag by name", () async {
      final account = await cash();
      final trip = await tags.addTag(workspace.id, 'Cox trip');
      final gone = await tags.addTag(workspace.id, 'Gone');
      await ledger.addTransaction(account,
          kind: 'expense', amountMinor: 500, occurredOn: '2026-10-01', note: 'Dinner', merchant: 'Star Kabab', tagIds: [trip]);
      await ledger.addTransaction(account, kind: 'expense', amountMinor: 700, occurredOn: '2026-10-02', note: 'Bus', tagIds: [gone]);
      await tags.deleteTag((await tags.watchTags(workspace.id).first).firstWhere((t) => t.id == gone));
      final feed = AccountLedger(db);
      Future<List<String>> notes(String query) async => [
            for (final row in (await feed.page(account.id, 'BDT', AccountFilter(query: query))).$1) row.transaction.note,
          ];
      expect(await notes('kabab'), ['Dinner']);
      expect(await notes('cox'), ['Dinner']);
      expect(await notes('gone'), isEmpty);
      expect(await notes(''), ['Bus', 'Dinner']);
    });

    test("the business widget names an entry without a title by its party", () async {
      await db.into(db.workspaces).insert(shop('owner'));
      final id = await books.createCashbook(shopId, 'Till', 'BDT');
      final book = (await books.watchCashbook(id).first)!.book;
      await books.addEntry(book, entryType: 'cash_out', amountMinor: 900, entryDate: '2026-10-16', merchant: 'Rahim');
      await books.addEntry(book, entryType: 'cash_out', amountMinor: 100, entryDate: '2026-10-15', title: 'Tea', merchant: 'Karim');
      final queries = BizWidgetQueries(db);
      expect((await queries.watchBiggestOut(shopId, '2026-10-11', '2026-10-17').first)[id]!.label, 'Rahim');
      expect([for (final e in (await queries.watchRecent(shopId, '2026-10-17').first)[id]!) e.title], ['Rahim', 'Tea']);
    });
  });

  group('screens', () {
    Future<ScreenHarness> tall(WidgetTester tester, {String me = 'me'}) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);
      return ScreenHarness(tester, overrides: [profileProvider.overrideWith(() => FixedProfile(me))]);
    }

    /// Before a second screen: the app keeps its first home page, and show() adds the workspace again.
    Future<void> again(ScreenHarness app) async {
      await app.tester.pumpWidget(const SizedBox.shrink());
      await app.run(() => app.db.delete(app.db.workspaces).go());
    }

    Finder typing(Finder field) => find.descendant(of: field, matching: find.byType(EditableText));

    /// Picks [name] from the tag sheet, making it when it is not there yet.
    Future<void> addTag(WidgetTester tester, ScreenHarness app, String name, {bool exists = false}) async {
      await tester.tap(find.byKey(const ValueKey('add-tag')));
      await app.settle();
      if (exists) {
        await tester.tap(find.text(name).last);
      } else {
        await tester.enterText(typing(find.byType(AppSearchField)), name);
        await app.settle();
        await tester.tap(find.text('Create "$name"'));
      }
      await app.settle();
    }

    testWidgets('the transaction form suggests a merchant, makes a tag on the spot, and saves both', (tester) async {
      final app = await tall(tester);
      late Account account;
      await app.run(() async {
        await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
        account = (await app.ledger.watchAccounts(workspace.id).first).single.account;
        await app.ledger.addTransaction(account, kind: 'expense', amountMinor: 100, occurredOn: '2026-10-01', merchant: 'Star Kabab');
      });
      await app.show(const TransactionFormPage(workspace: workspace));
      await tester.enterText(typing(find.byType(AmountField).first), '120');
      await tester.enterText(find.byKey(const ValueKey('merchant-field')), 'sta');
      await app.settle();
      await tester.tap(find.text('Star Kabab'));
      await app.settle();
      expect(tester.widget<TextFormField>(find.byKey(const ValueKey('merchant-field'))).controller!.text, 'Star Kabab');

      await addTag(tester, app, 'Trip');
      expect(find.widgetWithText(InputChip, 'Trip'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await app.settle();

      final tripId = (await app.run(() => TagRepository(app.db, app.store).watchTags(workspace.id).first)).single.id;
      final views = await app.run(() => app.ledger.watchTransactions(workspace.id, month: DateTime(2026, 10)).first);
      final saved = views.firstWhere((v) => v.transaction.amountMinor == -12000);
      expect(saved.transaction.merchant, 'Star Kabab');
      expect(decodeTagIds(saved.transaction.tagIds), [tripId]);

      // Editing takes the tag off and changes the merchant
      await again(app);
      await app.show(TransactionFormPage(workspace: workspace, existing: saved));
      await tester.tap(find.byTooltip('Remove Trip'));
      await app.settle();
      expect(find.widgetWithText(InputChip, 'Trip'), findsNothing);
      await tester.enterText(find.byKey(const ValueKey('merchant-field')), 'Star Kabab & Sweets');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await app.settle();
      final outbox = await app.run(() => app.db.select(app.db.outbox).get());
      expect(jsonDecode(outbox.last.data), {'merchant': 'Star Kabab & Sweets', 'tag_ids': []});
      await app.stop();
    });

    testWidgets('a transfer has no merchant or tags; picking a tag already there adds it once', (tester) async {
      final app = await tall(tester);
      await app.run(() async {
        await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
        await app.ledger.addAccount(workspace.id, name: 'Bank', kind: 'bank', currency: 'BDT');
        await TagRepository(app.db, app.store).addTag(workspace.id, 'Rent');
      });
      await app.show(const TransactionFormPage(workspace: workspace, initialKind: 'transfer'));
      expect(find.byKey(const ValueKey('merchant-field')), findsNothing);
      expect(find.byKey(const ValueKey('add-tag')), findsNothing);
      await again(app);
      await app.show(const TransactionFormPage(workspace: workspace));
      await addTag(tester, app, 'Rent', exists: true);
      expect(find.widgetWithText(InputChip, 'Rent'), findsOneWidget);
      // What is on already is not offered again
      await tester.tap(find.byKey(const ValueKey('add-tag')));
      await app.settle();
      expect(find.widgetWithText(ListTile, 'Rent'), findsNothing);
      await app.stop();
    });

    testWidgets('the list shows the merchant first and searches merchants and tags', (tester) async {
      final app = await tall(tester);
      final tags = TagRepository(app.db, app.store);
      late String trip;
      await app.run(() async {
        await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
        final account = (await app.ledger.watchAccounts(workspace.id).first).single.account;
        final food = await app.ledger.addCategory(workspace.id, 'Food', 'expense');
        trip = await tags.addTag(workspace.id, 'Cox trip');
        await app.ledger.addTransaction(account,
            kind: 'expense', amountMinor: 500, occurredOn: '2026-10-05', categoryId: food, note: 'Dinner',
            merchant: 'Star Kabab', tagIds: [trip]);
        await app.ledger.addTransaction(account, kind: 'expense', amountMinor: 50, occurredOn: '2026-10-04', merchant: 'Pathao');
        // A row from before merchants: it reads as it always did
        await app.ledger.addTransaction(account, kind: 'expense', amountMinor: 700, occurredOn: '2026-10-03', note: 'Bus');
      });
      // The home shell holds it in its own scaffold
      await app.show(const Scaffold(body: TransactionsPage(workspace: workspace)));
      expect(find.text('Star Kabab'), findsOneWidget);
      expect(find.text('Cash · Dinner · Food'), findsOneWidget);
      // Pathao has a merchant and no note; Bus a note and no merchant
      expect(find.text('Cash · Uncategorised'), findsNWidgets(2));
      expect(find.text('Pathao'), findsOneWidget);
      expect(find.text('Bus'), findsOneWidget);

      Future<void> search(String query) async {
        await tester.enterText(typing(find.byType(AppSearchField)), query);
        await app.settle();
      }

      await search('kabab');
      expect(find.text('Star Kabab'), findsOneWidget);
      expect(find.text('Bus'), findsNothing);
      await search('cox');
      expect(find.text('Star Kabab'), findsOneWidget);
      expect(find.text('Pathao'), findsNothing);
      await app.run(() async => tags.deleteTag((await tags.watchTags(workspace.id).first).single));
      await app.settle();
      expect(find.text('Star Kabab'), findsNothing);
      await app.stop();
    });

    testWidgets('tags are added, renamed and deleted on their page', (tester) async {
      final app = await tall(tester);
      final tags = TagRepository(app.db, app.store);
      await app.show(const TagsPage());
      expect(find.textContaining('No tags yet'), findsOneWidget);

      await tester.tap(find.text('New tag'));
      await app.settle();
      expect(find.widgetWithText(TextField, 'Tag name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Food');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await app.settle();
      expect(find.text('Food'), findsOneWidget);

      await tester.tap(find.text('Food'));
      await app.settle();
      await tester.enterText(find.byType(TextField), 'Meals');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await app.settle();
      expect(find.text('Meals'), findsOneWidget);

      // Tapped and left as it was: nothing goes out
      final queued = (await app.run(() => app.db.select(app.db.outbox).get())).length;
      await tester.tap(find.text('Meals'));
      await app.settle();
      await tester.tapAt(const Offset(10, 10));
      await app.settle();
      expect((await app.run(() => app.db.select(app.db.outbox).get())).length, queued);

      await tester.tap(find.byTooltip('Delete'));
      await app.settle();
      expect(find.textContaining('Delete "Meals"? Nothing carries it yet.'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await app.settle();
      expect(find.text('Meals'), findsNothing);
      expect(await app.run(() => tags.watchTags(workspace.id).first), isEmpty);

      // Without a workspace there is nothing to show
      await app.run(() => app.db.delete(app.db.workspaces).go());
      await app.settle();
      expect(find.text('New tag'), findsNothing);
      await app.stop();
    });

    testWidgets('the entry form saves a party and tags', (tester) async {
      final app = await tall(tester);
      final books = CashbookRepository(app.db, app.store);
      late Cashbook book;
      await app.run(() async {
        final id = await books.createCashbook(shopId, 'Till', 'BDT');
        book = (await books.watchCashbook(id).first)!.book;
        await books.addEntry(book, entryType: 'cash_out', amountMinor: 1, entryDate: '2026-10-01', merchant: 'Rahim Traders');
      });
      await app.show(EntryFormPage(book: book, entryType: 'cash_out'), space: shop('owner'));
      expect(find.text('Party'), findsOneWidget);
      await tester.enterText(typing(find.byType(AmountField).first), '250');
      await tester.enterText(find.byKey(const ValueKey('merchant-field')), 'rah');
      await app.settle();
      // The keyboard's next key takes the first name offered
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await app.settle();
      expect(tester.widget<TextFormField>(find.byKey(const ValueKey('merchant-field'))).controller!.text, 'Rahim Traders');
      await addTag(tester, app, 'Stock');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await app.settle();

      final stock = (await app.run(() => TagRepository(app.db, app.store).watchTags(shopId).first)).single;
      final entry = (await app.run(() => books.watchEntries(book.id).first)).first.entry;
      expect((entry.amountMinor, entry.merchant), (25000, 'Rahim Traders'));
      expect(decodeTagIds(entry.tagIds), [stock.id]);

      await again(app);
      await app.show(EntryFormPage(book: book, entryType: 'cash_out', entry: entry), space: shop('owner'));
      expect(find.widgetWithText(InputChip, 'Stock'), findsOneWidget);
      await app.stop();
    });

    testWidgets("a book's list shows the party, searches it with tags, and the details name both", (tester) async {
      final app = await tall(tester);
      final books = CashbookRepository(app.db, app.store);
      late Cashbook book;
      await app.run(() async {
        final id = await books.createCashbook(shopId, 'Till', 'BDT');
        book = (await books.watchCashbook(id).first)!.book;
        final stock = await TagRepository(app.db, app.store).addTag(shopId, 'Stock');
        await books.addEntry(book,
            entryType: 'cash_out', amountMinor: 900, entryDate: '2026-10-03', title: 'Rice', remarks: 'Five sacks',
            merchant: 'Rahim', tagIds: [stock]);
        await books.addEntry(book, entryType: 'cash_in', amountMinor: 500, entryDate: '2026-10-02', merchant: 'Karim');
        await books.addEntry(book, entryType: 'cash_in', amountMinor: 100, entryDate: '2026-10-01');
      });
      await app.show(CashbookPage(bookId: book.id), space: shop('viewer'));
      expect(find.text('Rice'), findsOneWidget);
      expect(find.textContaining('Rahim · '), findsOneWidget);
      expect(find.text('Karim'), findsOneWidget);
      expect(find.text('Cash in'), findsWidgets);

      Future<void> search(String query) async {
        await tester.enterText(typing(find.byType(AppSearchField)), query);
        await app.settle();
      }

      await search('stock');
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Karim'), findsNothing);
      await search('karim');
      expect(find.text('Rice'), findsNothing);
      expect(find.text('Karim'), findsOneWidget);
      await search('sacks');
      expect(find.text('Rice'), findsOneWidget);
      await search('nobody');
      expect(find.text('Nothing matches "nobody".'), findsOneWidget);
      await search('');

      await tester.tap(find.text('Rice'));
      await app.settle();
      expect(find.text('Rahim'), findsOneWidget);
      expect(find.text('Stock'), findsOneWidget);
      await app.stop();
    });

    testWidgets("history names a party change and lists tags by name", (tester) async {
      final app = await tall(tester);
      final event = HistoryEvent.fromJson({
        'id': 'x', 'at': '2026-10-01T00:00:00Z', 'kind': 'entry', 'action': 'updated', 'object_id': 'e',
        'changes': [], 'subject': '',
      });
      late List<String?> said;
      await app.show(Builder(builder: (context) {
        const merchant = FieldChange('merchant', '', 'Rahim');
        const tags = FieldChange('tags', <Object?>[], ['Stock', 'Rush']);
        said = [
          fieldLabel(context, event, merchant),
          fieldValue(context, event, merchant, merchant.after),
          fieldLabel(context, event, tags),
          fieldValue(context, event, tags, tags.after),
          fieldValue(context, event, tags, tags.before),
        ];
        return const SizedBox();
      }), space: shop('owner'));
      expect(said, ['Party', 'Rahim', 'Tags', 'Stock, Rush', null]);
      await app.stop();
    });

    testWidgets('settings lead the people who run the workspace to its tags', (tester) async {
      Future<void> open(String role) async {
        final app = ScreenHarness(tester, overrides: [
          apiClientProvider.overrideWith(
            (ref) => ApiClient(baseUrl: 'http://test', tokenStore: MemoryTokenStore(), httpClient: MockClient(FakeHistory().handle)),
          ),
          profileProvider.overrideWith(() => FixedProfile('me')),
        ]);
        tester.view.physicalSize = const Size(1080, 3200);
        tester.view.devicePixelRatio = 2.5;
        addTearDown(tester.view.reset);
        await app.db.into(app.db.workspaces).insert(shop(role));
        final router = GoRouter(initialLocation: '/settings', routes: [
          GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
          GoRoute(path: '/tags', builder: (_, _) => const TagsPage()),
        ]);
        await tester.pumpWidget(UncontrolledProviderScope(
          container: app.container,
          child: MaterialApp.router(
            routerConfig: router,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        ));
        await app.settle();
        if (role == 'owner') {
          expect(find.text('Labels for transactions and entries'), findsOneWidget);
          await tester.tap(find.text('Tags'));
          await app.settle();
          expect(find.byType(TagsPage), findsOneWidget);
        } else {
          expect(find.text('Tags'), findsNothing);
        }
        await app.stop();
      }

      await open('owner');
      await open('staff');
    });
  });
}
