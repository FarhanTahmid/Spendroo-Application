import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/entitlements/entitlements.dart';
import '../../../core/money.dart';
import '../../../l10n/app_localizations.dart';
import '../../personal/ledger_repository.dart' show daysInMonth, isoDate;
import '../widget_snapshot_builder.dart' show wholeAmount;
import 'biz_queries.dart';
import 'biz_snapshot.dart';

/// Links the widgets open; the app maps them in widget_launch.dart (widgetRoute)
/// and the Android side builds the same ones (WidgetLinks.kt).
abstract final class BizLinks {
  static String business(String workspaceId) => 'spendroo://business?ws=$workspaceId';

  /// The workspace goes along, so the app opens the book from its business.
  static String book(String bookId, String workspaceId) => 'spendroo://book?id=$bookId&ws=$workspaceId';
}

/// Everything known about one cashbook that its widget, and its business's, are made from.
class BookFacts {
  const BookFacts({
    required this.book,
    required this.balanceMinor,
    required this.entryCount,
    required this.daily,
    required this.canAdd,
    this.lastEntry,
    this.monthCategories = const {},
    this.weekBiggest,
    this.recent = const [],
  });

  final Cashbook book;
  final int balanceMinor;
  final int entryCount;

  /// yyyy-MM-dd -> money in and out, from the 1st of last month to today.
  final Map<String, DayFlow> daily;

  /// The user may add entries (their role allows it and the plan has not locked the book).
  final bool canAdd;
  final String? lastEntry;

  /// Category name ('' for none) -> cash out this month.
  final Map<String, int> monthCategories;
  final BigOut? weekBiggest;
  final List<RecentEntry> recent;
}

/// The first day the widgets need figures from on [today]: the 1st of last
/// month, which is always more than the 14 days the chart and "7 days" compare need.
DateTime bizWindowStart(DateTime today) => DateTime(today.year, today.month - 1, 1);

/// Whether the plan keeps the big sizes from the user; the same rule as the personal widget's.
bool bizWidgetLocked(Entitlements? plan, {DateTime? now}) =>
    plan != null && plan.enforced && !plan.can(F.businessWidget, now: now);

/// The words the widgets and their picker show, in [l10n]'s language.
Map<String, String> bizWidgetStrings(AppLocalizations l10n) => {
  'appName': l10n.appName,
  'balance': l10n.balance,
  'cashIn': l10n.cashIn,
  'cashOut': l10n.cashOut,
  'net': l10n.net,
  'today': l10n.today,
  'sevenDays': l10n.bizWidgetSevenDays,
  'thisMonth': l10n.thisMonth,
  'hide': l10n.widgetHideAmounts,
  'show': l10n.widgetShowAmounts,
  'unlockTitle': l10n.bizWidgetUnlockTitle,
  'unlockBody': l10n.bizWidgetUnlockBody,
  'unlockCta': l10n.widgetUnlockCta,
  'signInTitle': l10n.widgetSignInTitle,
  'signInBody': l10n.bizWidgetSignInBody,
  'chooseBusiness': l10n.bizWidgetChooseBusiness,
  'chooseBook': l10n.bizWidgetChooseBook,
  'chooseBody': l10n.bizWidgetChooseBody,
  'goneTitle': l10n.bizWidgetGoneTitle,
  'goneBody': l10n.bizWidgetGoneBody,
  'booksTitle': l10n.bizWidgetBooksTitle,
  'recentTitle': l10n.bizWidgetRecentTitle,
  'noEntries': l10n.bizWidgetNoEntries,
  'quietChart': l10n.bizWidgetQuietChart,
  'noBooks': l10n.bizWidgetNoBooks,
  'nextInsight': l10n.bizWidgetNextInsight,
  'refresh': l10n.bizWidgetRefresh,
  'period': l10n.bizWidgetPeriod,
  'pickerEmpty': l10n.bizWidgetPickerEmpty,
  'pickerBooksEmpty': l10n.bizWidgetPickerBooksEmpty,
};

/// Formats money, digits and dates for one currency in [l10n]'s language.
class _Format {
  _Format(this.l10n, this.currency) : bangla = l10n.localeName.startsWith('bn');

  final AppLocalizations l10n;
  final String currency;
  final bool bangla;

  String get locale => l10n.localeName;

  String money(int minor) => wholeAmount(minor, currency, locale);

  /// "+৳1,200", "-৳300", "৳0".
  String signed(int minor) => minor > 0 ? '+${money(minor)}' : money(minor);

  String digits(String text) => bangla ? Money.toBengaliDigits(text) : text;

  String percent(int value) => digits('$value%');

