import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/push/push_controller.dart';
import 'package:spendroo/features/home_widget/home_widget_bridge.dart';
import 'package:spendroo/features/home_widget/widget_launch.dart';
import 'package:spendroo/features/home_widget/widget_snapshot.dart';
import 'package:spendroo/features/home_widget/widget_snapshot_builder.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';
import 'package:spendroo/l10n/app_localizations.dart';

import 'plan_test.dart' show answer, entitlements;

final en = lookupAppLocalizations(const Locale('en'));
final bn = lookupAppLocalizations(const Locale('bn'));

/// Saturday 17 October 2026: 31 days, today the 17th.
final today = DateTime(2026, 10, 17);

BudgetProgress budget(int amountMinor, {String currency = 'BDT'}) => BudgetProgress(
      Budget(
        id: 'b-$amountMinor',
        workspaceId: 'w',
        version: 1,
        serverSeq: 0,
        createdAt: '2026-10-01T00:00:00Z',
        updatedAt: '2026-10-01T00:00:00Z',
        categoryId: 'food',
        amountMinor: amountMinor,
        currency: currency,
      ),
      'Food',
      0,
    );

HomeWidgetSnapshot snapshot({
  Map<int, int> daily = const {1: 50000, 17: 45000},
  int income = 500000,
  List<BudgetProgress> budgets = const [],
  Entitlements? plan,
  AppLocalizations? l10n,
}) =>
    buildWidgetSnapshot(
      inputs: WidgetInputs(
        currency: 'BDT',
        dailySpend: daily,
        incomeMinor: income,
        budgets: budgets,
      ),
      plan: plan,
      l10n: l10n ?? en,
      now: today,
    );

/// Plus with the widget, as the server's catalogue gives it (the shared fixture leaves it out).
Entitlements plusWithWidget({String? expiresAt}) => Entitlements(
      answer(plan: 'plus', expiresAt: expiresAt, features: {
        F.homeWidget: {'kind': 'flag', 'enabled': true},
      }),
      fetchedAt: DateTime.utc(2026, 10, 10),
    );

