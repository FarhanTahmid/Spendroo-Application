import 'dart:convert';

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
import 'package:spendroo/features/cashbook/cashbook_pages.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';
import 'package:spendroo/features/history/history_page.dart';
import 'package:spendroo/features/history/history_repository.dart';
import 'package:spendroo/features/plan/plan_text.dart';
import 'package:spendroo/features/profile/profile_repository.dart';
import 'package:spendroo/features/settings/settings_page.dart';
import 'package:spendroo/features/team/member_page.dart';
import 'package:spendroo/l10n/app_localizations.dart';

import 'personal_screens_test.dart' show ScreenHarness;
import 'plan_test.dart' show answer;
import 'team_test.dart' show FakeTeam, FixedProfile, shop, shopId;

final _now = DateTime.now();
String _at(DateTime moment) => moment.toUtc().toIso8601String();

Map<String, Object?> row(
  String id, {
  String kind = 'entry',
  String action = 'updated',
  String actor = 'carol',
  String subject = 'Lunch',
  String book = 'Till',
  DateTime? at,
  List<Map<String, Object?>> changes = const [],
  int? amount = 12500,
}) =>
    {
      'id': id,
      'at': _at(at ?? _now),
      'kind': kind,
      'action': action,
      'object_id': 'obj-$id',
      'cashbook': {'id': 'book-${book.toLowerCase()}', 'name': book},
      'actor': {'id': actor, 'name': actor == 'carol' ? 'Carol Khan' : '', 'email': '$actor@example.com'},
      'subject': subject,
      'changes': changes,
      if (kind == 'entry') ...{'amount_minor': amount, 'currency': 'BDT', 'entry_type': 'cash_out'},
    };

/// The team endpoints plus the history: two pages unless a test says otherwise.
class FakeHistory extends FakeTeam {
  var pages = <List<Map<String, Object?>>>[
    [
      row('1', changes: [
        {'field': 'amount_minor', 'before': 10000, 'after': 12500},
        {'field': 'category', 'before': 'Food', 'after': 'Rent'},
      ]),
      row('2', action: 'created', actor: 'alice', subject: 'Counter sales'),
      row('3', action: 'deleted', subject: 'Tea', at: _now.subtract(const Duration(days: 1))),
    ],
    [row('4', action: 'created', subject: 'Older one', at: _now.subtract(const Duration(days: 3)))],
  ];

  /// Answers the history instead, e.g. a refusal.
  http.Response? historyAnswer;

  Iterable<Uri> historyRequests() =>
      requests.where((r) => r.url.path.endsWith('/history/')).map((r) => r.url);

  @override
  Future<http.Response> handle(http.Request request) async {
    if (request.url.path == '/api/v1/workspaces/$shopId/history/') {
      if (offline) throw http.ClientException('no network');
      requests.add(request);
      if (historyAnswer != null) return historyAnswer!;
      final page = request.url.queryParameters['cursor'] == null ? 0 : int.parse(request.url.queryParameters['cursor']!);
      final last = page + 1 >= pages.length;
      return http.Response(jsonEncode({'results': pages[page], 'next': last ? null : '${page + 1}'}), 200);
    }
    return super.handle(request);
  }
}

Entitlements business({bool history = true}) => Entitlements(
      answer(plan: 'business', features: {F.auditTrail: {'kind': 'flag', 'enabled': history}}),
      fetchedAt: DateTime.utc(2026, 10, 10),
    );

class HistoryHarness {
  HistoryHarness(this.tester, {String role = 'owner', String me = 'alice', Entitlements? plan, FakeHistory? server})
      : server = server ?? FakeHistory() {
    h = ScreenHarness(tester, plan: plan, overrides: [
      apiClientProvider.overrideWith(
        (ref) => ApiClient(baseUrl: 'http://test', tokenStore: MemoryTokenStore(), httpClient: MockClient(this.server.handle)),
      ),
      profileProvider.overrideWith(() => FixedProfile(me)),
    ]);
    space = shop(role);
  }

  final WidgetTester tester;
  final FakeHistory server;
  late final ScreenHarness h;
  late final Workspace space;
  late final GoRouter router;

  Future<void> settle() => h.settle();

