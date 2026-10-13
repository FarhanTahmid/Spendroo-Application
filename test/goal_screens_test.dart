import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/theme.dart';
import 'package:spendroo/features/goals/goal_form_page.dart';
import 'package:spendroo/features/goals/goal_math.dart';
import 'package:spendroo/features/goals/goal_money.dart';
import 'package:spendroo/features/goals/goal_page.dart';
import 'package:spendroo/features/goals/goals_overview_card.dart';
import 'package:spendroo/features/goals/goals_page.dart';
import 'package:spendroo/features/goals/goal_widgets.dart' show everydaySpending;
import 'package:spendroo/features/goals/goals_repository.dart';
import 'package:spendroo/features/personal/ledger_repository.dart' show CategorySpend;
import 'package:spendroo/features/personal/personal_pages.dart';
import 'package:spendroo/features/personal/planner_page.dart';

import 'personal_screens_test.dart' show ScreenHarness, workspace;

/// Every goal screen drawn with real numbers, on a phone-sized screen, in both
/// languages and both themes: nothing overflows, nothing throws.
void main() {
  late String laptop;

  Future<ScreenHarness> seeded(WidgetTester tester, {Size size = const Size(1080, 2400)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final app = ScreenHarness(tester);
    final goals = GoalsRepository(app.db, app.store, app.ledger);
    await app.run(() async {
      await app.db.into(app.db.workspaces).insert(workspace);
      await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT', openingBalanceMinor: 9000000);
      final cash = (await app.ledger.watchAccounts(workspace.id).first).single.account;
      laptop = await goals.createGoal(workspace.id,
          name: 'Laptop', targetMinor: 5000000, currency: 'BDT', targetOn: '2027-03-15', icon: 'gadget');
      final trip = await goals.createGoal(workspace.id, name: 'Cox\'s Bazar trip', targetMinor: 2000000, currency: 'BDT', icon: 'trip');
      final eid = await goals.createGoal(workspace.id, name: 'Eid', targetMinor: 100000, currency: 'BDT', icon: 'festival');
      final laptopGoal = (await goals.watchGoal(laptop).first)!.goal;
      for (final (day, amount) in [('2026-06-02', 800000), ('2026-07-02', 900000), ('2026-08-02', 700000), ('2026-09-02', 1000000)]) {
        await goals.contribute(laptopGoal, cash, amountMinor: amount, occurredOn: day);
      }
      await goals.withdraw(laptopGoal, cash, amountMinor: 200000, occurredOn: '2026-08-20');
      await goals.contribute((await goals.watchGoal(trip).first)!.goal, cash, amountMinor: 300000, occurredOn: '2026-10-01');
      await goals.contribute((await goals.watchGoal(eid).first)!.goal, cash, amountMinor: 100000, occurredOn: '2026-10-03');
      await app.db.delete(app.db.workspaces).go(); // show() inserts it again
    });
    return app;
  }

  for (final (locale, dark) in [('en', false), ('bn', true)]) {
    testWidgets('the goals list, the overview card and the accounts section ($locale)', (tester) async {
      final app = await seeded(tester);
      final theme = dark ? AppTheme.darkTheme : AppTheme.lightTheme;
      await app.show(const GoalsPage(), theme: theme, locale: locale);
      expect(tester.takeException(), isNull);
      if (locale == 'en') {
        expect(find.text('In goals'), findsOneWidget);
        expect(find.text('Laptop'), findsWidgets);
        expect(find.text('Reached'), findsWidgets); // the Eid goal, on the trophy shelf
      }
      await app.stop();

      final again = await seeded(tester);
      await again.show(const Scaffold(body: AccountsPage(workspace: workspace)), theme: theme, locale: locale);
      expect(tester.takeException(), isNull);
      // In goals and net worth share one panel on the header, with the bar of what is set aside
      expect(find.byKey(const ValueKey('goals-worth-panel')), findsOneWidget);
      if (locale == 'en') {
        // The goal's account is listed with the goals, not with the accounts
        expect(find.text('Available to spend'), findsOneWidget);
        expect(find.text('Net worth'), findsOneWidget);
      }
      await again.stop();

      final card = await seeded(tester);
      await card.show(const Scaffold(body: SingleChildScrollView(child: GoalsStrip(workspace: workspace))),
          theme: theme, locale: locale);
      expect(tester.takeException(), isNull);
      // Every goal as a ring, after the bubble that starts a new one
      expect(find.byKey(const ValueKey('goals-strip')), findsOneWidget);
      await card.stop();

      // The Planner tab: budgets and goals behind one switch
      final planner = await seeded(tester);
      await planner.show(const Scaffold(body: PlannerPage(workspace: workspace)), theme: theme, locale: locale);
      // No budget yet, so it opens on the goals
      expect(find.byType(GoalsBody), findsOneWidget);
      await tester.tap(find.text(locale == 'en' ? 'Budgets' : 'বাজেট').first);
      await planner.settle();
      expect(find.byType(GoalsBody), findsNothing);
      expect(tester.takeException(), isNull);
      await planner.stop();
    });

    testWidgets('a goal in full, and money in and out of it ($locale)', (tester) async {
      final app = await seeded(tester, size: const Size(1080, 7000));
      final theme = dark ? AppTheme.darkTheme : AppTheme.lightTheme;
      await app.show(GoalPage(goalId: laptop), theme: theme, locale: locale);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('goal-trajectory')), findsOneWidget);
      expect(find.byKey(const ValueKey('goal-months')), findsOneWidget);
      if (locale == 'en') {
        expect(find.text('Pace'), findsOneWidget);
        expect(find.text('Milestones'), findsWidgets);
      }

      // The add-money sheet, with its quick amounts
      await tester.tap(find.text(locale == 'en' ? 'Add money' : 'টাকা জমান').first);
      await app.settle();
      expect(tester.takeException(), isNull);
      await tester.tapAt(const Offset(10, 10));
      await app.settle();

      // The withdraw screen: two rings and the cost
      final view = (await app.run(() => app.container.read(goalsRepositoryProvider).watchGoal(laptop).first))!;
      final moves = await app.run(() => app.container.read(goalsRepositoryProvider).watchMoves(laptop).first);
      final stats = GoalStats.of(moves: moves, targetMinor: view.goal.targetMinor, createdOn: view.createdOn, today: DateTime.now());
      await app.stop();

      final withdraw = await seeded(tester);
      await withdraw.show(WithdrawPage(view: view, stats: stats), theme: theme, locale: locale);
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField).first, '5000');
      await withdraw.settle();
      expect(tester.takeException(), isNull);
      // The line about what is lost appears above the amount; the amount keeps its focus, so the keypad stays
      expect(tester.widget<EditableText>(find.byType(EditableText).first).focusNode.hasFocus, isTrue);
      await withdraw.stop();
    });
  }

  testWidgets('the first-goal card can be closed, and stays closed', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final app = ScreenHarness(tester);
    await app.show(const Scaffold(body: SingleChildScrollView(child: GoalsStrip(workspace: workspace))));
    expect(find.byKey(const ValueKey('first-goal-invite')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('first-goal-invite-close')));
    await app.settle();
    expect(find.byKey(const ValueKey('first-goal-invite')), findsNothing);
    final saved = await app.run(() => app.db.getSetting(goalInviteDismissedSettingKey));
    expect(saved, isNotNull);
    await app.stop();
  });

  test('the cut-back tip is about everyday spending, not a bill paid in one go', () {
    final rent = CategorySpend('r', 'Housing', null, 1800000, count: 1, largestMinor: 1800000);
    final food = CategorySpend('f', 'Food', null, 600000, count: 14, largestMinor: 90000);
    final school = CategorySpend('s', 'Education', null, 500000, count: 3, largestMinor: 400000);
    expect(everydaySpending([rent, food, school])?.name, 'Food');
    expect(everydaySpending([rent, school]), isNull);
    expect(everydaySpending(null), isNull);
  });

  testWidgets('the new-goal form fills itself from a template and previews the pace', (tester) async {
    final app = await seeded(tester, size: const Size(1080, 4000));
    await app.show(const GoalFormPage(workspace: workspace, template: 'trip'));
    expect(find.text('Trip'), findsWidgets);
    await tester.enterText(find.byType(TextField).at(1), '120000');
    await tester.tap(find.text('Set a target date'));
    await app.settle();
    expect(find.textContaining('/month'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('"Save" on the add form puts money into a goal', (tester) async {
    final app = await seeded(tester, size: const Size(1080, 3000));
    await app.show(Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => openTransactionForm(context, workspace),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await app.settle();
    await tester.tap(find.descendant(of: find.byKey(const ValueKey('kind-switch')), matching: find.text('Save')));
    await app.settle();
    // The goal furthest along its date is offered first
    expect(find.text('Saves into goal'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await app.settle();
    expect(tester.takeException(), isNull);
    final goals = await app.run(() => app.container.read(goalsRepositoryProvider).watchGoals(workspace.id).first);
    expect(goals.map((g) => g.savedMinor).fold<int>(0, (a, b) => a + b), 3200000 + 300000 + 100000 + 100000);
    await app.stop();
  });
}
