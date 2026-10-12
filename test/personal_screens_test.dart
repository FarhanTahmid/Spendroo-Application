import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/design/category_color.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/entitlements/entitlements_controller.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/core/theme.dart';
import 'package:spendroo/features/personal/budget_calendar_page.dart';
import 'package:spendroo/features/personal/categories_page.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';
import 'package:spendroo/features/personal/personal_pages.dart';
import 'package:spendroo/l10n/app_localizations.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

const workspace = Workspace(
  id: '00000000-0000-0000-0000-000000000001',
  name: 'Personal',
  kind: 'personal',
  defaultCurrency: 'BDT',
  isDemo: false,
  role: 'owner',
);

/// The plan the server would have answered with, without a server.
class FixedEntitlements extends EntitlementsController {
  FixedEntitlements(this.plan);

  final Entitlements plan;

  @override
  Future<Entitlements?> build() async => plan;
}

/// A personal screen on an in-memory database, with the month fixed to October 2026.
/// Without [plan] nobody is signed in, so no plan limits anything.
class ScreenHarness {
  ScreenHarness(this.tester, {Entitlements? plan}) {
    useHostSqlite();
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    store = LocalStore(db);
    ledger = LedgerRepository(db, store);
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      localStoreProvider.overrideWithValue(store),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
      if (plan != null) entitlementsProvider.overrideWith(() => FixedEntitlements(plan)),
    ]);
    container.read(selectedMonthProvider.notifier).set(DateTime(2026, 10));
  }

  final WidgetTester tester;
  late final AppDatabase db;
  late final LocalStore store;
  late final LedgerRepository ledger;
  late final ProviderContainer container;

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<T> run<T>(Future<T> Function() action) async => (await tester.runAsync(action)) as T;

  Future<void> show(Widget child, {ThemeData? theme, String locale = 'en'}) async {
    await db.into(db.workspaces).insert(workspace);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: theme,
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    ));
    await settle();
  }

  Future<void> stop() async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.runAsync(db.close);
  }
}

