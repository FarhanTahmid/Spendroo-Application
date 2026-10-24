import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import 'allocations.dart';
import 'ledger_repository.dart';

/// The spans of time the account screen offers; [custom] is any two dates.
enum AccountPeriod { thisMonth, lastMonth, last3Months, thisYear, allTime, custom }

/// What the account screen is narrowed to. The dates set the period; kind,
/// categories, receipts and search pick rows inside it.
class AccountFilter {
  const AccountFilter({
    this.period = AccountPeriod.allTime,
    this.from,
    this.to,
    this.kind,
    this.categoryIds = const {},
    this.uncategorised = false,
    this.hasReceipt,
    this.query = '',
  });

  final AccountPeriod period;

  /// ISO dates, both inclusive; null leaves that side open.
  final String? from;
  final String? to;

  /// 'income', 'expense' or 'transfer'; null for all.
  final String? kind;
  final Set<String> categoryIds;

  /// Income and expenses filed under no category, alongside [categoryIds].
  final bool uncategorised;

  /// True: only those with a receipt; false: only those without; null: either.
  final bool? hasReceipt;
  final String query;

  /// The dates of a preset, counted from [now].
  AccountFilter withPeriod(AccountPeriod period, {DateTime? now, String? from, String? to}) {
    final today = now ?? DateTime.now();
    final (String? first, String? last) = switch (period) {
      AccountPeriod.thisMonth => monthRange(today),
      AccountPeriod.lastMonth => monthRange(DateTime(today.year, today.month - 1)),
      AccountPeriod.last3Months => (isoDate(DateTime(today.year, today.month - 2)), monthRange(today).$2),
      AccountPeriod.thisYear => (isoDate(DateTime(today.year)), isoDate(DateTime(today.year, 12, 31))),
      AccountPeriod.allTime => (null, null),
      AccountPeriod.custom => (from, to),
    };
    return AccountFilter(
      period: period,
      from: first,
      to: last,
      kind: kind,
      categoryIds: categoryIds,
      uncategorised: uncategorised,
      hasReceipt: hasReceipt,
      query: query,
    );
  }

  AccountFilter copyWith({
    String? Function()? kind,
    Set<String>? categoryIds,
    bool? uncategorised,
    bool? Function()? hasReceipt,
    String? query,
  }) =>
      AccountFilter(
        period: period,
        from: from,
        to: to,
        kind: kind == null ? this.kind : kind(),
        categoryIds: categoryIds ?? this.categoryIds,
        uncategorised: uncategorised ?? this.uncategorised,
        hasReceipt: hasReceipt == null ? this.hasReceipt : hasReceipt(),
        query: query ?? this.query,
      );

  bool get hasCategories => categoryIds.isNotEmpty || uncategorised;

  /// Rows are left out inside the period, so a running balance would skip amounts.
  bool get isNarrowed => kind != null || hasCategories || hasReceipt != null || query.trim().isNotEmpty;

  /// How many choices of the filter sheet are in force.
  int get sheetCount =>
      (kind == null ? 0 : 1) + categoryIds.length + (uncategorised ? 1 : 0) + (hasReceipt == null ? 0 : 1);

  @override
  bool operator ==(Object other) =>
      other is AccountFilter &&
      other.period == period &&
      other.from == from &&
      other.to == to &&
      other.kind == kind &&
      other.uncategorised == uncategorised &&
      other.hasReceipt == hasReceipt &&
      other.query == query &&
      other.categoryIds.length == categoryIds.length &&
      other.categoryIds.containsAll(categoryIds);

  @override
  int get hashCode =>
      Object.hash(period, from, to, kind, uncategorised, hasReceipt, query, Object.hashAllUnordered(categoryIds));
}

/// One row of the account screen.
class AccountFeedRow {
  AccountFeedRow(this.view, {this.otherAccountName, this.balanceAfterMinor});

  final TransactionView view;

  /// For a transfer: the account the money went to or came from.
  final String? otherAccountName;

  /// The account's balance once this transaction is counted; null while the
  /// filter leaves rows out.
  final int? balanceAfterMinor;