  String get mask => '${Money.symbol(currency)}••••';

  /// "12 Oct".
  String day(DateTime date) {
    try {
      return DateFormat('d MMM', bangla ? 'bn' : 'en').format(date);
    } on Object {
      // Date names load with the app's localizations
      return digits('${date.day}/${date.month}');
    }
  }

  String monthName(DateTime date) {
    try {
      return DateFormat.MMMM(bangla ? 'bn' : 'en').format(date);
    } on Object {
      return l10n.thisMonth;
    }
  }
}

DateTime _addDays(DateTime day, int days) => DateTime(day.year, day.month, day.day + days);

DateTime? _parseDay(String? iso) => iso == null ? null : DateTime.tryParse(iso);

/// Money in and out from [from] to [to], both inclusive.
DayFlow _sum(Map<String, DayFlow> daily, DateTime from, DateTime to) {
  var total = DayFlow.none;
  for (var day = from; !day.isAfter(to); day = _addDays(day, 1)) {
    total += daily[isoDate(day)] ?? DayFlow.none;
  }
  return total;
}

/// Whole-percent change from [before] to [now]; null when there is nothing to compare with.
int? _change(int now, int before) => before <= 0 ? null : ((now - before) * 100 / before).round();

String? _changeText(int? change, _Format f) {
  if (change == null || change == 0) return null;
  return '${change > 0 ? '▲' : '▼'}${f.percent(change.abs())}';
}

BizPeriod _period(String label, String compare, DayFlow now, DayFlow before, _Format f) {
  final inChange = _change(now.inMinor, before.inMinor);
  final outChange = _change(now.outMinor, before.outMinor);
  return BizPeriod(
    label: label,
    compare: compare,
    inText: f.money(now.inMinor),
    outText: f.money(now.outMinor),
    netText: f.signed(now.netMinor),
    netNegative: now.netMinor < 0,
    inChange: _changeText(inChange, f),
    inChangeGood: (inChange ?? 0) >= 0,
    outChange: _changeText(outChange, f),
    outChangeGood: (outChange ?? 0) <= 0,
  );
}

/// The seven days ending [end], against the seven before them.
BizPeriod _weekEnding(Map<String, DayFlow> daily, DateTime end, _Format f) => _period(
  f.l10n.bizWidgetSevenDays,
  f.l10n.bizWidgetVsPrevious7,
  _sum(daily, _addDays(end, -6), end),
  _sum(daily, _addDays(end, -13), _addDays(end, -7)),
  f,
);

/// The month so far, and the same days of last month.
(DayFlow, DayFlow) _monthAndLast(Map<String, DayFlow> daily, DateTime today) {
  final month = _sum(daily, DateTime(today.year, today.month), today);
  final lastMonth = DateTime(today.year, today.month - 1);
  final lastDay = today.day.clamp(1, daysInMonth(lastMonth));
  final last = _sum(daily, lastMonth, DateTime(lastMonth.year, lastMonth.month, lastDay));
  return (month, last);
}

/// One book's line in its business's figures.
class _BookLine {
  const _BookLine(this.name, this.balanceMinor, this.monthNetMinor);

  final String name;
  final int balanceMinor;
  final int monthNetMinor;
}

/// What the insights are worked out from; for a business, its books in the main currency added up.
class _InsightInput {
  const _InsightInput({
    required this.balanceMinor,
    required this.entryCount,
    required this.daily,
    required this.lastEntry,
    required this.monthCategories,
    required this.weekBiggest,
    this.books = const [],
  });

  final int balanceMinor;
  final int entryCount;
  final Map<String, DayFlow> daily;
  final String? lastEntry;
  final Map<String, int> monthCategories;
  final BigOut? weekBiggest;

  /// A business's books; empty for a single book.
  final List<_BookLine> books;
}

