import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../personal/ledger_repository.dart';

/// Which entries the insights add up: one book, or every book of a business
/// kept in [currency]. Books in another currency are left out, as on the
/// business's balance, since their amounts cannot be added up.
class InsightsScope {
  const InsightsScope.book(this.id) : currency = null;
  const InsightsScope.business(this.id, String this.currency);

  /// The book's id, or the business's.
  final String id;

  /// Null for a book: its entries are all in its own currency.
  final String? currency;

  bool get isBook => currency == null;

  /// Restricts `entries e` to the scope.
  String get where => isBook
      ? 'e.cashbook_id = ?'
      : 'e.cashbook_id IN (SELECT id FROM cashbooks WHERE workspace_id = ? AND currency = ? AND deleted_at IS NULL)';

  List<Variable<Object>> get variables => [Variable<String>(id), if (!isBook) Variable<String>(currency!)];

  @override
  bool operator ==(Object other) => other is InsightsScope && other.id == id && other.currency == currency;

  @override
  int get hashCode => Object.hash(id, currency);
}

/// The days the insights cover: a month, or a range chosen in its place (a
/// plan feature, [F.insightsCustomRange]). Each is compared with the period
/// just before: the month before, or as many days again before a range.
class InsightsPeriod {
  const InsightsPeriod.month(this.month) : range = null;
  const InsightsPeriod.range(InsightsRange this.range, this.month);

  /// The month shown, as its first day; kept under a range for the way back.
  final DateTime month;
  final InsightsRange? range;

  bool get isMonth => range == null;

  String get from => range?.from ?? monthRange(month).$1;
  String get to => range?.to ?? monthRange(month).$2;

  String get previousFrom => range?.previousFrom ?? monthRange(DateTime(month.year, month.month - 1)).$1;

  DateTime get start => DateTime.parse(from);
  DateTime get end => DateTime.parse(to);

  int get days => InsightsRange(from, to).days;

  /// Days of the period gone by on [today]: all of a past one, none of one to come.
  int daysElapsed(DateTime today) {
    final day = DateTime(today.year, today.month, today.day);
    if (day.isBefore(start)) return 0;
    if (!day.isBefore(end)) return days;
    return InsightsRange(from, isoDate(day)).days;
  }

  @override
  bool operator ==(Object other) => other is InsightsPeriod && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// Cash in and out on one day, or over any stretch.
class FlowTotals {
  const FlowTotals(this.inMinor, this.outMinor, this.count);

  static const zero = FlowTotals(0, 0, 0);

  final int inMinor;
  final int outMinor;
  final int count;

  int get netMinor => inMinor - outMinor;

  FlowTotals operator +(FlowTotals other) =>
      FlowTotals(inMinor + other.inMinor, outMinor + other.outMinor, count + other.count);
}

/// Percentage change from [before] to [now]; null when there was nothing before.
int? changePercent(int now, int before) => before == 0 ? null : ((now - before) * 100 / before.abs()).round();

/// How the money moved over a period, day by day, and what it was before.
class PeriodFlow {
  PeriodFlow({
    required this.period,
    required this.openingMinor,
    required this.previous,
    required this.byDay,
    required this.today,
  });

  final InsightsPeriod period;

  /// The balance on the morning of the first day.
  final int openingMinor;

  /// The period just before, to compare with.
  final FlowTotals previous;

  /// Days that had entries, by ISO date.
  final Map<String, FlowTotals> byDay;

  /// When the figures were read; decides how much of the period has gone by.
  final DateTime today;

  late final FlowTotals total = byDay.values.fold(FlowTotals.zero, (sum, day) => sum + day);

  int get closingMinor => openingMinor + total.netMinor;

  int? get inChange => changePercent(total.inMinor, previous.inMinor);
  int? get outChange => changePercent(total.outMinor, previous.outMinor);
  int? get netChange => changePercent(total.netMinor, previous.netMinor);

  bool get isEmpty => total.count == 0;

  /// Every day of the period in order, those without entries included.
  List<DateTime> get dates => [
        for (var i = 0; i < period.days; i++) DateTime(period.start.year, period.start.month, period.start.day + i),
      ];