  Transaction get transaction => view.transaction;
}

/// Where a page ended: the sort key of its last row.
typedef FeedCursor = (String occurredOn, String createdAt, String id);

/// What moved on an account inside a filter. All amounts positive.
class AccountSummary {
  AccountSummary({
    required this.incomeMinor,
    required this.expenseMinor,
    required this.transferInMinor,
    required this.transferOutMinor,
    required this.count,
    required this.largestExpenseMinor,
    required this.openingMinor,
    required this.closingMinor,
    this.firstDay,
    this.lastDay,
  });

  final int incomeMinor;
  final int expenseMinor;
  final int transferInMinor;
  final int transferOutMinor;
  final int count;
  final int largestExpenseMinor;

  /// The balance before the period's first day and after its last, whatever
  /// kind, category or search is chosen.
  final int openingMinor;
  final int closingMinor;

  /// The oldest and newest matching day (ISO), when anything matches.
  final String? firstDay;
  final String? lastDay;

  int get cashInMinor => incomeMinor + transferInMinor;
  int get cashOutMinor => expenseMinor + transferOutMinor;
  int get netMinor => cashInMinor - cashOutMinor;
}

/// One step of the charts: a day, or a month once the span is long.
class BalancePoint {
  BalancePoint(this.date, this.inMinor, this.outMinor, this.balanceMinor);

  /// The day, or the first day of the month.
  final DateTime date;
  final int inMinor;
  final int outMinor;

  /// The account's balance at the end of the step.
  final int balanceMinor;
}

class AccountSeries {
  AccountSeries(this.points, {required this.monthly, required this.openingMinor, this.hiddenMonths = 0});

  final List<BalancePoint> points;
  final bool monthly;

  /// The balance before the first point.
  final int openingMinor;

  /// Months of history before the first point that the plan does not chart
  /// ([F.insightsTrendMonths]); 0 when nothing was left out.
  final int hiddenMonths;
}

/// Of a month-by-month series, the [maxMonths] months up to its latest point,
/// with the balance the first of them starts from. The server shortens its
/// series the same way (API ledger_personal/trends.py, trim_months).
AccountSeries trimSeries(AccountSeries series, int? maxMonths) {
  final points = series.points;
  if (!series.monthly || maxMonths == null || points.isEmpty) return series;
  final latest = points.last.date;
  final cutoff = DateTime(latest.year, latest.month - (maxMonths - 1));
  final dropped = points.indexWhere((point) => !point.date.isBefore(cutoff));
  if (dropped <= 0) return series;
  final earliest = points.first.date;
  return AccountSeries(
    points.sublist(dropped),
    monthly: true,
    openingMinor: points[dropped - 1].balanceMinor,
    hiddenMonths: (cutoff.year - earliest.year) * 12 + cutoff.month - earliest.month,
  );
}

/// A span longer than this is charted month by month.
const seriesDailyLimit = 92;

const feedPageSize = 40;

/// Reads one account for its screen. Pages come by keyset: each asks for the
/// rows after the last one shown, so a long history costs the same per page.
class AccountLedger {
  AccountLedger(this.db);

  final AppDatabase db;

  static const _categoryJoin = 'LEFT JOIN categories c ON c.id = t.category_id AND c.deleted_at IS NULL ';

  // The other leg of a transfer and the account it sits on
  static const _otherLegJoin =
      'LEFT JOIN transactions o ON o.transfer_group_id = t.transfer_group_id AND o.id != t.id AND o.deleted_at IS NULL '
      'LEFT JOIN accounts oa ON oa.id = o.account_id ';

  /// The period of [filter] as SQL over `t`.
  (String, List<Variable>) _period(AccountFilter filter) => (
        '${filter.from == null ? '' : ' AND t.occurred_on >= ?'}${filter.to == null ? '' : ' AND t.occurred_on <= ?'}',
        [
          if (filter.from != null) Variable<String>(filter.from!),
          if (filter.to != null) Variable<String>(filter.to!),
        ],
      );

