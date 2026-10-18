import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/features/cashbook/access_page.dart';
import 'package:spendroo/features/cashbook/book_access.dart';
import 'package:spendroo/features/cashbook/cashbook_pages.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';

import 'personal_screens_test.dart' show ScreenHarness;
import 'test_support.dart';

const shopId = '00000000-0000-0000-0000-0000000000aa';

Workspace shop(String role) =>
    Workspace(id: shopId, name: 'Shop', kind: 'business', defaultCurrency: 'BDT', isDemo: false, role: role);

/// A staff member's grant to [bookId], as sync brings it.
Future<void> grant(AppDatabase db, String bookId, String role) => db.into(db.cashbookMembers).insert(
      CashbookMembersCompanion.insert(
        id: 'grant-$bookId',
        workspaceId: shopId,
        createdAt: '2026-10-01T00:00:00Z',
        updatedAt: '2026-10-01T00:00:00Z',
        cashbookId: bookId,
        memberId: 'me',
        role: role,
        deletedAt: const Value(null),
      ),
    );

void main() {
  group('BookAccess', () {
    test('a workspace role gives every book, except to staff', () {
      expect(BookAccess.forRole('owner'), BookAccess.manage);
      expect(BookAccess.forRole('admin'), BookAccess.manage);
      expect(BookAccess.forRole('viewer'), BookAccess.view);
      expect(BookAccess.forRole('staff'), isNull);
    });

    test('grants map both ways and each level includes the ones below', () {
      for (final access in BookAccess.values) {
        expect(BookAccess.fromGrant(access.grantRole), access);
      }
      expect(BookAccess.fromGrant(null), BookAccess.view);
      expect([for (final a in BookAccess.values) (a.canAdd, a.canEdit, a.canManage)], [
        (false, false, false),
        (true, false, false),
        (true, true, false),
        (true, true, true),
      ]);
    });

    test('accessFor reads the staff member\'s own grant and ignores grants for other roles', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final repo = CashbookRepository(db, LocalStore(db));
      final till = Cashbook(
          id: 'till', workspaceId: shopId, version: 0, serverSeq: 0, createdAt: '', updatedAt: '',
          bookName: 'Till', currency: 'BDT');
      expect(await repo.accessFor(till, shop('staff')), BookAccess.view);
      await grant(db, 'till', 'contributor');
      expect(await repo.accessFor(till, shop('staff')), BookAccess.add);
      expect(await repo.accessFor(till, shop('viewer')), BookAccess.view);
      expect(await repo.accessFor(till, shop('owner')), BookAccess.manage);
    });
  });

  group('cashbook page', () {
    Future<(ScreenHarness, String)> open(WidgetTester tester, String role, {String? grantRole}) async {
      final h = ScreenHarness(tester);
      final repo = CashbookRepository(h.db, h.store);
      final bookId = await h.run(() => repo.createCashbook(shopId, 'Till', 'BDT'));
      final book = (await h.run(() => repo.watchCashbook(bookId).first))!.book;
      await h.run(() => repo.addEntry(book, entryType: 'cash_in', amountMinor: 5000, entryDate: '2026-10-01', title: 'Sale'));
      if (grantRole != null) await h.run(() => grant(h.db, bookId, grantRole));
      await h.show(CashbookPage(bookId: bookId), space: shop(role));
      return (h, bookId);
    }

    testWidgets('add access: Cash in and out, but entries open for nobody', (tester) async {
      final (h, _) = await open(tester, 'staff', grantRole: 'contributor');
      expect(find.text('Cash in'), findsOneWidget);
      expect(find.text('You can add entries to this cashbook but not change them.'), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsNothing);
      await tester.tap(find.text('Sale'));
      await h.settle();
      expect(find.byType(EntryFormPage), findsNothing);
      await h.stop();
    });

    testWidgets('view access: read only', (tester) async {
      final (h, _) = await open(tester, 'staff', grantRole: 'viewer');
      expect(find.text('Cash in'), findsNothing);
      expect(find.text('You can view this cashbook but not change it.'), findsOneWidget);
      await h.stop();
    });

    testWidgets('edit access: no banner, rename but not categories or access', (tester) async {
      final (h, _) = await open(tester, 'staff', grantRole: 'editor');
      expect(find.text('Cash in'), findsOneWidget);
      expect(find.textContaining('You can'), findsNothing);
      await tester.tap(find.byType(PopupMenuButton<String>));
      await h.settle();
      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Categories'), findsNothing);
      expect(find.text('Who has access'), findsNothing);
      await h.stop();
    });

    testWidgets('the owner of a business sees who has access', (tester) async {
      final (h, _) = await open(tester, 'owner');
      await tester.tap(find.byType(PopupMenuButton<String>));
      await h.settle();
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Who has access'), findsOneWidget);
      await h.stop();
    });
  });

  group('who has access', () {
    late List<http.Request> requests;
    late Future<http.Response> Function(http.Request) respond;

    Future<http.Response> staffList(http.Request request) async => http.Response(
          jsonEncode([
            {'membership_id': 'm1', 'user': 'u-carol', 'user_email': 'carol@example.com', 'grant_id': null, 'role': null},
            {'membership_id': 'm2', 'user': 'u-erin', 'user_email': 'erin@example.com', 'grant_id': 'g-erin', 'role': 'editor'},
          ]),
          200,
        );

    Future<(ScreenHarness, String)> open(WidgetTester tester, {String role = 'owner'}) async {
      requests = [];
      respond = staffList;
      final h = ScreenHarness(tester, overrides: [
        apiClientProvider.overrideWith((ref) => ApiClient(
              baseUrl: 'http://test',
              tokenStore: MemoryTokenStore(),
              httpClient: MockClient((request) {
                requests.add(request);
                return request.method == 'GET' ? staffList(request) : respond(request);
              }),
            )),
      ]);
      final bookId = await h.run(() => CashbookRepository(h.db, h.store).createCashbook(shopId, 'Till', 'BDT'));
      await h.show(CashbookAccessPage(bookId: bookId), space: shop(role));
      return (h, bookId);
    }

    Future<void> pick(ScreenHarness h, WidgetTester tester, String who, String level) async {
      await tester.tap(find.text(who));
      await h.settle();
      await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text(level)));
      await h.settle();
    }

    testWidgets('lists staff with their access and grants, changes and takes it away', (tester) async {
      final (h, bookId) = await open(tester);
      expect(find.text('carol@example.com'), findsOneWidget);
      expect(find.text('No access'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      respond = (_) async => http.Response('{}', 201);
      await pick(h, tester, 'carol@example.com', 'Add');
      final granted = requests.lastWhere((r) => r.method == 'POST');
      expect(granted.url.path, '/api/v1/cashbooks/$bookId/add_member/');
      expect(jsonDecode(granted.body), {'member': 'u-carol', 'role': 'contributor'});

      respond = (_) async => http.Response('{}', 200);
      await pick(h, tester, 'erin@example.com', 'Manage');
      final changed = requests.lastWhere((r) => r.method == 'PATCH');
      expect(changed.url.path, '/api/v1/cashbooks/$bookId/members/g-erin/');
      expect(jsonDecode(changed.body), {'role': 'admin'});

      respond = (_) async => http.Response('', 204);
      await pick(h, tester, 'erin@example.com', 'No access');
      expect(requests.last.method, 'GET'); // fetched again after the change
      expect(requests.where((r) => r.method == 'DELETE').single.url.path, '/api/v1/cashbooks/$bookId/members/g-erin/');
      await h.stop();
    });

    testWidgets('says so when the server refuses or cannot be reached', (tester) async {
      final (h, _) = await open(tester);
      respond = (_) async => http.Response(jsonEncode({'code': 'not_staff', 'detail': 'x'}), 400);
      await pick(h, tester, 'carol@example.com', 'View');
      expect(find.text("You can't make that change."), findsOneWidget);

      respond = (_) async => throw http.ClientException('no network');
      await pick(h, tester, 'carol@example.com', 'View');
      expect(find.text('This needs an internet connection.'), findsOneWidget);
      await h.stop();
    });

    testWidgets('only the owner or an admin can hand out Manage', (tester) async {
      final (h, _) = await open(tester, role: 'staff');
      await tester.tap(find.text('carol@example.com'));
      await h.settle();
      final sheet = find.byType(BottomSheet);
      expect(find.descendant(of: sheet, matching: find.text('Edit')), findsOneWidget);
      expect(find.descendant(of: sheet, matching: find.text('Manage')), findsNothing);
      await h.stop();
    });
  });
}
