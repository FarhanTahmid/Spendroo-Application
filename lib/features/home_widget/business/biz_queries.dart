import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';

/// Money in and out on one day, in minor units.
class DayFlow {
  const DayFlow(this.inMinor, this.outMinor);

  static const none = DayFlow(0, 0);

  final int inMinor;
  final int outMinor;

  int get netMinor => inMinor - outMinor;

  DayFlow operator +(DayFlow other) => DayFlow(inMinor + other.inMinor, outMinor + other.outMinor);
}

/// The largest single cash out in a stretch of days.
class BigOut {
  const BigOut(this.label, this.amountMinor);

  /// The entry's title, else its party, else its category; null when it has none of them.
  final String? label;
  final int amountMinor;
}

/// A recent entry as the cashbook widget lists it.
class RecentEntry {
  const RecentEntry({required this.title, required this.cashIn, required this.amountMinor, required this.entryDate});

  /// Title, else party, else category; null when it has none of them.
  final String? title;
  final bool cashIn;
  final int amountMinor;

  /// yyyy-MM-dd.
  final String entryDate;
}

/// What the business widgets are made of for one business workspace, read in
/// a handful of queries grouped by book, however many books it has. Every map is
/// keyed by cashbook id.
class WorkspaceActivity {
  const WorkspaceActivity({
    required this.daily,
    required this.lastEntry,
    required this.monthCategories,
    required this.weekBiggest,
    required this.recent,
  });

  /// Book -> yyyy-MM-dd -> money in and out that day.
  final Map<String, Map<String, DayFlow>> daily;

  /// Book -> the date of its latest entry up to today.
  final Map<String, String> lastEntry;

  /// Book -> category name ('' for none) -> cash out this month.
  final Map<String, Map<String, int>> monthCategories;

  /// Book -> its largest cash out in the last seven days.
  final Map<String, BigOut> weekBiggest;

  /// Book -> its latest entries, newest first.
  final Map<String, List<RecentEntry>> recent;
}

/// Reads the figures behind the business and cashbook widgets. Entries of a
/// deleted book are tombstoned with it, but the book is checked too.
class BizWidgetQueries {
  BizWidgetQueries(this.db);

  final AppDatabase db;

  static const _totals =
      "COALESCE(SUM(CASE WHEN e.entry_type = 'cash_in' THEN e.amount_minor END), 0) AS cash_in, "
      "COALESCE(SUM(CASE WHEN e.entry_type = 'cash_out' THEN e.amount_minor END), 0) AS cash_out";

  static const _inWorkspace =
      'FROM entries e JOIN cashbooks b ON b.id = e.cashbook_id '
      'WHERE b.workspace_id = ? AND b.deleted_at IS NULL AND e.deleted_at IS NULL';

  Set<ResultSetImplementation> get _reads => {db.entries, db.cashbooks};

  /// Money in and out per book and day, [from] to [to] inclusive (yyyy-MM-dd).
  Stream<Map<String, Map<String, DayFlow>>> watchDaily(String workspaceId, String from, String to) => db
      .customSelect(
        'SELECT e.cashbook_id AS book, e.entry_date AS day, $_totals $_inWorkspace '
        'AND e.entry_date BETWEEN ? AND ? GROUP BY e.cashbook_id, e.entry_date',
        variables: [Variable<String>(workspaceId), Variable<String>(from), Variable<String>(to)],
        readsFrom: _reads,
      )
      .watch()
      .map((rows) {
        final byBook = <String, Map<String, DayFlow>>{};
        for (final row in rows) {
          (byBook[row.read<String>('book')] ??= {})[row.read<String>('day')] = DayFlow(
            row.read<int>('cash_in'),
            row.read<int>('cash_out'),
          );
        }
        return byBook;
      });

  /// Each book's latest entry date, ignoring entries dated after [today].
  Stream<Map<String, String>> watchLastEntry(String workspaceId, String today) => db
      .customSelect(
        'SELECT e.cashbook_id AS book, MAX(e.entry_date) AS last $_inWorkspace '
        'AND e.entry_date <= ? GROUP BY e.cashbook_id',
        variables: [Variable<String>(workspaceId), Variable<String>(today)],
        readsFrom: _reads,
      )
      .watch()
      .map((rows) => {for (final row in rows) row.read<String>('book'): row.read<String>('last')});