  /// Kind, categories, receipts and search of [filter] as one SQL condition
  /// over `t`, `c` and `oa`; '1' when nothing is chosen.
  (String, List<Variable>) _narrow(AccountFilter filter, String currency) {
    final parts = <String>[];
    final variables = <Variable>[];
    if (filter.kind != null) {
      parts.add('t.kind = ?');
      variables.add(Variable<String>(filter.kind!));
    }
    if (filter.hasCategories) {
      // A split is kept when any of its parts is; _amount() says how much of it counts
      parts.add(filedUnder(filter.categoryIds, uncategorised: filter.uncategorised));
    }
    if (filter.hasReceipt != null) {
      // One still on its way counts: it was attached here, and the server will have it
      parts.add('$receiptCountSql ${filter.hasReceipt! ? '>' : '='} 0');
    }
    final query = Money.toAsciiDigits(filter.query.trim());
    if (query.isNotEmpty) {
      final like = '%${query.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}')}%';
      final either = <String>[
        "t.note LIKE ? ESCAPE '\\'",
        "c.name LIKE ? ESCAPE '\\'",
        "oa.name LIKE ? ESCAPE '\\'",
        "t.merchant LIKE ? ESCAPE '\\'",
        // A live tag of the row's, by its name
        "EXISTS (SELECT 1 FROM json_each(t.tag_ids) j JOIN tags g ON g.id = j.value "
            "WHERE g.deleted_at IS NULL AND g.name LIKE ? ESCAPE '\\')",
      ];
      variables.addAll([for (var i = 0; i < 5; i++) Variable<String>(like)]);
      // "1,250" or "1250.50": also the amount, by its whole units
      final number = RegExp(r'^(\d+)(\.\d*)?$').firstMatch(query.replaceAll(',', ''));
      if (number != null) {
        var unit = 1;
        for (var i = 0; i < Money.exponent(currency); i++) {
          unit *= 10;
        }
        either.add('CAST(ABS(t.amount_minor) / $unit AS TEXT) LIKE ?');
        variables.add(Variable<String>('%${number[1]}%'));
      }
      parts.add('(${either.join(' OR ')})');
    }
    return (parts.isEmpty ? '1' : parts.join(' AND '), variables);
  }

  /// What a row counts for under [filter], signed: the whole amount, or under
  /// a choice of categories the chosen parts of a split.
  String _amount(AccountFilter filter) => filter.hasCategories
      ? countedAmount(filter.categoryIds, uncategorised: filter.uncategorised)
      : 't.amount_minor';

  bool _searches(AccountFilter filter) => filter.query.trim().isNotEmpty;

  /// What a filtered read depends on: a receipt coming or going changes what "with a receipt" keeps.
  Set<TableInfo> get _reads =>
      {db.transactions, db.accounts, db.categories, db.workspaceTags, db.transactionReceipts, db.billQueue};

  /// The account with its balance; null once it is deleted.
  Stream<AccountBalance?> watchAccount(String accountId) => db
      .customSelect(
        'SELECT a.*, a.opening_balance_minor + COALESCE((SELECT SUM(t.amount_minor) FROM transactions t '
        'WHERE t.account_id = a.id AND t.deleted_at IS NULL), 0) AS balance '
        'FROM accounts a WHERE a.id = ? AND a.deleted_at IS NULL',
        variables: [Variable<String>(accountId)],
        readsFrom: {db.accounts, db.transactions},
      )
      .watchSingleOrNull()
      .map((row) => row == null ? null : AccountBalance(db.accounts.map(row.data), row.read<int>('balance')));

  /// Up to [limit] rows after [cursor], newest first, and whether more follow.
  Future<(List<AccountFeedRow>, bool)> page(
    String accountId,
    String currency,
    AccountFilter filter, {
    FeedCursor? cursor,
    int limit = feedPageSize,
  }) async {
    final (period, periodVariables) = _period(filter);
    final (narrow, narrowVariables) = _narrow(filter, currency);
    final rows = await db.customSelect(
      'SELECT t.*, a.name AS a_name, c.name AS c_name, c.color AS c_color, oa.name AS o_name, '
      '$receiptCountSql AS r_count FROM transactions t '
      'JOIN accounts a ON a.id = t.account_id $_categoryJoin$_otherLegJoin'
      'WHERE t.account_id = ? AND t.deleted_at IS NULL$period AND $narrow '
      '${cursor == null ? '' : 'AND (t.occurred_on, t.created_at, t.id) < (?, ?, ?) '}'
      'ORDER BY t.occurred_on DESC, t.created_at DESC, t.id DESC LIMIT ?',
      variables: [
        Variable<String>(accountId),
        ...periodVariables,
        ...narrowVariables,
        if (cursor != null) ...[
          Variable<String>(cursor.$1),
          Variable<String>(cursor.$2),
          Variable<String>(cursor.$3),
        ],
        Variable<int>(limit + 1),
      ],
    ).get();
    return (
      [
        for (final row in rows.take(limit))
          AccountFeedRow(
            TransactionView(
              db.transactions.map(row.data),
              row.read<String>('a_name'),
              row.readNullable<String>('c_name'),
              categoryColor: row.readNullable<String>('c_color'),
              receiptCount: row.read<int>('r_count'),
            ),
            otherAccountName: row.readNullable<String>('o_name'),
          ),
      ],
      rows.length > limit,
    );
  }

  /// The balance at the end of [filter]'s period: where a running balance starts.
  Future<int> closingBalance(String accountId, AccountFilter filter) async {
    final row = await db.customSelect(
      'SELECT a.opening_balance_minor + COALESCE((SELECT SUM(t.amount_minor) FROM transactions t '
      'WHERE t.account_id = a.id AND t.deleted_at IS NULL${filter.to == null ? '' : ' AND t.occurred_on <= ?'}), 0) '
      'AS closing FROM accounts a WHERE a.id = ?',
      variables: [if (filter.to != null) Variable<String>(filter.to!), Variable<String>(accountId)],
    ).getSingleOrNull();
    return row?.read<int>('closing') ?? 0;
  }

  Stream<AccountSummary> watchSummary(String accountId, String currency, AccountFilter filter) {
    final (period, periodVariables) = _period(filter);
    final (narrow, narrowVariables) = _narrow(filter, currency);
    // Nothing before an open start; everything up to an open end
    final before = filter.from == null ? '0' : 'occurred_on < ?';
    final through = filter.to == null ? '1' : 'occurred_on <= ?';
    final amount = _amount(filter);
    return db
        .customSelect(
          'SELECT '
          "COALESCE(SUM(CASE WHEN t.kind = 'income' THEN $amount END), 0) AS income, "
          "COALESCE(-SUM(CASE WHEN t.kind = 'expense' THEN $amount END), 0) AS expense, "
          "COALESCE(SUM(CASE WHEN t.kind = 'transfer' AND t.amount_minor > 0 THEN t.amount_minor END), 0) AS t_in, "
          "COALESCE(-SUM(CASE WHEN t.kind = 'transfer' AND t.amount_minor < 0 THEN t.amount_minor END), 0) AS t_out, "
          // Expenses are negative, so the smallest is the biggest
          "COALESCE(-MIN(CASE WHEN t.kind = 'expense' THEN $amount END), 0) AS largest, "
          'COUNT(t.id) AS n, MIN(t.occurred_on) AS first_day, MAX(t.occurred_on) AS last_day, '
          'COALESCE((SELECT opening_balance_minor FROM accounts WHERE id = ?), 0) AS base, '
          'COALESCE((SELECT SUM(amount_minor) FROM transactions '
          'WHERE account_id = ? AND deleted_at IS NULL AND $before), 0) AS before, '
          'COALESCE((SELECT SUM(amount_minor) FROM transactions '
          'WHERE account_id = ? AND deleted_at IS NULL AND $through), 0) AS through '
          'FROM transactions t ${_searches(filter) ? '$_categoryJoin$_otherLegJoin' : ''}'
          'WHERE t.account_id = ? AND t.deleted_at IS NULL$period AND $narrow',
          variables: [
            Variable<String>(accountId),
            Variable<String>(accountId),
            if (filter.from != null) Variable<String>(filter.from!),
            Variable<String>(accountId),
            if (filter.to != null) Variable<String>(filter.to!),
            Variable<String>(accountId),
            ...periodVariables,
            ...narrowVariables,
          ],
          readsFrom: _reads,
        )
        .watchSingle()
        .map((row) {
      final base = row.read<int>('base');
      return AccountSummary(
        incomeMinor: row.read<int>('income'),
        expenseMinor: row.read<int>('expense'),
        transferInMinor: row.read<int>('t_in'),
        transferOutMinor: row.read<int>('t_out'),
        count: row.read<int>('n'),
        largestExpenseMinor: row.read<int>('largest'),
        openingMinor: base + row.read<int>('before'),
        closingMinor: base + row.read<int>('through'),
        firstDay: row.readNullable<String>('first_day'),
        lastDay: row.readNullable<String>('last_day'),
      );
    });
  }

  /// Expense (or [income]) per category inside [filter], largest first.
  Stream<List<CategorySpend>> watchCategories(String accountId, String currency, AccountFilter filter,
      {bool income = false}) {
    final (period, periodVariables) = _period(filter);
    final (narrow, narrowVariables) = _narrow(filter, currency);
    return db
        .customSelect(
          // Each part of a split under its own category
          'SELECT c.id AS c_id, c.name AS c_name, c.color AS c_color, ABS(SUM($partAmount)) AS total, '
          'COUNT(*) AS n, MAX(ABS($partAmount)) AS largest '
          'FROM transactions t ${partsJoin}LEFT JOIN categories c ON c.id = $partCategory AND c.deleted_at IS NULL '
          '${_searches(filter) ? _otherLegJoin : ''}'
          'WHERE t.account_id = ? AND t.deleted_at IS NULL AND t.kind = ?$period AND $narrow '
          '${filter.hasCategories ? 'AND ${partChosen(filter.categoryIds, uncategorised: filter.uncategorised)} ' : ''}'
          'GROUP BY c.id ORDER BY total DESC',
          variables: [
            Variable<String>(accountId),
            Variable<String>(income ? 'income' : 'expense'),
            ...periodVariables,
            ...narrowVariables,
          ],
          readsFrom: _reads,
        )
        .watch()
        .map((rows) => [
              for (final row in rows)
                CategorySpend(
                  row.readNullable<String>('c_id'),
                  row.readNullable<String>('c_name'),
                  row.readNullable<String>('c_color'),
                  row.read<int>('total'),
                  count: row.read<int>('n'),
                  largestMinor: row.read<int>('largest'),
                ),
            ]);
  }

  /// Cash in, cash out and the closing balance, step by step through the
  /// period. In and out follow the whole [filter]; the balance counts every
  /// transaction, as a balance must. A month-by-month series keeps only the
  /// [maxMonths] months up to its latest ([trimSeries]).
  Stream<AccountSeries> watchSeries(String accountId, String currency, AccountFilter filter, {int? maxMonths}) {
    final (period, periodVariables) = _period(filter);
    final (narrow, narrowVariables) = _narrow(filter, currency);
    final amount = _amount(filter);
    return db
        .customSelect(
          'SELECT t.occurred_on AS day, SUM(t.amount_minor) AS net, '
          'SUM(CASE WHEN ($narrow) AND t.amount_minor > 0 THEN $amount ELSE 0 END) AS cash_in, '
          '-SUM(CASE WHEN ($narrow) AND t.amount_minor < 0 THEN $amount ELSE 0 END) AS cash_out, '
          'COALESCE((SELECT opening_balance_minor FROM accounts WHERE id = ?), 0) + '
          'COALESCE((SELECT SUM(amount_minor) FROM transactions WHERE account_id = ? AND deleted_at IS NULL '
          'AND ${filter.from == null ? '0' : 'occurred_on < ?'}), 0) AS opening '
          'FROM transactions t ${_searches(filter) ? '$_categoryJoin$_otherLegJoin' : ''}'
          'WHERE t.account_id = ? AND t.deleted_at IS NULL$period GROUP BY t.occurred_on ORDER BY t.occurred_on',
          variables: [
            ...narrowVariables,
            ...narrowVariables,
            Variable<String>(accountId),
            Variable<String>(accountId),
            if (filter.from != null) Variable<String>(filter.from!),
            Variable<String>(accountId),
            ...periodVariables,
          ],
          readsFrom: _reads,
        )
        .watch()
        .map((rows) {
      if (rows.isEmpty) return AccountSeries(const [], monthly: false, openingMinor: 0);
      final opening = rows.first.read<int>('opening');
      final first = DateTime.parse(filter.from ?? rows.first.read<String>('day'));
      final last = DateTime.parse(filter.to ?? rows.last.read<String>('day'));
      final monthly = last.difference(first).inDays > seriesDailyLimit;
      final points = <BalancePoint>[];
      var balance = opening;
      for (final row in rows) {
        final day = DateTime.parse(row.read<String>('day'));
        final date = monthly ? DateTime(day.year, day.month) : day;
        balance += row.read<int>('net');
        final cashIn = row.read<int>('cash_in'), cashOut = row.read<int>('cash_out');
        if (points.isNotEmpty && points.last.date == date) {
          final previous = points.removeLast();
          points.add(BalancePoint(date, previous.inMinor + cashIn, previous.outMinor + cashOut, balance));
        } else {
          points.add(BalancePoint(date, cashIn, cashOut, balance));
        }
      }
      return trimSeries(AccountSeries(points, monthly: monthly, openingMinor: opening), maxMonths);
    });
  }
}

