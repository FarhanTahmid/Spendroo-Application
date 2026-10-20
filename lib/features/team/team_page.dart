import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../plan/plan_text.dart';
import '../plan/upgrade_sheet.dart';
import '../profile/profile_repository.dart';
import 'invite_sheet.dart';
import 'team_repository.dart';
import 'team_roles.dart';
import 'team_widgets.dart';

/// The people in the business on screen: who they are, what they may do, the
/// invitations waiting, and how many seats the owner's plan leaves. Everyone
/// in the business may look; the owner and admins change things.
class TeamPage extends ConsumerWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final workspace = ref.watch(currentWorkspaceProvider);
    if (workspace == null || workspace.kind != 'business' || workspace.isDemo) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.team)),
        body: EmptyState(icon: Icons.group_outlined, message: l10n.teamBusinessOnly),
      );
    }
    final team = ref.watch(teamProvider(workspace.id));
    final me = ref.watch(profileProvider).value?.id;
    final data = team.value;
    final seats = data?.seats;
    // The list just fetched knows the user's role before the next sync does
    final space = withFreshRole(workspace, data, me);
    final manager = TeamRole.isManager(space.role);
    // Syncing too brings in a role or business someone else just changed
    Future<void> reload() => Future.wait([
          ref.refresh(teamProvider(workspace.id).future),
          ref.read(syncControllerProvider.notifier).syncNow(),
        ]);

    return PassbookScaffold(
      title: Text(l10n.team),
      header: _Header(workspace: space, team: data),
      floatingActionButton: manager && data != null && !(seats?.none ?? false)
          ? _InviteButton(onPressed: () => startInvite(context, ref, space, data))
          : null,
      // A refresh keeps the list on screen; only the first load shows the skeleton
      body: AnimatedSwitcher(
        duration: context.motion(AppMotion.emphasised),
        child: data != null
            ? RefreshIndicator(
                key: const ValueKey('team'),
                onRefresh: reload,
                child: _TeamList(workspace: space, team: data, me: me),
              )
            : team.isLoading
                ? const Padding(
                    key: ValueKey('loading'),
                    padding: EdgeInsets.only(top: AppSpace.lg),
                    child: SkeletonList(rows: 5),
                  )
                : EmptyState(
                    key: const ValueKey('offline'),
                    icon: Icons.cloud_off_outlined,
                    message: l10n.needsConnectionRetry,
                    actionLabel: l10n.retry,
                    onAction: reload,
                  ),
      ),
    );
  }
}

/// [workspace] with the role the server's member list gives [me], which may
/// be newer than the phone's copy.
Workspace withFreshRole(Workspace workspace, Team? team, String? me) {
  final role = team?.byUser(me)?.role;
  return role == null || role == workspace.role ? workspace : workspace.copyWith(role: role);
}

/// Opens the invitation form, unless every seat is taken: the owner then sees
/// what more seats cost, an admin is told to ask the owner.
Future<void> startInvite(BuildContext context, WidgetRef ref, Workspace workspace, Team team) async {
  final seats = team.seats;
  if (seats != null && seats.full) {
    await showSeatRefusal(context, workspace, seats.refusal);
    return;
  }
  final refusal = await showInviteSheet(context, workspace: workspace, seats: seats);
  if (refusal != null && context.mounted) await showSeatRefusal(context, workspace, refusal);
}

/// The owner can buy more seats; anyone else can only ask them to.
Future<void> showSeatRefusal(BuildContext context, Workspace workspace, PlanLimitException refusal) async {
  if (workspace.role == TeamRole.owner) {
    await showUpgradeSheet(context, refusal: refusal);
  } else {
    context.showMessage(context.l10n.seatsFullAskOwner);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.workspace, required this.team});

  final Workspace workspace;
  final Team? team;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final team = this.team;
    final seats = team?.seats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workspace.name, style: text.headlineSmall?.copyWith(color: colors.onHeader), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    team == null ? l10n.yourRole(roleLabel(context, workspace.role)) : l10n.peopleCount(team.members.length),
                    style: text.bodyMedium?.copyWith(color: colors.onHeaderMuted),
                  ),
                ],
              ),
            ),
            if (team != null) AvatarStack(members: team.members),
          ],
        ),
        AnimatedSize(
          duration: context.motion(AppMotion.emphasised),
          curve: AppMotion.ease,
          child: seats == null || team == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpace.lg),
                  child: SeatMeter(seats: seats, members: team.members.where((m) => m.role != TeamRole.owner).length),
                ),
        ),
      ],
    );
  }
}