  Future<String> book(String name) => h.run(() => CashbookRepository(h.db, h.store).createCashbook(shopId, name, 'BDT'));

  Future<void> open(String location) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await h.db.into(h.db.workspaces).insert(space);
    router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('home'))),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
        GoRoute(path: '/team/:id', builder: (_, state) => MemberPage(membershipId: state.pathParameters['id']!)),
        GoRoute(path: '/cashbook/:id', builder: (_, state) => CashbookPage(bookId: state.pathParameters['id']!)),
        GoRoute(
          path: '/history',
          builder: (_, state) => HistoryPage(
            bookId: state.uri.queryParameters['book'],
            personId: state.uri.queryParameters['person'],
            entryId: state.uri.queryParameters['entry'],
          ),
        ),
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

  /// Lets a page that was pushed finish arriving, so the one under it is offstage.
  Future<void> arrive() async {
    await tester.pump(const Duration(seconds: 1));
    await settle();
  }

  Finder inSheet(Finder finder) => find.descendant(of: find.byType(BottomSheet), matching: finder);

  Future<void> stop() => h.stop();
}

void main() {
  group('model', () {
    test('a row from the server, with what it changed', () {
      final event = HistoryEvent.fromJson(row('1', changes: [
        {'field': 'category', 'before': null, 'after': 'Rent'},
      ]));
      expect((event.kind, event.action, event.subject, event.cashbookName), ('entry', 'updated', 'Lunch', 'Till'));
      expect(event.actor!.displayName, 'Carol Khan');
      expect(event.actor!.initials, 'CK');
      expect((event.amountMinor, event.currency, event.entryType), (12500, 'BDT', 'cash_out'));
      expect(event.changes.single.before, isNull);
      expect(event.changes.single.after, 'Rent');
    });

    test('a change nobody made, and fields this app does not know, still read', () {
      final event = HistoryEvent.fromJson({...row('1'), 'actor': null, 'cashbook': null, 'something_new': 1});
      expect(event.actor, isNull);
      expect(event.cashbookId, isNull);
    });

    test('days go to the server as moments where the owner is, the last day included', () {
      final filter = HistoryFilter(cashbookId: 'b', personId: 'p', from: DateTime(2026, 10, 1), to: DateTime(2026, 10, 3));
      expect(filter.query, {
        'cashbook': 'b',
        'person': 'p',
        'from': DateTime(2026, 10, 1).toUtc().toIso8601String(),
        'to': DateTime(2026, 10, 4).toUtc().toIso8601String(),
      });
      expect(filter.count, 3);
      expect(filter.cleared(), const HistoryFilter());
      // One entry's story is never narrowed further
      expect(const HistoryFilter(entryId: 'e', cashbookId: 'b').query, {'entry': 'e'});
    });

    test('filters compare by value, so the same one is the same feed', () {
      expect(const HistoryFilter(cashbookId: 'b'), const HistoryFilter(cashbookId: 'b'));
      expect(const HistoryFilter(cashbookId: 'b').copyWith(cashbookId: () => null), const HistoryFilter());
    });

    test('the upgrade screen lists the edit history', () {
      expect(shownFeatures, contains(F.auditTrail));
    });
  });

  group('history page', () {
    testWidgets('changes by day, newest first, with who made them', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      await t.open('/history');
      expect(find.text('Edit history'), findsOneWidget);
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(find.textContaining('Carol Khan'), findsWidgets);
      expect(find.textContaining('Edited an entry'), findsOneWidget);
      // The signed-in owner reads as "You"
      expect(find.textContaining('You'), findsWidgets);
      expect(find.text('Counter sales'), findsOneWidget);
      expect(find.text('Amount, Category'), findsOneWidget);
      expect(t.server.historyRequests().first.queryParameters, {'limit': '${HistoryRepository.pageSize}'});
      await t.stop();
    });

    testWidgets('a change opens to show each field before and after', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      await t.open('/history');
      expect(find.text('Food'), findsNothing);
      await t.tap(find.text('Lunch').first);
      expect(find.text('AMOUNT'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('History of this entry'), findsOneWidget);
      await t.tap(find.text('Lunch').first);
      expect(find.text('Food'), findsNothing);
      await t.stop();
    });

    testWidgets('an entry row leads to that entry\'s own history', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      await t.open('/history');
      await t.tap(find.text('Lunch').first);
      t.server.pages = [[row('9', subject: 'Lunch')]];
      await t.tap(find.text('History of this entry'));
      await t.arrive();
      expect(t.server.historyRequests().last.queryParameters['entry'], 'obj-1');
      // No filters for one entry; its name and how often it changed instead
      expect(find.text('All cashbooks'), findsNothing);
      expect(find.text('৳125.00 · 1 change'), findsOneWidget);
      await t.stop();
    });

    testWidgets('scrolling on asks for the next page with the cursor, then shows the end', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      await t.open('/history');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await t.settle();
      expect(t.server.historyRequests().last.queryParameters['cursor'], '1');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await t.settle();
      expect(find.text('Older one'), findsOneWidget);
      expect(find.text('That’s everything'), findsOneWidget);
      expect(t.server.historyRequests().length, 2);
      await t.stop();
    });

    testWidgets('narrowed to a cashbook, a person, then cleared', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      final till = await t.book('Till');
      await t.open('/history');
      await t.tap(find.text('All cashbooks'));
      await t.tap(t.inSheet(find.text('Till')));
      expect(t.server.historyRequests().last.queryParameters['cashbook'], till);
      await t.tap(find.text('Everyone'));
      await t.tap(t.inSheet(find.text('Carol Khan')));
      expect(t.server.historyRequests().last.queryParameters, containsPair('person', 'carol'));
      expect(t.server.historyRequests().last.queryParameters, containsPair('cashbook', till));
      expect(find.text('Changes by Carol Khan'), findsOneWidget);
      final before = t.server.historyRequests().length;
      await t.tap(find.text('Clear all'));
      expect(t.server.historyRequests().elementAt(before).queryParameters.keys, ['limit']);
      expect(find.text('All cashbooks'), findsOneWidget);
      await t.stop();
    });

    testWidgets('a filter clears with its ✕', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      await t.open('/history?person=carol');
      expect(t.server.historyRequests().last.queryParameters['person'], 'carol');
      await t.tap(find.byIcon(Icons.close_rounded));
      expect(t.server.historyRequests().last.queryParameters.containsKey('person'), isFalse);
      await t.stop();
    });

    testWidgets('nothing yet, and nothing for these filters', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      t.server.pages = [[]];
      await t.open('/history');
      expect(find.textContaining('Nothing has changed yet'), findsOneWidget);
      await t.stop();

      final f = HistoryHarness(tester, plan: business());
      f.server.pages = [[]];
      await f.open('/history?person=carol');
      expect(find.text('No changes match these filters.'), findsOneWidget);
      f.server.pages = [[row('1')]];
      await f.tap(find.text('Clear filters'));
      expect(find.text('Lunch'), findsOneWidget);
      await f.stop();
    });

    testWidgets('offline: retry brings it in', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      t.server.offline = true;
      await t.open('/history');
      expect(find.text('Retry'), findsOneWidget);
      t.server.offline = false;
      await t.tap(find.text('Retry'));
      expect(find.text('Lunch'), findsOneWidget);
      await t.stop();
    });
  });

  group('plan', () {
    testWidgets('without the feature: a blurred preview and the way to it, and no request', (tester) async {
      final t = HistoryHarness(tester, plan: business(history: false));
      await t.open('/history');
      expect(find.text('See who changed what, and when'), findsOneWidget);
      expect(find.text('Every edit, with before and after'), findsOneWidget);
      expect(t.server.historyRequests(), isEmpty);
      await t.tap(find.text('See plans'));
      expect(find.byType(BottomSheet), findsOneWidget);
      await t.stop();
    });

    testWidgets('the server says the plan lacks it: the same preview', (tester) async {
      final t = HistoryHarness(tester);
      t.server.historyAnswer = http.Response(
        jsonEncode({'code': 'plan_limit', 'feature': F.auditTrail, 'reason': 'feature'}),
        402,
      );
      await t.open('/history');
      expect(find.text('See who changed what, and when'), findsOneWidget);
      await t.stop();
    });
  });

  group('who sees it', () {
    testWidgets('anyone but the owner is told it is the owner\'s', (tester) async {
      final t = HistoryHarness(tester, role: 'admin', plan: business());
      await t.open('/history');
      expect(find.text('Only the business owner can see the edit history.'), findsOneWidget);
      expect(t.server.historyRequests(), isEmpty);
      await t.stop();
    });

    test('only the owner of a real business has a way in', () {
      expect(showsHistory(shop('owner')), isTrue);
      for (final role in ['admin', 'staff', 'viewer']) {
        expect(showsHistory(shop(role)), isFalse);
      }
      expect(showsHistory(shop('owner').copyWith(isDemo: true)), isFalse);
      expect(showsHistory(shop('owner').copyWith(kind: 'personal')), isFalse);
      expect(showsHistory(null), isFalse);
    });
  });

  group('ways in', () {
    testWidgets('settings has it under the team, for the owner', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      await t.open('/settings');
      expect(find.text('Who changed what, and when'), findsOneWidget);
      await t.tap(find.text('Edit history'));
      expect(find.byType(HistoryPage), findsOneWidget);
      await t.stop();

      final admin = HistoryHarness(tester, role: 'admin', me: 'bob', plan: business());
      await admin.open('/settings');
      expect(find.text('Edit history'), findsNothing);
      await admin.stop();
    });

    testWidgets('a member\'s page opens their changes', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      await t.open('/team/m-carol');
      expect(find.text('See their changes'), findsOneWidget);
      await t.tap(find.text('See their changes'));
      expect(find.byType(HistoryPage), findsOneWidget);
      expect(t.server.historyRequests().last.queryParameters['person'], 'carol');
      await t.stop();
    });

    testWidgets('a member\'s page shows a lock on a plan without it', (tester) async {
      final t = HistoryHarness(tester, plan: business(history: false));
      await t.open('/team/m-carol');
      expect(
        find.descendant(of: find.widgetWithText(ListTile, 'See their changes'), matching: find.byIcon(Icons.lock_outline_rounded)),
        findsOneWidget,
      );
      await t.stop();
    });

    testWidgets('an admin\'s view of a member has no way in', (tester) async {
      final t = HistoryHarness(tester, role: 'admin', me: 'bob', plan: business());
      await t.open('/team/m-carol');
      expect(find.text('See their changes'), findsNothing);
      await t.stop();
    });

    testWidgets('the cashbook menu opens the book\'s history, and an entry its own', (tester) async {
      final t = HistoryHarness(tester, plan: business());
      final till = await t.book('Till');
      final repo = CashbookRepository(t.h.db, t.h.store);
      final book = (await t.h.run(() => repo.watchCashbook(till).first))!.book;
      await t.h.run(() => repo.addEntry(book, entryType: 'cash_in', amountMinor: 5000, entryDate: '2026-10-01', title: 'Sale'));
      await t.open('/cashbook/$till');
      await t.tap(find.byType(PopupMenuButton<String>));
      await t.tap(find.text('Edit history'));
      expect(t.server.historyRequests().last.queryParameters['cashbook'], till);
      t.router.pop();
      await t.settle();

      await t.tap(find.text('Sale'));
      expect(find.byType(EntryFormPage), findsOneWidget);
      await t.tap(find.byTooltip('History of this entry'));
      expect(find.byType(HistoryPage), findsOneWidget);
      expect(t.server.historyRequests().last.queryParameters.containsKey('entry'), isTrue);
      await t.stop();
    });

    testWidgets('an admin\'s cashbook menu and entry have no way in', (tester) async {
      final t = HistoryHarness(tester, role: 'admin', plan: business());
      final till = await t.book('Till');
      final repo = CashbookRepository(t.h.db, t.h.store);
      final book = (await t.h.run(() => repo.watchCashbook(till).first))!.book;
      await t.h.run(() => repo.addEntry(book, entryType: 'cash_in', amountMinor: 5000, entryDate: '2026-10-01', title: 'Sale'));
      await t.open('/cashbook/$till');
      await t.tap(find.byType(PopupMenuButton<String>));
      expect(find.text('Edit history'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await t.settle();
      await t.tap(find.text('Sale'));
      expect(find.byTooltip('History of this entry'), findsNothing);
      await t.stop();
    });
  });
}