  FlowTotals on(DateTime day) => byDay[isoDate(day)] ?? FlowTotals.zero;

  /// The balance at the end of each day, through the last day gone by.
  List<int> get runningBalance {
    final elapsed = math.max(period.daysElapsed(today), 1);
    var balance = openingMinor;
    return [
      for (final day in dates.take(elapsed)) balance += on(day).netMinor,
    ];
  }

  int get activeDays => byDay.values.where((d) => d.count > 0).length;

  int get _elapsed => math.max(period.daysElapsed(today), 1);

  int get averageDailyOutMinor => total.outMinor ~/ _elapsed;

  int get averageEntryMinor => total.count == 0 ? 0 : (total.inMinor + total.outMinor) ~/ total.count;

  /// Cash out as a share of cash in; null with nothing in.
  double? get outRatio => total.inMinor == 0 ? null : total.outMinor / total.inMinor;

  /// How many days the closing balance lasts at the period's rate of loss.
  /// Null while more comes in than goes out, or with nothing left to spend.
  int? get runwayDays {
    final lossPerDay = -total.netMinor / _elapsed;
    if (lossPerDay <= 0 || closingMinor <= 0) return null;
    return (closingMinor / lossPerDay).floor();
  }

  /// The weekday (1 Monday – 7 Sunday) with the most cash out; null with none.
  int? get busiestWeekday {
    final byWeekday = <int, int>{};
    byDay.forEach((day, flow) {
      final weekday = DateTime.parse(day).weekday;
      byWeekday[weekday] = (byWeekday[weekday] ?? 0) + flow.outMinor;
    });
    final busiest = byWeekday.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return busiest.firstOrNull?.key;
  }

  /// Days in a row with an entry, up to the last day gone by (or the one before,
  /// so a streak is not lost before today's first entry).
  int get streakDays {
    final elapsed = dates.take(_elapsed).toList();
    var streak = 0;
    for (final (index, day) in elapsed.reversed.indexed) {
      if (on(day).count > 0) {
        streak++;
      } else if (index > 0 || streak > 0) {
        break;
      }
    }
    return streak;
  }
}

/// A category's, payment method's or custom field value's share of a period.
class SplitRow {
  const SplitRow({
    required this.key,
    required this.name,
    this.color,
    required this.inMinor,
    required this.outMinor,
    this.inCount = 0,
    this.outCount = 0,
    this.largestOutMinor = 0,
    this.previousOutMinor = 0,
    this.previousInMinor = 0,
  });

  /// A category or payment method id, or the value itself; null for none.
  final String? key;
  final String? name;
  final String? color;
  final int inMinor;
  final int outMinor;
  final int inCount;
  final int outCount;
  final int largestOutMinor;
  final int previousOutMinor;
  final int previousInMinor;

  CategorySpend get asSpend => CategorySpend(key, name, color, outMinor,
      count: outCount, largestMinor: largestOutMinor, previousMinor: previousOutMinor);
}

/// Cash out by category in the shape the personal breakdown draws.
MonthSummary spendSummary(List<SplitRow> rows) {
  final spent = [for (final row in rows) if (row.outCount > 0) row.asSpend]
    ..sort((a, b) => b.amountMinor.compareTo(a.amountMinor));
  return MonthSummary(
    rows.fold(0, (sum, r) => sum + r.inMinor),
    rows.fold(0, (sum, r) => sum + r.outMinor),
    spent,
  );
}

/// One of a period's biggest entries.
class TopEntry {
  const TopEntry(this.entry, {this.categoryName, this.categoryColor, this.paymentMethodName, this.bookName});

  final Entry entry;
  final String? categoryName;
  final String? categoryColor;
  final String? paymentMethodName;
  final String? bookName;
}

/// What one person recorded over a period.
class MemberFlow {
  const MemberFlow(this.userId, this.flow, {this.lastDay});

  /// Null for entries whose author is not known.
  final String? userId;
  final FlowTotals flow;
  final String? lastDay;
}

/// How many of a period's cash-out entries keep a bill.
class BillCoverage {
  const BillCoverage(this.withBill, this.total, {this.missingMinor = 0});

