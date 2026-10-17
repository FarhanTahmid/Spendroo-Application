import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/design/amounts.dart';
import 'package:spendroo/core/design/category_color.dart';
import 'package:spendroo/core/design/layout.dart';
import 'package:spendroo/core/design/select_field.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/entitlements/entitlements_controller.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/core/theme.dart';
import 'package:spendroo/features/personal/allocations.dart';
import 'package:spendroo/features/personal/budget_calendar_page.dart';
import 'package:spendroo/features/personal/categories_page.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';
import 'package:spendroo/features/personal/personal_pages.dart';
import 'package:spendroo/l10n/app_localizations.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:fl_chart/fl_chart.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'plan_test.dart' show entitlements;
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

  /// The server answers with another plan, as after a downgrade.
  void change(Entitlements next) => state = AsyncData(next);
}

/// A personal screen on an in-memory database, with the month fixed to October 2026.
/// Without [plan] nobody is signed in, so no plan limits anything.
class ScreenHarness {
  ScreenHarness(this.tester, {Entitlements? plan, List<Override> overrides = const []}) {
    useHostSqlite();
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    store = LocalStore(db);
    ledger = LedgerRepository(db, store);
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      localStoreProvider.overrideWithValue(store),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
      if (plan != null) entitlementsProvider.overrideWith(() => FixedEntitlements(plan)),
      ...overrides,
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

  testWidgets('a transaction is split across categories, and the parts must add up', (tester) async {
    final app = ScreenHarness(tester);
    await app.run(() async {
      await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
      await app.ledger.addCategory(workspace.id, 'Food', 'expense');
      await app.ledger.addCategory(workspace.id, 'Transport', 'expense');
    });
    await app.show(const TransactionFormPage(workspace: workspace));
    final categoryFields = find.byWidgetPredicate((w) => w is SelectField<String> && w.label == 'Category');
    Finder amountOf(Finder field) => find.descendant(of: field, matching: find.byType(EditableText));
    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pump();
      await tester.tap(finder);
      await app.settle();
    }

    await tester.enterText(amountOf(find.byType(AmountField).first), '500');
    await tap(find.text('Split into categories'));
    expect(tester.widget<Text>(find.byKey(const Key('split-status'))).data, contains('left to file'));

    await tap(categoryFields.first);
    await tap(find.text('Food').last);
    await tester.enterText(amountOf(find.byKey(const Key('split-amount-0'))), '300');
    await tester.enterText(amountOf(find.byKey(const Key('split-amount-1'))), '150');
    await app.settle();
    await tap(find.widgetWithText(FilledButton, 'Save'));
    expect(find.textContaining('The parts must add up to'), findsOneWidget);
    expect(await app.run(() => app.ledger.watchTransactions(workspace.id).first), isEmpty);

    // A new part starts with what is still to be filed
    await tap(find.text('Add a part'));
    expect(tester.widget<Text>(find.byKey(const Key('split-status'))).data, 'All of it is filed');
    await tap(categoryFields.at(2));
    await tap(find.text('Transport').last);
    await tap(find.widgetWithText(FilledButton, 'Save'));

    final saved = (await app.run(() => app.ledger.watchTransactions(workspace.id).first)).single.transaction;
    final categories = {for (final c in await app.run(() => app.ledger.watchCategories(workspace.id).first)) c.name: c.id};
    expect((saved.amountMinor, saved.categoryId), (-50000, null));
    expect(saved.parts, [
      SplitPart(categories['Food'], 30000),
      const SplitPart(null, 15000),
      SplitPart(categories['Transport'], 5000),
    ]);
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

  testWidgets('overview: chosen dates in place of the month, on a plan that has them', (tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final app = ScreenHarness(tester, plan: entitlements(plan: 'plus'));
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
      final cash = (await app.ledger.watchAccounts(workspace.id).first).single.account;
      final rent = await app.ledger.addCategory(workspace.id, 'Housing', 'expense');
      final food = await app.ledger.addCategory(workspace.id, 'Food', 'expense');
      Future<void> spend(String category, int amount, String day) => app.ledger
          .addTransaction(cash, kind: 'expense', amountMinor: amount, occurredOn: day, categoryId: category);
      await spend(rent, 1800000, '2026-10-05');
      await spend(food, 40000, '2026-10-02');
      await spend(food, 20000, '2026-10-07'); // after the range
      await spend(food, 20000, '2026-09-28'); // in the six days before it
      await app.ledger.setBudget(workspace.id, food, 100000, 'BDT');
      await app.db.delete(app.db.workspaces).go();
    });

    await app.show(const Scaffold(body: OverviewPage(workspace: workspace)));
    expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    await tester.tap(find.byTooltip('Choose dates'));
    await app.settle();
    expect(find.byType(DateRangePickerDialog), findsOneWidget);
    Navigator.of(tester.element(find.byType(DateRangePickerDialog))).pop();
    await app.settle();

    app.container.read(overviewRangeProvider.notifier).set(const InsightsRange('2026-10-01', '2026-10-06'));
    await app.settle();
    expect(tester.takeException(), isNull);
    expect(find.byType(MonthSwitcher), findsNothing);
    expect(find.text('Housing takes 98% of what you spent.'), findsOneWidget);
    expect(find.text('Food is up 100% on the period before.'), findsOneWidget);
    // A month's budgets and pace have no place in chosen dates
    expect(find.text('Budget health'), findsNothing);
    expect(find.byKey(const ValueKey('pace-chart')), findsNothing);

    await tester.tap(find.text('Food').last);
    await app.settle();
    expect(find.text('+100% vs the period before'), findsOneWidget);
    await tester.tap(find.text('See transactions'));
    await app.settle();
    expect(find.byType(TransactionTile), findsOneWidget); // not the one on the 7th
    await tester.tapAt(const Offset(10, 10));
    await app.settle();

    await tester.tap(find.byTooltip('Back to months'));
    await app.settle();
    expect(app.container.read(overviewRangeProvider), isNull);
    expect(find.byType(MonthSwitcher), findsOneWidget);
    expect(find.text('Budget health'), findsOneWidget);
    await app.stop();
  });