class _InviteButton extends StatelessWidget {
  const _InviteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: context.motion(AppMotion.emphasised),
      curve: AppMotion.spring,
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: FloatingActionButton.extended(
        heroTag: 'invite',
        backgroundColor: colors.gold,
        foregroundColor: colors.onGold,
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(context.l10n.invite),
      ),
    );
  }
}

class _TeamList extends ConsumerWidget {
  const _TeamList({required this.workspace, required this.team, required this.me});

  final Workspace workspace;
  final Team team;
  final String? me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final plan = ref.watch(entitlementsProvider).value;
    final manager = TeamRole.isManager(workspace.role);
    final seats = team.seats;
    final mine = team.byUser(me);
    var index = 0;

    List<Widget> group(String role) {
      final people = team.members.where((m) => m.role == role).toList();
      if (people.isEmpty) return const [];
      return [
        GroupHeading(
          label: switch (role) {
            TeamRole.owner => l10n.roleOwner,
            TeamRole.admin => l10n.groupAdmins,
            TeamRole.staff => l10n.groupStaff,
            _ => l10n.groupViewers,
          },
          count: people.length,
          icon: roleIcon(role),
          color: roleColor(context, role),
        ),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (i, member) in people.indexed) ...[
                if (i > 0) const Divider(indent: 72),
                Entrance(
                  index: index++,
                  child: _MemberRow(
                    member: member,
                    isMe: member.userId == me,
                    locked: plan?.isLocked(member.membershipId) ?? false,
                    onTap: () => context.push('/team/${member.membershipId}'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ];
    }

    final alone = team.members.length <= 1 && team.invites.isEmpty;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, 112),
      children: [
        if (manager && seats != null && seats.none)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.md),
            child: _BringYourTeam(
              onPressed: () => showSeatRefusal(context, workspace, seats.refusal),
              owner: workspace.role == TeamRole.owner,
            ),
          )
        else if (manager && alone)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.md),
            child: _FirstInvite(onPressed: () => startInvite(context, ref, workspace, team)),
          ),
        for (final role in TeamRole.all) ...group(role),
        if (team.invites.isNotEmpty) ...[
          GroupHeading(label: l10n.groupInvited, count: team.invites.length, icon: Icons.mark_email_unread_outlined),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (i, invite) in team.invites.indexed) ...[
                  if (i > 0) const Divider(indent: 72),
                  Entrance(index: index++, child: _InviteRow(workspace: workspace, invite: invite)),
                ],
              ],
            ),
          ),
        ],
        if (mine != null && TeamRole.canLeave(mine.role)) ...[
          const SizedBox(height: AppSpace.xl),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => leaveBusiness(context, ref, workspace, mine),
              icon: const Icon(Icons.logout_rounded),
              label: Text(l10n.leaveBusiness),
            ),
          ),
        ],
      ],
    );
  }
}

/// Asks, leaves, and goes home: the business is gone from this phone. What
/// it needs after the request is taken first, because the screen it was asked
/// from goes as the business does.
Future<void> leaveBusiness(BuildContext context, WidgetRef ref, Workspace workspace, TeamMember me) async {
  final l10n = context.l10n;
  if (!await confirm(context, l10n.leaveBusinessConfirm(workspace.name), action: l10n.leaveBusiness)) return;
  if (!context.mounted) return;
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final root = Navigator.of(context, rootNavigator: true).context;
  final repo = ref.read(teamRepositoryProvider);
  final error = await repo.leave(workspace.id, me);
  if (error != null) {
    messenger.showSnackBar(SnackBar(content: Text(teamErrorText(l10n, error))));
    return;
  }
  router.go('/');
  if (root.mounted) showEventBurst(root, AppEvent.deleted, label: l10n.leftBusiness(workspace.name));
  await repo.moveOut();
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.isMe, required this.locked, required this.onTap});

  final TeamMember member;
  final bool isMe;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
        child: Row(
          children: [
            MemberAvatar(seed: member.email, initials: member.initials, hero: 'member-${member.membershipId}'),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(member.displayName, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      if (isMe) const YouTag(),
                    ],
                  ),
                  if (member.name.isNotEmpty)
                    Text(member.email, style: text.bodySmall?.copyWith(color: context.colors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (locked) const Padding(padding: EdgeInsets.only(right: AppSpace.sm), child: LockedTag()),
            RoleChip(role: member.role, dense: true),
            Icon(Icons.chevron_right_rounded, color: context.colors.muted),
          ],
        ),
      ),
    );
  }
}