  final int withBill;
  final int total;

  /// Cash out with nothing to show for it.
  final int missingMinor;

  int get missing => total - withBill;
  double get share => total == 0 ? 1 : withBill / total;
}

/// One book of a business over a period, with its last months for a sparkline.
class BookStanding {
  const BookStanding(this.book, this.flow, this.months);

  final Cashbook book;
  final FlowTotals flow;

  /// Net of each of the last months, oldest first.
  final List<int> months;
}

/// Adds up a book's or a business's entries for the insights screens. All of
/// it is worked out on the device, from what sync has brought down.
class InsightsRepository {
  InsightsRepository(this.db);

  final AppDatabase db;

  static const _live = 'e.deleted_at IS NULL';
  static const _in = "CASE WHEN e.entry_type = 'cash_in' THEN e.amount_minor ELSE 0 END";
  static const _out = "CASE WHEN e.entry_type = 'cash_out' THEN e.amount_minor ELSE 0 END";

  /// Day by day over the period, the period before in one, and what came before both as the opening balance.
  Stream<PeriodFlow> watchFlow(InsightsScope scope, InsightsPeriod period, {DateTime? today}) => db
      .customSelect(
        "SELECT CASE WHEN e.entry_date < ? THEN 'opening' WHEN e.entry_date < ? THEN 'previous' ELSE e.entry_date END AS day, "
        'SUM($_in) AS cash_in, SUM($_out) AS cash_out, COUNT(*) AS n '
        'FROM entries e WHERE ${scope.where} AND $_live AND e.entry_date <= ? GROUP BY day',
        variables: [
          Variable<String>(period.previousFrom),
          Variable<String>(period.from),
          ...scope.variables,
          Variable<String>(period.to),
        ],
        readsFrom: {db.entries, db.cashbooks},
      )
      .watch()
      .map((rows) {
        var opening = 0;
        var previous = FlowTotals.zero;
        final byDay = <String, FlowTotals>{};
        for (final row in rows) {
          final flow = FlowTotals(row.read<int>('cash_in'), row.read<int>('cash_out'), row.read<int>('n'));
          switch (row.read<String>('day')) {
            case 'opening':
              opening += flow.netMinor;
            case 'previous':
              opening += flow.netMinor;
              previous = flow;
            case final day:
              byDay[day] = flow;
          }
        }
        return PeriodFlow(
          period: period,
          openingMinor: opening,
          previous: previous,
          byDay: byDay,
          today: today ?? DateTime.now(),
        );
      });

  /// Cash in and out for the [count] months ending with [month], oldest first.
  Stream<List<MonthTotals>> watchMonthly(InsightsScope scope, DateTime month, {int count = 6}) {
    final start = DateTime(month.year, month.month - count + 1, 1);
    return db
        .customSelect(
          'SELECT substr(e.entry_date, 1, 7) AS ym, SUM($_in) AS cash_in, SUM($_out) AS cash_out '
          'FROM entries e WHERE ${scope.where} AND $_live AND e.entry_date BETWEEN ? AND ? GROUP BY ym',
          variables: [...scope.variables, Variable<String>(isoDate(start)), Variable<String>(monthRange(month).$2)],
          readsFrom: {db.entries, db.cashbooks},
        )
        .watch()
        .map((rows) {
          final byMonth = {for (final row in rows) row.read<String>('ym'): row};
          return [
            for (var i = 0; i < count; i++)
              () {
                final m = DateTime(start.year, start.month + i, 1);
                final row = byMonth[monthKey(m).substring(0, 7)];
                return MonthTotals(m, row?.read<int>('cash_in') ?? 0, row?.read<int>('cash_out') ?? 0);
              }(),
          ];
        });
  }