  /// Cash out per book and category name between [from] and [to].
  Stream<Map<String, Map<String, int>>> watchCategoryOut(String workspaceId, String from, String to) => db
      .customSelect(
        "SELECT e.cashbook_id AS book, COALESCE(c.category_name, '') AS name, SUM(e.amount_minor) AS total "
        'FROM entries e JOIN cashbooks b ON b.id = e.cashbook_id '
        'LEFT JOIN entry_categories c ON c.id = e.category_id '
        "WHERE b.workspace_id = ? AND b.deleted_at IS NULL AND e.deleted_at IS NULL AND e.entry_type = 'cash_out' "
        'AND e.entry_date BETWEEN ? AND ? GROUP BY e.cashbook_id, name',
        variables: [Variable<String>(workspaceId), Variable<String>(from), Variable<String>(to)],
        readsFrom: {..._reads, db.entryCategories},
      )
      .watch()
      .map((rows) {
        final byBook = <String, Map<String, int>>{};
        for (final row in rows) {
          (byBook[row.read<String>('book')] ??= {})[row.read<String>('name')] = row.read<int>('total');
        }
        return byBook;
      });

  /// Each book's largest cash out between [from] and [to].
  Stream<Map<String, BigOut>> watchBiggestOut(String workspaceId, String from, String to) => db
      .customSelect(
        'SELECT book, label, amount FROM ('
        "SELECT e.cashbook_id AS book, COALESCE(NULLIF(TRIM(e.title), ''), NULLIF(e.merchant, ''), c.category_name) AS label, "
        'e.amount_minor AS amount, ROW_NUMBER() OVER (PARTITION BY e.cashbook_id '
        'ORDER BY e.amount_minor DESC, e.entry_date DESC, e.id) AS rank '
        'FROM entries e JOIN cashbooks b ON b.id = e.cashbook_id '
        'LEFT JOIN entry_categories c ON c.id = e.category_id '
        "WHERE b.workspace_id = ? AND b.deleted_at IS NULL AND e.deleted_at IS NULL AND e.entry_type = 'cash_out' "
        'AND e.entry_date BETWEEN ? AND ?) WHERE rank = 1',
        variables: [Variable<String>(workspaceId), Variable<String>(from), Variable<String>(to)],
        readsFrom: {..._reads, db.entryCategories},
      )
      .watch()
      .map(
        (rows) => {
          for (final row in rows)
            row.read<String>('book'): BigOut(row.readNullable<String>('label'), row.read<int>('amount')),
        },
      );

  /// Each book's [limit] latest entries up to [today], newest first.
  Stream<Map<String, List<RecentEntry>>> watchRecent(String workspaceId, String today, {int limit = 3}) => db
      .customSelect(
        'SELECT book, label, kind, amount, day FROM ('
        "SELECT e.cashbook_id AS book, COALESCE(NULLIF(TRIM(e.title), ''), NULLIF(e.merchant, ''), c.category_name) AS label, "
        'e.entry_type AS kind, e.amount_minor AS amount, e.entry_date AS day, '
        'ROW_NUMBER() OVER (PARTITION BY e.cashbook_id ORDER BY e.entry_date DESC, e.created_at DESC, e.id) AS rank '
        'FROM entries e JOIN cashbooks b ON b.id = e.cashbook_id '
        'LEFT JOIN entry_categories c ON c.id = e.category_id '
        'WHERE b.workspace_id = ? AND b.deleted_at IS NULL AND e.deleted_at IS NULL AND e.entry_date <= ?) '
        'WHERE rank <= ? ORDER BY book, rank',
        variables: [Variable<String>(workspaceId), Variable<String>(today), Variable<int>(limit)],
        readsFrom: {..._reads, db.entryCategories},
      )
      .watch()
      .map((rows) {
        final byBook = <String, List<RecentEntry>>{};
        for (final row in rows) {
          (byBook[row.read<String>('book')] ??= []).add(
            RecentEntry(
              title: row.readNullable<String>('label'),
              cashIn: row.read<String>('kind') == 'cash_in',
              amountMinor: row.read<int>('amount'),
              entryDate: row.read<String>('day'),
            ),
          );
        }
        return byBook;
      });

  /// Book -> the signed-in member's own grant role. Staff only ever receive their own grants.
  Stream<Map<String, String>> watchGrants() => (db.select(
    db.cashbookMembers,
  )..where((m) => m.deletedAt.isNull())).watch().map((rows) => {for (final row in rows) row.cashbookId: row.role});
}

final bizWidgetQueriesProvider = Provider<BizWidgetQueries>((ref) => BizWidgetQueries(ref.watch(databaseProvider)));
