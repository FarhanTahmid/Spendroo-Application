import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../cashbook/access_page.dart';
import '../cashbook/access_repository.dart';
import '../cashbook/book_access.dart';
import '../cashbook/cashbook_repository.dart';
import '../history/history_page.dart';
import '../plan/upgrade_sheet.dart';
import '../profile/profile_repository.dart';
import 'invite_sheet.dart' show RoleOption;
import 'team_page.dart' show leaveBusiness, withFreshRole;
import 'team_repository.dart';
import 'team_roles.dart';
import 'team_widgets.dart';

/// One person in the business: their role, which cashbooks they may use
/// (staff only), and the ways out: removal, or taking over the business.
class MemberPage extends ConsumerStatefulWidget {
  const MemberPage({super.key, required this.membershipId});

  final String membershipId;

  @override
  ConsumerState<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends ConsumerState<MemberPage> {
  /// The role being saved, shown chosen before the server answers.
  String? _saving;

  /// Kept on screen while the page closes after a removal.
  TeamMember? _last;
  var _closing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workspace = ref.watch(currentWorkspaceProvider);
    final team = workspace == null ? null : ref.watch(teamProvider(workspace.id));
    final found = team?.value?.byId(widget.membershipId);
    if (found != null) _last = found;
    final member = found ?? (_closing ? _last : null);
    if (workspace == null || member == null) {
      return Scaffold(
        appBar: AppBar(),
        body: team?.isLoading ?? false
            ? const Center(child: AppLoader())
            : EmptyState(icon: Icons.person_off_outlined, message: l10n.memberGone),
      );
    }
    final me = ref.watch(profileProvider).value?.id;
    final space = withFreshRole(workspace, team?.value, me);
    final isMe = member.userId == me;
    final manages = TeamRole.canManage(space.role, member.role, isSelf: isMe);
    final roles = manages ? TeamRole.assignable(space.role) : const <String>[];
    final shownRole = _saving ?? member.role;

    return PassbookScaffold(
      header: _Header(member: member, role: shownRole, isMe: isMe),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.xxl),
        children: [
          Entrance(
            child: SectionCard(
              title: l10n.role,
              children: [
                if (roles.isEmpty) ...[
                  RoleOption(role: member.role, selected: true, enabled: false, onTap: () {}),
                  if (!isMe && member.role != TeamRole.owner)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.sm),
                      child: Text(member.role == TeamRole.admin ? l10n.roleChangeNotYours : l10n.roleChangeManagersOnly, style: Theme.of(context).textTheme.bodySmall),
                    ),
                ] else
                  for (final role in roles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.sm),
                      child: RoleOption(
                        role: role,
                        selected: role == shownRole,
                        onTap: () => _changeRole(space, member, role),
                      ),
                    ),
              ],
            ),
          ),
          if (member.role == TeamRole.staff && TeamRole.isManager(space.role))
            Entrance(index: 1, child: _BookAccess(workspace: workspace, member: member))
          else
            Entrance(
              index: 1,
              child: SectionCard(
                title: l10n.cashbookAccess,
                children: [
                  Row(
                    children: [
                      IconBadge(Icons.menu_book_outlined, color: roleColor(context, member.role)),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Text(
                          switch (member.role) {
                            TeamRole.owner || TeamRole.admin => l10n.accessByRoleAll,
                            TeamRole.viewer => l10n.accessByRoleView,
                            _ => l10n.accessByRoleStaff,
                          },
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (showsHistory(space))
            Entrance(
              index: 2,
              child: SectionCard(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
                children: [
                  ListTile(
                    leading: Icon(Icons.history_rounded, color: Theme.of(context).colorScheme.primary),
                    title: Text(l10n.historyTheirChanges),
                    subtitle: Text(l10n.historyTheirChangesHint(member.displayName)),
                    trailing: HistoryTrailing(workspace: space),
                    onTap: () => openHistory(context, person: member.userId),
                  ),
                ],
              ),
            ),
          if (TeamRole.canHandOver(space.role, member.role) || manages || (isMe && TeamRole.canLeave(member.role)))
            Entrance(
              index: 3,
              child: SectionCard(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
                children: [
                  if (TeamRole.canHandOver(space.role, member.role))
                    ListTile(
                      leading: Icon(Icons.workspace_premium_outlined, color: roleColor(context, TeamRole.owner)),
                      title: Text(l10n.handOver),
                      subtitle: Text(l10n.handOverHint(member.displayName)),
                      onTap: () => _handOver(space, member),
                    ),
                  if (manages)
                    ListTile(
                      leading: Icon(Icons.person_remove_outlined, color: Theme.of(context).colorScheme.error),
                      title: Text(l10n.removeMember, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      subtitle: Text(l10n.removeMemberHint),
                      onTap: () => _remove(space, member),
                    ),
                  if (isMe && TeamRole.canLeave(member.role))
                    ListTile(
                      leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
                      title: Text(l10n.leaveBusiness, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      onTap: () => leaveBusiness(context, ref, workspace, member),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _changeRole(Workspace workspace, TeamMember member, String role) async {
    final l10n = context.l10n;
    if (role == member.role || _saving != null) return;
    // Staff lose their per-book grants when they move to another role
    if (member.role == TeamRole.staff) {
      final grants = ref.read(memberGrantsProvider((workspace.id, member.userId))).value ?? const {};
      if (grants.isNotEmpty &&
          !await confirm(context, l10n.roleChangeDropsAccess(member.displayName, roleLabel(context, role)), action: l10n.change)) {
        return;
      }
    }
    if (!mounted) return;
    setState(() => _saving = role);
    String? error = TeamError.failed;
    final allowed = await guarded(context, () async {
      error = await ref.read(teamRepositoryProvider).changeRole(workspace.id, member, role);
    });
    if (!mounted) return;
    // The list is fetched again; keep showing the choice until it arrives
    await ref.read(teamProvider(workspace.id).future);
    if (!mounted) return;
    setState(() => _saving = null);
    if (!allowed) return;
    if (error == null) {
      showEventBurst(context, AppEvent.saved, label: roleLabel(context, role));
    } else {
      context.showMessage(teamErrorText(l10n, error!));
    }
  }

  Future<void> _remove(Workspace workspace, TeamMember member) async {
    final l10n = context.l10n;
    if (!await confirm(context, l10n.removeMemberConfirm(member.displayName, workspace.name), action: l10n.removeMember)) return;
    if (!mounted) return;
    final router = GoRouter.of(context);
    _closing = true;
    final error = await ref.read(teamRepositoryProvider).remove(workspace.id, member);
    if (!mounted) return;
    if (error != null) {
      _closing = false;
      context.showMessage(teamErrorText(l10n, error));
      return;
    }
    showEventBurst(context, AppEvent.deleted, label: l10n.memberRemoved);
    router.pop();
  }

  Future<void> _handOver(Workspace workspace, TeamMember member) async {
    final l10n = context.l10n;
    final sure = await showAppSheet<bool>(
      context,
      title: l10n.handOverTitle,
      builder: (_) => _HandOverConfirm(business: workspace.name, to: member),
    );
    if (sure != true || !mounted) return;
    String? error;
    try {
      error = await ref.read(teamRepositoryProvider).handOver(workspace.id, member);
    } on PlanLimitException {
      // The refusal is about the new owner's plan, which only they can change
      error = TeamError.noRoom;
    }
    if (!mounted) return;
    if (error == TeamError.noRoom) {
      context.showMessage(l10n.handOverNoRoom(member.displayName));
    } else if (error == null) {
      showEventBurst(context, AppEvent.transfer, label: l10n.handedOver(member.displayName));
    } else {
      context.showMessage(teamErrorText(l10n, error));
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.member, required this.role, required this.isMe});

  final TeamMember member;
  final String role;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final joined = member.joinedAt;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // The admin's blue would vanish into the navy
            border: Border.all(color: role == TeamRole.admin ? colors.onHeader : roleColor(context, role), width: 2),
          ),
          child: MemberAvatar(seed: member.email, initials: member.initials, size: 68, hero: 'member-${member.membershipId}'),
        ),
        const SizedBox(width: AppSpace.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.displayName, style: text.titleLarge?.copyWith(color: colors.onHeader), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (member.name.isNotEmpty)
                Text(member.email, style: text.bodySmall?.copyWith(color: colors.onHeaderMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: RoleChip(role: role, dense: true),
                  ),
                  if (joined != null) ...[
                    const SizedBox(width: AppSpace.sm),
                    Flexible(
                      child: Text(
                        l10n.joinedOn(formatDay(context, joined.toLocal())),
                        style: text.bodySmall?.copyWith(color: colors.onHeaderMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Every cashbook of the business with how far this staff member may use it.
class _BookAccess extends ConsumerWidget {
  const _BookAccess({required this.workspace, required this.member});

  final Workspace workspace;
  final TeamMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final books = ref.watch(cashbooksProvider(workspace.id)).value ?? const <CashbookSummary>[];
    final grants = ref.watch(memberGrantsProvider((workspace.id, member.userId))).value ?? const {};
    final open = books.where((s) => grants.containsKey(s.book.id)).length;
    return SectionCard(
      title: l10n.cashbookAccess,
      trailing: Text(l10n.booksOpenCount(open, books.length), style: Theme.of(context).textTheme.bodySmall),
      padding: const EdgeInsets.only(top: AppSpace.lg, bottom: AppSpace.sm),
      children: [
        if (books.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: Text(l10n.noCashbooks, style: Theme.of(context).textTheme.bodySmall),
          ),
        for (final summary in books)
          _BookRow(
            book: summary.book,
            grant: grants[summary.book.id],
            onTap: () => _choose(context, ref, summary.book, grants[summary.book.id]),
          ),
      ],
    );
  }

  Future<void> _choose(BuildContext context, WidgetRef ref, Cashbook book, CashbookMember? grant) async {
    final l10n = context.l10n;
    final current = grant == null ? null : BookAccess.fromGrant(grant.role);
    final picked = await showAccessPicker(context, title: book.bookName, current: current, mayGrantManage: true);
    if (picked == null || picked.access == current || !context.mounted) return;
    final staff = StaffAccess(userId: member.userId, email: member.email, grantId: grant?.id, access: current);
    var outcome = AccessOutcome.refused;
    final allowed = await guarded(context, () async {
      outcome = await ref.read(accessRepositoryProvider).set(book.id, staff, picked.access);
    });
    if (!allowed || !context.mounted) return;
    switch (outcome) {
      case AccessOutcome.saved:
        showEventBurst(context, AppEvent.saved);
      case AccessOutcome.offline:
        context.showMessage(l10n.needsConnection);
      case AccessOutcome.refused:
        context.showMessage(l10n.accessRefused);
    }
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({required this.book, required this.grant, required this.onTap});

  final Cashbook book;
  final CashbookMember? grant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final access = grant == null ? null : BookAccess.fromGrant(grant!.role);
    final on = access != null;
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: AnimatedContainer(
        duration: context.motion(AppMotion.standard),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: on ? scheme.primary.withValues(alpha: 0.12) : context.colors.field,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(on ? Icons.menu_book_rounded : Icons.lock_outline_rounded, color: on ? scheme.primary : context.colors.muted, size: 20),
      ),
      title: Text(book.bookName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: AnimatedSwitcher(
        duration: context.motion(AppMotion.standard),
        layoutBuilder: (current, previous) => Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [...previous, ?current],
        ),
        child: Text(accessLabel(context, access), key: ValueKey(access)),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: context.colors.muted),
    );
  }
}

/// Handing over can't be undone by the one handing over, so the business's
/// name is typed out first.
class _HandOverConfirm extends StatefulWidget {
  const _HandOverConfirm({required this.business, required this.to});

  final String business;
  final TeamMember to;

  @override
  State<_HandOverConfirm> createState() => _HandOverConfirmState();
}

class _HandOverConfirmState extends State<_HandOverConfirm> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  bool get _matches => _typed.text.trim().toLowerCase() == widget.business.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final gold = roleColor(context, TeamRole.owner);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            MemberAvatar(seed: widget.to.email, initials: widget.to.initials, size: 48),
            const SizedBox(width: AppSpace.md),
            Icon(Icons.arrow_forward_rounded, color: context.colors.muted),
            const SizedBox(width: AppSpace.md),
            IconBadge(Icons.workspace_premium_rounded, color: gold),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        Text(l10n.handOverBody(widget.to.displayName, widget.business), style: text.bodyMedium),
        const SizedBox(height: AppSpace.lg),
        TextField(
          controller: _typed,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: l10n.handOverTypeName(widget.business)),
        ),
        const SizedBox(height: AppSpace.lg),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.white),
          onPressed: _matches ? () => Navigator.pop(context, true) : null,
          child: Text(l10n.handOver),
        ),
      ],
    );
  }
}