class _InviteRow extends ConsumerWidget {
  const _InviteRow({required this.workspace, required this.invite});

  final Workspace workspace;
  final TeamInvite invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final days = invite.expiresAt.difference(DateTime.now()).inHours / 24;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.sm, AppSpace.md),
      child: Row(
        children: [
          MemberAvatar(seed: invite.contact, initials: '', pending: true),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invite.contact, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  '${roleLabel(context, invite.role)} · ${l10n.inviteExpiresIn(days.ceil().clamp(0, 99))}',
                  style: text.bodySmall?.copyWith(color: context.colors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.inviteCancel,
            icon: Icon(Icons.close_rounded, color: context.colors.muted),
            onPressed: () async {
              if (!await confirm(context, l10n.inviteCancelConfirm(invite.contact), action: l10n.inviteCancel)) return;
              final error = await ref.read(teamRepositoryProvider).cancelInvite(workspace.id, invite.id);
              if (!context.mounted) return;
              if (error == null) {
                showEventBurst(context, AppEvent.deleted);
              } else {
                context.showMessage(teamErrorText(l10n, error));
              }
            },
          ),
        ],
      ),
    );
  }
}

/// No seats on this plan: what the Business plan would bring, with the way there.
class _BringYourTeam extends StatelessWidget {
  const _BringYourTeam({required this.onPressed, required this.owner});

  final VoidCallback onPressed;
  final bool owner;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Entrance(
      child: Container(
        padding: const EdgeInsets.all(AppSpace.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.gold.withValues(alpha: 0.22), colors.gold.withValues(alpha: 0.06)],
          ),
          border: Border.all(color: colors.gold.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Faces(),
            const SizedBox(height: AppSpace.lg),
            Text(l10n.teamUpsellTitle, style: text.titleLarge),
            const SizedBox(height: AppSpace.sm),
            Text(owner ? l10n.teamUpsellBody : l10n.seatsFullAskOwner, style: text.bodyMedium),
            if (owner) ...[
              const SizedBox(height: AppSpace.lg),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: colors.gold, foregroundColor: colors.onGold),
                onPressed: onPressed,
                icon: const Icon(Icons.workspace_premium_rounded),
                label: Text(l10n.planSeePlans),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Three faces leaning in: a team, before there is one.
class _Faces extends StatelessWidget {
  const _Faces();

  @override
  Widget build(BuildContext context) {
    const people = [('A', 'a@x'), ('S', 's@y'), ('M', 'm@z')];
    return SizedBox(
      height: 48,
      width: 48 + 2 * 30,
      child: Stack(
        children: [
          for (final (i, (initial, seed)) in people.indexed)
            Positioned(
              left: i * 30.0,
              child: Entrance(
                index: i + 1,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.sheet),
                  child: MemberAvatar(seed: seed, initials: initial, size: 44),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Only the owner so far: a nudge to bring someone in.
class _FirstInvite extends StatelessWidget {
  const _FirstInvite({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Entrance(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            children: [
              const _Faces(),
              const SizedBox(height: AppSpace.lg),
              Text(l10n.teamEmptyTitle, style: text.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpace.xs),
              Text(l10n.teamEmptyBody, style: text.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpace.lg),
              FilledButton.tonalIcon(
                onPressed: onPressed,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(l10n.inviteSomeone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The seats in use on the Plan page, for the owner of the business on screen.
class SeatUsageRow extends ConsumerWidget {
  const SeatUsageRow({super.key, required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final seats = ref.watch(seatsProvider(workspace.id)).value;
    if (seats == null || !seats.enforced) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${featureLabel(l10n, F.teamSeats)} · ${workspace.name}', style: text.bodyMedium, overflow: TextOverflow.ellipsis),
              ),
              Text(
                seats.limited ? l10n.planCountOf(seats.used, seats.limit!) : '${seats.used} · ${l10n.planUnlimited}',
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontFeatures: tabularFigures),
              ),
            ],
          ),
          if (seats.limited && seats.limit! > 0) ...[const SizedBox(height: 2), LimitBar(value: seats.share, height: 8)],
        ],
      ),
    );
  }
}
