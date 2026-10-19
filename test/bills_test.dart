import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/core/sync/bill_files.dart';
import 'package:spendroo/core/sync/bill_outbox.dart';
import 'package:spendroo/features/bills/bill_picker.dart';
import 'package:spendroo/features/bills/bill_viewer_page.dart';
import 'package:spendroo/features/cashbook/cashbook_pages.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';
import 'package:spendroo/features/profile/profile_repository.dart';

import 'app_flow_test.dart' show onePixelPng;
import 'bill_outbox_test.dart' show pdfBytes;
import 'cashbook_access_test.dart' show grant, shop, shopId;
import 'personal_screens_test.dart' show ScreenHarness;
import 'plan_test.dart' show answer;
import 'team_test.dart' show FixedProfile;

/// The plan as the server sends it, with the bill limits of [plan].
Entitlements billPlan(String plan, {int usedBytes = 0}) {
  final free = plan == 'free';
  return Entitlements(
    answer(plan: plan, features: {
      F.storageMb: {'kind': 'limit', 'limit': free ? 10 : 1024, 'unlimited': false, 'used_bytes': usedBytes},
      F.storageFileMb: {'kind': 'limit', 'limit': free ? 2 : 20, 'unlimited': false},
      F.storagePdf: {'kind': 'flag', 'enabled': !free},
    }),
    fetchedAt: DateTime.utc(2026, 10, 10),
  );
}

/// Hands back files as if the person had picked them.
class FakeBillPicker extends BillPicker {
  FakeBillPicker(this.folder);

  final Directory folder;
  var photoSize = 0;
  var photos = 0;

  @override
  Future<PickedBill?> photo({required bool camera}) async {
    photos++;
    final file = File('${folder.path}/photo-$photos.png');
    // A real picture, so it can be drawn; past its end a decoder reads nothing
    final bytes = [...onePixelPng];
    if (photoSize > bytes.length) bytes.addAll(List.filled(photoSize - bytes.length, 0));
    file.writeAsBytesSync(bytes);
    return BillPicker.describe(file.path, 'photo-$photos.png');
  }

  @override
  Future<PickedBill?> pdf() async {
    final file = File('${folder.path}/invoice.pdf')..writeAsBytesSync(pdfBytes);
    return BillPicker.describe(file.path, 'invoice.pdf');
  }
}