/// Up to [limit] pieces of advice, most useful first. Each rule only speaks when
/// it has something worth saying; scores rank them (higher first).
List<BizInsight> _insights(_InsightInput input, DateTime today, _Format f, {int limit = 4}) {
  final l10n = f.l10n;
  final todayIso = isoDate(today);
  final monthEnd = isoDate(DateTime(today.year, today.month + 1, 0));
  const always = '9999-12-31';
  final found = <BizInsight>[];

  void add(String kind, String text, String masked, BizTone tone, String until, int score) =>
      found.add(BizInsight(kind: kind, text: text, masked: masked, tone: tone, until: until, score: score));

  // Below zero: the business as a whole, else its worst book
  if (input.balanceMinor < 0) {
    add(
      'negative',
      l10n.bizInsightNegative(f.money(-input.balanceMinor)),
      l10n.bizInsightNegativeMasked,
      BizTone.warn,
      always,
      100,
    );
  } else {
    final negative = input.books.where((b) => b.balanceMinor < 0).toList()
      ..sort((a, b) => a.balanceMinor.compareTo(b.balanceMinor));
    if (negative.isNotEmpty) {
      final book = negative.first;
      add(
        'negative',
        l10n.bizInsightNegativeBook(book.name, f.money(-book.balanceMinor)),
        l10n.bizInsightNegativeBookMasked(book.name),
        BizTone.warn,
        always,
        95,
      );
    }
  }

  // Gone quiet: a date rather than a count of days, so it stays true while the app is closed
  final last = _parseDay(input.lastEntry);
  if (last != null && today.difference(last).inDays >= 3) {
    final text = l10n.bizInsightIdle(f.day(last));
    add('idle', text, text, BizTone.warn, always, 80);
  }

  final (month, lastMonth) = _monthAndLast(input.daily, today);

  // This month against the same days of last month
  final outChange = _change(month.outMinor, lastMonth.outMinor);
  if (outChange != null && outChange.abs() >= 15 && month.outMinor > 0) {
    final up = outChange > 0;
    final text = up ? l10n.bizInsightOutUp(f.percent(outChange)) : l10n.bizInsightOutDown(f.percent(-outChange));
    add('outChange', text, text, up ? BizTone.warn : BizTone.good, todayIso, 60 + outChange.abs().clamp(0, 100) ~/ 5);
  }
  final inChange = _change(month.inMinor, lastMonth.inMinor);
  if (inChange != null && inChange.abs() >= 15 && month.inMinor > 0) {
    final up = inChange > 0;
    final text = up ? l10n.bizInsightInUp(f.percent(inChange)) : l10n.bizInsightInDown(f.percent(-inChange));
    add('inChange', text, text, up ? BizTone.good : BizTone.warn, todayIso, 58 + inChange.abs().clamp(0, 100) ~/ 5);
  }

  // Cash in ahead of cash out, day after day (today counts once it has entries)
  var streak = 0;
  var day = (input.daily[todayIso]?.inMinor ?? 0) > 0 || (input.daily[todayIso]?.outMinor ?? 0) > 0
      ? today
      : _addDays(today, -1);
  while (true) {
    final flow = input.daily[isoDate(day)];
    if (flow == null || flow.inMinor <= flow.outMinor) break;
    streak++;
    day = _addDays(day, -1);
  }
  if (streak >= 3) {
    final text = l10n.bizInsightStreak(f.digits('$streak'));
    add('streak', text, text, BizTone.good, todayIso, 55 + streak.clamp(0, 10));
  }

  // A business's best and worst book this month
  final active = input.books.where((b) => b.monthNetMinor != 0).toList()
    ..sort((a, b) => b.monthNetMinor.compareTo(a.monthNetMinor));
  if (active.length >= 2) {
    final losing = active.last;
    if (losing.monthNetMinor < 0) {
      add(
        'losingBook',
        l10n.bizInsightLosingBook(losing.name, f.signed(losing.monthNetMinor)),
        l10n.bizInsightLosingBookMasked(losing.name),
        BizTone.warn,
        monthEnd,
        57,
      );
    }
    final lead = active.first;
    if (lead.monthNetMinor > 0) {
      add(
        'leadBook',
        l10n.bizInsightLeadBook(lead.name, f.signed(lead.monthNetMinor)),
        l10n.bizInsightLeadBookMasked(lead.name),
        BizTone.good,
        monthEnd,
        52,
      );
    }
  }

  // Where the month's money goes
  final categories = input.monthCategories.entries.where((e) => e.value > 0).toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  if (month.outMinor > 0 && categories.length >= 2) {
    final top = categories.first;
    final share = (top.value * 100 / month.outMinor).round();
    if (share >= 25) {
      final name = top.key.isEmpty ? l10n.uncategorised : top.key;
      final text = l10n.bizInsightTopCategory(name, f.percent(share));
      add('topCategory', text, text, BizTone.info, monthEnd, 50);
    }
  }

  // Where the month is heading, once a few days have set the pace
  final days = daysInMonth(today);
  if (today.day >= 5 && today.day < days && (month.inMinor > 0 || month.outMinor > 0)) {
    final projected = (month.netMinor * days / today.day).round();
    final name = f.monthName(today);
    add(
      'projection',
      l10n.bizInsightProjection(name, f.signed(projected)),
      projected >= 0 ? l10n.bizInsightProjectionAhead(name) : l10n.bizInsightProjectionBehind(name),
      projected >= 0 ? BizTone.good : BizTone.warn,
      todayIso,
      45,
    );
  }

  final biggest = input.weekBiggest;
  if (biggest != null && biggest.amountMinor > 0) {
    final label = biggest.label ?? l10n.cashOut;
    add(
      'biggestOut',
      l10n.bizInsightBiggestOut(label, f.money(biggest.amountMinor)),
      l10n.bizInsightBiggestOutMasked(label),
      BizTone.info,
      todayIso,
      40,
    );
  }

  if (found.isEmpty) {
    final text = switch (input) {
      _ when input.entryCount == 0 => l10n.bizInsightEmptyBook,
      _ when month.inMinor == 0 && month.outMinor == 0 => l10n.bizInsightQuietMonth,
      _ => l10n.bizInsightSteady,
    };
    add('fallback', text, text, BizTone.info, always, 0);
  }
  found.sort((a, b) => b.score.compareTo(a.score));
  return found.take(limit).toList();
}