  testWidgets('overview: on Free, choosing dates offers the upgrade', (tester) async {
    final app = ScreenHarness(tester, plan: entitlements());
    app.container.read(overviewRangeProvider.notifier).set(const InsightsRange('2026-10-01', '2026-10-06'));
    await app.show(const Scaffold(body: OverviewPage(workspace: workspace)));
    // Chosen while the plan still had it
    expect(app.container.read(overviewRangeProvider), isNull);
    expect(find.byType(MonthSwitcher), findsOneWidget);
    expect(find.descendant(of: find.byTooltip('Choose dates'), matching: find.byIcon(Icons.lock_outline_rounded)),
        findsOneWidget);

    await tester.tap(find.byTooltip('Choose dates'));
    await app.settle();
    expect(find.byType(DateRangePickerDialog), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  /// Income in each of the [months] months up to October 2026, and the overview showing them.
  Future<ScreenHarness> trendOverview(WidgetTester tester, {Entitlements? plan, int months = 30}) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final app = ScreenHarness(tester, plan: plan);
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
      final cash = (await app.ledger.watchAccounts(workspace.id).first).single.account;
      for (var back = 0; back < months; back++) {
        await app.ledger.addTransaction(cash,
            kind: 'income', amountMinor: 1000 + back, occurredOn: isoDate(DateTime(2026, 10 - back, 3)));
      }
      await app.db.delete(app.db.workspaces).go();
    });
    await app.show(const Scaffold(body: OverviewPage(workspace: workspace)));
    return app;
  }

  /// How many months the cash-flow chart draws.
  int chartedMonths(WidgetTester tester) =>
      tester.widget<BarChart>(find.descendant(of: find.byKey(const ValueKey('cash-flow-chart')), matching: find.byType(BarChart)))
          .data
          .barGroups
          .length;

  bool chipLocked(WidgetTester tester, int months) => find
      .descendant(of: find.byKey(ValueKey('trend-length-$months')), matching: find.byIcon(Icons.lock_outline_rounded))
      .evaluate()
      .isNotEmpty;