void main() {
  testWidgets('budget calendar: daily spend, colours, a day sheet and month switching', (tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final app = ScreenHarness(tester);
    late final String food;
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
      final cash = (await app.ledger.watchAccounts(workspace.id).first).single.account;
      food = await app.ledger.addCategory(workspace.id, 'Food', 'expense');
      // 3,200 a month is a little over 100 a day in October
      await app.ledger.setBudget(workspace.id, food, 310000, 'BDT');
      final fun = await app.ledger.addCategory(workspace.id, 'Fun', 'expense');
      await app.ledger.setBudget(workspace.id, fun, 10000, 'BDT');
      await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 11200, occurredOn: '2026-10-09',
          categoryId: fun, note: 'Cinema');
      final taxi = await app.ledger.addCategory(workspace.id, 'Taxi', 'expense');
      await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 5000, occurredOn: '2026-10-09',
          categoryId: taxi);
      await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 8000, occurredOn: '2026-10-02',
          categoryId: food, note: 'Groceries');
      await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 250000, occurredOn: '2026-10-05',
          categoryId: food, note: 'Party');
      await app.db.delete(app.db.workspaces).go(); // show() inserts it again
    });

    await app.show(const Scaffold(body: BudgetCalendarPage(workspace: workspace)));
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('80'), findsOneWidget); // day 2, within the daily allowance
    expect(find.text('2.5k'), findsOneWidget); // day 5, far over it
    // Used and left, as amounts and as shares: the month, then each budget with the fullest first
    expect(find.text('86%'), findsOneWidget);
    expect(find.text('Spent · 86%'), findsOneWidget);
    expect(find.text('Left · 14%'), findsOneWidget);
    expect(find.text('Spent · 83%'), findsOneWidget);
    expect(find.text('Left · 17%'), findsOneWidget);
    expect(find.text('৳520.00'), findsOneWidget);
    expect(find.text('Spent · 112%'), findsOneWidget);
    expect(find.text('Over · 12%'), findsOneWidget);
    expect(find.text('৳12.00'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Fun')).dy, lessThan(tester.getTopLeft(find.text('Food')).dy));
    // Spending without a limit is offered one
    expect(find.text('No limit set'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Set limit'), findsOneWidget);

    Color? shade(int day) =>
        tester.widget<Material>(find.byKey(ValueKey('day-$day'))).color;
    expect(shade(2), AppTheme.successColor.withValues(alpha: 0.18));
    expect(shade(5), AppTheme.errorColor.withValues(alpha: 0.25));
    expect(shade(3), Colors.transparent);

    await tester.tap(find.byKey(const ValueKey('day-5')));
    await app.settle();
    expect(find.text('Party'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await app.settle();

    // A budget opens on its days and its expenses; a tapped day narrows the list to it
    await tester.tap(find.byKey(ValueKey('budget-$food')));
    await app.settle();
    expect(find.text('Day by day'), findsOneWidget);
    expect(find.text('Party'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    final days = tester.getRect(find.byKey(const ValueKey('budget-days')));
    await tester.tapAt(Offset(days.left + 40 + (days.width - 40) * 4.5 / 31, days.center.dy));
    await app.settle();
    expect(find.text('Party'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
    await tester.tap(find.widgetWithText(TextButton, 'Edit'));
    await app.settle();
    expect(find.text('Monthly limit'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await app.settle();

    await tester.tap(find.byTooltip('Previous month'));
    await app.settle();
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('2.5k'), findsNothing);
    await app.stop();
  });

  testWidgets('categories: add, rename, recolour and delete', (tester) async {
    final app = ScreenHarness(tester);
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.container.read(currentWorkspaceIdProvider.notifier).select(workspace.id);
      await app.ledger.addCategory(workspace.id, 'Food', 'expense');
      await app.ledger.addCategory(workspace.id, 'Salary', 'income');
      await app.db.delete(app.db.workspaces).go();
    });

    await app.show(const CategoriesPage());
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsNothing); // on the income tab

    await tester.tap(find.text('Food'));
    await app.settle();
    await tester.enterText(find.byType(TextField), 'Groceries');
    await tester.tap(find.byWidgetPredicate((w) => w is ColoredBox && w.color == categoryPalette[3]));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await app.settle();
    expect(find.text('Groceries'), findsOneWidget);
    Future<String?> groceriesColor() async =>
        (await app.run(() => app.ledger.watchCategories(workspace.id).first)).firstWhere((c) => c.name == 'Groceries').color;
    expect(await groceriesColor(), toHexColor(categoryPalette[3]));

    // "Automatic" hands the choice back to the app
    await tester.tap(find.text('Groceries'));
    await app.settle();
    await tester.tap(find.byTooltip('Automatic'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await app.settle();
    expect(await groceriesColor(), isNull);

    await tester.tap(find.text('New category'));
    await app.settle();
    await tester.enterText(find.byType(TextField), 'Transport');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await app.settle();
    expect(find.text('Transport'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete').first);
    await app.settle();
    expect(find.textContaining('Delete "Groceries"?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await app.settle();
    expect(find.text('Groceries'), findsNothing);

    await tester.tap(find.text('Income'));
    await app.settle();
    expect(find.text('Salary'), findsOneWidget);
    await app.stop();
  });

  testWidgets('categories on a limited plan: defaults are tagged, own ones counted, the limit explained', (tester) async {
    final plan = Entitlements({
      'version': 'v1',
      'plan': {'code': 'free', 'name': 'Free', 'rank': 0},
      'source': 'default',
      'features': {
        F.customCategories: {'kind': 'limit', 'limit': 2, 'unlimited': false},
      },
    }, fetchedAt: DateTime(2026, 10, 10));
    final app = ScreenHarness(tester, plan: plan);
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.container.read(currentWorkspaceIdProvider.notifier).select(workspace.id);
      // One the account started with, as the server marks it, and two of the user's own
      await app.store.upsertRow('categories', {
        'id': 'd1', 'workspace_id': workspace.id, 'created_at': '2026-10-01', 'updated_at': '2026-10-01',
        'name': 'Food', 'kind': 'expense', 'is_default': true,
      });
      await app.ledger.addCategory(workspace.id, 'Cricket', 'expense');
      await app.ledger.addCategory(workspace.id, 'Books', 'expense');
      await app.db.delete(app.db.workspaces).go();
    });
    final queued = (await app.run(() => app.db.select(app.db.outbox).get())).length;

    await app.show(const CategoriesPage());
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Your own: 2 of 2'), findsOneWidget);

    await tester.tap(find.text('New category'));
    await app.settle();
    await tester.enterText(find.byType(TextField), 'Travel');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await app.settle();
    expect(find.text('Your Free plan allows 2 categories of your own.'), findsOneWidget);
    expect(find.text('Travel'), findsNothing);
    expect((await app.run(() => app.db.select(app.db.outbox).get())).length, queued);
    await app.stop();
  });

  testWidgets('overview: where the money went, in the colours of the categories, with details on a tap', (tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final app = ScreenHarness(tester);
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
      final cash = (await app.ledger.watchAccounts(workspace.id).first).single.account;
      final rent = await app.ledger.addCategory(workspace.id, 'Housing', 'expense', color: '#2F6FD0');
      final food = await app.ledger.addCategory(workspace.id, 'Food', 'expense', color: '#F08A3C');
      Future<void> spend(String category, int amount, String day) => app.ledger
          .addTransaction(cash, kind: 'expense', amountMinor: amount, occurredOn: day, categoryId: category);
      await spend(rent, 1800000, '2026-10-05');
      await spend(food, 40000, '2026-10-02');
      await spend(food, 20000, '2026-10-07');
      await spend(food, 30000, '2026-09-11');
      await app.ledger.setBudget(workspace.id, food, 100000, 'BDT');
      await app.db.delete(app.db.workspaces).go();
    });

    await app.show(const Scaffold(body: OverviewPage(workspace: workspace)));
    expect(tester.takeException(), isNull);
    expect(find.text('Housing takes 97% of what you spent.'), findsOneWidget);
    expect(find.text('Food is up 100% on last month.'), findsOneWidget);
    expect(find.text('Top spending'), findsNothing); // said once, in the breakdown
    expect(tester.widgetList<ColorDot>(find.byType(ColorDot)).map((d) => d.color).toList(),
        const [Color(0xFF2F6FD0), Color(0xFFF08A3C)]);

    // The budgets together: 18,600 spent against 1,000
    expect(find.text('Budget health'), findsOneWidget);
    expect(find.text('৳17,600.00 over budget'), findsOneWidget);

    // The biggest day, and a day tapped on the chart, open what was spent on them
    await tester.tap(find.byKey(const ValueKey('biggest-day')));
    await app.settle();
    expect(find.text('Mon, Oct 5'), findsOneWidget);
    expect(find.byType(TransactionTile), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await app.settle();
    final pace = tester.getRect(find.byKey(const ValueKey('pace-chart')));
    await tester.tapAt(Offset(pace.left + 44 + (pace.width - 44) * 7 / 31, pace.center.dy));
    await app.settle();
    expect(find.text('Wed, Oct 7'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await app.settle();

    await tester.tap(find.text('Food').last);
    await app.settle();
    expect(find.text('3% of spending'), findsOneWidget);
    expect(find.text('+100% vs last month'), findsOneWidget);
    expect(find.text('৳400.00'), findsOneWidget); // the largest of the two
    expect(find.text('৳300.00'), findsOneWidget); // their average
    expect(find.text('৳600.00 of ৳1,000.00'), findsOneWidget);

    await tester.tap(find.text('See transactions'));
    await app.settle();
    expect(find.byType(TransactionTile), findsNWidgets(2));
    await tester.tapAt(const Offset(10, 10));
    await app.settle();

    // A month tapped on the cash flow chart says how it went, and the screen can move to it.
    // September had Food alone, so nothing is left in focus that is not there
    final flow = tester.getRect(find.byKey(const ValueKey('cash-flow-chart')));
    await tester.tapAt(Offset(flow.left + 44 + (flow.width - 44) * 4.5 / 6, flow.center.dy));
    await app.settle();
    await tester.tap(find.text('Go to September 2026'));
    await app.settle();
    expect(app.container.read(selectedMonthProvider), DateTime(2026, 9));
    expect(tester.takeException(), isNull);
    expect(find.text('100% of spending'), findsOneWidget);
    expect(find.text('Housing'), findsNothing);
    await app.stop();
  });

  testWidgets('overview and budgets hold together in the dark theme and in Bangla', (tester) async {
    tester.view.physicalSize = const Size(1080, 8000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final app = ScreenHarness(tester);
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT', openingBalanceMinor: 9000000);
      final cash = (await app.ledger.watchAccounts(workspace.id).first).single.account;
      final food = await app.ledger.addCategory(workspace.id, 'Food', 'expense');
      final rent = await app.ledger.addCategory(workspace.id, 'Housing', 'expense');
      await app.ledger.setBudget(workspace.id, food, 500000, 'BDT');
      await app.ledger.setBudget(workspace.id, rent, 1500000, 'BDT');
      await app.ledger.addTransaction(cash, kind: 'income', amountMinor: 6500000, occurredOn: '2026-10-01');
      await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 1800000, occurredOn: '2026-10-03',
          categoryId: rent);
      await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 123456, occurredOn: '2026-10-06',
          categoryId: food);
      await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 2200000, occurredOn: '2026-09-04',
          categoryId: rent);
      await app.db.delete(app.db.workspaces).go();
    });

    await app.show(const Scaffold(body: OverviewPage(workspace: workspace)), theme: AppTheme.darkTheme, locale: 'bn');
    expect(tester.takeException(), isNull);
    expect(find.text('খরচের গতি'), findsOneWidget);
    expect(find.text('বাজেটের অবস্থা'), findsOneWidget);
    expect(find.text('আয়-ব্যয়ের ধারা'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await app.db.delete(app.db.workspaces).go();
    await app.show(const Scaffold(body: BudgetCalendarPage(workspace: workspace)), theme: AppTheme.darkTheme, locale: 'bn');
    expect(tester.takeException(), isNull);
    expect(find.text('খরচ · ৯৬%'), findsOneWidget); // 19,234.56 of 20,000
    expect(find.text('অতিরিক্ত · ২০%'), findsOneWidget); // Housing
    await app.stop();
  });
}
