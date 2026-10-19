import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/db/database.dart';
import '../../core/db/local_store.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/providers.dart';
import '../../core/sync/bill_files.dart';
import '../../core/sync/bill_outbox.dart';
import 'bill_picker.dart';
import 'bill_text.dart';

enum BillStatus {
  /// On the server.
  stored,

  /// Picked for an entry that is not saved yet.
  staged,

  /// On its way to the server.
  waiting,

  /// The server would not keep the file.
  failed,

  /// The plan has no room for it.
  refused,
}

/// A bill as the app shows it: on the server already, or still on its way.
class BillView {
  const BillView({
    required this.id,
    required this.contentType,
    required this.status,
    this.entryId = '',
    this.cashbookId = '',
    this.originalName = '',
    this.sizeBytes = 0,
    this.pageCount,
    this.createdAt,
    this.localPath,
    this.error,
  });

  factory BillView.stored(EntryBill bill) => BillView(
        id: bill.id,
        entryId: bill.entryId,
        cashbookId: bill.cashbookId,
        contentType: bill.contentType,
        originalName: bill.originalName,
        sizeBytes: bill.sizeBytes,
        pageCount: bill.pageCount,
        createdAt: bill.createdAt,
        status: BillStatus.stored,
      );

  factory BillView.queued(BillQueueData job) => BillView(
        id: job.id,
        entryId: job.entryId,
        cashbookId: job.cashbookId,
        contentType: job.contentType,
        originalName: job.originalName,
        sizeBytes: job.sizeBytes,
        createdAt: job.createdAt,
        localPath: job.path,
        error: job.error,
        status: switch (job.state) {
          BillOutbox.failed => BillStatus.failed,
          BillOutbox.refused => BillStatus.refused,
          _ => BillStatus.waiting,
        },
      );

  /// Picked in a form whose entry is not saved yet; its id is made already.
  factory BillView.staged(PickedBill picked, String id) => BillView(
        id: id,
        contentType: picked.contentType,
        originalName: picked.name,
        sizeBytes: picked.sizeBytes,
        localPath: picked.path,
        status: BillStatus.staged,
      );

  final String id;
  final String entryId;
  final String cashbookId;
  final String contentType;
  final String originalName;
  final int sizeBytes;
  final int? pageCount;
  final String? createdAt;

  /// The file on this phone, for a bill not on the server yet.
  final String? localPath;
  final BillStatus status;

  /// For a failed or refused bill: a code from the server, or the plan feature.
  final String? error;

  bool get isPdf => contentType == pdfType;
  bool get isStored => status == BillStatus.stored;
  bool get needsAttention => status == BillStatus.failed || status == BillStatus.refused;

  /// Shared by the strip's tile and the viewer's page, so one flies into the other.
  String get heroTag => 'bill-$id';

  @override
  bool operator ==(Object other) =>
      other is BillView && other.id == id && other.status == status && other.error == error;

  @override
  int get hashCode => Object.hash(id, status, error);
}

/// Opening a bill failed: offline with no copy here, or gone from the server.
class BillUnavailable implements Exception {
  const BillUnavailable({required this.offline});

  final bool offline;
}

/// What the owner's plan allows for bills, as far as this phone knows.
class BillRules {
  const BillRules({this.fileMb, this.totalMb, this.pdf = true, this.usedBytes = 0, this.known = false});

  /// From the signed-in user's plan; only in their own business does it apply.
  factory BillRules.of(Entitlements? plan, Workspace? workspace) {
    if (plan == null || !plan.enforced || workspace?.role != 'owner') return const BillRules();
    return BillRules(
      fileMb: plan.limitOf(F.storageFileMb),
      totalMb: plan.limitOf(F.storageMb),
      pdf: plan.can(F.storagePdf),
      usedBytes: plan[F.storageMb]?.usedBytes ?? 0,
      known: true,
    );
  }

  /// Largest file the server reads on any plan.
  static const hardCapMb = 50;

  final int? fileMb;
  final int? totalMb;
  final bool pdf;
  final int usedBytes;

  /// False in someone else's business, where the owner's plan is not on this phone.
  final bool known;

  int get fileCapBytes => (fileMb == null || fileMb! > hardCapMb ? hardCapMb : fileMb!) * megabyte;
}