  testWidgets('trends: Free charts six months and offers the upgrade for more', (tester) async {
    final app = await trendOverview(tester, plan: entitlements());
    expect(chartedMonths(tester), 6);
    expect(find.byKey(const ValueKey('cash-flow-scroll')), findsNothing);
    expect(find.byKey(const ValueKey('cash-flow-axis')), findsNothing); // the chart draws its own
    expect(find.text('2026'), findsNothing);
    expect([chipLocked(tester, 6), chipLocked(tester, 12), chipLocked(tester, 24)], [false, true, true]);
    expect(find.bySemanticsLabel('Last 6 months'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('trend-length-12')));
    await app.settle();
    expect(find.byType(BottomSheet), findsOneWidget); // the upgrade sheet
    expect(find.text('Your Free plan charts the last 6 months. Upgrade to look further back.'), findsOneWidget);
    // Nothing changed behind it
    expect(app.container.read(trendLengthProvider), 6);
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('trends: Plus charts up to two years, latest first, and a downgrade falls back', (tester) async {
    final app = await trendOverview(tester, plan: entitlements(plan: 'plus'));
    expect(trendLengths.any((months) => chipLocked(tester, months)), isFalse);

    await tester.tap(find.byKey(const ValueKey('trend-length-12')));
    await app.settle();
    expect(app.container.read(trendLengthProvider), 12);
    expect(chartedMonths(tester), 12);

    await tester.tap(find.byKey(const ValueKey('trend-length-24')));
    await app.settle();
    expect(chartedMonths(tester), 24);
    // More than fits: it scrolls, opening on the latest months
    final scroll = find.byKey(const ValueKey('cash-flow-scroll'));
    expect(scroll, findsOneWidget);
    expect(tester.widget<SingleChildScrollView>(scroll).reverse, isTrue);
    expect(find.text('Oct'), findsWidgets);
    // The amounts stay in view beside the scrolling months, and two years name their years
    final axis = find.byKey(const ValueKey('cash-flow-axis'));
    expect(axis, findsOneWidget);
    expect(find.descendant(of: scroll, matching: axis), findsNothing);
    expect(find.text('2024'), findsOneWidget); // under November, the first month
    expect(find.text('2025'), findsOneWidget); // under January
    expect(find.text('2026'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The plan drops to Free: the chart goes back to what Free charts
    (app.container.read(entitlementsProvider.notifier) as FixedEntitlements).change(entitlements());
    await app.settle();
    expect(app.container.read(trendLengthProvider), 6);
    expect(chartedMonths(tester), 6);
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('trends: going to a month from the chart brings its figures into view', (tester) async {
    final app = await trendOverview(tester, months: 8);
    // A phone, so the chart sits below the fold
    tester.view.physicalSize = const Size(1080, 2400);
    await app.settle();
    final page = find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const ValueKey('cash-flow-chart')), 300, scrollable: page);
    await app.settle();
    final scrolled = tester.state<ScrollableState>(page).position;
    expect(scrolled.pixels, greaterThan(0));

    // May to October: September is the fifth
    final flow = tester.getRect(find.byKey(const ValueKey('cash-flow-chart')));
    await tester.tapAt(Offset(flow.left + 44 + (flow.width - 44) * 4.5 / 6, flow.center.dy));
    await app.settle();
    await tester.ensureVisible(find.text('Go to September 2026'));
    await app.settle();
    await tester.tap(find.text('Go to September 2026'));
    await tester.pumpAndSettle();
    expect(app.container.read(selectedMonthProvider), DateTime(2026, 9));
    expect(tester.state<ScrollableState>(page).position.pixels, 0);
    expect(find.text('September 2026'), findsWidgets);
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('trends: without a plan to go by nothing is locked', (tester) async {
    final app = await trendOverview(tester, months: 14);
    expect(trendLengths.any((months) => chipLocked(tester, months)), isFalse);
    await tester.tap(find.byKey(const ValueKey('trend-length-24')));
    await app.settle();
    expect(chartedMonths(tester), 24);
    await app.stop();
  });

  testWidgets('trends: a long chart holds together in the dark theme and in Bangla', (tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final app = ScreenHarness(tester, plan: entitlements(plan: 'plus'));
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
      final cash = (await app.ledger.watchAccounts(workspace.id).first).single.account;
      await app.ledger.addTransaction(cash, kind: 'expense', amountMinor: 123456, occurredOn: '2025-02-10');
      await app.ledger.addTransaction(cash, kind: 'income', amountMinor: 6500000, occurredOn: '2026-10-01');
      await app.db.delete(app.db.workspaces).go();
    });
    app.container.read(trendLengthProvider.notifier).set(24);
    await app.show(const Scaffold(body: OverviewPage(workspace: workspace)), theme: AppTheme.darkTheme, locale: 'bn');
    expect(tester.takeException(), isNull);
    expect(chartedMonths(tester), 24);
    expect(find.text('২৪ মাস'), findsOneWidget);
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
