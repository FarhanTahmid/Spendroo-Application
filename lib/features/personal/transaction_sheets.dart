import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/ui.dart';
import 'ledger_repository.dart';
import 'personal_pages.dart';

/// Expense per day of the selected month, keyed by (workspace id, currency).
final dailySpendProvider = StreamProvider.family<Map<int, int>, (String, String)>(
  (ref, key) => ref.watch(ledgerRepositoryProvider).watchDailySpend(key.$1, ref.watch(selectedMonthProvider), key.$2),
);

/// The same for the month before the selected one, to compare the two day by day.
final previousDailySpendProvider = StreamProvider.family<Map<int, int>, (String, String)>((ref, key) {
  final month = ref.watch(selectedMonthProvider);
  return ref
      .watch(ledgerRepositoryProvider)
      .watchDailySpend(key.$1, DateTime(month.year, month.month - 1), key.$2);
});

/// One category's expense per day of the selected month, keyed by (workspace id, currency, category id).
final categoryDailySpendProvider = StreamProvider.autoDispose.family<Map<int, int>, (String, String, String)>(
  (ref, key) => ref
      .watch(ledgerRepositoryProvider)
      .watchDailySpend(key.$1, ref.watch(selectedMonthProvider), key.$2, categoryId: key.$3),
);

/// Transactions of one day, keyed by (workspace id, ISO date).
final dayTransactionsProvider = StreamProvider.family<List<TransactionView>, (String, String)>(
  (ref, key) => ref.watch(ledgerRepositoryProvider).watchTransactions(key.$1, day: key.$2),
);

/// The selected month's expenses in one category, keyed by (workspace id, category id);
/// a null category id means the uncategorised ones.
final categoryTransactionsProvider = StreamProvider.autoDispose.family<List<TransactionView>, (String, String?)>(
  (ref, key) => ref.watch(ledgerRepositoryProvider).watchTransactions(
        key.$1,
        month: ref.watch(selectedMonthProvider),
        kind: 'expense',
        categoryId: key.$2,
        uncategorised: key.$2 == null,
      ),
);

/// What happened on [date], with a way to add to it.
Future<void> showDaySheet(BuildContext context, Workspace workspace, DateTime date) => showAppSheet<void>(
      context,
      title: formatDate(context, isoDate(date)),
      scrolls: false,
      trailing: Builder(
        builder: (context) => TextButton.icon(
          icon: const Icon(Icons.add_rounded),
          label: Text(context.l10n.addTransaction),
          onPressed: () {
            Navigator.pop(context);
            openTransactionForm(context, workspace, date: isoDate(date));
          },
        ),
      ),
      builder: (_) => Consumer(
        builder: (context, ref, _) => TransactionSheetList(
          workspace: workspace,
          transactions: ref.watch(dayTransactionsProvider((workspace.id, isoDate(date)))).value,
          emptyMessage: context.l10n.noTransactionsOnDay,
          showDate: false,
        ),
      ),
    );

/// The selected month's expenses in one category; [categoryId] null for the uncategorised ones.
Future<void> showCategoryTransactions(BuildContext context, Workspace workspace,
        {required String? categoryId, required String title}) =>
    showAppSheet<void>(
      context,
      title: title,
      scrolls: false,
      builder: (_) => Consumer(
        builder: (context, ref, _) => TransactionSheetList(
          workspace: workspace,
          transactions: ref.watch(categoryTransactionsProvider((workspace.id, categoryId))).value,
          emptyMessage: context.l10n.noTransactionsHere,
        ),
      ),
    );

/// The rows of a sheet of transactions. Tapping one closes the sheet and opens it for editing.
class TransactionSheetList extends StatelessWidget {
  const TransactionSheetList({
    super.key,
    required this.workspace,
    required this.transactions,
    required this.emptyMessage,
    this.showDate = true,
    this.embedded = false,
  });

  final Workspace workspace;

  /// Null while they load.
  final List<TransactionView>? transactions;
  final String emptyMessage;
  final bool showDate;

  /// True inside a list that already scrolls: the rows are laid out in full.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final transactions = this.transactions;
    if (transactions == null) return const SizedBox(height: 96);
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Text(emptyMessage, textAlign: TextAlign.center, style: TextStyle(color: context.colors.muted)),
      );
    }
    final rows = [
      for (final view in transactions)
        TransactionTile(
          view: view,
          showDate: showDate,
          onTap: () {
            Navigator.pop(context);
            openTransactionForm(context, workspace, existing: view);
          },
        ),
    ];
    if (embedded) return Column(children: rows);
    return ListView(shrinkWrap: true, padding: const EdgeInsets.only(bottom: 12), children: rows);
  }
}