/// The periods, chart and labels both kinds of snapshot share.
class _Common {
  _Common(Map<String, DayFlow> daily, DateTime today, _Format f)
    : todayPeriod = _period(
        f.l10n.today,
        f.l10n.bizWidgetVsYesterday,
        daily[isoDate(today)] ?? DayFlow.none,
        daily[isoDate(_addDays(today, -1))] ?? DayFlow.none,
        f,
      ),
      week = _weekEnding(daily, today, f),
      month = _monthPeriod(daily, today, f),
      weekRoll = [for (var k = 1; k <= 6; k++) _weekEnding(daily, _addDays(today, k), f)],
      dailyIn = [for (var i = 13; i >= 0; i--) daily[isoDate(_addDays(today, -i))]?.inMinor ?? 0],
      dailyOut = [for (var i = 13; i >= 0; i--) daily[isoDate(_addDays(today, -i))]?.outMinor ?? 0],
      dayLabels = [for (var i = -13; i <= 6; i++) f.digits('${_addDays(today, i).day}')];

  final BizPeriod todayPeriod;
  final BizPeriod week;
  final BizPeriod month;
  final List<BizPeriod> weekRoll;
  final List<int> dailyIn;
  final List<int> dailyOut;
  final List<String> dayLabels;

  static BizPeriod _monthPeriod(Map<String, DayFlow> daily, DateTime today, _Format f) {
    final (month, last) = _monthAndLast(daily, today);
    return _period(f.monthName(today), f.l10n.bizWidgetVsLastMonth, month, last, f);
  }
}

/// One cashbook's widget.
BizSnapshot buildBookSnapshot({
  required Workspace workspace,
  required BookFacts facts,
  required AppLocalizations l10n,
  required DateTime today,
}) {
  final f = _Format(l10n, facts.book.currency);
  final common = _Common(facts.daily, today, f);
  final link = BizLinks.book(facts.book.id, workspace.id);
  return BizSnapshot(
    kind: 'book',
    id: facts.book.id,
    workspaceId: workspace.id,
    name: facts.book.bookName,
    subtitle: workspace.name,
    date: isoDate(today),
    balance: f.money(facts.balanceMinor),
    balanceNegative: facts.balanceMinor < 0,
    mask: f.mask,
    zero: f.money(0),
    canAdd: facts.canAdd,
    today: common.todayPeriod,
    week: common.week,
    month: common.month,
    weekRoll: common.weekRoll,
    dailyIn: common.dailyIn,
    dailyOut: common.dailyOut,
    dayLabels: common.dayLabels,
    insights: _insights(
      _InsightInput(
        balanceMinor: facts.balanceMinor,
        entryCount: facts.entryCount,
        daily: facts.daily,
        lastEntry: facts.lastEntry,
        monthCategories: facts.monthCategories,
        weekBiggest: facts.weekBiggest,
      ),
      today,
      f,
    ),
    rows: [
      for (final entry in facts.recent)
        BizRow(
          title: entry.title ?? (entry.cashIn ? l10n.cashIn : l10n.cashOut),
          detail: _parseDay(entry.entryDate) == null ? null : f.day(_parseDay(entry.entryDate)!),
          amount: entry.cashIn ? '+${f.money(entry.amountMinor)}' : f.money(-entry.amountMinor),
          negative: !entry.cashIn,
          link: link,
        ),
    ],
  );
}