void main() {
  late Directory folder;

  setUp(() => folder = Directory.systemTemp.createTempSync('bills-ui'));
  tearDown(() {
    if (folder.existsSync()) folder.deleteSync(recursive: true);
  });

  Future<(ScreenHarness, FakeBillPicker, Cashbook)> open(
    WidgetTester tester, {
    String plan = 'free',
    String role = 'owner',
    int usedBytes = 0,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final picker = FakeBillPicker(folder);
    final h = ScreenHarness(
      tester,
      plan: billPlan(plan, usedBytes: usedBytes),
      overrides: [
        billFilesProvider.overrideWithValue(BillFiles(() async => Directory('${folder.path}/store'))),
        billPickerProvider.overrideWithValue(picker),
        profileProvider.overrideWith(() => FixedProfile('me')),
      ],
    );
    final repo = CashbookRepository(h.db, h.store);
    final bookId = await h.run(() => repo.createCashbook(shopId, 'Till', 'BDT'));
    final book = (await h.run(() => repo.watchCashbook(bookId).first))!.book;
    return (h, picker, book);
  }

  Future<String> addEntry(ScreenHarness h, Cashbook book, {String title = 'Rice', String? by}) async {
    final id = await h.run(() => CashbookRepository(h.db, h.store)
        .addEntry(book, entryType: 'cash_out', amountMinor: 120000, entryDate: '2026-10-01', title: title));
    if (by != null) {
      await h.run(() => (h.db.update(h.db.entries)..where((e) => e.id.equals(id)))
          .write(EntriesCompanion(createdById: Value(by))));
    }
    return id;
  }

  Future<void> storeBill(ScreenHarness h, Cashbook book, String entryId, String id, {String name = 'receipt.jpg'}) =>
      h.run(() async {
        await h.store.upsertRow('entry_bills', {
          'id': id,
          'workspace_id': shopId,
          'entry_id': entryId,
          'cashbook_id': book.id,
          'content_type': 'image/png',
          'original_name': name,
          'size_bytes': 1200,
          'version': 1,
          'server_seq': 9,
          'created_at': '2026-10-02T00:00:00Z',
          'updated_at': '2026-10-02T00:00:00Z',
          'deleted_at': null,
        });
        // Opened before, so it shows without a server
        final file = await BillFiles(() async => Directory('${folder.path}/store')).cached(id, 'image/png');
        await file.writeAsBytes(onePixelPng);
      });

  Future<List<BillQueueData>> queue(ScreenHarness h) => h.run(() => h.db.select(h.db.billQueue).get());

  testWidgets('a new entry: a photo picked before saving goes with it once saved', (tester) async {
    final (h, _, book) = await open(tester);
    await h.show(EntryFormPage(book: book, entryType: 'cash_out'), space: shop('owner'));

    expect(find.text('Keep a photo or PDF of the receipt with this entry.'), findsOneWidget);
    await tester.tap(find.text('Attach bill'));
    await h.settle();
    expect(find.text('Take a photo'), findsOneWidget);
    expect(find.text('Choose a photo'), findsOneWidget);
    expect(find.text('Up to 2 MB per bill · 10 MB left'), findsOneWidget);

    await tester.tap(find.text('Choose a photo'));
    await h.settle();
    await h.settle();
    expect(find.text('Take a photo'), findsNothing, reason: 'the sheet closes with the photo');
    expect(find.bySemanticsLabel(RegExp('Attached when you save')), findsOneWidget);
    expect(await queue(h), isEmpty, reason: 'nothing is queued before the entry exists');

    await tester.enterText(find.byType(TextFormField).first, '250');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await h.settle();
    await h.settle();

    final entry = await h.run(() => h.db.select(h.db.entries).getSingle());
    final waiting = (await queue(h)).single;
    expect((waiting.entryId, waiting.op, waiting.state, waiting.contentType),
        (entry.id, BillOutbox.upload, BillOutbox.queued, 'image/png'));
    expect(File(waiting.path!).existsSync(), isTrue);
    await h.stop();
  });

  testWidgets('free: PDFs are locked and say which plan has them', (tester) async {
    final (h, _, book) = await open(tester);
    await h.show(EntryFormPage(book: book, entryType: 'cash_out'), space: shop('owner'));
    await tester.tap(find.text('Attach bill'));
    await h.settle();
    expect(find.text('Locked'), findsOneWidget);

    await tester.tap(find.text('Choose a PDF'));
    await h.settle();
    expect(find.text('PDF bills is not part of your Free plan.'), findsOneWidget);
    await h.stop();
  });

  testWidgets('free: a photo over two megabytes is refused before anything is kept', (tester) async {
    final (h, picker, book) = await open(tester);
    picker.photoSize = 3 * 1024 * 1024;
    await h.show(EntryFormPage(book: book, entryType: 'cash_out'), space: shop('owner'));
    await tester.tap(find.text('Attach bill'));
    await h.settle();
    await tester.tap(find.text('Take a photo'));
    await h.settle();
    expect(find.text('On your Free plan, one bill can be up to 2 MB.'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Attached when you save')), findsNothing);
    await h.stop();
  });

  testWidgets('free: no room left says so and points at the plans', (tester) async {
    final (h, _, book) = await open(tester, usedBytes: 10 * 1024 * 1024 - 10);
    await h.show(EntryFormPage(book: book, entryType: 'cash_out'), space: shop('owner'));
    await tester.tap(find.text('Attach bill'));
    await h.settle();
    await tester.tap(find.text('Choose a photo'));
    await h.settle();
    expect(find.text('Your Free plan keeps up to 10 MB of bills. Remove some, or upgrade for more room.'), findsOneWidget);
    await h.stop();
  });

  testWidgets('plus: a PDF attaches to a saved entry at once', (tester) async {
    final (h, _, book) = await open(tester, plan: 'plus');
    final entryId = await addEntry(h, book);
    final entry = await h.run(() => (h.db.select(h.db.entries)..where((e) => e.id.equals(entryId))).getSingle());
    await h.show(EntryFormPage(book: book, entryType: 'cash_out', entry: entry), space: shop('owner'));

    await tester.tap(find.text('Attach bill'));
    await h.settle();
    expect(find.text('Locked'), findsNothing);
    expect(find.text('Up to 20 MB per bill · 1 GB left'), findsOneWidget);
    await tester.tap(find.text('Choose a PDF'));
    await h.settle();
    await h.settle();
    expect(find.text('Bill attached. It uploads in the background.'), findsOneWidget);
    final waiting = (await queue(h)).single;
    expect((waiting.entryId, waiting.contentType, waiting.originalName), (entryId, 'application/pdf', 'invoice.pdf'));
    await h.stop();
  });

  testWidgets('the list shows which entries keep bills', (tester) async {
    final (h, _, book) = await open(tester);
    final rice = await addEntry(h, book);
    await addEntry(h, book, title: 'Tea');
    await storeBill(h, book, rice, 'b1');
    await storeBill(h, book, rice, 'b2');
    await h.show(CashbookPage(bookId: book.id), space: shop('owner'));
    expect(find.bySemanticsLabel(RegExp('2 bills')), findsOneWidget);
    expect(find.byIcon(Icons.attach_file_rounded), findsOneWidget, reason: 'Tea has none');
    await h.stop();
  });

  testWidgets('a bill opens full screen and can be removed from there', (tester) async {
    final (h, _, book) = await open(tester);
    final rice = await addEntry(h, book);
    await storeBill(h, book, rice, 'b1', name: 'Rice receipt.jpg');
    await storeBill(h, book, rice, 'b2', name: 'Delivery.jpg');
    final entry = await h.run(() => (h.db.select(h.db.entries)..where((e) => e.id.equals(rice))).getSingle());
    await h.show(EntryFormPage(book: book, entryType: 'cash_out', entry: entry), space: shop('owner'));

    await tester.tap(find.bySemanticsLabel(RegExp('Rice receipt.jpg')));
    await h.settle();
    expect(find.byType(BillViewerPage), findsOneWidget);
    expect(find.text('Rice receipt.jpg'), findsOneWidget);
    expect(find.text('1 of 2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await h.settle();
    await tester.tap(find.text('Remove bill'));
    await h.settle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await h.settle();

    expect(find.byType(BillViewerPage), findsNothing);
    final removal = (await queue(h)).single;
    expect((removal.id, removal.op), ('b1', BillOutbox.remove));
    expect(find.bySemanticsLabel(RegExp('Rice receipt.jpg')), findsNothing, reason: 'hidden at once');
    expect(find.bySemanticsLabel(RegExp('Delivery.jpg')), findsOneWidget);
    await h.stop();
  });

  testWidgets('a bill the server would not keep says why, and can be removed', (tester) async {
    final (h, _, book) = await open(tester);
    final rice = await addEntry(h, book);
    await h.run(() => h.db.into(h.db.billQueue).insert(BillQueueCompanion.insert(
          id: 'bad',
          op: BillOutbox.upload,
          workspaceId: shopId,
          cashbookId: book.id,
          entryId: rice,
          contentType: const Value('image/png'),
          state: const Value(BillOutbox.failed),
          error: const Value('bill_unsafe'),
          createdAt: '2026-10-02T00:00:00Z',
        )));
    final entry = await h.run(() => (h.db.select(h.db.entries)..where((e) => e.id.equals(rice))).getSingle());
    await h.show(EntryFormPage(book: book, entryType: 'cash_out', entry: entry), space: shop('owner'));

    await tester.tap(find.bySemanticsLabel(RegExp("Couldn't attach")));
    await h.settle();
    expect(find.text('This file has scripts or hidden content in it, so it can\'t be kept.'), findsOneWidget);
    expect(find.text('Try again'), findsNothing, reason: 'sending the same file again would not help');
    await tester.tap(find.text('Remove bill'));
    await h.settle();
    expect(await queue(h), isEmpty);
    await h.stop();
  });

  testWidgets('a viewer opens an entry read-only and sees its bills', (tester) async {
    final (h, _, book) = await open(tester);
    final rice = await addEntry(h, book);
    await storeBill(h, book, rice, 'b1');
    await h.show(CashbookPage(bookId: book.id), space: shop('viewer'));

    await tester.tap(find.text('Rice'));
    await h.settle();
    expect(find.text('Entry'), findsOneWidget);
    expect(find.text('You can view these bills but not change them.'), findsOneWidget);
    expect(find.text('Attach bill'), findsNothing);
    await h.stop();
  });

  testWidgets('someone who only adds may attach to the entries they added', (tester) async {
    final (h, _, book) = await open(tester);
    await addEntry(h, book, title: 'Mine', by: 'me');
    await addEntry(h, book, title: 'Theirs', by: 'someone-else');
    await h.run(() => grant(h.db, book.id, 'contributor'));
    await h.show(CashbookPage(bookId: book.id), space: shop('staff'));

    await tester.tap(find.text('Mine'));
    await h.settle();
    expect(find.text('Attach bill'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await h.settle();

    await tester.tap(find.text('Theirs'));
    await h.settle();
    expect(find.text('Entry'), findsOneWidget);
    expect(find.text('Attach bill'), findsNothing);
    await h.stop();
  });
}