final accountLedgerProvider = Provider<AccountLedger>((ref) => AccountLedger(ref.watch(databaseProvider)));

final accountProvider = StreamProvider.autoDispose.family<AccountBalance?, String>(
  (ref, accountId) => ref.watch(accountLedgerProvider).watchAccount(accountId),
);

class AccountFilterController extends Notifier<AccountFilter> {
  AccountFilterController(this.accountId);

  final String accountId;

  @override
  AccountFilter build() => const AccountFilter();

  void set(AccountFilter filter) => state = filter;

  void setPeriod(AccountPeriod period, {String? from, String? to}) =>
      state = state.withPeriod(period, from: from, to: to);

  /// Back to everything in the period.
  void clearNarrowing() =>
      state = state.copyWith(
          kind: () => null, categoryIds: const {}, uncategorised: false, hasReceipt: () => null, query: '');
}

final accountFilterProvider = NotifierProvider.autoDispose
    .family<AccountFilterController, AccountFilter, String>(AccountFilterController.new);

// The account's currency, which every transaction on it shares
final _accountCurrencyProvider = Provider.autoDispose.family<String?, String>(
  (ref, accountId) => ref.watch(accountProvider(accountId).select((value) => value.value?.account.currency)),
);

class AccountFeed {
  const AccountFeed({this.rows = const [], this.hasMore = false, this.loading = true, this.loadingMore = false});

