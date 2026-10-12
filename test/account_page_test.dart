import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/design/layout.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/features/personal/account_ledger.dart';
import 'package:spendroo/features/personal/account_page.dart';
import 'package:spendroo/features/personal/personal_pages.dart';

import 'personal_screens_test.dart' show ScreenHarness, workspace;
import 'plan_test.dart' show entitlements;

void main() {
  /// Cash with 1,000 to start, a bank, and the two months of [fill] on them.
  Future<(Account, Account)> accounts(ScreenHarness app, Future<void> Function(Account cash, Account bank) fill) =>
      app.run(() async {
        await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT', openingBalanceMinor: 100000);
        await app.ledger.addAccount(workspace.id, name: 'Brac Bank', kind: 'bank', currency: 'BDT');
        final all = await app.ledger.watchAccounts(workspace.id).first;
        final cash = all.firstWhere((a) => a.account.name == 'Cash').account;
        final bank = all.firstWhere((a) => a.account.name == 'Brac Bank').account;
        await fill(cash, bank);
        return (cash, bank);
      });

  void phone(WidgetTester tester, {double height = 2400}) {
    tester.view.physicalSize = Size(1080, height);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
  }

  testWidgets('balance, totals, the statement with its running balance, and a filter', (tester) async {
    phone(tester, height: 4000);
    final app = ScreenHarness(tester);
    final (cash, _) = await accounts(app, (cash, bank) async {
      final food = await app.ledger.addCategory(workspace.id, 'Food', 'expense');
      await app.ledger.addTransaction(cash, kind: 'income', amountMinor: 5000000, occurredOn: '2026-09-01', note: 'Pay');
      await app.ledger.addTransaction(cash,
          kind: 'expense', amountMinor: 120000, occurredOn: '2026-09-10', categoryId: food, note: 'Groceries');
      await app.ledger.addTransfer(cash, bank, amountMinor: 2000000, occurredOn: '2026-09-15');
      await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 30000, occurredOn: '2026-09-20', note: 'Rickshaw');
    });

    await app.show(AccountPage(accountId: cash.id));
    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(AppBar, 'Cash'), findsOneWidget);
    expect(find.text('Current balance'), findsOneWidget);
    // 1,000 + 50,000 − 1,200 − 20,000 − 300
    expect(find.text('৳29,500.00'), findsNWidgets(3)); // the header, the newest day and its row
    expect(tester.widgetList<HeaderStat>(find.byType(HeaderStat)).map((s) => s.amountMinor).toList(), [5000000, 2150000]);

    expect(find.text('To Brac Bank'), findsOneWidget);
    expect(find.text('৳29,800.00'), findsNWidgets(2)); // after the transfer: its day and its row
    expect(find.text('Opening balance'), findsOneWidget);
    expect(find.text('৳1,000.00'), findsOneWidget);

    // Searching narrows the list and the totals; the balance stays today's
    await tester.enterText(find.byType(TextField), 'groc');
    await tester.pump(const Duration(milliseconds: 300));
    await app.settle();
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Rickshaw'), findsNothing);
    expect(find.text('Opening balance'), findsNothing);
    expect(tester.widgetList<HeaderStat>(find.byType(HeaderStat)).map((s) => s.amountMinor).toList(), [0, 120000]);
    expect(tester.widget<HeaderFigure>(find.byType(HeaderFigure)).amountMinor, 2950000);

    // The make-up of the totals
    await tester.tap(find.byType(HeaderStat).first);
    await app.settle();
    expect(find.text('In and out, in detail'), findsOneWidget);
    expect(find.text('Closing balance'), findsOneWidget);
    await app.stop();
  });

  testWidgets('more rows load as the list is scrolled', (tester) async {
    phone(tester);
    final app = ScreenHarness(tester);
    final (cash, _) = await accounts(app, (cash, bank) async {
      for (var i = 0; i < 100; i++) {
        await app.ledger.addTransaction(cash,
            kind: 'expense', amountMinor: 100, occurredOn: '2026-09-${(1 + i % 28).toString().padLeft(2, '0')}');
      }
    });

    await app.show(AccountPage(accountId: cash.id));
    AccountFeed feed() => app.container.read(accountFeedProvider(cash.id));
    expect((feed().rows.length, feed().hasMore), (feedPageSize, true));

    for (var i = 0; i < 12 && feed().hasMore; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
      await app.settle();
    }
    expect((feed().rows.length, feed().hasMore), (100, false));
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('insights: a category there filters the list', (tester) async {
    phone(tester, height: 6000);
    final app = ScreenHarness(tester);
    final (cash, _) = await accounts(app, (cash, bank) async {
      final food = await app.ledger.addCategory(workspace.id, 'Food', 'expense');
      await app.ledger.addTransaction(cash,
          kind: 'expense', amountMinor: 45000, occurredOn: '2026-09-02', categoryId: food, note: 'Lunch');
      await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 15000, occurredOn: '2026-09-03', note: 'Bus');
    });

    await app.show(AccountPage(accountId: cash.id));
    await tester.tap(find.text('Insights'));
    await app.settle();
    expect(tester.takeException(), isNull);
    expect(find.text('Balance over time'), findsOneWidget);
    expect(find.text('Where it went'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);

    await tester.tap(find.text('Food'));
    await app.settle();
    expect(app.container.read(accountFilterProvider(cash.id)).categoryIds.length, 1);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Bus'), findsNothing);
    expect(find.byType(InputChip), findsOneWidget);
    await app.stop();
  });

  testWidgets('a locked account can be read, and adding to it offers the upgrade', (tester) async {
    phone(tester);
    late Account cash;
    // The plan must exist before the harness, the accounts after: ids are made on the device
    final setup = ScreenHarness(tester);
    (cash, _) = await accounts(setup, (cash, bank) async {
      await setup.ledger.addTransaction(cash, kind: 'expense', amountMinor: 2500, occurredOn: '2026-09-02', note: 'Tea');
    });
    final rows = await setup.run(() => setup.db.select(setup.db.transactions).get());
    final account = await setup.run(() => (setup.db.select(setup.db.accounts)..where((a) => a.id.equals(cash.id))).getSingle());
    await setup.stop();

    final app = ScreenHarness(
      tester,
      plan: entitlements(locks: [
        {
          'feature': F.personalAccounts, 'scope': workspace.id, 'limit': 1,
          'kept': <String>[], 'locked': [cash.id], 'pending': true, 'can_change_at': null,
        },
      ]),
    );
    await app.run(() async {
      await app.db.into(app.db.accounts).insert(account);
      for (final row in rows) {
        await app.db.into(app.db.transactions).insert(row);
      }
    });

    await app.show(AccountPage(accountId: cash.id));
    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Tea'), findsOneWidget);

    await tester.tap(find.byTooltip('Add transaction'));
    await app.settle();
    expect(find.byType(TransactionFormPage), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget); // the upgrade sheet
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('an account that is gone says so', (tester) async {
    phone(tester);
    final app = ScreenHarness(tester);
    await app.show(const AccountPage(accountId: 'missing'));
    expect(find.text('This account is no longer here.'), findsOneWidget);
    await app.stop();
  });
}
