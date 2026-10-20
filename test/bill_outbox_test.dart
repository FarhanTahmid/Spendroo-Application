import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/sync/bill_files.dart';
import 'package:spendroo/core/sync/bill_outbox.dart';
import 'package:spendroo/features/bills/bill_picker.dart';
import 'package:spendroo/features/bills/bill_repository.dart';
import 'package:spendroo/features/bills/bill_text.dart';

import 'test_support.dart';

const shopId = '00000000-0000-0000-0000-0000000000b1';
const bookId = '00000000-0000-0000-0000-0000000000b2';
const entryId = '00000000-0000-0000-0000-0000000000b3';

/// The first bytes of each kind of bill; the rest does not matter to the phone.
final jpegBytes = [0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(400, 7)];
final pdfBytes = [...utf8.encode('%PDF-1.7\n'), ...List.filled(400, 32)];

Map<String, Object?> storedRow(String id, {String? deletedAt, int size = 1200, String type = 'image/jpeg'}) => {
      'id': id,
      'workspace_id': shopId,
      'entry_id': entryId,
      'cashbook_id': bookId,
      'created_by_id': 'u1',
      'content_type': type,
      'original_name': 'receipt.jpg',
      'size_bytes': size,
      'page_count': null,
      'width': 400,
      'height': 300,
      'version': 1,
      'server_seq': 40,
      'created_at': '2026-10-02T00:00:00Z',
      'updated_at': '2026-10-02T00:00:00Z',
      'deleted_at': deletedAt,
    };

