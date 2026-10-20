import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';
import 'package:spendroo/features/profile/profile_repository.dart';
import 'package:spendroo/features/team/join_page.dart';
import 'package:spendroo/features/team/member_page.dart';
import 'package:spendroo/features/team/team_page.dart';
import 'package:spendroo/features/team/team_repository.dart';
import 'package:spendroo/features/team/team_roles.dart';
import 'package:spendroo/l10n/app_localizations.dart';

import 'personal_screens_test.dart' show ScreenHarness;

const shopId = '00000000-0000-0000-0000-0000000000aa';

Workspace shop(String role) =>
    Workspace(id: shopId, name: 'Shop', kind: 'business', defaultCurrency: 'BDT', isDemo: false, role: role);

/// The signed-in user is Alice, unless a test says otherwise.
class FixedProfile extends ProfileController {
  FixedProfile(this.userId);

  final String userId;

  @override
  Future<Profile?> build() async => Profile(id: userId, email: '$userId@example.com', username: userId);
}

Map<String, Object?> member(String id, String user, String role, {String name = ''}) =>
    {'id': id, 'user': user, 'user_email': '$user@example.com', 'user_name': name, 'role': role, 'created_at': '2026-10-01T00:00:00Z'};

/// The team endpoints with a team that answers back: Alice owns Shop, Bob is
/// an admin, Carol staff and Dan a viewer; one phone invitation waits.
class FakeTeam {
  final requests = <http.Request>[];
  var members = [
    member('m-alice', 'alice', 'owner', name: 'Alice Rahman'),
    member('m-bob', 'bob', 'admin'),
    member('m-carol', 'carol', 'staff', name: 'Carol Khan'),
    member('m-dan', 'dan', 'viewer'),
  ];
  var invites = <Map<String, Object?>>[
    {'id': 'i-1', 'email': '', 'phone': '+8801711111111', 'role': 'staff', 'invited_by_email': 'alice@example.com', 'expires_at': DateTime.now().add(const Duration(days: 5)).toUtc().toIso8601String()},
  ];
  Map<String, Object?> seats = {'limit': 5, 'unlimited': false, 'used': 4, 'members': 3, 'pending': 1, 'enforced': true, 'upgrade_to': null};

  /// Replaces the answer to the next write.
  Future<http.Response> Function(http.Request)? write;

  /// Answers to the join code endpoints.
  Future<http.Response> Function(http.Request)? code;

  /// Every request fails as if there were no network.
  var offline = false;

  Future<http.Response> handle(http.Request request) async {
    if (offline) throw http.ClientException('no network');
    requests.add(request);
    final path = request.url.path;
    if (path.contains('/invitations/preview/') || path.contains('/invitations/accept/')) return code!(request);
    if (request.method != 'GET') {
      final answer = write;
      if (answer != null) return answer(request);
    }
    return switch ((request.method, path)) {
      ('GET', '/api/v1/workspaces/$shopId/members/') => http.Response(jsonEncode(members), 200),
      ('GET', '/api/v1/workspaces/$shopId/seats/') => http.Response(jsonEncode(seats), 200),
      ('GET', '/api/v1/workspaces/$shopId/invitations/') => http.Response(jsonEncode(invites), 200),
      ('POST', '/api/v1/workspaces/$shopId/invitations/') => http.Response(
          jsonEncode({
            'id': 'i-2',
            'email': (jsonDecode(request.body) as Map)['email'] ?? '',
            'phone': (jsonDecode(request.body) as Map)['phone'] ?? '',
            'role': (jsonDecode(request.body) as Map)['role'],
            'status': 'pending',
            'expires_at': DateTime.now().add(const Duration(days: 7)).toUtc().toIso8601String(),
            'code': 'ABCDEFGH23',
            'emailed': (jsonDecode(request.body) as Map).containsKey('email'),
          }),
          201,
        ),
      ('PATCH', _) => http.Response('{}', 200),
      ('DELETE', _) => http.Response('', 204),
      ('POST', _) => http.Response('{}', 200),
      _ => http.Response('{}', 404),
    };
  }

