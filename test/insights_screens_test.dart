import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/theme.dart';
import 'package:spendroo/features/cashbook/book_access.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';
import 'package:spendroo/features/cashbook/insights/cash_heatmap.dart';
import 'package:spendroo/features/cashbook/insights/insights_pages.dart';
import 'package:spendroo/features/cashbook/insights/insights_providers.dart';
import 'package:spendroo/features/profile/profile_repository.dart';
import 'package:spendroo/features/team/team_repository.dart';

import 'personal_screens_test.dart' show ScreenHarness;
import 'plan_test.dart' show answer;
import 'team_test.dart' show FixedProfile;

const shop = Workspace(
  id: '00000000-0000-0000-0000-0000000000b1',
  name: 'Shop',
  kind: 'business',
  defaultCurrency: 'BDT',
  isDemo: false,
  role: 'owner',
);

Entitlements plan(String code, {bool advanced = false}) => Entitlements(
      answer(plan: code, features: {
        F.insightsBusinessAdvanced: {'kind': 'flag', 'enabled': advanced},
      }),
      fetchedAt: DateTime.now().toUtc(),
    );

void main() {
  /// A business with two books and a month of entries, its insights in October 2026.
  Future<(ScreenHarness, Cashbook)> business(WidgetTester tester, Entitlements entitlements) async {
    tester.view.physicalSize = const Size(1080, 9000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final app = ScreenHarness(tester, plan: entitlements, overrides: [
      profileProvider.overrideWith(() => FixedProfile('me')),
      teamProvider.overrideWith((ref, id) async => null),
    ]);
    late Cashbook till;
    await app.run(() async {
      final books = CashbookRepository(app.db, app.store);
      final tillId = await books.createCashbook(shop.id, 'Till', 'BDT');
      final safeId = await books.createCashbook(shop.id, 'Safe', 'BDT');
      till = (await books.watchCashbook(tillId).first)!.book;
      final safe = (await books.watchCashbook(safeId).first)!.book;
      final food = (await books.watchCategories(tillId).first).firstWhere((c) => c.categoryName == 'Food');
      final cash = (await books.watchPaymentMethods(tillId).first).firstWhere((m) => m.paymentMethodName == 'Cash');
      await books.addEntry(till, entryType: 'cash_in', amountMinor: 900000, entryDate: '2026-09-28', title: 'Opening float');
      for (var day = 1; day <= 18; day += 3) {
        final date = '2026-10-${'$day'.padLeft(2, '0')}';
        await books.addEntry(till,
            entryType: 'cash_in', amountMinor: 120000 + day * 1000, entryDate: date, title: 'Sales', paymentMethodId: cash.id);
        await books.addEntry(till,
            entryType: 'cash_out', amountMinor: 45000 + day * 500, entryDate: date, categoryId: food.id, title: 'Stock');
      }
      await books.addEntry(safe, entryType: 'cash_out', amountMinor: 300000, entryDate: '2026-10-07', title: 'Rent');
    });
    for (final id in [shop.id, till.id]) {
      app.container.read(insightsPeriodProvider(id).notifier).month(DateTime(2026, 10));
    }
    return (app, till);
  }

  Future<void> showBusiness(ScreenHarness app, {ThemeData? theme}) => app.show(
        Scaffold(body: BusinessInsightsPage(workspace: shop, tabs: BusinessTabs(insights: true, onChanged: (_) {}))),
        space: shop,
        theme: theme,
      );

  testWidgets('a business on Free sees the basics, and the Business charts locked', (tester) async {
    final (app, _) = await business(tester, plan('free'));
    await showBusiness(app);
    expect(tester.takeException(), isNull);
    expect(find.text('Net cash flow'), findsOneWidget);
    expect(find.text('Cash flow'), findsOneWidget);
    expect(find.text('Unlock with Business'), findsWidgets);
    expect(find.textContaining('more chart'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsWidgets); // custom dates, and 12/24 months
    await app.stop();
  });

  testWidgets('a business on the Business plan sees every chart, in light and dark', (tester) async {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final (app, _) = await business(tester, plan('plus', advanced: true));
      await showBusiness(app, theme: theme);
      expect(tester.takeException(), isNull);
      expect(find.text('Unlock with Business'), findsNothing);
      expect(find.text('Books compared'), findsOneWidget);
      expect(find.text('Till'), findsOneWidget);
      expect(find.text('Where the money went'), findsOneWidget);
      expect(find.text('Payment methods'), findsOneWidget);
      expect(find.text('Team activity'), findsOneWidget);
      await app.stop();
    }
  });

  testWidgets("a book's insights: pulse, balance, calendar, health, biggest entries and bills", (tester) async {
    final (app, till) = await business(tester, plan('plus', advanced: true));
    await app.show(
      Scaffold(body: BookInsightsView(book: till, workspace: shop, access: BookAccess.manage)),
      space: shop,
    );
    expect(tester.takeException(), isNull);
    for (final title in ['Net cash flow', 'Balance over time', 'Activity', 'Cash health', 'Biggest entries', 'Bills kept']) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    // A day of the calendar says what it held
    await tester.tap(find.descendant(of: find.byType(ActivityHeatmapCard), matching: find.text('4')));
    await app.settle();
    expect(find.textContaining('Sunday'), findsOneWidget);
    await app.stop();
  });
}
