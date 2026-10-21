// End-to-end sync against a running Spendroo API. Skipped unless LIVE_API_URL,
// LIVE_EMAIL and LIVE_PASSWORD are set (a verified account on that server):
//
//   flutter test test/live_sync_test.dart
@Tags(['live'])
library;

import 'dart:io';

import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/auth/auth_repository.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/sync/sync_engine.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';
import 'package:spendroo/features/tags/tag_ids.dart';
import 'package:spendroo/features/tags/tag_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

/// One phone: its own database and session.
class Device {
  Device(String apiUrl) {
    db = memoryDatabase();
    api = ApiClient(baseUrl: apiUrl, tokenStore: MemoryTokenStore());
    store = LocalStore(db);
    engine = SyncEngine(db, api, store);
    books = CashbookRepository(db, store);
    ledger = LedgerRepository(db, store);
  }

  late final AppDatabase db;
  late final ApiClient api;
  late final LocalStore store;
  late final SyncEngine engine;
  late final CashbookRepository books;
  late final LedgerRepository ledger;

  Future<void> logIn(String email, String password) async {
    final result = await AuthRepository(api).logIn(email, password);
    expect(result.step, AuthStep.signedIn, reason: result.error);
  }

  Future<Workspace> workspace(String kind) async =>
      (await db.select(db.workspaces).get()).firstWhere((w) => w.kind == kind);
}

