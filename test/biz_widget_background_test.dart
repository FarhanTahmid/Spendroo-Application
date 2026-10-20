import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/intl.dart';
import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/auth/auth_repository.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/features/home_widget/business/biz_snapshot.dart';
import 'package:spendroo/features/home_widget/business/biz_widget_background.dart';
import 'package:spendroo/features/home_widget/business/biz_widget_targets.dart';
import 'package:spendroo/features/personal/ledger_repository.dart' show isoDate;

import 'biz_widget_test.dart' show RecordingBizBridge, plusWithBizWidget, shop;
import 'test_support.dart';

const bookId = '00000000-0000-0000-0000-0000000000b2';
const entryId = '00000000-0000-0000-0000-0000000000b3';
const otherShop = '00000000-0000-0000-0000-0000000000c1';

/// What the launcher would say the placed widgets show.
class FixedTargets implements BizWidgetTargetSource {
  FixedTargets(this.targets);

  BizWidgetTargets? targets;

  @override
  Future<BizWidgetTargets?> read() async => targets;
}

Map<String, dynamic> serverRow(String id, int seq, Map<String, dynamic> fields) => {
      'id': id,
      'workspace_id': shop.id,
      'version': 1,
      'server_seq': seq,
      'created_at': '2026-10-01T00:00:00Z',
      'updated_at': '2026-10-01T00:00:00Z',
      'deleted_at': null,
      ...fields,
    };