/// Bills of business entries: offline first, like everything else. A picked
/// file is copied in and queued at once (core/sync/bill_outbox.dart sends it
/// after its entry); removing one hides it at once and queues the removal.
class BillRepository {
  BillRepository(this.db, this.api, this.files, {this.onQueued});

  final AppDatabase db;
  final ApiClient api;
  final BillFiles files;

  /// Called after something was queued, so sync runs soon.
  final void Function()? onQueued;

  /// The entry's bills, oldest first: stored ones (less any being removed) and ones on their way.
  Stream<List<BillView>> watchForEntry(String entryId) => db
      .customSelect(
        'SELECT * FROM ('
        "  SELECT 's' AS kind, b.id, b.created_at FROM entry_bills b "
        '  WHERE b.entry_id = ?1 AND b.deleted_at IS NULL '
        "  AND b.id NOT IN (SELECT id FROM bill_queue WHERE op = 'remove') "
        '  UNION ALL '
        "  SELECT 'q' AS kind, q.id, q.created_at FROM bill_queue q WHERE q.entry_id = ?1 AND q.op = 'upload'"
        ') ORDER BY created_at, id',
        variables: [Variable<String>(entryId)],
        readsFrom: {db.entryBills, db.billQueue},
      )
      .watch()
      .asyncMap((rows) async {
        final stored = {
          for (final bill in await (db.select(db.entryBills)..where((b) => b.entryId.equals(entryId))).get()) bill.id: bill,
        };
        final queued = {
          for (final job in await (db.select(db.billQueue)..where((q) => q.entryId.equals(entryId))).get()) job.id: job,
        };
        final bills = [
          for (final row in rows)
            if (row.read<String>('kind') == 's')
              BillView.stored(stored[row.read<String>('id')]!)
            else
              BillView.queued(queued[row.read<String>('id')]!),
        ];
        // The server and the phone write times differently: order by the moment, not the text
        DateTime moment(BillView bill) => DateTime.tryParse(bill.createdAt ?? '') ?? DateTime(9999);
        return bills..sort((a, b) => moment(a).compareTo(moment(b)));
      });

  /// Bytes waiting to be sent from this phone, counted against the room left before the server has them.
  Future<int> waitingBytes() async {
    final total = db.billQueue.sizeBytes.sum();
    final row = await (db.selectOnly(db.billQueue)
          ..addColumns([total])
          ..where(db.billQueue.op.equals(BillOutbox.upload) & db.billQueue.state.equals(BillOutbox.queued)))
        .getSingle();
    return row.read(total) ?? 0;
  }

  /// Throws PlanLimitException when the plan would not take [picked], the
  /// way the server would refuse it, so the person hears at once. [alsoStaged]
  /// is what this form already holds that is not queued yet.
  Future<void> check(PickedBill picked, BillRules rules, {int alsoStaged = 0}) async {
    if (picked.sizeBytes > BillRules.hardCapMb * megabyte) {
      throw const PlanLimitException(F.storageFileMb, limit: BillRules.hardCapMb);
    }
    if (!rules.known) return;
    if (picked.isPdf && !rules.pdf) {
      throw const PlanLimitException(F.storagePdf, reason: PlanLimitException.reasonFeature);
    }
    if (picked.sizeBytes > rules.fileCapBytes) {
      throw PlanLimitException(F.storageFileMb, limit: rules.fileMb, current: (picked.sizeBytes / megabyte).ceil());
    }
    final total = rules.totalMb;
    if (total == null) return;
    final after = rules.usedBytes + await waitingBytes() + alsoStaged + picked.sizeBytes;
    if (after > total * megabyte) {
      throw PlanLimitException(F.storageMb, limit: total);
    }
  }

  /// Keeps [picked] as a bill of the entry and queues it. Returns the bill's id.
  Future<String> attach(
    PickedBill picked, {
    required String workspaceId,
    required String cashbookId,
    required String entryId,
    String? id,
  }) async {
    final billId = id ?? newId();
    final copy = await files.pending(billId, picked.contentType);
    await File(picked.path).copy(copy.path);
    await db.into(db.billQueue).insert(BillQueueCompanion.insert(
          id: billId,
          op: BillOutbox.upload,
          workspaceId: workspaceId,
          cashbookId: cashbookId,
          entryId: entryId,
          path: Value(copy.path),
          contentType: Value(picked.contentType),
          originalName: Value(picked.name),
          sizeBytes: Value(picked.sizeBytes),
          createdAt: nowIso(),
        ));
    onQueued?.call();
    return billId;
  }