void main() {
  setUpAll(() => initializeDateFormatting('bn'));

  group('the snapshot', () {
    test('the month is the main figure, today beside it, and what is left of the month', () {
      final s = snapshot();
      expect(s.signedIn, isTrue);
      expect(s.date, '2026-10-17');
      expect(s.month, '2026-10');
      expect(s.today, '৳450');
      expect(s.zero, '৳0');
      expect(s.monthTotal, '৳950');
      expect(s.monthName, 'October');
      expect(s.monthLabel, 'Spent in October');
      // 5,000 came in this month, 950 went out: savings and other months play no part
      expect(s.left.label, 'Left this month');
      expect(s.left.value, '৳4,050');
      expect(s.leftNegative, isFalse);
      expect(s.daily, hasLength(31));
      expect(s.daily[0], 50000);
      expect(s.daily[16], 45000);
      expect(s.daily.where((d) => d > 0), hasLength(2));
      expect(s.axis, ['1', '16', '31']);
    });

    test('without a budget the pace is the daily average', () {
      final s = snapshot();
      // 950 over 17 days
      expect(s.pace, 'Avg ৳55.88/day');
      expect(s.paceTone, PaceTone.average);
      expect(s.middle!.label, 'Daily average');
      expect(s.middle!.value, '৳55.88');
      expect(s.budgetPerDayMinor, 0);
    });

    test('with budget left, what is safe to spend each day for the rest of the month', () {
      final s = snapshot(budgets: [budget(200000), budget(110000), budget(99999, currency: 'USD')]);
      // 3,100 - 950 = 2,150 over the 15 days from today to the 31st
      expect(s.pace, 'Safe ৳143.33/day');
      expect(s.paceTone, PaceTone.safe);
      // 950 of 3,100 is 31% used
      expect(s.middle!.label, 'Budget left');
      expect(s.middle!.value, '69%');
      expect(s.budgetPerDayMinor, 10000);
    });

    test('over budget turns the chip red and the budget left to nothing', () {
      final s = snapshot(budgets: [budget(50000)]);
      expect(s.pace, 'Over budget');
      expect(s.paceTone, PaceTone.over);
      expect(s.middle!.value, '0%');
    });

    test('nothing spent yet this month: no chip, an empty chart', () {
      final s = snapshot(daily: const {});
      expect(s.pace, isNull);
      expect(s.today, '৳0');
      expect(s.monthTotal, '৳0');
      expect(s.daily.every((d) => d == 0), isTrue);
    });

    test('spending past the month income leaves less than nothing, flagged', () {
      final s = snapshot(income: 20000);
      expect(s.left.value, '-৳750');
      expect(s.leftNegative, isTrue);
    });

    test('before month names have loaded the caption still reads', () {
      // lookupAppLocalizations alone loads no dates; the builder must not throw
      expect(snapshot().monthLabel, isNotEmpty);
    });

    test('in Bangla: Bangla words and digits, the month in Bangla', () {
      final s = snapshot(l10n: bn);
      expect(s.today, '৳৪৫০');
      expect(s.monthTotal, '৳৯৫০');
      expect(s.monthName, 'অক্টোবর');
      expect(s.monthLabel, 'অক্টোবর-এর খরচ');
      expect(s.left.value, '৳৪,০৫০');
      expect(s.axis, ['১', '১৬', '৩১']);
      expect(s.strings['today'], bn.today);
      expect(s.strings['expense'], bn.expense);
    });

    test('every word the widget reads is there, in both languages', () {
      const keys = {
        'appName', 'today', 'thisMonth', 'spentThisMonth', 'expense', 'income', 'transfer', 'add', 'unlockTitle', 'unlockBody',
        'unlockCta', 'signInTitle', 'signInBody', 'emptyChart', 'hide', 'show',
      };
      for (final l10n in [en, bn]) {
        final strings = widgetStrings(l10n);
        expect(strings.keys.toSet(), keys);
        expect(strings.values.where((v) => v.isEmpty), isEmpty);
      }
    });

    test('signed out: no figures, only the invitation', () {
      final s = signedOutSnapshot(en);
      final json = jsonDecode(s.encode()) as Map<String, dynamic>;
      expect(json['signedIn'], isFalse);
      expect(json['today'], '');
      expect(json['daily'], isEmpty);
      expect((json['strings'] as Map)['signInTitle'], 'Sign in to Spendroo');
    });

    test('the JSON has the shape the Android widget reads (WidgetSnapshot.kt)', () {
      final json = jsonDecode(snapshot(budgets: [budget(310000)]).stamped('Updated 10:42').encode()) as Map;
      expect(json['v'], HomeWidgetSnapshot.version);
      expect(json.keys, containsAll(<String>[
        'signedIn', 'unlocked', 'date', 'month', 'today', 'zero', 'mask', 'monthName', 'monthLabel', 'monthTotal',
        'middle', 'left', 'leftNegative', 'pace', 'paceTone', 'daily', 'budgetPerDay', 'axis', 'strings', 'updated',
      ]));
      expect(json['paceTone'], 'safe');
      expect(json['middle'], {'label': 'Budget left', 'value': '69%'});
      expect(json['mask'], '৳••••');
      expect(json['updated'], 'Updated 10:42');
    });

    test('the time it was stamped with does not make it a different snapshot', () {
      final s = snapshot();
      expect(s.stamped('Updated 10:42').fingerprint, s.stamped('Updated 23:59').fingerprint);
      expect(s.fingerprint, isNot(snapshot(daily: const {17: 1}).fingerprint));
    });
  });

  group('the plan', () {
    test('no plan known yet locks nothing', () {
      expect(widgetLocked(null), isFalse);
      expect(snapshot().unlocked, isTrue);
    });

    test('Free locks the bigger sizes, Plus with the widget opens them', () {
      expect(snapshot(plan: entitlements()).unlocked, isFalse);
      expect(snapshot(plan: plusWithWidget()).unlocked, isTrue);
    });

    test('a plan the server does not enforce locks nothing', () {
      final relaxed = Entitlements({...answer(), 'enforced': false}, fetchedAt: DateTime.utc(2026, 10, 10));
      expect(widgetLocked(relaxed), isFalse);
    });

    test('a paid plan long out of touch with the server stops counting', () {
      final lapsed = plusWithWidget(expiresAt: '2026-09-01T00:00:00+00:00');
      expect(widgetLocked(lapsed, now: DateTime.utc(2026, 10, 17)), isTrue);
    });
  });

  group('amounts', () {
    test('whole amounts lose their ".00", others keep it', () {
      expect(wholeAmount(45000, 'BDT', 'en'), '৳450');
      expect(wholeAmount(45050, 'BDT', 'en'), '৳450.50');
      expect(wholeAmount(45000, 'BDT', 'bn'), '৳৪৫০');
      expect(wholeAmount(45050, 'BDT', 'bn'), '৳৪৫০.৫০');
      expect(wholeAmount(-12345600, 'BDT', 'en'), '-৳1,23,456');
      expect(wholeAmount(1500, 'JPY', 'en'), contains('1,500'));
    });
  });

  group('widget links', () {
    test('each button opens its screen', () {
      expect(widgetRoute(Uri.parse('spendroo://home')), '/');
      expect(widgetRoute(Uri.parse('spendroo://plan')), '/plan');
      expect(widgetRoute(Uri.parse('spendroo://add?kind=expense')), '/add?kind=expense');
      expect(widgetRoute(Uri.parse('spendroo://add?kind=income')), '/add?kind=income');
      expect(widgetRoute(Uri.parse('spendroo://add?kind=transfer')), '/add?kind=transfer');
    });

    test('anything else is refused or made safe', () {
      expect(widgetRoute(null), isNull);
      expect(widgetRoute(Uri.parse('https://spendroo.app/plan')), isNull);
      expect(widgetRoute(Uri.parse('spendroo://settings')), isNull);
      expect(widgetRoute(Uri.parse('spendroo://add?kind=save')), '/add');
      expect(widgetRoute(Uri.parse('spendroo://add')), '/add');
    });

    test('the pending route only takes the screens a widget may open', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final route = container.read(pushRouteProvider.notifier);
      route.openFromWidget('/add?kind=income');
      expect(container.read(pushRouteProvider), '/add?kind=income');
      route.done();
      route.openFromWidget('/settings');
      expect(container.read(pushRouteProvider), isNull);
      route.openFromWidget('/plan');
      expect(container.read(pushRouteProvider), '/plan');
    });

    test('midnights for a week ahead, across the end of the month', () {
      final times = nextMidnights(DateTime(2026, 10, 30, 22, 15));
      expect(times, hasLength(7));
      expect(times.first, DateTime(2026, 10, 31, 0, 0, 5));
      expect(times[1], DateTime(2026, 11, 1, 0, 0, 5));
      expect(times.last, DateTime(2026, 11, 6, 0, 0, 5));
    });
  });
}