  /// The period by category or by payment method, largest cash out first.
  /// A business's books each have their own lists: the same name is one row.
  Stream<List<SplitRow>> watchSplit(InsightsScope scope, InsightsPeriod period, {required bool byCategory}) {
    final join = byCategory
        ? 'LEFT JOIN entry_categories x ON x.id = e.category_id'
        : 'LEFT JOIN payment_methods x ON x.id = e.payment_method_id';
    final name = byCategory ? 'x.category_name' : 'x.payment_method_name';
    final group = scope.isBook ? 'x.id' : 'name';
    return _split(
      select: '${scope.isBook ? 'x.id' : 'MIN(x.id)'} AS k, $name AS name, '
          '${byCategory ? 'MIN(x.color)' : 'NULL'} AS color',
      from: 'entries e $join',
      scope: scope,
      period: period,
      group: group,
      readsFrom: {db.entries, db.cashbooks, db.entryCategories, db.paymentMethods},
    );
  }

  /// The period by the value of one of a book's own fields. Number fields are
  /// grouped too; their sums are what [watchFieldSum] gives.
  Stream<List<SplitRow>> watchFieldSplit(String bookId, String fieldId, InsightsPeriod period) {
    final value = "NULLIF(TRIM(CAST(json_extract(e.custom_values, '\$.\"' || ? || '\"') AS TEXT)), '')";
    return _split(
      select: '$value AS k, $value AS name, NULL AS color',
      selectVariables: [Variable<String>(fieldId), Variable<String>(fieldId)],
      from: 'entries e',
      scope: InsightsScope.book(bookId),
      period: period,
      group: 'k',
      readsFrom: {db.entries},
    );
  }

  Stream<List<SplitRow>> _split({
    required String select,
    List<Variable<Object>> selectVariables = const [],
    required String from,
    required InsightsScope scope,
    required InsightsPeriod period,
    required String group,
    required Set<ResultSetImplementation<dynamic, dynamic>> readsFrom,
  }) {
    const now = 'e.entry_date >= ?';
    return db
        .customSelect(
          'SELECT $select, '
          "SUM(CASE WHEN $now THEN $_in ELSE 0 END) AS cash_in, "
          "SUM(CASE WHEN $now THEN $_out ELSE 0 END) AS cash_out, "
          "SUM(CASE WHEN $now AND e.entry_type = 'cash_in' THEN 1 ELSE 0 END) AS in_n, "
          "SUM(CASE WHEN $now AND e.entry_type = 'cash_out' THEN 1 ELSE 0 END) AS out_n, "
          "MAX(CASE WHEN $now THEN $_out ELSE 0 END) AS largest, "
          "SUM(CASE WHEN e.entry_date < ? THEN $_out ELSE 0 END) AS previous_out, "
          "SUM(CASE WHEN e.entry_date < ? THEN $_in ELSE 0 END) AS previous_in "
          'FROM $from WHERE ${scope.where} AND $_live AND e.entry_date BETWEEN ? AND ? GROUP BY $group',
          variables: [
            ...selectVariables,
            for (var i = 0; i < 5; i++) Variable<String>(period.from),
            for (var i = 0; i < 2; i++) Variable<String>(period.from),
            ...scope.variables,
            Variable<String>(period.previousFrom),
            Variable<String>(period.to),
          ],
          readsFrom: readsFrom,
        )
        .watch()
        .map((rows) => [
              for (final row in rows)
                if (row.read<int>('in_n') + row.read<int>('out_n') > 0)
                  SplitRow(
                    key: row.readNullable<String>('k'),
                    name: row.readNullable<String>('name'),
                    color: row.readNullable<String>('color'),
                    inMinor: row.read<int>('cash_in'),
                    outMinor: row.read<int>('cash_out'),
                    inCount: row.read<int>('in_n'),
                    outCount: row.read<int>('out_n'),
                    largestOutMinor: row.read<int>('largest'),
                    previousOutMinor: row.read<int>('previous_out'),
                    previousInMinor: row.read<int>('previous_in'),
                  ),
            ]..sort((a, b) => (b.outMinor + b.inMinor).compareTo(a.outMinor + a.inMinor)));
  }