  final List<AccountFeedRow> rows;
  final bool hasMore;

  /// Nothing read yet for this filter.
  final bool loading;
  final bool loadingMore;
}

/// The rows of the account screen so far. [loadMore] adds a page; a change to
/// the data (an edit, a sync) re-reads what is already shown, in place.
class AccountFeedController extends Notifier<AccountFeed> {
  AccountFeedController(this.accountId);

  final String accountId;

  late AccountFilter _filter;
  String? _currency;
  int _generation = 0;
  bool _busy = false;
  bool _stale = false;

  @override
  AccountFeed build() {
    _filter = ref.watch(accountFilterProvider(accountId));
    _currency = ref.watch(_accountCurrencyProvider(accountId));
    _generation++;
    _busy = false;
    _stale = false;
    if (_currency == null) return const AccountFeed();

    final db = ref.watch(databaseProvider);
    final updates = db
        .tableUpdates(TableUpdateQuery.onAllTables(
            [db.transactions, db.categories, db.accounts, db.transactionReceipts, db.billQueue]))
        .listen((_) => _reload());
    ref.onDispose(updates.cancel);
    // After build has returned: the first read looks at the state
    Future.microtask(_reload);
    return const AccountFeed();
  }

  AccountLedger get _ledger => ref.read(accountLedgerProvider);