  /// Takes the bill away. One not on the server yet simply goes; a stored one
  /// is hidden at once and its removal queued.
  Future<void> remove(BillView bill) async {
    if (!bill.isStored) {
      await (db.delete(db.billQueue)..where((q) => q.id.equals(bill.id))).go();
      await files.drop([bill.id]);
      return;
    }
    final stored = await (db.select(db.entryBills)..where((b) => b.id.equals(bill.id))).getSingleOrNull();
    if (stored == null) return;
    await db.into(db.billQueue).insertOnConflictUpdate(BillQueueCompanion.insert(
          id: bill.id,
          op: BillOutbox.remove,
          workspaceId: stored.workspaceId,
          cashbookId: stored.cashbookId,
          entryId: stored.entryId,
          createdAt: nowIso(),
        ));
    onQueued?.call();
  }

  /// Sends a failed or refused bill again, right away.
  Future<void> retry(BillView bill) async {
    await (db.update(db.billQueue)..where((q) => q.id.equals(bill.id))).write(const BillQueueCompanion(
      state: Value(BillOutbox.queued),
      error: Value(null),
      attempts: Value(0),
      nextTryAt: Value(null),
    ));
    onQueued?.call();
  }

  /// The entry is gone: what of its bills is still on the phone goes too. The
  /// server takes the stored ones with the entry.
  Future<void> forgetEntry(String entryId) => _forget(db.billQueue.entryId.equals(entryId));

  Future<void> forgetCashbook(String bookId) => _forget(db.billQueue.cashbookId.equals(bookId));

  Future<void> _forget(Expression<bool> which) async {
    final jobs = await (db.select(db.billQueue)..where((_) => which)).get();
    await (db.delete(db.billQueue)..where((_) => which)).go();
    await files.drop(jobs.map((job) => job.id));
  }

  /// The bill's file if this phone has a copy; never goes to the network.
  Future<File?> local(BillView bill) async {
    if (bill.localPath != null && await File(bill.localPath!).exists()) return File(bill.localPath!);
    return files.find(bill.id, bill.contentType);
  }

  /// The bill's file, from this phone when it has a copy, else fetched once
  /// through a short-lived link and kept. Throws BillUnavailable.
  Future<File> open(BillView bill) async {
    final here = await local(bill);
    if (here != null) return here;
    if (!bill.isStored) throw const BillUnavailable(offline: false);
    try {
      final link = await api.get('/api/v1/cashbooks/${bill.cashbookId}/entries/${bill.entryId}/bills/${bill.id}/link/');
      if (!link.ok || link.body is! Map) throw const BillUnavailable(offline: false);
      final response = await api.fetchFile('${link.json['url']}');
      if (response.statusCode != 200) throw const BillUnavailable(offline: false);
      final file = await files.cached(bill.id, bill.contentType);
      await file.writeAsBytes(response.bodyBytes, flush: true);
      return file;
    } on OfflineException {
      throw const BillUnavailable(offline: true);
    }
  }
}

final billRepositoryProvider = Provider<BillRepository>(
  (ref) => BillRepository(
    ref.watch(databaseProvider),
    ref.watch(apiClientProvider),
    ref.watch(billFilesProvider),
    onQueued: () => ref.read(syncControllerProvider.notifier).schedule(),
  ),
);

final entryBillsProvider = StreamProvider.family<List<BillView>, String>(
  (ref, entryId) => ref.watch(billRepositoryProvider).watchForEntry(entryId),
);

/// The bill's file if this phone has it, for previews that should not download (a PDF's first page).
final billLocalFileProvider = FutureProvider.autoDispose.family<File?, BillView>(
  (ref, bill) => ref.watch(billRepositoryProvider).local(bill),
);

/// The bill's file, fetched when first shown and kept for the life of the screen.
final billFileProvider = FutureProvider.autoDispose.family<File, BillView>(
  (ref, bill) => ref.watch(billRepositoryProvider).open(bill),
);