  /// A number field's values added up over the period, for cash in and cash
  /// out, and how many entries hold one. In the field's own units, not money.
  Stream<({double inSum, double outSum, int count})> watchFieldSum(String bookId, String fieldId, InsightsPeriod period) {
    final value = "CAST(json_extract(e.custom_values, '\$.\"' || ? || '\"') AS REAL)";
    return db
        .customSelect(
          "SELECT COALESCE(SUM(CASE WHEN e.entry_type = 'cash_in' THEN $value END), 0.0) AS cash_in, "
          "COALESCE(SUM(CASE WHEN e.entry_type = 'cash_out' THEN $value END), 0.0) AS cash_out, "
          'COUNT($value) AS n FROM entries e WHERE e.cashbook_id = ? AND $_live AND e.entry_date BETWEEN ? AND ?',
          variables: [
            for (var i = 0; i < 3; i++) Variable<String>(fieldId),
            Variable<String>(bookId),
            Variable<String>(period.from),
            Variable<String>(period.to),
          ],
          readsFrom: {db.entries},
        )
        .watchSingle()
        .map((row) => (
              inSum: (row.data['cash_in'] as num).toDouble(),
              outSum: (row.data['cash_out'] as num).toDouble(),
              count: row.read<int>('n'),
            ));
  }

  /// The period's biggest entries of [entryType], biggest first.
  Stream<List<TopEntry>> watchTopEntries(InsightsScope scope, InsightsPeriod period, String entryType,
          {int limit = 5}) =>
      db
          .customSelect(
            'SELECT e.*, c.category_name AS c_name, c.color AS c_color, p.payment_method_name AS p_name, '
            'b.book_name AS b_name FROM entries e '
            'LEFT JOIN entry_categories c ON c.id = e.category_id '
            'LEFT JOIN payment_methods p ON p.id = e.payment_method_id '
            'LEFT JOIN cashbooks b ON b.id = e.cashbook_id '
            'WHERE ${scope.where} AND $_live AND e.entry_type = ? AND e.entry_date BETWEEN ? AND ? '
            'ORDER BY e.amount_minor DESC, e.entry_date DESC LIMIT ?',
            variables: [
              ...scope.variables,
              Variable<String>(entryType),
              Variable<String>(period.from),
              Variable<String>(period.to),
              Variable<int>(limit),
            ],
            readsFrom: {db.entries, db.entryCategories, db.paymentMethods, db.cashbooks},
          )
          .watch()
          .map((rows) => [
                for (final row in rows)
                  TopEntry(
                    db.entries.map(row.data),
                    categoryName: row.readNullable<String>('c_name'),
                    categoryColor: row.readNullable<String>('c_color'),
                    paymentMethodName: row.readNullable<String>('p_name'),
                    bookName: row.readNullable<String>('b_name'),
                  ),
              ]);

  /// Who recorded what over the period, most entries first.
  Stream<List<MemberFlow>> watchByMember(InsightsScope scope, InsightsPeriod period) => db
      .customSelect(
        'SELECT e.created_by_id AS who, SUM($_in) AS cash_in, SUM($_out) AS cash_out, COUNT(*) AS n, '
        'MAX(e.entry_date) AS last_day FROM entries e '
        'WHERE ${scope.where} AND $_live AND e.entry_date BETWEEN ? AND ? GROUP BY who ORDER BY n DESC',
        variables: [...scope.variables, Variable<String>(period.from), Variable<String>(period.to)],
        readsFrom: {db.entries, db.cashbooks},
      )
      .watch()
      .map((rows) => [
            for (final row in rows)
              MemberFlow(
                row.readNullable<String>('who'),
                FlowTotals(row.read<int>('cash_in'), row.read<int>('cash_out'), row.read<int>('n')),
                lastDay: row.readNullable<String>('last_day'),
              ),
          ]);

  /// How many of the period's cash-out entries keep a bill, those still uploading included.
  Stream<BillCoverage> watchBillCoverage(InsightsScope scope, InsightsPeriod period) {
    const kept = '(EXISTS (SELECT 1 FROM entry_bills b WHERE b.entry_id = e.id AND b.deleted_at IS NULL '
        "AND b.id NOT IN (SELECT id FROM bill_queue WHERE op = 'remove')) "
        "OR EXISTS (SELECT 1 FROM bill_queue q WHERE q.entry_id = e.id AND q.op = 'upload'))";
    return db
        .customSelect(
          'SELECT COUNT(*) AS n, COALESCE(SUM(CASE WHEN $kept THEN 1 ELSE 0 END), 0) AS kept, '
          'COALESCE(SUM(CASE WHEN $kept THEN 0 ELSE e.amount_minor END), 0) AS missing FROM entries e '
          "WHERE ${scope.where} AND $_live AND e.entry_type = 'cash_out' AND e.entry_date BETWEEN ? AND ?",
          variables: [...scope.variables, Variable<String>(period.from), Variable<String>(period.to)],
          readsFrom: {db.entries, db.cashbooks, db.entryBills, db.billQueue},
        )
        .watchSingle()
        .map((row) =>
            BillCoverage(row.read<int>('kept'), row.read<int>('n'), missingMinor: row.read<int>('missing')));
  }