void main() {
  late AppDatabase db;
  late LocalStore store;
  late Directory folder;
  late BillFiles files;
  late List<http.BaseRequest> requests;
  late List<String> uploadedFields;
  late Future<http.Response> Function(http.Request request) respond;
  late DateTime now;

  http.Response json(Object body, [int status = 200]) =>
      http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

  ApiClient api() => ApiClient(
        baseUrl: 'http://api.test',
        tokenStore: MemoryTokenStore()..token = 'token',
        httpClient: MockClient((request) {
          requests.add(request);
          final type = request.headers['content-type'] ?? '';
          if (type.startsWith('multipart/form-data')) uploadedFields.add(latin1.decode(request.bodyBytes));
          return respond(request);
        }),
      );

  setUp(() async {
    db = memoryDatabase();
    store = LocalStore(db);
    folder = await Directory.systemTemp.createTemp('bills');
    files = BillFiles(() async => folder);
    requests = [];
    uploadedFields = [];
    now = DateTime.utc(2026, 10, 19, 12);
    respond = (_) async => json({}, 500);
  });
  tearDown(() async {
    await db.close();
    if (await folder.exists()) await folder.delete(recursive: true);
  });

  Future<void> addEntry({int serverSeq = 7, bool deleted = false}) => store.upsertRow('entries', {
        'id': entryId,
        'workspace_id': shopId,
        'version': 1,
        'server_seq': serverSeq,
        'created_at': '2026-10-01T00:00:00Z',
        'updated_at': '2026-10-01T00:00:00Z',
        'deleted_at': deleted ? '2026-10-03T00:00:00Z' : null,
        'cashbook_id': bookId,
        'entry_type': 'cash_out',
        'amount_minor': 5000,
        'currency': 'BDT',
        'entry_date': '2026-10-01',
        'source': 'manual',
      });

  Future<PickedBill> pick(List<int> bytes, {String name = 'receipt.jpg'}) async {
    final picked = File('${folder.path}/picked-$name');
    await picked.writeAsBytes(bytes);
    return BillPicker.describe(picked.path, name);
  }

  BillRepository repository() => BillRepository(db, api(), files);

  final refusals = <Map<String, dynamic>>[];
  final progress = <double?>[];
  BillOutbox outbox() => BillOutbox(
        db,
        api(),
        store,
        files,
        clock: () => now,
        onPlanLimit: refusals.add,
        onProgress: (_, sent) => progress.add(sent),
      );

  Future<String> queueBill([List<int>? bytes]) async =>
      repository().attach(await pick(bytes ?? jpegBytes), workspaceId: shopId, cashbookId: bookId, entryId: entryId);

  Future<BillQueueData?> job(String id) =>
      (db.select(db.billQueue)..where((q) => q.id.equals(id))).getSingleOrNull();

  group('picked files', () {
    test('are judged by their first bytes, not their names', () async {
      expect((await pick(jpegBytes, name: 'x.pdf')).contentType, jpegType);
      expect((await pick(pdfBytes, name: 'x.jpg')).contentType, pdfType);
      expect(sniffBill([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]), pngType);
      expect(() => pick(utf8.encode('<html><script>'), name: 'bill.png'), throwsA(isA<NotABillException>()));
      expect(() => pick([0x4D, 0x5A, 0x90, 0x00], name: 'bill.jpg'), throwsA(isA<NotABillException>()));
    });

    test('sizes read the way people say them', () {
      expect(formatBytes(740 * 1024, 'en'), '740 KB');
      expect(formatBytes((3.2 * megabyte).round(), 'en'), '3.2 MB');
      expect(formatMegabytes(10, 'en'), '10 MB');
      expect(formatMegabytes(1024, 'en'), '1 GB');
      expect(formatMegabytes(10240, 'en'), '10 GB');
    });
  });

  group('the plan, checked on the phone', () {
    const free = BillRules(fileMb: 2, totalMb: 10, pdf: false, usedBytes: 9 * megabyte, known: true);

    test('free takes photos up to two megabytes and no pdfs', () async {
      final repo = repository();
      await repo.check(await pick(jpegBytes), free);
      await expectLater(
        repo.check(await pick(pdfBytes, name: 'invoice.pdf'), free),
        throwsA(isA<PlanLimitException>().having((e) => e.feature, 'feature', F.storagePdf)),
      );
      final big = PickedBill(path: '', name: 'big.jpg', contentType: jpegType, sizeBytes: 2 * megabyte + 1);
      await expectLater(
        repo.check(big, free),
        throwsA(isA<PlanLimitException>().having((e) => e.feature, 'feature', F.storageFileMb).having((e) => e.limit, 'limit', 2)),
      );
    });

    test('the room left counts bills still waiting to be sent', () async {
      await addEntry();
      final repo = repository();
      final halfMb = PickedBill(path: '', name: 'a.jpg', contentType: jpegType, sizeBytes: megabyte ~/ 2);
      await repo.check(halfMb, free);
      // A megabyte of photos queued: the next half megabyte does not fit in the 10 MB
      await queueBill(List.filled(megabyte, 0xFF)..setRange(0, 3, [0xFF, 0xD8, 0xFF]));
      await expectLater(
        repo.check(halfMb, free),
        throwsA(isA<PlanLimitException>().having((e) => e.feature, 'feature', F.storageMb)),
      );
      // ...nor bills picked in a form not saved yet
      await expectLater(repo.check(halfMb, const BillRules(totalMb: 10, known: true, usedBytes: 0), alsoStaged: 10 * megabyte),
          throwsA(isA<PlanLimitException>()));
    });

    test('in someone else\'s business only the server decides, past the largest file it reads', () async {
      final repo = repository();
      await repo.check(await pick(pdfBytes, name: 'a.pdf'), const BillRules());
      final huge = PickedBill(path: '', name: 'huge.jpg', contentType: jpegType, sizeBytes: 51 * megabyte);
      await expectLater(repo.check(huge, const BillRules()), throwsA(isA<PlanLimitException>()));
    });

    test('rules come from the owner\'s own plan only', () {
      final plan = Entitlements({
        'enforced': true,
        'plan': {'code': 'free', 'name': 'Free', 'rank': 0},
        'features': {
          F.storageMb: {'kind': 'limit', 'limit': 10, 'unlimited': false, 'used_bytes': 1234},
          F.storageFileMb: {'kind': 'limit', 'limit': 2, 'unlimited': false},
          F.storagePdf: {'kind': 'flag', 'enabled': false},
        },
      }, fetchedAt: DateTime.utc(2026, 10, 10));
      const owned = Workspace(id: shopId, name: 'Shop', kind: 'business', defaultCurrency: 'BDT', isDemo: false, role: 'owner');
      final rules = BillRules.of(plan, owned);
      expect((rules.known, rules.fileMb, rules.totalMb, rules.pdf, rules.usedBytes), (true, 2, 10, false, 1234));
      expect(BillRules.of(plan, owned.copyWith(role: 'staff')).known, isFalse);
    });
  });

  group('the bill outbox', () {
    test('waits for the entry, then sends the bill with the id made here', () async {
      await addEntry(serverSeq: 0);
      final id = await queueBill();
      respond = (request) async => json({'bills': [storedRow(id)]}, 201);

      await outbox().run();
      expect(requests, isEmpty, reason: 'the entry is not on the server yet');

      await addEntry(serverSeq: 7);
      await outbox().run();
      expect(requests.single.url.path, '/api/v1/cashbooks/$bookId/entries/$entryId/add-bill/');
      expect(uploadedFields.single, contains('name="bill_id"'));
      expect(uploadedFields.single, contains(id));
      expect(uploadedFields.single, contains('content-type: image/jpeg'));
      expect(await job(id), isNull);
      final stored = await (db.select(db.entryBills)..where((b) => b.id.equals(id))).getSingle();
      expect((stored.contentType, stored.sizeBytes, stored.deletedAt), ('image/jpeg', 1200, null));
      expect(await (await files.cached(id, jpegType)).exists(), isTrue, reason: 'kept to open offline');
      expect(await (await files.pending(id, jpegType)).exists(), isFalse);
      expect(progress.last, isNull, reason: 'the ring goes away when done');
    });

    test('the entry still waiting in the sync outbox holds its bills back', () async {
      await addEntry();
      await db.into(db.outbox).insert(OutboxCompanion.insert(
          mutationId: 'm1', workspaceId: shopId, tableName_: 'entries', op: 'upsert', rowId: entryId, data: '{}'));
      await queueBill();
      await outbox().run();
      expect(requests, isEmpty);
    });

    test('offline: tries again later, each time waiting longer', () async {
      await addEntry();
      final id = await queueBill();
      respond = (_) async => throw const SocketException('down');

      await expectLater(outbox().run(), throwsA(isA<OfflineException>()));
      var waiting = (await job(id))!;
      expect((waiting.state, waiting.attempts), (BillOutbox.queued, 1));
      expect(DateTime.parse(waiting.nextTryAt!), now.add(const Duration(seconds: 30)));

      // Not due yet: nothing is sent
      requests.clear();
      await outbox().run();
      expect(requests, isEmpty);

      now = now.add(const Duration(minutes: 1));
      await expectLater(outbox().run(), throwsA(isA<OfflineException>()));
      waiting = (await job(id))!;
      expect(waiting.attempts, 2);
      expect(DateTime.parse(waiting.nextTryAt!), now.add(const Duration(minutes: 1)));
    });

    test('no room on the plan: kept, marked, and the sheet is raised', () async {
      await addEntry();
      final id = await queueBill();
      respond = (_) async =>
          json({'code': 'plan_limit', 'feature': F.storageMb, 'reason': 'limit', 'limit': 10, 'upgrade_to': 'plus'}, 402);
      await outbox().run();
      final refused = (await job(id))!;
      expect((refused.state, refused.error), (BillOutbox.refused, F.storageMb));
      expect(refusals.single['upgrade_to'], 'plus');

      // Retried after an upgrade, it goes
      respond = (_) async => json({'bills': [storedRow(id)]}, 201);
      await repository().retry(BillView.queued(refused));
      await outbox().run();
      expect(await job(id), isNull);
    });

    test('a file the server will not keep is marked with its reason', () async {
      await addEntry();
      final id = await queueBill();
      respond = (_) async => json({'code': 'bill_unsafe', 'detail': 'scripts'}, 400);
      await outbox().run();
      final failed = (await job(id))!;
      expect((failed.state, failed.error), (BillOutbox.failed, 'bill_unsafe'));
      // A failed bill is not sent again by itself
      requests.clear();
      await outbox().run();
      expect(requests, isEmpty);
    });

    test('a file gone from the phone is marked, not lost silently', () async {
      await addEntry();
      final id = await queueBill();
      await File((await job(id))!.path!).delete();
      await outbox().run();
      expect((await job(id))!.error, BillOutbox.missing);
    });

    test('an entry deleted here takes its waiting bills with it', () async {
      await addEntry();
      final id = await queueBill();
      final waiting = (await job(id))!.path!;
      await addEntry(deleted: true);
      await outbox().run();
      expect(await job(id), isNull);
      expect(await File(waiting).exists(), isFalse);
      expect(requests, isEmpty);
    });

    test('removing a stored bill hides it at once and tells the server', () async {
      await addEntry();
      await store.upsertRow('entry_bills', storedRow('b1'));
      final cached = await files.cached('b1', jpegType);
      await cached.writeAsBytes(jpegBytes);
      final repo = repository();
      expect((await repo.watchForEntry(entryId).first).map((b) => b.id), ['b1']);

      await repo.remove((await repo.watchForEntry(entryId).first).single);
      expect(await repo.watchForEntry(entryId).first, isEmpty, reason: 'hidden while the removal waits');

      respond = (_) async => json({'message': 'Bill removed successfully'});
      await outbox().run();
      expect(requests.single.method, 'DELETE');
      expect(requests.single.url.path, '/api/v1/cashbooks/$bookId/entries/$entryId/remove-bill/b1/');
      final row = await (db.select(db.entryBills)..where((b) => b.id.equals('b1'))).getSingle();
      expect(row.deletedAt, isNotNull);
      expect(await cached.exists(), isFalse);
      expect(await job('b1'), isNull);
    });

    test('files of bills no longer on the phone are swept, new ones are left alone', () async {
      await addEntry();
      await store.upsertRow('entry_bills', storedRow('kept'));
      final kept = await files.cached('kept', jpegType);
      final stale = await files.cached('gone', jpegType);
      final fresh = await files.cached('just-picked', jpegType);
      for (final file in [kept, stale, fresh]) {
        await file.writeAsBytes(jpegBytes);
      }
      await stale.setLastModified(DateTime.now().subtract(const Duration(hours: 1)));
      await outbox().run();
      expect((await kept.exists(), await stale.exists(), await fresh.exists()), (true, false, true));
    });
  });

  group('the bills of an entry', () {
    test('stored and waiting ones together, oldest first', () async {
      await addEntry();
      await store.upsertRow('entry_bills', storedRow('b1'));
      final waiting = await queueBill();
      final bills = await repository().watchForEntry(entryId).first;
      expect(bills.map((b) => (b.id, b.status)), [('b1', BillStatus.stored), (waiting, BillStatus.waiting)]);
    });

    test('a stored bill opens through a link once, then from the phone', () async {
      await addEntry();
      await store.upsertRow('entry_bills', storedRow('b1'));
      respond = (request) async {
        if (request.url.path.endsWith('/link/')) {
          return json({'url': '/api/v1/bills/file/signed-token/', 'expires_at': '2026-10-19T12:05:00Z'});
        }
        return http.Response.bytes(jpegBytes, 200, headers: {'content-type': 'image/jpeg'});
      };
      final repo = repository();
      final bill = (await repo.watchForEntry(entryId).first).single;
      final file = await repo.open(bill);
      expect(await file.readAsBytes(), jpegBytes);
      expect(requests.map((r) => r.url.path),
          ['/api/v1/cashbooks/$bookId/entries/$entryId/bills/b1/link/', '/api/v1/bills/file/signed-token/']);
      // The link carries no session to anywhere but this server
      expect(requests.last.headers['X-Session-Token'], 'token');

      requests.clear();
      await repo.open(bill);
      expect(requests, isEmpty);
    });

    test('a link to a file store gets no session token', () async {
      await addEntry();
      await store.upsertRow('entry_bills', storedRow('b2'));
      respond = (request) async => request.url.path.endsWith('/link/')
          ? json({'url': 'https://files.example.com/b2.jpg?signature=abc', 'expires_at': '2026-10-19T12:05:00Z'})
          : http.Response.bytes(jpegBytes, 200);
      final repo = repository();
      await repo.open((await repo.watchForEntry(entryId).first).single);
      expect(requests.last.url.host, 'files.example.com');
      expect(requests.last.headers.containsKey('X-Session-Token'), isFalse);
    });

    test('offline with no copy here, opening says so', () async {
      await addEntry();
      await store.upsertRow('entry_bills', storedRow('b1'));
      respond = (_) async => throw const SocketException('down');
      final repo = repository();
      await expectLater(
        repo.open((await repo.watchForEntry(entryId).first).single),
        throwsA(isA<BillUnavailable>().having((e) => e.offline, 'offline', isTrue)),
      );
    });
  });
}