  /// With every row of the period shown, each one's balance follows from the one above it.
  Future<List<AccountFeedRow>> _withBalances(List<AccountFeedRow> rows, {int? startMinor}) async {
    if (_filter.isNarrowed) return rows;
    var balance = startMinor ?? await _ledger.closingBalance(accountId, _filter);
    return [
      for (final row in rows)
        () {
          final after = balance;
          balance -= row.transaction.amountMinor;
          return AccountFeedRow(row.view, otherAccountName: row.otherAccountName, balanceAfterMinor: after);
        }(),
    ];
  }

  /// Reads again as many rows as are shown, from the top.
  Future<void> _reload() async {
    if (_busy) {
      _stale = true;
      return;
    }
    _busy = true;
    final generation = _generation;
    try {
      do {
        _stale = false;
        final shown = state.rows.length < feedPageSize ? feedPageSize : state.rows.length;
        final (rows, hasMore) = await _ledger.page(accountId, _currency!, _filter, limit: shown);
        final balanced = await _withBalances(rows);
        if (generation != _generation || !ref.mounted) return;
        state = AccountFeed(rows: balanced, hasMore: hasMore, loading: false);
      } while (_stale);
    } finally {
      if (generation == _generation) _busy = false;
    }
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasMore || state.rows.isEmpty) return;
    _busy = true;
    final generation = _generation;
    final before = state;
    state = AccountFeed(rows: before.rows, hasMore: true, loading: false, loadingMore: true);
    try {
      final last = before.rows.last;
      final t = last.transaction;
      final (rows, hasMore) =
          await _ledger.page(accountId, _currency!, _filter, cursor: (t.occurredOn, t.createdAt, t.id));
      final balanced = await _withBalances(
        rows,
        startMinor: last.balanceAfterMinor == null ? null : last.balanceAfterMinor! - t.amountMinor,
      );
      if (generation != _generation || !ref.mounted) return;
      state = AccountFeed(rows: [...before.rows, ...balanced], hasMore: hasMore, loading: false);
    } finally {
      if (generation == _generation) _busy = false;
    }
    // Something changed while the page was read
    if (_stale && generation == _generation) await _reload();
  }
}