void main() {
  final apiUrl = Platform.environment['LIVE_API_URL'];
  final email = Platform.environment['LIVE_EMAIL'];
  final password = Platform.environment['LIVE_PASSWORD'];
  final skip = apiUrl == null || email == null || password == null ? 'LIVE_API_URL not set' : null;

  test('two devices converge through the server', skip: skip, () async {
    HttpOverrides.global = null; // allow real network in tests
    final phone = Device(apiUrl!);
    final tablet = Device(apiUrl);
    addTearDown(phone.db.close);
    addTearDown(tablet.db.close);
    await phone.logIn(email!, password!);
    await tablet.logIn(email, password);

    // --- first sync brings the personal workspace with its seeded defaults
    await phone.engine.sync();
    final personal = await phone.workspace('personal');
    final accounts = await phone.ledger.watchAccounts(personal.id).first;
    expect(accounts.map((a) => a.account.name), ['Cash']);
    expect(await phone.ledger.watchCategories(personal.id).first, isNotEmpty);

    // --- the demo business arrives through sync
    expect((await phone.api.post('/api/v1/workspaces/demo/')).statusCode, 201);
    await phone.engine.sync();
    final demo = await phone.workspace('business');
    final demoBook = (await phone.books.watchCashbooks(demo.id).first).single;
    expect(demoBook.entryCount, 12);
    expect(demoBook.book.currency, 'BDT');

    // --- work done offline on the phone reaches the tablet
    final bookId = await phone.books.createCashbook(demo.id, 'Offline till', 'BDT');
    final book = (await phone.books.watchCashbook(bookId).first)!.book;
    final entryId = await phone.books.addEntry(book, entryType: 'cash_in', amountMinor: 12345, entryDate: '2026-10-01', title: 'Sale');
    await phone.ledger.addTransaction(accounts.single.account, kind: 'expense', amountMinor: 2500, occurredOn: '2026-10-01', note: 'Lunch');
    expect(await phone.db.select(phone.db.outbox).get(), isNotEmpty);

    await phone.engine.sync();
    expect(await phone.db.select(phone.db.outbox).get(), isEmpty);
    expect(await phone.db.select(phone.db.syncFailures).get(), isEmpty);
    // The server's copy replaced the local one: it now has a version and a cursor position
    final pushed = (await phone.books.watchEntries(bookId).first).single.entry;
    expect((pushed.version, pushed.serverSeq > 0, pushed.createdById != null), (1, true, true));

    await tablet.engine.sync();
    final onTablet = (await tablet.books.watchEntries(bookId).first).single.entry;
    expect((onTablet.id, onTablet.amountMinor, onTablet.title), (entryId, 12345, 'Sale'));
    expect((await tablet.books.watchCategories(bookId).first).length, defaultEntryCategories.length);
    expect((await tablet.ledger.watchAccounts(personal.id).first).single.balanceMinor, -2500);

    // --- both devices edit different fields of the same entry while offline: both edits survive
    await phone.books.updateEntry(pushed, amountMinor: 99900, entryDate: pushed.entryDate, title: pushed.title);
    await tablet.books.updateEntry(onTablet, amountMinor: onTablet.amountMinor, entryDate: onTablet.entryDate, title: 'Big sale');
    await phone.engine.sync();
    await tablet.engine.sync();
    await phone.engine.sync();
    for (final device in [phone, tablet]) {
      final entry = (await device.books.watchEntries(bookId).first).single.entry;
      expect((entry.amountMinor, entry.title, entry.version), (99900, 'Big sale', 3));
    }

    // --- a delete on one device removes the entry on the other
    await tablet.books.deleteEntry(entryId);
    await tablet.engine.sync();
    await phone.engine.sync();
    expect(await phone.books.watchEntries(bookId).first, isEmpty);
    expect((await phone.books.watchCashbook(bookId).first)!.balanceMinor, 0);

    // --- a change the server refuses is undone locally and reported
    final refusedId = await phone.books.addEntry(book, entryType: 'cash_in', amountMinor: 0, entryDate: '2026-10-01');
    await phone.engine.sync();
    expect(await phone.books.watchEntries(bookId).first, isEmpty);
    final failure = (await phone.db.select(phone.db.syncFailures).get()).single;
    expect((failure.rowId, failure.code), (refusedId, 'invalid'));

    // --- syncing again with nothing new changes nothing
    final before = await phone.db.select(phone.db.entries).get();
    await phone.engine.sync();
    expect((await phone.db.select(phone.db.entries).get()).length, before.length);

    // --- deleting the demo business on the server removes it from the device
    expect((await tablet.api.delete('/api/v1/workspaces/${demo.id}/')).statusCode, 204);
    await phone.engine.sync();
    expect((await phone.db.select(phone.db.workspaces).get()).map((w) => w.kind), ['personal']);
    expect(await phone.db.select(phone.db.cashbooks).get(), isEmpty);
    expect(await phone.db.select(phone.db.entries).get(), isEmpty);
  });

  test("a merchant, a party and tags made on one device reach the other, and so do edits", skip: skip, () async {
    HttpOverrides.global = null;
    final phone = Device(apiUrl!);
    final tablet = Device(apiUrl);
    addTearDown(phone.db.close);
    addTearDown(tablet.db.close);
    await phone.logIn(email!, password!);
    await tablet.logIn(email, password);
    await phone.engine.sync();
    await tablet.engine.sync();
    final personal = await phone.workspace('personal');
    final cash = (await phone.ledger.watchAccounts(personal.id).first).first.account;
    final phoneTags = TagRepository(phone.db, phone.store);
    final tabletTags = TagRepository(tablet.db, tablet.store);
    final stamp = DateTime.now().microsecondsSinceEpoch;

    // --- the phone makes a tag, a transaction and an entry carrying it
    final tagId = await phoneTags.addTag(personal.id, 'Trip $stamp', color: '#3B9EE5');
    final spentId = await phone.ledger.addTransaction(cash,
        kind: 'expense', amountMinor: 4500, occurredOn: '2026-10-20', note: 'Dinner $stamp',
        merchant: ' Star  Kabab ', tagIds: [tagId]);
    final bookId = await phone.books.createCashbook(personal.id, 'Tags till $stamp', 'BDT');
    final book = (await phone.books.watchCashbook(bookId).first)!.book;
    final entryId = await phone.books.addEntry(book,
        entryType: 'cash_out', amountMinor: 900, entryDate: '2026-10-20', title: 'Rice', merchant: 'Rahim Traders',
        tagIds: [tagId]);
    await phone.engine.sync();
    expect(await phone.db.select(phone.db.syncFailures).get(), isEmpty);

    // --- the tablet sees all of it as the phone made it
    await tablet.engine.sync();
    final tag = (await tabletTags.watchTags(personal.id).first).firstWhere((t) => t.id == tagId);
    expect((tag.name, tag.color), ('Trip $stamp', '#3B9EE5'));
    Future<Transaction> spentOn(Device device) async =>
        (await device.ledger.watchTransactions(personal.id).first).firstWhere((v) => v.transaction.id == spentId).transaction;
    var spent = await spentOn(tablet);
    expect(spent.merchant, 'Star Kabab');
    expect(decodeTagIds(spent.tagIds), [tagId]);
    final entry = (await tablet.books.watchEntries(bookId).first).firstWhere((v) => v.entry.id == entryId).entry;
    expect(entry.merchant, 'Rahim Traders');
    expect(decodeTagIds(entry.tagIds), [tagId]);

    // --- the tablet edits; the phone sees the edit
    await tablet.ledger.updateTransaction(spent,
        amountMinor: 4500, occurredOn: spent.occurredOn, note: spent.note, merchant: 'Star Kabab & Sweets');
    await tablet.engine.sync();
    await phone.engine.sync();
    spent = await spentOn(phone);
    expect(spent.merchant, 'Star Kabab & Sweets');
    expect(decodeTagIds(spent.tagIds), isEmpty);

    // --- a tag deleted on one device is gone on the other, and the entry keeps naming nothing live
    await phoneTags.deleteTag((await phoneTags.watchTags(personal.id).first).firstWhere((t) => t.id == tagId));
    await phone.engine.sync();
    await tablet.engine.sync();
    expect((await tabletTags.watchTags(personal.id).first).where((t) => t.id == tagId), isEmpty);

    // Leave the account as it was
    await phone.ledger.deleteTransaction(spent);
    await phone.books.deleteCashbook(book.id);
    await phone.engine.sync();
  });
}

