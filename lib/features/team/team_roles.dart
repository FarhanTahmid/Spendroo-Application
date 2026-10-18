import 'package:flutter/material.dart';

import '../../core/ui.dart';
import '../../l10n/app_localizations.dart';

/// The roles in a business, as the server spells them, and who may do what
/// to whom. The server decides; these keep the app from offering what it
/// would refuse (workspaces/members.py and invitations.py in the API).
abstract final class TeamRole {
  static const owner = 'owner';
  static const admin = 'admin';
  static const staff = 'staff';
  static const viewer = 'viewer';

  /// Highest first, the order the team is listed in.
  static const all = [owner, admin, staff, viewer];

  static bool isManager(String role) => role == owner || role == admin;

  /// Roles [me] may give someone, by invitation or by a change: only the
  /// owner makes admins, and nobody is made owner but by a hand-over.
  static List<String> assignable(String me) => switch (me) {
        owner => const [admin, staff, viewer],
        admin => const [staff, viewer],
        _ => const [],
      };

  /// Whether [me] may change [target]'s role or take them out. Nobody touches
  /// themselves or the owner, and an admin leaves other admins alone.
  static bool canManage(String me, String target, {required bool isSelf}) {
    if (isSelf || target == owner) return false;
    return me == owner || (me == admin && target != admin);
  }

  /// Ownership only goes to an admin, and only the owner gives it.
  static bool canHandOver(String me, String target) => me == owner && target == admin;

  /// The owner can't leave; they hand the business over first.
  static bool canLeave(String me) => me != owner;
}

String roleLabel(BuildContext context, String role) {
  final l10n = context.l10n;
  return switch (role) {
    TeamRole.owner => l10n.roleOwner,
    TeamRole.admin => l10n.roleAdmin,
    TeamRole.staff => l10n.roleStaff,
    _ => l10n.roleViewer,
  };
}

/// What the role will let the person joining do, said to them.
String joinRoleHint(BuildContext context, String role) {
  final l10n = context.l10n;
  return switch (role) {
    TeamRole.admin => l10n.joinRoleAdminHint,
    TeamRole.staff => l10n.joinRoleStaffHint,
    _ => l10n.joinRoleViewerHint,
  };
}

/// What the role lets someone do, in one line.
String roleHint(BuildContext context, String role) {
  final l10n = context.l10n;
  return switch (role) {
    TeamRole.owner => l10n.roleOwnerHint,
    TeamRole.admin => l10n.roleAdminHint,
    TeamRole.staff => l10n.roleStaffHint,
    _ => l10n.roleViewerHint,
  };
}

IconData roleIcon(String role) => switch (role) {
      TeamRole.owner => Icons.workspace_premium_rounded,
      TeamRole.admin => Icons.shield_outlined,
      TeamRole.staff => Icons.badge_outlined,
      _ => Icons.visibility_outlined,
    };

/// Each role keeps one colour wherever it shows: gold for the owner, then
/// blue, green and grey down the ranks.
Color roleColor(BuildContext context, String role) => switch (role) {
      TeamRole.owner => const Color(0xFFB7791F),
      TeamRole.admin => Theme.of(context).colorScheme.primary,
      TeamRole.staff => context.colors.moneyIn,
      _ => context.colors.muted,
    };

/// Why a team change or a code did not work, from the code the repository gave.
String teamErrorText(AppLocalizations l10n, String code) => switch (code) {
      'offline' => l10n.needsConnection,
      'already_member' => l10n.teamErrorAlreadyMember,
      'invalid' || 'not_found' => l10n.teamErrorInvalidCode,
      'expired' => l10n.teamErrorExpired,
      'used' => l10n.teamErrorUsed,
      'wrong_account' => l10n.teamErrorWrongAccount,
      'no_seats' => l10n.teamErrorNoSeats,
      'too_many' => l10n.teamErrorTooMany,
      'bad_input' => l10n.teamErrorBadInput,
      'refused' || 'owner' || 'owner_role' || 'not_admin' => l10n.teamErrorRefused,
      _ => l10n.teamErrorFailed,
    };
