import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/database.dart';
import '../../../core/entitlements/entitlements_controller.dart';
import '../../../core/money.dart';
import '../../../core/providers.dart';
import '../../../core/ui.dart';
import '../../cashbook/cashbook_pages.dart';
import '../../cashbook/cashbook_repository.dart';
import 'biz_widget_providers.dart';

/// The two kinds of entry a widget's buttons open the form on.
const bizEntryTypes = {'cash_in', 'cash_out'};

String _entryType(String? type) => bizEntryTypes.contains(type) ? type! : 'cash_out';

/// Whether the user may add entries to [book] now: their role allows it and the
/// plan has not locked the book. The same rule as the widget's buttons.
bool _canAdd(WidgetRef ref, Cashbook book, Workspace? workspace) {
  if (workspace == null) return false;
  final grants = ref.watch(bizGrantsProvider).value ?? const {};
  final locked = ref.watch(entitlementsProvider).value?.isLocked(book.id) ?? false;
  return bookPermission(workspace.role, grants[book.id]) != 'view' && !locked;
}

/// The entry form for one book as a screen of its own (/cashbook/:id/entry?type=cash_in),
/// so a cashbook widget's buttons open it straight away.
class CashbookEntryLauncher extends ConsumerWidget {
  const CashbookEntryLauncher({super.key, required this.bookId, this.type});

  final String bookId;
  final String? type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(cashbookProvider(bookId));
    final workspaces = ref.watch(workspacesProvider).value;
    final summary = value.value;
    if (summary == null || workspaces == null) {
      return Scaffold(
        appBar: AppBar(),
        body: value.isLoading || workspaces == null
            ? const Center(child: AppLoader())
            // Deleted here or on another device since the widget last drew it
            : EmptyState(icon: Icons.menu_book_outlined, message: context.l10n.noCashbooks),
      );
    }
    final book = summary.book;
    final workspace = workspaces.where((w) => w.id == book.workspaceId).firstOrNull;
    if (!_canAdd(ref, book, workspace)) {
      return Scaffold(
        appBar: AppBar(title: Text(book.bookName)),
        body: EmptyState(icon: Icons.visibility_outlined, message: context.l10n.readOnly),
      );
    }
    return EntryFormPage(book: book, entryType: _entryType(type));
  }
}

/// A business widget's Cash in / Cash out (/business/:ws/add?type=cash_in): which
/// book it goes in. With only one book the user may add to, its form opens at once.
class BusinessQuickAddPage extends ConsumerWidget {
  const BusinessQuickAddPage({super.key, required this.workspaceId, this.type});

  final String workspaceId;
  final String? type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final workspace = (ref.watch(workspacesProvider).value ?? const <Workspace>[])
        .where((w) => w.id == workspaceId)
        .firstOrNull;
    final books = ref.watch(cashbooksProvider(workspaceId));
    final grants = ref.watch(bizGrantsProvider);
    if (!books.hasValue || !grants.hasValue) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: AppLoader()),
      );
    }
    final writable = [
      for (final summary in books.value!)
        if (_canAdd(ref, summary.book, workspace)) summary,
    ];
    final entryType = _entryType(type);
    if (writable.length == 1) return EntryFormPage(book: writable.single.book, entryType: entryType);

    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bizChooseBookTitle)),
      body: writable.isEmpty
          ? EmptyState(
              icon: Icons.visibility_outlined,
              message: books.value!.isEmpty ? l10n.noCashbooks : l10n.bizChooseBookNone,
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpace.page),
              children: [
                for (final summary in writable)
                  Card(
                    margin: const EdgeInsets.only(bottom: AppSpace.md),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: Icon(
                        entryType == 'cash_in' ? Icons.south_west_rounded : Icons.north_east_rounded,
                        color: amountColor(entryType == 'cash_in'),
                      ),
                      title: Text(summary.book.bookName, overflow: TextOverflow.ellipsis),
                      subtitle: Text(l10n.entriesCount(summary.entryCount)),
                      trailing: Text(
                        Money.format(summary.balanceMinor, summary.book.currency, locale: context.languageCode),
                        style: text.titleSmall?.copyWith(color: context.amountColor(summary.balanceMinor >= 0)),
                      ),
                      // In place of this page, so saving the entry leads back to where the user was
                      onTap: () => context.pushReplacement('/cashbook/${summary.book.id}/entry?type=$entryType'),
                    ),
                  ),
              ],
            ),
    );
  }
}