  Iterable<http.Request> writes() => requests.where((r) => r.method != 'GET');
}

class TeamHarness {
  TeamHarness(this.tester, {String role = 'owner', String me = 'alice', FakeTeam? server}) : server = server ?? FakeTeam() {
    h = ScreenHarness(tester, overrides: [
      apiClientProvider.overrideWith(
        (ref) => ApiClient(baseUrl: 'http://test', tokenStore: MemoryTokenStore(), httpClient: MockClient(this.server.handle)),
      ),
      profileProvider.overrideWith(() => FixedProfile(me)),
    ]);
    space = shop(role);
  }

  final WidgetTester tester;
  final FakeTeam server;
  late final ScreenHarness h;
  late final Workspace space;

  Future<void> settle() => h.settle();

  Future<void> open(String location) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await h.db.into(h.db.workspaces).insert(space);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('home'))),
        GoRoute(
          path: '/team',
          builder: (_, _) => const TeamPage(),
          routes: [GoRoute(path: ':id', builder: (_, state) => MemberPage(membershipId: state.pathParameters['id']!))],
        ),
        GoRoute(path: '/join', builder: (_, _) => const JoinPage()),
      ],
    );
    await tester.pumpWidget(UncontrolledProviderScope(
      container: h.container,
      child: MaterialApp.router(
        routerConfig: router,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ));
    await settle();
  }

  Future<void> tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await settle();
  }

  Finder inSheet(Finder finder) => find.descendant(of: find.byType(BottomSheet), matching: finder);

  Future<void> stop() => h.stop();
}

