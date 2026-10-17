import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../../core/entitlements/entitlements.dart';
import '../../core/money.dart';
import '../../l10n/app_localizations.dart';
import '../personal/ledger_repository.dart';
import 'widget_snapshot.dart';

/// What the widget's figures are made from, all for the personal workspace
/// in its default currency.
class WidgetInputs {
  const WidgetInputs({
    required this.currency,
    required this.dailySpend,
    required this.incomeMinor,
    required this.budgets,
  });

  final String currency;

  /// Day of the current month -> spent (positive), as watchDailySpend gives it.
  final Map<int, int> dailySpend;

  /// What came in this month.
  final int incomeMinor;
  final List<BudgetProgress> budgets;
}

/// Whether the plan keeps the widget's bigger sizes from the user. The same
/// rule as featureLocked: with no plan known yet, or one not enforced, nothing is locked.
/// The personal workspace is always the user's own.
bool widgetLocked(Entitlements? plan, {DateTime? now}) =>
    plan != null && plan.enforced && !plan.can(F.homeWidget, now: now);

/// The widget's words, in [l10n]'s language.
Map<String, String> widgetStrings(AppLocalizations l10n) => {
      'appName': l10n.appName,
      'today': l10n.today,
      'thisMonth': l10n.thisMonth,
      'spentThisMonth': l10n.widgetSpentThisMonth,
      'expense': l10n.expense,
      'income': l10n.income,
      'transfer': l10n.transfer,
      'add': l10n.widgetAdd,
      'unlockTitle': l10n.widgetUnlockTitle,
      'unlockBody': l10n.widgetUnlockBody,
      'unlockCta': l10n.widgetUnlockCta,
      'signInTitle': l10n.widgetSignInTitle,
      'signInBody': l10n.widgetSignInBody,
      'emptyChart': l10n.widgetEmptyChart,
      'hide': l10n.widgetHideAmounts,
      'show': l10n.widgetShowAmounts,
    };

/// Turns the ledger's numbers into what the widget shows on [now]'s date.
HomeWidgetSnapshot buildWidgetSnapshot({
  required WidgetInputs inputs,
  required Entitlements? plan,
  required AppLocalizations l10n,
  required DateTime now,
}) {
  final locale = l10n.localeName;
  final bangla = locale.startsWith('bn');
  final currency = inputs.currency;
  String money(int minor) => wholeAmount(minor, currency, locale);
  String digits(String text) => bangla ? Money.toBengaliDigits(text) : text;

  final days = daysInMonth(now);
  final daily = [for (var day = 1; day <= days; day++) inputs.dailySpend[day] ?? 0];
  final spentToday = inputs.dailySpend[now.day] ?? 0;
  final spentMonth = daily.fold<int>(0, (sum, value) => sum + value);

  // The month's own money: what came in less what went out, as the overview's
  // "Net remaining balance". Savings and other months stay out of it.
  final left = inputs.incomeMinor - spentMonth;
  final monthName = _monthName(now, bangla);

  final budgetTotal =
      inputs.budgets.where((b) => b.budget.currency == currency).fold<int>(0, (sum, b) => sum + b.budget.amountMinor);
  final pace = SpendPace(month: DateTime(now.year, now.month), spentMinor: spentMonth, limitMinor: budgetTotal, today: now);

  final (String? paceText, PaceTone tone) = switch (pace) {
    _ when budgetTotal > 0 && pace.isOver => (l10n.overBudget, PaceTone.over),
    _ when budgetTotal > 0 && pace.safePerDayMinor > 0 => (l10n.widgetSafePace(money(pace.safePerDayMinor)), PaceTone.safe),
    _ when spentMonth > 0 => (l10n.widgetAveragePace(money(pace.averageMinor)), PaceTone.average),
    _ => (null, PaceTone.average),
  };

  final middle = budgetTotal > 0
      ? WidgetStat(l10n.widgetBudgetLeft, digits('${(100 - pace.usedPercent).clamp(0, 100)}%'))
      : WidgetStat(l10n.dailyAverage, money(pace.averageMinor));

  return HomeWidgetSnapshot(
    unlocked: !widgetLocked(plan, now: now),
    date: isoDate(now),
    today: money(spentToday),
    zero: money(0),
    mask: '${Money.symbol(currency)}••••',
    monthName: monthName,
    monthLabel: monthName.isEmpty ? l10n.widgetSpentThisMonth : l10n.widgetSpentIn(monthName),
    monthTotal: money(spentMonth),
    middle: middle,
    left: WidgetStat(l10n.widgetLeftThisMonth, money(left)),
    leftNegative: left < 0,
    pace: paceText,
    paceTone: tone,
    daily: daily,
    budgetPerDayMinor: budgetTotal > 0 ? budgetTotal ~/ days : 0,
    axis: [digits('1'), digits('${(days + 1) ~/ 2}'), digits('$days')],
    strings: widgetStrings(l10n),
  );
}

String _monthName(DateTime date, bool bangla) {
  try {
    return DateFormat.MMMM(bangla ? 'bn' : 'en').format(date);
  } on Object {
    // Month names load with the app's localizations (LocaleDataException before
    // then, for English too); the widget then says "This month"
    return '';
  }
}

/// What a signed-out phone shows: an invitation in place of figures.
HomeWidgetSnapshot signedOutSnapshot(AppLocalizations l10n) => HomeWidgetSnapshot.signedOut(strings: widgetStrings(l10n));

/// "৳1,250" for a whole amount and "৳1,250.50" otherwise: a widget has no
/// room for ".00" on every figure.
String wholeAmount(int minor, String currency, String locale) {
  final text = Money.format(minor, currency, locale: locale);
  final scale = math.pow(10, Money.exponent(currency)).toInt();
  return minor % scale == 0 ? text.replaceFirst(RegExp(r'[.][0০]+$'), '') : text;
}