void main() {
  late AppDatabase db;
  late RecordingBizBridge bridge;
  late FixedTargets targets;
  late MemoryTokenStore tokens;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request request) respond;
  late List<BizWidgetTargets> devicesAsked;

  http.Response json(Object body, [int status = 200]) =>
      http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

  /// A teammate's entry of today, as the pull hands it over.
  Map<String, dynamic> pullWithEntry() => {
        'changes': {
          'cashbooks': [serverRow(bookId, 7, {'book_name': 'Till', 'description': null, 'currency': 'BDT'})],
          'entries': [
            serverRow(entryId, 8, {
              'cashbook_id': bookId, 'category_id': null, 'payment_method_id': null, 'entry_type': 'cash_in',
              'amount_minor': 123400, 'title': 'Sale', 'remarks': null, 'entry_date': isoDate(DateTime.now()),
              'source': 'manual', 'currency': 'BDT', 'created_by_id': null,
            }),
          ],
        },
        'next_since': 8,
        'has_more': false,
        'accessible_cashbook_ids': [bookId],
        'billing_stamp': null,
      };

  BizWidgetRefresher refresher() => BizWidgetRefresher(
        db: db,
        api: ApiClient(
          baseUrl: 'http://api.test',
          tokenStore: tokens,
          httpClient: MockClient((request) {
            requests.add(request);
            return respond(request);
          }),
        ),
        bridge: bridge,
        targets: targets,
        device: (shown, locale) async {
          devicesAsked.add(shown);
          return {'token': 'fcm-token', 'platform': 'android', 'locale': locale, ...shown.toJson()};
        },
      );

  setUp(() async {
    db = memoryDatabase();
    bridge = RecordingBizBridge();
    targets = FixedTargets(BizWidgetTargets(books: {bookId}));
    tokens = MemoryTokenStore()..token = 'session';
    requests = [];
    devicesAsked = [];
    respond = (request) async => json(pullWithEntry());
    await db.into(db.workspaces).insert(shop);
    await db.setSetting(authStepSettingKey, AuthStep.signedIn.name);
    await db.setSetting(entitlementsSettingKey, plusWithBizWidget().encode());
  });
  tearDown(() => db.close());

  group('a teammate changed something', () {
    test('the book is pulled alone and its widget redrawn, without opening the app', () async {
      expect(await refresher().onPing(WidgetPing(shop.id, 8)), BizRefreshOutcome.redrawn);

      // One incremental pull of that business: no push, no census, no workspace refresh
      expect(requests.map((r) => '${r.method} ${r.url.path}'), ['GET /api/v1/sync/pull/']);
      expect(requests.single.url.queryParameters, {'workspace': shop.id, 'since': '0'});

      final book = bridge.json(BizKeys.book(bookId))!;
      expect(book['name'], 'Till');
      expect(book['subtitle'], 'Rahman Traders');
      expect(book['balance'], contains('1,234'));
      expect(book['updated'], isNotEmpty);
      // Named as the open app names them, though no localizations were loaded here
      expect((book['month'] as Map)['label'], DateFormat.MMMM('en').format(DateTime.now()));
      expect(bridge.json(BizKeys.catalog)!['signedIn'], isTrue);
      // Only what was looked at is written; the list of keys the open app keeps is left alone
      expect(bridge.writes.single.keys.toSet(), {BizKeys.catalog, BizKeys.business(shop.id), BizKeys.book(bookId)});
    });

    test('a phone that already has the change stops before the network', () async {
      expect(await refresher().onPing(WidgetPing(shop.id, 8)), BizRefreshOutcome.redrawn);
      requests.clear();
      bridge.writes.clear();

      // As on the phone that made the change: it pulled up to there itself
      expect(await refresher().onPing(WidgetPing(shop.id, 8)), BizRefreshOutcome.upToDate);
      expect(requests, isEmpty);
      expect(bridge.writes, isEmpty);
    });

    test('a business no widget here shows is ignored', () async {
      await bridge.publish({
        BizKeys.catalog: jsonEncode({
          'businesses': [
            {'id': otherShop, 'books': [{'id': bookId}]},
          ],
        }),
      });
      bridge.writes.clear();

      // The widget shows a book of the other business
      expect(await refresher().onPing(WidgetPing(shop.id, 8)), BizRefreshOutcome.notShown);
      targets.targets = BizWidgetTargets.none;
      expect(await refresher().onPing(WidgetPing(shop.id, 8)), BizRefreshOutcome.notShown);
      expect(requests, isEmpty);
      expect(bridge.writes, isEmpty);
    });

    test('signed out, nothing is done', () async {
      tokens.token = null;
      expect(await refresher().onPing(WidgetPing(shop.id, 8)), BizRefreshOutcome.signedOut);
      expect(requests, isEmpty);
    });

    test('a refused session wipes nothing: the app deals with it when it opens', () async {
      respond = (request) async => json({'detail': 'expired'}, 401);
      expect(await refresher().onPing(WidgetPing(shop.id, 8)), BizRefreshOutcome.sessionEnded);
      expect(await db.getSetting(authStepSettingKey), AuthStep.signedIn.name);
      expect(await db.select(db.workspaces).get(), hasLength(1));
      expect(bridge.writes, isEmpty);
    });

    test('offline, the widget keeps its picture', () async {
      respond = (request) async => throw http.ClientException('no network');
      expect(await refresher().onPing(WidgetPing(shop.id, 8)), BizRefreshOutcome.offline);
      expect(bridge.writes, isEmpty);
    });
  });

  group('a widget was given a business or book', () {
    test('the server is told, once', () async {
      respond = (request) async => http.Response('', 204);
      expect(await refresher().reportTargets(), BizRefreshOutcome.targetsReported);
      expect(requests.single.method, 'PUT');
      expect(requests.single.url.path, '/api/v1/me/devices/');
      expect(jsonDecode(requests.single.body), containsPair('widget_books', [bookId]));

      requests.clear();
      expect(await refresher().reportTargets(), BizRefreshOutcome.targetsReported);
      expect(requests, isEmpty);

      targets.targets = BizWidgetTargets(workspaces: {shop.id});
      await refresher().reportTargets();
      expect(jsonDecode(requests.single.body), containsPair('widget_workspaces', [shop.id]));
    });

    test('a failed telling is tried again next time', () async {
      respond = (request) async => json({}, 500);
      expect(await refresher().reportTargets(), BizRefreshOutcome.offline);
      expect(await db.getSetting(widgetTargetsSettingKey), isNull);
    });
  });

  group('messages and targets', () {
    test('only the widgets message is read as a ping', () {
      final ping = WidgetPing.from({'kind': 'widgets', 'workspace_id': shop.id, 'seq': '41'})!;
      expect((ping.workspaceId, ping.seq), (shop.id, 41));
      expect(WidgetPing.from({'kind': 'inbox', 'workspace_id': shop.id, 'seq': '41'}), isNull);
      expect(WidgetPing.from({'kind': 'widgets', 'workspace_id': shop.id}), isNull);
    });

    test('a copy without a choice shows the only business or book there is', () {
      String catalog(List<Map<String, Object>> businesses) => jsonEncode({'businesses': businesses});
      final one = catalog([
        {'id': shop.id, 'books': [{'id': bookId}]},
      ]);
      expect(
        BizWidgetTargets.of(copies: [(true, null), (false, null)], catalogJson: one).toJson(),
        {'widget_workspaces': [shop.id], 'widget_books': [bookId]},
      );
      final two = catalog([
        {'id': shop.id, 'books': [{'id': bookId}]},
        {'id': otherShop, 'books': [{'id': 'b9'}]},
      ]);
      // Two of each: only what was picked counts
      expect(
        BizWidgetTargets.of(copies: [(true, null), (false, 'b9')], catalogJson: two).toJson(),
        {'widget_workspaces': <String>[], 'widget_books': ['b9']},
      );
      expect(BizWidgetTargets.bookBusinessOf(two), {bookId: shop.id, 'b9': otherShop});
    });
  });
}
