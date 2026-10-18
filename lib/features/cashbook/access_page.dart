import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../plan/upgrade_sheet.dart';
import 'access_repository.dart';
import 'book_access.dart';
import 'cashbook_repository.dart';

/// Who of the business's staff may use one cashbook, and how far. Owners,
/// admins and viewers reach every book through their role, so only staff are
/// listed. For the people who may manage the book.
class CashbookAccessPage extends ConsumerWidget {
  const CashbookAccessPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final book = ref.watch(cashbookProvider(bookId)).value?.book;
    final workspaces = ref.watch(workspacesProvider).value ?? const <Workspace>[];
    final workspace = workspaces.where((w) => w.id == book?.workspaceId).firstOrNull;
    // Only the owner or an admin may let someone else manage a book
    final mayGrantManage = workspace != null && BookAccess.forRole(workspace.role) == BookAccess.manage;
    final staff = ref.watch(bookAccessListProvider(bookId));
    Future<void> reload() => ref.refresh(bookAccessListProvider(bookId).future);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.whoHasAccess)),
      body: AsyncView(
        value: staff,
        builder: (members) {
          if (members == null) {
            return EmptyState(
              icon: Icons.cloud_off_outlined,
              message: l10n.needsConnectionRetry,
              actionLabel: l10n.retry,
              onAction: reload,
            );
          }
          return RefreshIndicator(
            onRefresh: reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.page),
              children: [
                Text(l10n.accessIntro, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpace.lg),
                if (members.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpace.lg),
                    child: EmptyState(
                      icon: Icons.group_outlined,
                      message: l10n.noStaff,
                      actionLabel: l10n.teamOpen,
                      onAction: () => context.push('/team'),
                    ),
                  )
                else
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (final (index, member) in members.indexed) ...[
                          if (index > 0) const Divider(indent: 68),
                          ListTile(
                            leading: AvatarCircle(initials: member.email.characters.first.toUpperCase(), size: 36),
                            title: Text(member.email, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(accessLabel(context, member.access)),
                            trailing: Icon(Icons.chevron_right_rounded, color: context.colors.muted),
                            onTap: () => _choose(context, ref, member, mayGrantManage: mayGrantManage),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _choose(BuildContext context, WidgetRef ref, StaffAccess member, {required bool mayGrantManage}) async {
    final l10n = context.l10n;
    // Someone who manages the book but isn't an owner or admin can't touch another manager either
    if (member.access == BookAccess.manage && !mayGrantManage) {
      context.showMessage(l10n.accessRefused);
      return;
    }
    final picked = await showAccessPicker(context, title: member.email, current: member.access, mayGrantManage: mayGrantManage);
    if (picked == null || picked.access == member.access || !context.mounted) return;

    var outcome = AccessOutcome.refused;
    final allowed = await guarded(context, () async {
      outcome = await ref.read(accessRepositoryProvider).set(bookId, member, picked.access);
    });
    if (!allowed || !context.mounted) return;
    switch (outcome) {
      case AccessOutcome.saved:
        showEventBurst(context, AppEvent.saved);
      case AccessOutcome.offline:
        context.showMessage(l10n.needsConnection);
      case AccessOutcome.refused:
        context.showMessage(l10n.accessRefused);
        ref.invalidate(bookAccessListProvider(bookId));
    }
  }
}

/// Asks which level of access to give, [current] ticked. Only the owner or an
/// admin ([mayGrantManage]) may let someone else manage a book. Null when
/// dismissed; a record so that "no access" can be the answer.
Future<({BookAccess? access})?> showAccessPicker(
  BuildContext context, {
  required String title,
  required BookAccess? current,
  required bool mayGrantManage,
}) {
  final levels = <BookAccess?>[null, ...BookAccess.values.where((a) => a != BookAccess.manage || mayGrantManage)];
  return showAppSheet<({BookAccess? access})>(
    context,
    title: title,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final level in levels)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(accessLabel(context, level)),
            subtitle: Text(_accessHint(context, level)),
            trailing: level == current ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () => Navigator.of(context).pop((access: level)),
          ),
      ],
    ),
  );
}

String _accessHint(BuildContext context, BookAccess? access) {
  final l10n = context.l10n;
  return switch (access) {
    null => l10n.accessNoneHint,
    BookAccess.view => l10n.accessViewHint,
    BookAccess.add => l10n.accessAddHint,
    BookAccess.edit => l10n.accessEditHint,
    BookAccess.manage => l10n.accessManageHint,
  };
}

/// The name of a level of access to a cashbook; null is none at all.
String accessLabel(BuildContext context, BookAccess? access) {
  final l10n = context.l10n;
  return switch (access) {
    null => l10n.accessNone,
    BookAccess.view => l10n.accessView,
    BookAccess.add => l10n.accessAdd,
    BookAccess.edit => l10n.accessEdit,
    BookAccess.manage => l10n.accessManage,
  };
}
