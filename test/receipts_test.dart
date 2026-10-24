import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/core/sync/bill_files.dart';
import 'package:spendroo/core/sync/bill_outbox.dart';
import 'package:spendroo/core/sync/bill_target.dart';
import 'package:spendroo/features/bills/bill_picker.dart';
import 'package:spendroo/features/bills/bill_viewer_page.dart';
import 'package:spendroo/features/personal/account_ledger.dart';
import 'package:spendroo/features/personal/account_page.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';
import 'package:spendroo/features/personal/personal_pages.dart';

import 'app_flow_test.dart' show onePixelPng;
import 'bills_test.dart' show FakeBillPicker, billPlan;
import 'personal_screens_test.dart' show ScreenHarness, workspace;

/// A phone whose camera and files the system will not open.
class RefusingPicker extends FakeBillPicker {
  RefusingPicker(super.folder);

  @override
  Future<PickedBill?> photo({required bool camera}) async => throw PlatformException(code: 'denied');
}

/// A server that cannot be reached.
ApiClient offlineApi() => ApiClient(
      baseUrl: 'http://api.test',
      tokenStore: MemoryTokenStore(),
      httpClient: MockClient((_) async => throw http.ClientException('down')),
    );

void main() {
  late Directory folder;

  setUp(() => folder = Directory.systemTemp.createTempSync('receipts-ui'));
  tearDown(() {
    if (folder.existsSync()) folder.deleteSync(recursive: true);
  });

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
  }

  ScreenHarness harness(WidgetTester tester,
          {String plan = 'free', int usedBytes = 0, BillPicker? picker, ApiClient? api}) =>
      ScreenHarness(
        tester,
        plan: billPlan(plan, usedBytes: usedBytes),
        // Offline, a file that cannot be fetched says so at once
        retry: api == null,
        overrides: [
          billFilesProvider.overrideWithValue(BillFiles(() async => Directory('${folder.path}/store'))),
          billPickerProvider.overrideWithValue(picker ?? FakeBillPicker(folder)),
          if (api != null) apiClientProvider.overrideWithValue(api),
        ],
      );

  /// Cash, and a lunch on it unless [lunch] is false.
  Future<(Account, String?)> cashAndLunch(ScreenHarness app, {bool lunch = true}) => app.run(() async {
        await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
        final cash = (await app.ledger.watchAccounts(workspace.id).first).single.account;
        final id = lunch
            ? await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 25000, occurredOn: '2026-10-02', note: 'Lunch')
            : null;
        return (cash, id);
      });

  Future<void> storeReceipt(ScreenHarness app, String transactionId, String id,
          {String name = 'Lunch.png', bool onPhone = true}) =>
      app.run(() async {
        await app.store.upsertRow('transaction_receipts', {
          'id': id,
          'workspace_id': workspace.id,
          'transaction_id': transactionId,
          'content_type': 'image/png',
          'original_name': name,
          'size_bytes': 1200,
          'version': 1,
          'server_seq': 9,
          'created_at': '2026-10-02T00:00:00Z',
          'updated_at': '2026-10-02T00:00:00Z',
          'deleted_at': null,
        });
        if (!onPhone) return;
        // Opened before, so it shows without a server
        final file = await BillFiles(() async => Directory('${folder.path}/store')).cached(id, 'image/png');
        await file.writeAsBytes(onePixelPng);
      });

  Future<List<BillQueueData>> queue(ScreenHarness app) => app.run(() => app.db.select(app.db.billQueue).get());

  Future<TransactionView> viewOf(ScreenHarness app, String id) async =>
      (await app.run(() => app.ledger.watchTransactions(workspace.id).first)).firstWhere((v) => v.transaction.id == id);

  /// Reading files and the network takes real time, which a widget test's clock does not pass by itself.
  Future<void> waitForFiles(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> tap(WidgetTester tester, ScreenHarness app, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await app.settle();
  }

  group('the transaction form', () {
    testWidgets('a receipt picked while adding goes with the expense once it is saved', (tester) async {
      phone(tester);
      final app = harness(tester);
      await cashAndLunch(app, lunch: false);
      await app.show(const TransactionFormPage(workspace: workspace));

      expect(find.text('Receipts'), findsOneWidget);
      expect(find.text('Keep a photo or PDF of the receipt with this transaction.'), findsOneWidget);
      await tap(tester, app, find.text('Attach receipt'));
      expect(find.text('Up to 2 MB per receipt · 10 MB left'), findsOneWidget);
      await tap(tester, app, find.text('Choose a photo'));
      await app.settle();
      expect(find.bySemanticsLabel(RegExp('Receipts: Attached when you save')), findsOneWidget);
      expect(await queue(app), isEmpty, reason: 'nothing is queued before the transaction exists');

      await tester.enterText(find.byType(TextFormField).first, '250');
      await tap(tester, app, find.widgetWithText(FilledButton, 'Save'));
      await app.settle();

      final saved = (await app.run(() => app.ledger.watchTransactions(workspace.id).first)).single;
      final waiting = (await queue(app)).single;
      expect((waiting.transactionId, waiting.entryId, waiting.op, waiting.contentType),
          (saved.transaction.id, '', BillOutbox.upload, 'image/png'));
      expect(File(waiting.path!).existsSync(), isTrue);
      expect(saved.receiptCount, 1, reason: 'counted while it waits to be sent');
      await app.stop();
    });

    testWidgets('a transfer has no receipt to keep', (tester) async {
      phone(tester);
      final app = harness(tester);
      await cashAndLunch(app, lunch: false);
      await app.show(const TransactionFormPage(workspace: workspace, initialKind: 'transfer'));
      expect(find.text('Attach receipt'), findsNothing);
      await app.stop();
    });

    testWidgets('plus: a receipt attaches to a saved expense at once, and deleting it drops what waits', (tester) async {
      phone(tester);
      final app = harness(tester, plan: 'plus');
      final (_, lunch) = await cashAndLunch(app);
      await app.show(TransactionFormPage(workspace: workspace, existing: await viewOf(app, lunch!)));

      await tap(tester, app, find.text('Attach receipt'));
      expect(find.text('Locked'), findsNothing);
      expect(find.text('Up to 20 MB per receipt · 1 GB left'), findsOneWidget);
      await tap(tester, app, find.text('Take a photo'));
      await app.settle();
      expect(find.text('Receipt attached. It uploads in the background.'), findsOneWidget);
      final waiting = (await queue(app)).single;
      expect((waiting.transactionId, waiting.contentType), (lunch, 'image/png'));

      await tap(tester, app, find.byTooltip('Delete'));
      await tap(tester, app, find.widgetWithText(FilledButton, 'Delete'));
      expect(await queue(app), isEmpty);
      await app.stop();
    });

    testWidgets('free: PDFs are locked and say which plan has them', (tester) async {
      phone(tester);
      final app = harness(tester);
      await cashAndLunch(app, lunch: false);
      await app.show(const TransactionFormPage(workspace: workspace));
      await tap(tester, app, find.text('Attach receipt'));
      expect(find.text('Locked'), findsOneWidget);
      await tap(tester, app, find.text('Choose a PDF'));
      expect(find.text('Attaching PDFs is not part of your Free plan.'), findsOneWidget);
      await app.stop();
    });

    testWidgets('free: with no room left the upgrade sheet says so before anything is kept', (tester) async {
      phone(tester);
      final app = harness(tester, usedBytes: 10 * 1024 * 1024 - 10);
      final (_, lunch) = await cashAndLunch(app);
      await app.show(TransactionFormPage(workspace: workspace, existing: await viewOf(app, lunch!)));
      await tap(tester, app, find.text('Attach receipt'));
      await tap(tester, app, find.text('Choose a photo'));
      expect(find.text('Your Free plan keeps up to 10 MB of bills and receipts. Remove some, or upgrade for more room.'),
          findsOneWidget);
      expect(await queue(app), isEmpty);
      await app.stop();
    });

    testWidgets('a stored receipt opens full screen and can be removed from there', (tester) async {
      phone(tester);
      final app = harness(tester);
      final (_, lunch) = await cashAndLunch(app);
      await storeReceipt(app, lunch!, 'r1', name: 'Lunch receipt.png');
      await app.show(TransactionFormPage(workspace: workspace, existing: await viewOf(app, lunch)));

      await tap(tester, app, find.bySemanticsLabel(RegExp('Lunch receipt.png')));
      expect(find.byType(BillViewerPage), findsOneWidget);
      expect(find.text('Lunch receipt.png'), findsOneWidget);
      await tap(tester, app, find.byIcon(Icons.more_vert_rounded));
      await tap(tester, app, find.text('Remove receipt'));
      expect(find.text('Remove this receipt? The file is deleted from all your devices.'), findsOneWidget);
      await tap(tester, app, find.widgetWithText(FilledButton, 'Delete'));

      expect(find.byType(BillViewerPage), findsNothing);
      final removal = (await queue(app)).single;
      expect((removal.id, removal.op, removal.transactionId), ('r1', BillOutbox.remove, lunch));
      expect(find.text('Receipt removed'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Lunch receipt.png')), findsNothing, reason: 'hidden at once');
      await app.stop();
    });

    testWidgets('a receipt the server would not take says why in a receipt\'s words', (tester) async {
      phone(tester);
      final app = harness(tester);
      final (_, lunch) = await cashAndLunch(app);
      await app.run(() => app.db.into(app.db.billQueue).insert(
            const TransactionTarget(workspaceId: '00000000-0000-0000-0000-000000000001', transactionId: 'x')
                .queueRow('bad', BillOutbox.upload, createdAt: '2026-10-02T00:00:00Z')
                .copyWith(
                  transactionId: Value(lunch),
                  contentType: const Value('image/png'),
                  state: const Value(BillOutbox.failed),
                  error: const Value('bill_forbidden'),
                ),
          ));
      await app.show(TransactionFormPage(workspace: workspace, existing: await viewOf(app, lunch!)));
      await tap(tester, app, find.bySemanticsLabel(RegExp("Receipts: Couldn't attach")));
      expect(find.text("You can't add receipts to this transaction."), findsOneWidget);
      await tap(tester, app, find.text('Remove receipt'));
      expect(await queue(app), isEmpty);
      await app.stop();
    });
  });

  group('when things go wrong', () {
    testWidgets('a camera the system will not open says so in a receipt\'s words', (tester) async {
      phone(tester);
      final app = harness(tester, picker: RefusingPicker(folder));
      await cashAndLunch(app, lunch: false);
      await app.show(const TransactionFormPage(workspace: workspace));
      await tap(tester, app, find.text('Attach receipt'));
      await tap(tester, app, find.text('Take a photo'));
      expect(find.text("The receipt couldn't be attached."), findsOneWidget);
      await app.stop();
    });

    testWidgets('offline, a receipt never opened on this phone says how to open it', (tester) async {
      phone(tester);
      final app = harness(tester, api: offlineApi());
      final (_, lunch) = await cashAndLunch(app);
      await storeReceipt(app, lunch!, 'r1', name: 'Far away.png', onPhone: false);
      await app.show(TransactionFormPage(workspace: workspace, existing: await viewOf(app, lunch)));

      await tap(tester, app, find.bySemanticsLabel(RegExp('Far away.png')));
      await waitForFiles(tester);
      const offline = "This receipt isn't saved on this phone yet. Connect to the internet to open it.";
      expect(find.text(offline), findsOneWidget);
      await tester.tap(find.byTooltip('Share'));
      await waitForFiles(tester);
      expect(find.text(offline), findsAtLeastNWidgets(2), reason: 'the page and the message both say it');
      await app.stop();
    });
  });

  testWidgets('a receipt the server no longer has says it could not be opened', (tester) async {
    phone(tester);
    final gone = ApiClient(
      baseUrl: 'http://api.test',
      tokenStore: MemoryTokenStore(),
      httpClient: MockClient((_) async => http.Response('{}', 404)),
    );
    final app = harness(tester, api: gone);
    final (_, lunch) = await cashAndLunch(app);
    await storeReceipt(app, lunch!, 'r1', name: 'Gone.png', onPhone: false);
    await app.show(TransactionFormPage(workspace: workspace, existing: await viewOf(app, lunch)));
    await tap(tester, app, find.bySemanticsLabel(RegExp('Gone.png')));
    await waitForFiles(tester);
    expect(find.text("The receipt couldn't be opened. Try again."), findsOneWidget);
    await app.stop();
  });

  group('lists', () {
    testWidgets('the month\'s list shows which have a receipt, and keeps only those when asked', (tester) async {
      phone(tester);
      final app = harness(tester);
      final (cash, lunch) = await cashAndLunch(app);
      await app.run(() => app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 5000, occurredOn: '2026-10-03', note: 'Tea'));
      await storeReceipt(app, lunch!, 'r1');
      await storeReceipt(app, lunch, 'r2', name: 'Second.png');
      await app.show(Scaffold(body: TransactionsPage(workspace: workspace)));

      expect(find.bySemanticsLabel(RegExp('2 receipts')), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);
      await tap(tester, app, find.byTooltip('With receipt'));
      expect(find.text('Tea'), findsNothing);
      expect(find.text('Lunch'), findsOneWidget);

      // Transfers never have one: choosing them lets the toggle go
      await tap(tester, app, find.text('Transfer'));
      await tap(tester, app, find.text('All'));
      expect(find.text('Tea'), findsOneWidget);
      await app.stop();
    });

    testWidgets('the account\'s filter sheet narrows to transactions with a receipt, or without', (tester) async {
      phone(tester);
      final app = harness(tester);
      final (cash, lunch) = await cashAndLunch(app);
      await app.run(() => app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 5000, occurredOn: '2026-10-03', note: 'Tea'));
      await storeReceipt(app, lunch!, 'r1');
      await app.show(AccountPage(accountId: cash.id));
      expect(find.bySemanticsLabel(RegExp('1 receipt')), findsOneWidget);

      await tap(tester, app, find.byTooltip('Filters'));
      expect(find.text('Receipt'), findsOneWidget);
      await tap(tester, app, find.text('With receipt'));
      await tap(tester, app, find.widgetWithText(FilledButton, 'Apply'));
      expect(find.text('Tea'), findsNothing);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'With receipt'), findsOneWidget);

      await tap(tester, app, find.byTooltip('Filters'));
      await tap(tester, app, find.text('Without receipt'));
      await tap(tester, app, find.widgetWithText(FilledButton, 'Apply'));
      expect(find.text('Lunch'), findsNothing);
      expect(find.text('Tea'), findsOneWidget);

      // Taken off from its chip
      tester.widget<InputChip>(find.widgetWithText(InputChip, 'Without receipt')).onDeleted!();
      await app.settle();
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);

      // Choosing transfers in the sheet lets the receipt choice go
      await tap(tester, app, find.byTooltip('Filters'));
      await tap(tester, app, find.text('With receipt'));
      await tap(tester, app, find.text('Transfer').last);
      expect(find.text('With receipt'), findsNothing);
      await tap(tester, app, find.text('Reset'));
      await app.stop();
    });
  });

  group('the account ledger', () {
    late ScreenHarness app;

    testWidgets('counts receipts on their way, and none being removed', (tester) async {
      app = harness(tester);
      final (cash, lunch) = await cashAndLunch(app);
      final tea = await app.run(
          () => app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 5000, occurredOn: '2026-10-03', note: 'Tea'));
      await storeReceipt(app, lunch!, 'r1');
      final ledger = AccountLedger(app.db);
      Future<List<String>> notes(AccountFilter filter) async =>
          [for (final row in (await app.run(() => ledger.page(cash.id, 'BDT', filter))).$1) row.transaction.note];

      expect(await notes(const AccountFilter(hasReceipt: true)), ['Lunch']);
      expect(await notes(const AccountFilter(hasReceipt: false)), ['Tea']);

      // One picked here counts before the server has it; one being removed no longer does
      await app.run(() => app.db.into(app.db.billQueue).insert(
          TransactionTarget(workspaceId: workspace.id, transactionId: tea).queueRow('q1', BillOutbox.upload, createdAt: 'x')));
      await app.run(() => app.db.into(app.db.billQueue).insert(
          TransactionTarget(workspaceId: workspace.id, transactionId: lunch).queueRow('r1', BillOutbox.remove, createdAt: 'x')));
      expect(await notes(const AccountFilter(hasReceipt: true)), ['Tea']);
      final summary = await app.run(() => ledger.watchSummary(cash.id, 'BDT', const AccountFilter(hasReceipt: false)).first);
      expect(summary.count, 1);
      await app.stop();
    });

    testWidgets('clearing the narrowing lets the receipt choice go too', (tester) async {
      app = harness(tester);
      final controller = app.container.read(accountFilterProvider('a1').notifier);
      controller.set(const AccountFilter(hasReceipt: true, kind: 'expense'));
      controller.clearNarrowing();
      expect(app.container.read(accountFilterProvider('a1')), const AccountFilter());
      await app.stop();
    });

    test('the receipt choice is part of the filter like any other', () {
      const none = AccountFilter();
      const withOne = AccountFilter(hasReceipt: true);
      expect((none.isNarrowed, withOne.isNarrowed), (false, true));
      expect((none.sheetCount, withOne.sheetCount), (0, 1));
      expect(withOne == const AccountFilter(hasReceipt: true), isTrue);
      expect(withOne == const AccountFilter(hasReceipt: false), isFalse);
      expect(withOne.hashCode == const AccountFilter(hasReceipt: true).hashCode, isTrue);
      expect(withOne.copyWith(query: 'x').hasReceipt, isTrue);
      expect(withOne.copyWith(hasReceipt: () => null).hasReceipt, isNull);
      expect(withOne.withPeriod(AccountPeriod.thisMonth).hasReceipt, isTrue);
    });
  });
}