/// A whole business's widget: its books in the workspace's main currency added
/// up, as the business screen totals them; books in other currencies are counted in the subtitle.
BizSnapshot buildBusinessSnapshot({
  required Workspace workspace,
  required List<BookFacts> books,
  required AppLocalizations l10n,
  required DateTime today,
}) {
  final currency = workspace.defaultCurrency;
  final f = _Format(l10n, currency);
  final main = books.where((b) => b.book.currency == currency).toList();
  final others = books.where((b) => b.book.currency != currency).toList();

  final daily = <String, DayFlow>{};
  final categories = <String, int>{};
  BigOut? biggest;
  String? lastEntry;
  for (final book in main) {
    book.daily.forEach((day, flow) => daily[day] = (daily[day] ?? DayFlow.none) + flow);
    book.monthCategories.forEach((name, out) => categories[name] = (categories[name] ?? 0) + out);
    final big = book.weekBiggest;
    if (big != null && (biggest == null || big.amountMinor > biggest.amountMinor)) biggest = big;
    final last = book.lastEntry;
    if (last != null && (lastEntry == null || last.compareTo(lastEntry) > 0)) lastEntry = last;
  }
  final balance = main.fold<int>(0, (sum, b) => sum + b.balanceMinor);
  final common = _Common(daily, today, f);

  final lines = [
    for (final book in main)
      _BookLine(
        book.book.bookName,
        book.balanceMinor,
        _sum(book.daily, DateTime(today.year, today.month), today).netMinor,
      ),
  ];

  // Other currencies: "+1 in USD", one note per currency
  final otherCounts = <String, int>{};
  for (final book in others) {
    otherCounts[book.book.currency] = (otherCounts[book.book.currency] ?? 0) + 1;
  }
  // Plurals come out with Western digits; Bangla shows its own
  final subtitle = f.digits(
    [
      l10n.bizWidgetBooks(books.length),
      for (final entry in otherCounts.entries) l10n.bizWidgetOtherCurrency(entry.value, entry.key),
    ].join(' · '),
  );

  final ranked = [...books]..sort((a, b) => b.balanceMinor.compareTo(a.balanceMinor));
  return BizSnapshot(
    kind: 'business',
    id: workspace.id,
    workspaceId: workspace.id,
    name: workspace.name,
    subtitle: subtitle,
    date: isoDate(today),
    balance: f.money(balance),
    balanceNegative: balance < 0,
    mask: f.mask,
    zero: f.money(0),
    canAdd: books.any((b) => b.canAdd),
    today: common.todayPeriod,
    week: common.week,
    month: common.month,
    weekRoll: common.weekRoll,
    dailyIn: common.dailyIn,
    dailyOut: common.dailyOut,
    dayLabels: common.dayLabels,
    insights: _insights(
      _InsightInput(
        balanceMinor: balance,
        entryCount: main.fold<int>(0, (sum, b) => sum + b.entryCount),
        daily: daily,
        lastEntry: lastEntry,
        monthCategories: categories,
        weekBiggest: biggest,
        books: lines,
      ),
      today,
      f,
    ),
    rows: [
      for (final book in ranked.take(5))
        BizRow(
          title: book.book.bookName,
          detail: book.book.currency == currency
              ? f.digits(l10n.entriesCount(book.entryCount))
              : '${f.digits(l10n.entriesCount(book.entryCount))} · ${book.book.currency}',
          amount: wholeAmount(book.balanceMinor, book.book.currency, l10n.localeName),
          negative: book.balanceMinor < 0,
          link: BizLinks.book(book.book.id, workspace.id),
        ),
    ],
  );
}

/// What the picker offers: every business, and each one's books.
BizCatalog buildBizCatalog({
  required List<(Workspace, List<BookFacts>)> businesses,
  required Entitlements? plan,
  required AppLocalizations l10n,
  required DateTime today,
}) {
  // Plurals come out with Western digits; Bangla shows its own
  final digits = _Format(l10n, '').digits;
  return BizCatalog(
    signedIn: true,
    unlocked: !bizWidgetLocked(plan, now: today),
    strings: bizWidgetStrings(l10n),
    businesses: [
      for (final (workspace, books) in businesses)
        BizCatalogBusiness(
          id: workspace.id,
          name: workspace.isDemo ? '${workspace.name} · ${l10n.demo}' : workspace.name,
          detail: digits(l10n.bizWidgetBooks(books.length)),
          books: [
            for (final book in books)
              BizCatalogBook(
                id: book.book.id,
                name: book.book.bookName,
                detail:
                    '${wholeAmount(book.balanceMinor, book.book.currency, l10n.localeName)} · '
                    '${digits(l10n.entriesCount(book.entryCount))}',
              ),
          ],
        ),
    ],
  );
}

/// Signed out: the widgets invite the user in, and nothing of theirs stays on the home screen.
BizCatalog signedOutBizCatalog(AppLocalizations l10n) =>
    BizCatalog(signedIn: false, unlocked: false, strings: bizWidgetStrings(l10n));