final accountFeedProvider =
    NotifierProvider.autoDispose.family<AccountFeedController, AccountFeed, String>(AccountFeedController.new);

final accountSummaryProvider = StreamProvider.autoDispose.family<AccountSummary, String>((ref, accountId) {
  final currency = ref.watch(_accountCurrencyProvider(accountId));
  if (currency == null) return const Stream.empty();
  return ref
      .watch(accountLedgerProvider)
      .watchSummary(accountId, currency, ref.watch(accountFilterProvider(accountId)));
});

/// Keyed by account and whether it is the income side.
final accountCategoriesProvider =
    StreamProvider.autoDispose.family<List<CategorySpend>, (String, bool)>((ref, key) {
  final currency = ref.watch(_accountCurrencyProvider(key.$1));
  if (currency == null) return const Stream.empty();
  return ref
      .watch(accountLedgerProvider)
      .watchCategories(key.$1, currency, ref.watch(accountFilterProvider(key.$1)), income: key.$2);
});

final accountSeriesProvider = StreamProvider.autoDispose.family<AccountSeries, String>((ref, accountId) {
  final currency = ref.watch(_accountCurrencyProvider(accountId));
  if (currency == null) return const Stream.empty();
  return ref
      .watch(accountLedgerProvider)
      .watchSeries(accountId, currency, ref.watch(accountFilterProvider(accountId)),
          maxMonths: ref.watch(trendLimitProvider));
});
