import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/entitlements/entitlements_controller.dart';
import 'package:spendroo/core/theme.dart';
import 'package:spendroo/features/goals/goals_repository.dart';
import 'package:spendroo/features/insights/year_review_page.dart';
import 'package:spendroo/features/insights/year_review_providers.dart';
import 'package:spendroo/features/insights/year_review_share.dart';
import 'package:spendroo/features/personal/allocations.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';
import 'package:spendroo/features/personal/personal_pages.dart';
import 'package:spendroo/l10n/app_localizations.dart';

import 'personal_screens_test.dart' show FixedEntitlements, ScreenHarness, workspace;
import 'plan_test.dart' show entitlements;

/// Keeps what would have gone to the share sheet.
class FakeSharer extends YearReviewSharer {
  final shared = <(Uint8List, int, String)>[];

  @override
  Future<void> share(Uint8List png, {required int year, required String text}) async => shared.add((png, year, text));
}

void main() {
  final today = DateTime(2026, 10, 17);

  /// The year screen on a tall phone, with 2024 and 2025 recorded (the figures
  /// of test/year_review_test.dart) and one goal reached in 2025.
  Future<(ScreenHarness, FakeSharer)> reviewScreen(WidgetTester tester,
      {Entitlements? plan, ThemeData? theme, String locale = 'en', Widget? child}) async {
    tester.view.physicalSize = const Size(1080, 7000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final sharer = FakeSharer();
    final app = ScreenHarness(tester, plan: plan, overrides: [
      reviewTodayProvider.overrideWithValue(today),
      yearReviewSharerProvider.overrideWithValue(sharer),
    ]);
    await app.run(() async {
      final ledger = app.ledger;
      await ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
      final cash = (await ledger.watchAccounts(workspace.id).first).single.account;
      final salary = await ledger.addCategory(workspace.id, 'Salary', 'income');
      final food = await ledger.addCategory(workspace.id, 'Food', 'expense');
      final home = await ledger.addCategory(workspace.id, 'Home', 'expense');
      Future<void> add(String kind, int amount, String day, [String? category]) =>
          ledger.addTransaction(cash, kind: kind, amountMinor: amount, occurredOn: day, categoryId: category);
      await add('income', 300000, '2024-03-10', salary);
      await add('expense', 100000, '2024-03-12', food);
      await add('income', 500000, '2025-01-05', salary);
      await add('expense', 120000, '2025-01-20', food);
      await add('expense', 30000, '2025-02-14');
      await ledger.addTransaction(cash,
          kind: 'expense',
          amountMinor: 200000,
          occurredOn: '2025-03-03',
          splits: [SplitPart(food, 40000), SplitPart(home, 160000)]);
      await add('income', 100000, '2025-03-25', salary);
      await add('expense', 10000, '2025-12-31', food);
      final goals = GoalsRepository(app.db, app.store, ledger);
      final reached = await goals.createGoal(workspace.id, name: 'Laptop', targetMinor: 100, currency: 'BDT');
      await goals.createGoal(workspace.id, name: 'Phone', targetMinor: 100, currency: 'BDT');
      await (app.db.update(app.db.savingsGoals)..where((g) => g.id.equals(reached)))
          .write(const SavingsGoalsCompanion(reachedAt: Value('2025-07-01T10:00:00+06:00')));
    });
    await app.show(child ?? const YearReviewPage(), theme: theme, locale: locale);
    return (app, sharer);
  }

  Future<void> goBackAYear(ScreenHarness app, WidgetTester tester) async {
    await tester.tap(find.byTooltip('Previous year'));
    await app.settle();
  }

  testWidgets('year in review: opens on this year, steps back to a full year and shows it all', (tester) async {
    final (app, _) = await reviewScreen(tester, plan: entitlements(plan: 'plus'));
    // Nothing recorded this year yet
    expect(find.text('2026'), findsOneWidget);
    expect(find.textContaining('Nothing was recorded in 2026'), findsOneWidget);
    expect(find.byTooltip('Share your year'), findsNothing);
    final next = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right_rounded));
    expect(next.onPressed, isNull);

    await goBackAYear(app, tester);
    expect(app.container.read(reviewYearProvider), 2025);
    expect(find.text('You kept'), findsOneWidget);
    expect(find.text('40% of what came in'), findsOneWidget);
    expect(find.text('Against 2024'), findsOneWidget);
    expect(find.text('+100% on 2024'), findsOneWidget); // income
    expect(find.text('+260% on 2024'), findsOneWidget); // spending
    expect(find.text('+20% on 2024'), findsOneWidget); // kept
    expect(find.text('Month by month'), findsOneWidget);
    expect(find.text('March'), findsOneWidget); // spent most
    expect(find.text('December'), findsOneWidget); // spent least
    expect(find.text('Where it went'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Uncategorised'), findsOneWidget);
    expect(find.text('+70% on 2024'), findsOneWidget); // Food, against 100,000 the year before
    expect(find.text('Best month for saving'), findsOneWidget);
    expect(find.text('January'), findsOneWidget);
    expect(find.text('1 of 12'), findsOneWidget); // months in the green
    expect(find.text('Goals reached'), findsOneWidget);
    expect(find.byTooltip('Share your year'), findsOneWidget);

    // 2024 is the first year: there is nothing before it
    await goBackAYear(app, tester);
    expect(find.text('Against 2023'), findsNothing);
    final previous = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_left_rounded));
    expect(previous.onPressed, isNull);
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('year in review: the card is shared as a picture', (tester) async {
    final (app, sharer) = await reviewScreen(tester, plan: entitlements(plan: 'plus'));
    await goBackAYear(app, tester);
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Share your year'));
      for (var i = 0; i < 20 && sharer.shared.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await app.settle();
    expect(sharer.shared, hasLength(1));
    final (png, year, text) = sharer.shared.single;
    expect((year, text), (2025, 'My 2025 with Spendroo'));
    expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]); // a PNG
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('year in review: the sharer writes the picture where the share sheet can read it', (tester) async {
    final folder = await tester.runAsync(() => Directory.systemTemp.createTemp('review'));
    addTearDown(() => folder!.deleteSync(recursive: true));
    // The share sheet itself needs a phone; the file it is handed is what is checked here
    final sharer = YearReviewSharer(folder: () async => folder!);
    await tester.runAsync(() async {
      try {
        await sharer.share(Uint8List.fromList([1, 2, 3]), year: 2025, text: 'x');
      } catch (_) {}
    });
    final file = File('${folder!.path}/spendroo-2025-in-review.png');
    expect(file.readAsBytesSync(), [1, 2, 3]);
  });

  testWidgets('year in review: tapping a month opens it on the overview', (tester) async {
    final (app, _) = await reviewScreen(tester, plan: entitlements(plan: 'plus'));
    app.container.read(overviewRangeProvider.notifier).set(const InsightsRange('2026-10-01', '2026-10-06'));
    await goBackAYear(app, tester);
    await tester.tap(find.byKey(const ValueKey('review-month-2025-03-01')));
    await app.settle();
    expect(app.container.read(selectedMonthProvider), DateTime(2025, 3));
    expect(app.container.read(overviewRangeProvider), isNull);
    await app.stop();
  });

  testWidgets('year in review: on Free the screen says what the plan lacks and offers the upgrade', (tester) async {
    final (app, _) = await reviewScreen(tester, plan: entitlements());
    expect(find.text('You kept'), findsNothing);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    await tester.tap(find.text('See plans'));
    await app.settle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('year in review: a downgrade while it is open locks it, an upgrade brings it back', (tester) async {
    final (app, _) = await reviewScreen(tester, plan: entitlements(plan: 'plus'));
    await goBackAYear(app, tester);
    expect(find.text('You kept'), findsOneWidget);
    final plan = app.container.read(entitlementsProvider.notifier) as FixedEntitlements;
    plan.change(entitlements());
    await app.settle();
    expect(find.text('You kept'), findsNothing);
    expect(find.text('See plans'), findsOneWidget);
    expect(find.byTooltip('Share your year'), findsNothing);
    plan.change(entitlements(plan: 'plus'));
    await app.settle();
    expect(find.text('You kept'), findsOneWidget);
    await app.stop();
  });

  testWidgets('year in review: holds together in the dark theme and in Bangla', (tester) async {
    final (app, _) = await reviewScreen(tester, plan: entitlements(plan: 'plus'), theme: AppTheme.darkTheme, locale: 'bn');
    await tester.tap(find.byTooltip('আগের বছর'));
    await app.settle();
    expect(find.text('২০২৫'), findsWidgets);
    expect(find.text('আপনি জমিয়েছেন'), findsOneWidget);
    expect(find.text('২০২৪-এর তুলনায়'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('overview: the year in review tile is locked on Free and opens the upgrade', (tester) async {
    final (app, _) =
        await reviewScreen(tester, plan: entitlements(), child: const Scaffold(body: OverviewPage(workspace: workspace)));
    final tile = find.byType(YearReviewTile);
    expect(tile, findsOneWidget);
    expect(find.text('Your 2026 in review'), findsOneWidget);
    expect(find.descendant(of: tile, matching: find.byIcon(Icons.lock_outline_rounded)), findsOneWidget);
    await tester.tap(tile);
    await app.settle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
    await app.stop();
  });

  testWidgets('overview: on Plus the tile opens the year in review', (tester) async {
    final (app, _) = await reviewScreen(tester, plan: entitlements(plan: 'plus'), child: const SizedBox());
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: OverviewPage(workspace: workspace))),
      GoRoute(path: '/year-review', builder: (_, _) => const YearReviewPage()),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: app.container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ));
    // A phone, so the tile sits below the fold
    tester.view.physicalSize = const Size(1080, 2400);
    await app.settle();
    final tile = find.byType(YearReviewTile);
    final page = find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(tile, 300, scrollable: page);
    await app.settle();
    expect(tester.state<ScrollableState>(page).position.pixels, greaterThan(0));
    expect(find.descendant(of: tile, matching: find.byIcon(Icons.chevron_right_rounded)), findsOneWidget);
    await tester.tap(tile);
    await app.settle();
    await app.settle();
    expect(find.byType(YearReviewPage), findsOneWidget);
    expect(find.text('Year in review'), findsOneWidget);

    // Opening a month comes back to the overview, scrolled up to that month's figures
    await goBackAYear(app, tester);
    await tester.tap(find.byKey(const ValueKey('review-month-2025-03-01')));
    await app.settle();
    await tester.pumpAndSettle();
    expect(find.byType(YearReviewPage), findsNothing);
    expect(app.container.read(selectedMonthProvider), DateTime(2025, 3));
    expect(tester.state<ScrollableState>(page).position.pixels, 0);
    expect(find.text('March 2025'), findsWidgets);
    expect(tester.takeException(), isNull);
    await app.stop();
  });
}
