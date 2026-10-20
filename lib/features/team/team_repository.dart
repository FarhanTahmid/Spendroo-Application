import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import 'team_roles.dart';

DateTime _time(Object? value) => (value is String ? DateTime.tryParse(value) : null) ?? DateTime.now();

/// Someone in the business. [membershipId] names them in the team endpoints,
/// [userId] in cashbook grants.
class TeamMember {
  const TeamMember({
    required this.membershipId,
    required this.userId,
    required this.email,
    required this.role,
    this.name = '',
    this.joinedAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        membershipId: json['id'] as String,
        userId: json['user'] as String,
        email: json['user_email'] as String? ?? '',
        name: (json['user_name'] as String? ?? '').trim(),
        role: json['role'] as String? ?? TeamRole.viewer,
        joinedAt: _time(json['created_at']),
      );

  final String membershipId;
  final String userId;
  final String email;
  final String name;
  final String role;
  final DateTime? joinedAt;

  String get displayName => name.isEmpty ? email : name;

  /// Up to two letters: of the name's first and last words, else the email's first.
  String get initials => initialsOf(displayName);
}

String initialsOf(String text) {
  final words = text.split(RegExp(r'[\s@.]+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '?';
  if (words.length == 1 || text.contains('@')) return words.first.characters.first.toUpperCase();
  return (words.first.characters.first + words.last.characters.first).toUpperCase();
}

/// An invitation not yet taken up. It holds a seat until it is.
class TeamInvite {
  const TeamInvite({
    required this.id,
    required this.role,
    required this.expiresAt,
    this.email = '',
    this.phone = '',
    this.invitedBy = '',
  });

  factory TeamInvite.fromJson(Map<String, dynamic> json) => TeamInvite(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? TeamRole.staff,
        invitedBy: json['invited_by_email'] as String? ?? '',
        expiresAt: _time(json['expires_at']),
      );

  final String id;
  final String email;
  final String phone;
  final String role;
  final String invitedBy;
  final DateTime expiresAt;

  /// Where it went: the email, or the phone number.
  String get contact => email.isNotEmpty ? email : phone;
}

/// A new invitation with its code, which the server shows this once.
class NewInvite {
  const NewInvite({required this.invite, required this.code, required this.emailed});

  final TeamInvite invite;
  final String code;
  final bool emailed;
}

/// The business's team seats on its owner's plan. Everyone but the owner takes
/// one, and so does each invitation waiting.
class Seats {
  const Seats({required this.used, this.limit, this.unlimited = false, this.enforced = true, this.upgradeTo});

  factory Seats.fromJson(Map<String, dynamic> json) => Seats(
        limit: (json['limit'] as num?)?.toInt(),
        unlimited: json['unlimited'] as bool? ?? false,
        used: (json['used'] as num?)?.toInt() ?? 0,
        enforced: json['enforced'] as bool? ?? true,
        upgradeTo: json['upgrade_to'] as String?,
      );

  final int? limit;
  final bool unlimited;
  final int used;
  final bool enforced;
  final String? upgradeTo;

  /// Whether a number holds anyone back: not when unlimited or not enforced.
  bool get limited => enforced && !unlimited && limit != null;

  bool get full => limited && used >= limit!;

  /// No seats at all on this plan.
  bool get none => limited && limit == 0;

  double get share => !limited || limit == 0 ? 0 : used / limit!;

  /// What the server would say to one more invitation.
  PlanLimitException get refusal => PlanLimitException(F.teamSeats, limit: limit, current: used, upgradeTo: upgradeTo);
}

/// Everything the team screen shows, fetched together.
class Team {
  const Team({required this.members, this.invites = const [], this.seats});

  final List<TeamMember> members;

  /// Only the owner and admins see these.
  final List<TeamInvite> invites;

  /// Null when the server did not say.
  final Seats? seats;

  TeamMember? byId(String membershipId) => members.where((m) => m.membershipId == membershipId).firstOrNull;
  TeamMember? byUser(String? userId) => members.where((m) => m.userId == userId).firstOrNull;
}

/// What a code invites to, before it is used.
class InvitePreview {
  const InvitePreview({
    required this.workspaceId,
    required this.workspaceName,
    required this.role,
    required this.expiresAt,
    this.invitedBy = '',
  });

  factory InvitePreview.fromJson(Map<String, dynamic> json) => InvitePreview(
        workspaceId: json['workspace_id'] as String,
        workspaceName: json['workspace_name'] as String? ?? '',
        invitedBy: json['invited_by'] as String? ?? '',
        role: json['role'] as String? ?? TeamRole.staff,
        expiresAt: _time(json['expires_at']),
      );

  final String workspaceId;
  final String workspaceName;
  final String invitedBy;
  final String role;
  final DateTime expiresAt;
}

/// Why a team change did not go through. The server's own codes come through
/// as they are (`already_member`, `expired`, `used`, `invalid`,
/// `wrong_account`, …); these are the app's.
abstract final class TeamError {
  static const offline = 'offline';
  static const refused = 'refused';
  static const notFound = 'not_found';
  static const badInput = 'bad_input';
  static const tooMany = 'too_many';
  static const failed = 'failed';

  /// The business has no seat left on its owner's plan.
  static const noSeats = 'no_seats';

  /// The one taking over the business has no room for it on their plan.
  static const noRoom = 'no_room';
}

/// Codes are ten letters and digits; people type them with spaces, dashes
/// and lower case, which the server ignores too.
String normalizeInviteCode(String code) => code.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

/// "ABCDE-FGH23": easier to read out and type back.
String formatInviteCode(String code) {
  final clean = normalizeInviteCode(code);
  return clean.length <= 5 ? clean : '${clean.substring(0, 5)}-${clean.substring(5)}';
}

/// The team lives on the server and is changed there, so all of this needs a
/// connection. Reads return null offline; writes return null when done, else
/// a [TeamError] or the server's code. A plan refusal is thrown as a
/// PlanLimitException, for `guarded` to show.
class TeamRepository {
  TeamRepository(this.ref);

  final Ref ref;

  ApiClient get _api => ref.read(apiClientProvider);

  String _base(String workspaceId) => '/api/v1/workspaces/$workspaceId';

  /// Null when the server could not be reached or would not say.
  Future<Team?> fetch(String workspaceId, {required bool manager}) async {
    try {
      final responses = await Future.wait([
        _api.get('${_base(workspaceId)}/members/'),
        _api.get('${_base(workspaceId)}/seats/'),
        if (manager) _api.get('${_base(workspaceId)}/invitations/'),
      ]);
      final members = responses[0];
      if (!members.ok) return null;
      final seats = responses[1];
      final invites = manager ? responses[2] : null;
      List<Map<String, dynamic>> rows(ApiResponse response) =>
          [for (final row in response.body as List) (row as Map).cast<String, dynamic>()];
      final list = [for (final row in rows(members)) TeamMember.fromJson(row)]
        ..sort((a, b) {
          final rank = TeamRole.all.indexOf(a.role).compareTo(TeamRole.all.indexOf(b.role));
          return rank != 0 ? rank : a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
        });
      return Team(
        members: list,
        invites: invites != null && invites.ok ? [for (final row in rows(invites)) TeamInvite.fromJson(row)] : const [],
        seats: seats.ok && seats.body is Map ? Seats.fromJson(seats.json) : null,
      );
    } on OfflineException {
      return null;
    }
  }

  /// The seats alone, for a meter outside the team screen.
  Future<Seats?> seats(String workspaceId) async {
    try {
      final response = await _api.get('${_base(workspaceId)}/seats/');
      return response.ok && response.body is Map ? Seats.fromJson(response.json) : null;
    } on OfflineException {
      return null;
    }
  }

  /// Invites someone by [email] or [phone] (one of them) as [role].
  Future<(NewInvite?, String?)> invite(String workspaceId, {required String role, String? email, String? phone}) async {
    final (response, error) = await _write(() => _api.post('${_base(workspaceId)}/invitations/', {
          'role': role,
          'email': ?email,
          'phone': ?phone,
        }));
    if (response == null) return (null, error);
    _changed(workspaceId);
    final json = response.json;
    return (NewInvite(invite: TeamInvite.fromJson(json), code: json['code'] as String, emailed: json['emailed'] as bool? ?? false), null);
  }

  Future<String?> cancelInvite(String workspaceId, String inviteId) =>
      _done(workspaceId, () => _api.delete('${_base(workspaceId)}/invitations/$inviteId/'));

  /// Moving someone off staff takes away their cashbook grants, so the phone syncs after.
  Future<String?> changeRole(String workspaceId, TeamMember member, String role) =>
      _done(workspaceId, () => _api.patch('${_base(workspaceId)}/members/${member.membershipId}/', {'role': role}), sync: true);

  Future<String?> remove(String workspaceId, TeamMember member) =>
      _done(workspaceId, () => _api.delete('${_base(workspaceId)}/members/${member.membershipId}/'), sync: true);

  /// The signed-in user leaves. Call [moveOut] once the screen is off the
  /// business, so nothing on it is left showing a business that is gone.
  Future<String?> leave(String workspaceId, TeamMember me) =>
      _done(workspaceId, () => _api.delete('${_base(workspaceId)}/members/${me.membershipId}/'));

  /// Back to the personal workspace; the sync then drops the business left.
  Future<void> moveOut() async {
    await ref.read(currentWorkspaceIdProvider.notifier).select(null);
    await ref.read(syncControllerProvider.notifier).syncNow();
  }

  /// Gives the business to [admin]; the owner stays on as an admin.
  Future<String?> handOver(String workspaceId, TeamMember admin) => _done(
        workspaceId,
        () => _api.post('${_base(workspaceId)}/transfer-ownership/', {'membership_id': admin.membershipId}),
        sync: true,
      );

  Future<(InvitePreview?, String?)> preview(String code) async {
    final (response, error) = await _write(
      () => _api.get('/api/v1/workspaces/invitations/preview/', query: {'code': normalizeInviteCode(code)}),
    );
    return (response == null ? null : InvitePreview.fromJson(response.json), error);
  }

  /// Joins the business the code invites to and switches to it. Returns its id.
  Future<(String?, String?)> accept(String code) async {
    final (response, error) =
        await _write(() => _api.post('/api/v1/workspaces/invitations/accept/', {'code': normalizeInviteCode(code)}));
    if (response == null) return (null, error);
    final id = response.json['id'] as String;
    await ref.read(syncControllerProvider.notifier).syncNow();
    await ref.read(currentWorkspaceIdProvider.notifier).select(id);
    return (id, null);
  }

  Future<String?> _done(String workspaceId, Future<ApiResponse> Function() request, {bool sync = false}) async {
    final (response, error) = await _write(request);
    if (response == null) return error;
    _changed(workspaceId);
    if (sync) await ref.read(syncControllerProvider.notifier).syncNow();
    return null;
  }

  void _changed(String workspaceId) {
    ref.invalidate(teamProvider(workspaceId));
    ref.invalidate(seatsProvider(workspaceId));
  }

  /// The response when it went through, else why not. A 403 here is "not
  /// yours to do", never an ended session: these routes are not sync's.
  Future<(ApiResponse?, String?)> _write(Future<ApiResponse> Function() request) async {
    try {
      final response = await request();
      if (response.ok) return (response, null);
      if (response.statusCode == 402 && response.body is Map) {
        ref.read(entitlementsProvider.notifier).refresh();
        throw PlanLimitException.fromJson(response.body as Map);
      }
      return (null, errorOf(response));
    } on OfflineException {
      return (null, TeamError.offline);
    }
  }
}

/// The server's code for a refusal, or the app's word for its status.
String errorOf(ApiResponse response) {
  final body = response.body;
  if (body is Map) {
    final code = body['code'];
    // DRF may wrap a single value in a list
    final value = code is List && code.isNotEmpty ? code.first : code;
    if (value is String && value.isNotEmpty) return value;
  }
  return switch (response.statusCode) {
    400 => TeamError.badInput,
    403 => TeamError.refused,
    404 => TeamError.notFound,
    429 => TeamError.tooMany,
    _ => TeamError.failed,
  };
}

final teamRepositoryProvider = Provider<TeamRepository>(TeamRepository.new);

/// The team of a business, fresh from the server. Null when it could not be
/// reached. Fetched again when the user's role there changes.
final teamProvider = FutureProvider.autoDispose.family<Team?, String>((ref, workspaceId) {
  final role = ref.watch(workspacesProvider.select(
    (value) => value.value?.where((w) => w.id == workspaceId).firstOrNull?.role,
  ));
  _watchOwnSeats(ref);
  return ref.read(teamRepositoryProvider).fetch(workspaceId, manager: TeamRole.isManager(role ?? ''));
});

/// An owner who upgrades or downgrades changes their businesses' seats.
void _watchOwnSeats(Ref ref) =>
    ref.watch(entitlementsProvider.select((value) => (value.value?.plan.code, value.value?.limitOf(F.teamSeats))));

final seatsProvider = FutureProvider.autoDispose.family<Seats?, String>(
  (ref, workspaceId) {
    _watchOwnSeats(ref);
    return ref.read(teamRepositoryProvider).seats(workspaceId);
  },
);

/// One person's cashbook grants in a business, from the phone's copy. The
/// owner and admins receive everyone's grants by sync.
final memberGrantsProvider = StreamProvider.autoDispose.family<Map<String, CashbookMember>, (String, String)>((ref, key) {
  final (workspaceId, userId) = key;
  final db = ref.watch(databaseProvider);
  return (db.select(db.cashbookMembers)
        ..where((m) => m.workspaceId.equals(workspaceId) & m.memberId.equals(userId) & m.deletedAt.isNull())
        ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
      .watch()
      .map((rows) => {for (final row in rows) row.cashbookId: row});
});