  /// Each book of a business in [currency] over the period, with the net of
  /// its last [months] months ending with the period's, best net first.
  Stream<List<BookStanding>> watchBooks(String workspaceId, String currency, InsightsPeriod period, {int months = 6}) {
    final last = DateTime(period.end.year, period.end.month);
    final first = DateTime(last.year, last.month - months + 1);
    return db
        .customSelect(
          'SELECT b.*, substr(e.entry_date, 1, 7) AS ym, '
          'COALESCE(SUM(CASE WHEN e.entry_date BETWEEN ? AND ? THEN $_in END), 0) AS cash_in, '
          'COALESCE(SUM(CASE WHEN e.entry_date BETWEEN ? AND ? THEN $_out END), 0) AS cash_out, '
          'COALESCE(SUM(CASE WHEN e.entry_date BETWEEN ? AND ? THEN 1 END), 0) AS n, '
          'COALESCE(SUM(CASE WHEN e.entry_date BETWEEN ? AND ? THEN $_in - $_out END), 0) AS month_net '
          'FROM cashbooks b LEFT JOIN entries e ON e.cashbook_id = b.id AND $_live '
          'AND e.entry_date BETWEEN ? AND ? '
          'WHERE b.workspace_id = ? AND b.currency = ? AND b.deleted_at IS NULL GROUP BY b.id, ym',
          variables: [
            for (var i = 0; i < 3; i++) ...[Variable<String>(period.from), Variable<String>(period.to)],
            Variable<String>(isoDate(first)),
            Variable<String>(monthRange(last).$2),
            Variable<String>(period.from.compareTo(isoDate(first)) < 0 ? period.from : isoDate(first)),
            Variable<String>(monthRange(last).$2),
            Variable<String>(workspaceId),
            Variable<String>(currency),
          ],
          readsFrom: {db.entries, db.cashbooks},
        )
        .watch()
        .map((rows) {
          final books = <String, Cashbook>{};
          final flows = <String, FlowTotals>{};
          final nets = <String, Map<String, int>>{};
          for (final row in rows) {
            final book = db.cashbooks.map(row.data);
            books[book.id] = book;
            flows[book.id] = (flows[book.id] ?? FlowTotals.zero) +
                FlowTotals(row.read<int>('cash_in'), row.read<int>('cash_out'), row.read<int>('n'));
            final ym = row.readNullable<String>('ym');
            if (ym != null) (nets[book.id] ??= {})[ym] = row.read<int>('month_net');
          }
          return [
            for (final id in books.keys)
              BookStanding(books[id]!, flows[id]!, [
                for (var i = 0; i < months; i++)
                  nets[id]?[monthKey(DateTime(first.year, first.month + i)).substring(0, 7)] ?? 0,
              ]),
          ]..sort((a, b) => b.flow.netMinor.compareTo(a.flow.netMinor));
        });
  }

  /// Books of the business kept in another currency than [currency]: not in its figures.
  Stream<int> watchOtherCurrencyBooks(String workspaceId, String currency) => db
      .customSelect(
        'SELECT COUNT(*) AS n FROM cashbooks WHERE workspace_id = ? AND currency != ? AND deleted_at IS NULL',
        variables: [Variable<String>(workspaceId), Variable<String>(currency)],
        readsFrom: {db.cashbooks},
      )
      .watchSingle()
      .map((row) => row.read<int>('n'));
}

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) => InsightsRepository(ref.watch(databaseProvider)));