void main() {
  group('roles', () {
    test('only the owner makes admins; nobody is made owner', () {
      expect(TeamRole.assignable('owner'), ['admin', 'staff', 'viewer']);
      expect(TeamRole.assignable('admin'), ['staff', 'viewer']);
      expect(TeamRole.assignable('staff'), isEmpty);
      expect(TeamRole.assignable('viewer'), isEmpty);
    });

    test('who may change whom', () {
      expect(TeamRole.canManage('owner', 'admin', isSelf: false), isTrue);
      expect(TeamRole.canManage('owner', 'owner', isSelf: true), isFalse);
      expect(TeamRole.canManage('admin', 'staff', isSelf: false), isTrue);
      expect(TeamRole.canManage('admin', 'admin', isSelf: false), isFalse);
      expect(TeamRole.canManage('admin', 'owner', isSelf: false), isFalse);
      expect(TeamRole.canManage('admin', 'admin', isSelf: true), isFalse);
      expect(TeamRole.canManage('staff', 'viewer', isSelf: false), isFalse);
      expect(TeamRole.canHandOver('owner', 'admin'), isTrue);
      expect(TeamRole.canHandOver('owner', 'staff'), isFalse);
      expect(TeamRole.canHandOver('admin', 'admin'), isFalse);
      expect(TeamRole.canLeave('owner'), isFalse);
      expect(TeamRole.canLeave('staff'), isTrue);
    });
  });

  group('model', () {
    test('seats: full, none, and nothing held back when unlimited or not enforced', () {
      const some = Seats(limit: 5, used: 4);
      expect((some.full, some.none, some.share), (false, false, 0.8));
      expect(const Seats(limit: 5, used: 5).full, isTrue);
      expect(const Seats(limit: 0, used: 0).none, isTrue);
      expect(const Seats(limit: 0, used: 0).full, isTrue);
      expect(const Seats(used: 9, unlimited: true).full, isFalse);
      expect(const Seats(limit: 1, used: 3, enforced: false).full, isFalse);
      final refusal = const Seats(limit: 5, used: 5, upgradeTo: 'business').refusal;
      expect((refusal.feature, refusal.limit, refusal.current, refusal.upgradeTo), (F.teamSeats, 5, 5, 'business'));
    });

    test('codes are read forgivingly and shown in two halves', () {
      expect(normalizeInviteCode(' abcde-fgh 23 '), 'ABCDEFGH23');
      expect(formatInviteCode('abcdefgh23'), 'ABCDE-FGH23');
      expect(formatInviteCode('abc'), 'ABC');
    });

    test('initials from a name, or the first letter of an email', () {
      expect(initialsOf('Carol Khan'), 'CK');
      expect(initialsOf('carol@example.com'), 'C');
      expect(initialsOf('Shop'), 'S');
      expect(initialsOf(''), '?');
    });

    test('errors: the server\'s code when it gives one, else the status', () {
      expect(errorOf(ApiResponse(400, {'code': 'expired', 'detail': 'x'})), 'expired');
      expect(errorOf(ApiResponse(400, {'code': ['used']})), 'used');
      expect(errorOf(ApiResponse(400, {'email': ['Enter a valid email address.']})), TeamError.badInput);
      expect(errorOf(ApiResponse(403, {'detail': 'no'})), TeamError.refused);
      expect(errorOf(ApiResponse(404, null)), TeamError.notFound);
      expect(errorOf(ApiResponse(429, null)), TeamError.tooMany);
      expect(errorOf(ApiResponse(500, null)), TeamError.failed);
    });
  });

  group('team page', () {
    testWidgets('the owner sees everyone by role, the seats, and the invitation waiting', (tester) async {
      final t = TeamHarness(tester);
      await t.open('/team');
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('4 people'), findsOneWidget);
      expect(find.text('4 of 5 seats used'), findsOneWidget);
      expect(find.text('1 seat left'), findsOneWidget);
      expect(find.text('Alice Rahman'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(find.text('Carol Khan'), findsOneWidget);
      expect(find.text('bob@example.com'), findsOneWidget);
      expect(find.text('ADMINS'), findsOneWidget);
      expect(find.text('INVITED'), findsOneWidget);
      expect(find.text('+8801711111111'), findsOneWidget);
      expect(find.text('Invite'), findsOneWidget);
      // The owner can't leave
      expect(find.text('Leave business'), findsNothing);
      await t.stop();
    });

    testWidgets('invites by email as a viewer and shows the code once', (tester) async {
      final t = TeamHarness(tester);
      await t.open('/team');
      await t.tap(find.text('Invite'));
      expect(t.inSheet(find.text('Invite to Shop')), findsOneWidget);
      expect(t.inSheet(find.text('This takes seat 5 of 5 until they join or the invitation ends.')), findsOneWidget);

      // Nothing is sent until the address looks like one
      await t.tap(t.inSheet(find.text('Send invitation')));
      expect(find.text('Enter their email.'), findsOneWidget);
      await tester.enterText(t.inSheet(find.byType(TextField)), 'erin@example');
      await t.tap(t.inSheet(find.text('Send invitation')));
      expect(find.text("That doesn’t look like an email address."), findsOneWidget);
      expect(t.server.writes(), isEmpty);

      await tester.enterText(t.inSheet(find.byType(TextField)), 'erin@example.com');
      await t.tap(t.inSheet(find.text('Viewer')));
      await t.tap(t.inSheet(find.text('Send invitation')));
      final sent = t.server.writes().single;
      expect(sent.url.path, '/api/v1/workspaces/$shopId/invitations/');
      expect(jsonDecode(sent.body), {'role': 'viewer', 'email': 'erin@example.com'});
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Invitation to Shop'), findsOneWidget);
      expect(find.textContaining('Sent to erin@example.com'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      await t.stop();
    });

    testWidgets('an admin may invite staff and viewers but not admins; a phone invite asks to share', (tester) async {
      final t = TeamHarness(tester, role: 'admin', me: 'bob');
      await t.open('/team');
      await t.tap(find.text('Invite'));
      expect(t.inSheet(find.text('Admin')), findsNothing);
      expect(t.inSheet(find.text('Staff')), findsOneWidget);
      await t.tap(t.inSheet(find.text('Phone')));
      await tester.enterText(t.inSheet(find.byType(TextField)), '+880 1712-345678');
      await t.tap(t.inSheet(find.text('Create code')));
      expect(jsonDecode(t.server.writes().single.body), {'role': 'staff', 'phone': '+880 1712-345678'});
      expect(find.text('Send this code to them now. It is shown only once.'), findsOneWidget);
      await t.stop();
    });

    testWidgets('with every seat taken the owner is shown the plans before any form', (tester) async {
      final t = TeamHarness(tester);
      t.server.seats = {...t.server.seats, 'used': 5, 'upgrade_to': 'business'};
      await t.open('/team');
      expect(find.text('All seats taken'), findsOneWidget);
      await t.tap(find.text('Invite'));
      expect(find.text('Invite to Shop'), findsNothing);
      expect(find.text('Get more from Spendroo'), findsOneWidget);
      await t.stop();
    });

    testWidgets('with every seat taken an admin is told to ask the owner', (tester) async {
      final t = TeamHarness(tester, role: 'admin', me: 'bob');
      t.server.seats = {...t.server.seats, 'used': 5};
      await t.open('/team');
      await t.tap(find.text('Invite'));
      expect(find.text('Get more from Spendroo'), findsNothing);
      expect(find.textContaining('Ask the owner'), findsOneWidget);
      await t.stop();
    });

    testWidgets('the server\'s seat refusal closes the form and shows the plans', (tester) async {
      final t = TeamHarness(tester);
      t.server.write = (_) async => http.Response(
            jsonEncode({'code': 'plan_limit', 'feature': 'team.seats', 'reason': 'limit', 'limit': 5, 'current': 5, 'upgrade_to': null}),
            402,
          );
      await t.open('/team');
      await t.tap(find.text('Invite'));
      await tester.enterText(t.inSheet(find.byType(TextField)), 'erin@example.com');
      await t.tap(t.inSheet(find.text('Send invitation')));
      expect(find.text('Invite to Shop'), findsNothing);
      expect(find.text('Get more from Spendroo'), findsOneWidget);
      await t.stop();
    });

    testWidgets('a plan without seats offers the Business plan instead of an Invite button', (tester) async {
      final t = TeamHarness(tester);
      t.server
        ..members = [member('m-alice', 'alice', 'owner')]
        ..invites = []
        ..seats = {'limit': 0, 'unlimited': false, 'used': 0, 'members': 0, 'pending': 0, 'enforced': true, 'upgrade_to': 'business'};
      await t.open('/team');
      expect(find.text('Bring your team'), findsOneWidget);
      expect(find.text('No team seats on this plan'), findsOneWidget);
      expect(find.text('All seats taken'), findsNothing);
      expect(find.text('Invite'), findsNothing);
      await t.tap(find.text('See plans'));
      expect(find.text('Get more from Spendroo'), findsOneWidget);
      await t.stop();
    });

    testWidgets('the member list\'s role wins over a stale copy on the phone', (tester) async {
      // The phone still thinks Alice is staff; the server's list says she owns Shop
      final t = TeamHarness(tester, role: 'staff');
      await t.open('/team');
      expect(find.text('Invite'), findsOneWidget);
      expect(find.text('Leave business'), findsNothing);
      await t.stop();
    });

    testWidgets('cancels an invitation that is waiting', (tester) async {
      final t = TeamHarness(tester);
      await t.open('/team');
      await t.tap(find.byTooltip('Withdraw invitation'));
      await t.tap(t.inSheet(find.text('Withdraw invitation')));
      expect(t.server.writes().single.method, 'DELETE');
      expect(t.server.writes().single.url.path, '/api/v1/workspaces/$shopId/invitations/i-1/');
      await t.stop();
    });

    testWidgets('staff see the team without invitations and can leave', (tester) async {
      final t = TeamHarness(tester, role: 'staff', me: 'carol');
      // Leaving falls back to the personal workspace, which takes the team screen's business away
      await t.h.run(() => t.h.db.into(t.h.db.workspaces).insert(
            const Workspace(id: 'personal', name: 'Personal', kind: 'personal', defaultCurrency: 'BDT', isDemo: false, role: 'owner'),
          ));
      await t.h.run(() => t.h.container.read(currentWorkspaceIdProvider.notifier).select(shopId));
      // Carol is staff on the server too
      t.server.members = [for (final m in t.server.members) m['user'] == 'alice' ? {...m, 'role': 'owner'} : m];
      await t.open('/team');
      expect(t.server.requests.where((r) => r.url.path.endsWith('/invitations/')), isEmpty);
      expect(find.text('Invite'), findsNothing);
      expect(find.text('INVITED'), findsNothing);
      await t.tap(find.text('Leave business'));
      await t.tap(t.inSheet(find.text('Leave business')));
      expect(t.server.writes().single.method, 'DELETE');
      expect(t.server.writes().single.url.path, '/api/v1/workspaces/$shopId/members/m-carol/');
      expect(find.text('home'), findsOneWidget);
      expect(t.h.container.read(currentWorkspaceProvider)?.id, 'personal');
      await t.stop();
    });

    testWidgets('offline: says so and tries again', (tester) async {
      final t = TeamHarness(tester);
      t.server.offline = true;
      await t.open('/team');
      expect(find.text('This needs an internet connection. Try again when you are online.'), findsOneWidget);
      t.server.offline = false;
      await t.tap(find.text('Retry'));
      expect(find.text('Alice Rahman'), findsOneWidget);
      await t.stop();
    });
  });

  group('member page', () {
    Future<void> grant(TeamHarness t, String bookId, String role) => t.h.run(() => t.h.db.into(t.h.db.cashbookMembers).insert(
          CashbookMembersCompanion.insert(
            id: 'grant-$bookId',
            workspaceId: shopId,
            createdAt: '2026-10-01T00:00:00Z',
            updatedAt: '2026-10-01T00:00:00Z',
            cashbookId: bookId,
            memberId: 'carol',
            role: role,
            deletedAt: const Value(null),
          ),
        ));

    testWidgets('a staff member: their books, a role change that warns, and removal', (tester) async {
      final t = TeamHarness(tester);
      final books = CashbookRepository(t.h.db, t.h.store);
      final till = await t.h.run(() => books.createCashbook(shopId, 'Till', 'BDT'));
      await t.h.run(() => books.createCashbook(shopId, 'Safe', 'BDT'));
      await grant(t, till, 'contributor');
      await t.open('/team/m-carol');

      expect(find.text('Carol Khan'), findsWidgets);
      expect(find.text('Cashbook access'), findsOneWidget);
      expect(find.text('1 of 2 open'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('No access'), findsOneWidget);
      // The owner can give any role but owner
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Make owner'), findsNothing);

      // Opening a book to them
      await t.tap(find.text('Safe'));
      await t.tap(t.inSheet(find.text('View')));
      final granted = t.server.writes().last;
      expect(granted.url.path, endsWith('/add_member/'));
      expect(jsonDecode(granted.body), {'member': 'carol', 'role': 'viewer'});

      // Off staff, the grants go: asked first
      await t.tap(find.text('Viewer'));
      expect(find.textContaining('Their access to single cashbooks will be removed'), findsOneWidget);
      await t.tap(t.inSheet(find.text('Change')));
      final changed = t.server.writes().last;
      expect((changed.method, changed.url.path), ('PATCH', '/api/v1/workspaces/$shopId/members/m-carol/'));
      expect(jsonDecode(changed.body), {'role': 'viewer'});

      await t.tap(find.text('Remove from business'));
      await t.tap(t.inSheet(find.text('Remove from business')));
      final removed = t.server.writes().last;
      expect((removed.method, removed.url.path), ('DELETE', '/api/v1/workspaces/$shopId/members/m-carol/'));
      await t.stop();
    });

    testWidgets('the owner hands the business to an admin after typing its name', (tester) async {
      final t = TeamHarness(tester);
      await t.open('/team/m-bob');
      await t.tap(find.text('Make owner'));
      final button = find.widgetWithText(FilledButton, 'Make owner');
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.enterText(t.inSheet(find.byType(TextField)), 'shop ');
      await t.settle();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      await t.tap(button);
      final handed = t.server.writes().single;
      expect(handed.url.path, '/api/v1/workspaces/$shopId/transfer-ownership/');
      expect(jsonDecode(handed.body), {'membership_id': 'm-bob'});
      await t.stop();
    });

    testWidgets('a hand-over the new owner\'s plan has no room for is explained, not sold', (tester) async {
      final t = TeamHarness(tester);
      t.server.write = (_) async => http.Response(
            jsonEncode({'code': 'plan_limit', 'feature': 'team.seats', 'reason': 'limit', 'limit': 0, 'current': 3, 'upgrade_to': 'business'}),
            402,
          );
      await t.open('/team/m-bob');
      await t.tap(find.text('Make owner'));
      await tester.enterText(t.inSheet(find.byType(TextField)), 'Shop');
      await t.settle();
      await t.tap(find.widgetWithText(FilledButton, 'Make owner'));
      expect(find.text('Get more from Spendroo'), findsNothing);
      expect(find.textContaining('bob@example.com’s plan has no room for this business yet.'), findsOneWidget);
      await t.stop();
    });

    testWidgets('an admin cannot change another admin, and sees why', (tester) async {
      final t = TeamHarness(tester, role: 'admin', me: 'dan');
      t.server.members = [...t.server.members, member('m-erin', 'erin', 'admin')];
      await t.open('/team/m-erin');
      expect(find.text('Only the owner can change this role.'), findsOneWidget);
      expect(find.text('Remove from business'), findsNothing);
      await t.stop();
    });
  });

  group('join', () {
    testWidgets('looks up a complete code, shows the business and joins it', (tester) async {
      final t = TeamHarness(tester, me: 'erin');
      t.server.code = (request) async => request.url.path.endsWith('/preview/')
          ? http.Response(
              jsonEncode({
                'workspace_id': shopId,
                'workspace_name': 'Shop',
                'invited_by': 'Alice Rahman',
                'role': 'staff',
                'email': '',
                'expires_at': DateTime.now().add(const Duration(days: 3)).toUtc().toIso8601String(),
              }),
              200,
            )
          : http.Response(jsonEncode({'id': shopId, 'name': 'Shop', 'role': 'staff'}), 200);
      await t.open('/join');
      await tester.enterText(find.byType(TextField), 'abcde');
      await t.settle();
      expect(t.server.requests, isEmpty);
      await tester.enterText(find.byType(TextField), 'abcde fgh23');
      await t.settle();
      expect(find.text('ABCDE-FGH23'), findsOneWidget);
      expect(t.server.requests.single.url.queryParameters['code'], 'ABCDEFGH23');
      expect(find.text('Invited by Alice Rahman'), findsOneWidget);
      await t.tap(find.text('Join as Staff'));
      final accepted = t.server.requests.last;
      expect((accepted.method, accepted.url.path), ('POST', '/api/v1/workspaces/invitations/accept/'));
      expect(jsonDecode(accepted.body), {'code': 'ABCDEFGH23'});
      expect(t.h.container.read(currentWorkspaceIdProvider), shopId);
      expect(find.text('home'), findsOneWidget);
      await t.stop();
    });

    testWidgets('an ended or full invitation is explained', (tester) async {
      final t = TeamHarness(tester, me: 'erin');
      t.server.code = (_) async => http.Response(jsonEncode({'code': 'expired', 'detail': 'x'}), 400);
      await t.open('/join');
      await tester.enterText(find.byType(TextField), 'ABCDEFGH23');
      await t.settle();
      expect(find.text('This invitation has ended. Ask for a new one.'), findsOneWidget);
      expect(find.textContaining('Join as'), findsNothing);
      await t.stop();
    });
  });
}
