import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../api/api_client.dart';
import '../db/database.dart';
import '../db/local_store.dart';
import 'bill_files.dart';
import 'bill_target.dart';

/// Sends the bills and receipts waiting in bill_queue, after each sync.
///
/// A file goes once the entry or transaction it belongs to is on the server:
/// that row travels in the sync outbox, the file in a request of its own
/// (features/bills/bill_target.dart says where). Each upload carries the id
/// the file was given here, so a resend after a lost answer stores nothing
/// twice. When the server cannot be reached a bill waits longer each time;
/// when it refuses the file or the plan has no room, the bill stays on the
/// phone, marked, for the person to retry or remove.
class BillOutbox {
  BillOutbox(
    this.db,
    this.api,
    this.store,
    this.files, {
    this.onPlanLimit,
    this.onProgress,
    this.onStored,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final ApiClient api;
  final LocalStore store;
  final BillFiles files;

  /// The server's 402 body for a file the plan has no room for.
  final void Function(Map<String, dynamic> refusal)? onPlanLimit;

  /// The share of a bill sent so far, 0 to 1; null once it is done either way.
  final void Function(String billId, double? sent)? onProgress;

  /// Storage changed on the server: the plan's numbers are worth fetching again.
  final void Function()? onStored;

  final DateTime Function() _clock;

  static const queued = 'queued';
  static const failed = 'failed';
  static const refused = 'refused';
  static const upload = 'upload';
  static const remove = 'remove';

  /// Code for a waiting file that is no longer on the phone.
  static const missing = 'bill_missing';

  static const _firstWait = Duration(seconds: 30);
  static const _longestWait = Duration(minutes: 30);

  bool _running = false;

  /// One pass over the queue. Throws OfflineException when the server cannot
  /// be reached; what was not sent waits for the next pass.
  Future<void> run() async {
    if (_running) return;
    _running = true;
    var stored = false;
    try {
      final jobs = await (db.select(db.billQueue)
            ..where((q) => q.state.equals(queued))
            ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
          .get();
      final now = _clock();
      for (final job in jobs) {
        final due = job.nextTryAt == null ? null : DateTime.tryParse(job.nextTryAt!);
        if (due != null && due.isAfter(now)) continue;
        try {
          stored = (job.op == upload ? await _upload(job) : await _remove(job)) || stored;
        } on OfflineException {
          await _later(job);
          rethrow;
        }
      }
      await files.keepOnly(await _billsOnPhone());
    } finally {
      _running = false;
      if (stored) onStored?.call();
    }
  }

  /// True when the server now holds a file it did not before.
  Future<bool> _upload(BillQueueData job) async {
    final target = BillTarget.ofJob(job);
    final owner = await db
        .customSelect(
          'SELECT server_seq, deleted_at FROM ${target.ownerTable} WHERE id = ?',
          variables: [Variable<String>(target.ownerId)],
        )
        .getSingleOrNull();
    if (owner == null || owner.read<String?>('deleted_at') != null) {
      await _forget(job);
      return false;
    }
    // The entry or transaction goes first; until the server has it there is nothing to attach to
    if (owner.read<int>('server_seq') == 0 || await _ownerWaiting(target.ownerId)) return false;

    final file = job.path == null ? null : File(job.path!);
    if (file == null || !await file.exists()) {
      await _mark(job, failed, missing);
      return false;
    }
    final bytes = await file.readAsBytes();
    final ApiResponse response;
    try {
      response = await api.upload(
        target.uploadPath,
        field: target.fileField,
        bytes: bytes,
        filename: job.originalName.isEmpty ? '${job.id}.${BillFiles.extensionFor(job.contentType)}' : job.originalName,
        contentType: job.contentType,
        fields: {target.idField: job.id},
        onProgress: (sent) => onProgress?.call(job.id, sent),
      );
    } finally {
      onProgress?.call(job.id, null);
    }

    final body = response.body;
    final stored = body is Map ? body[target.responseKey] : null;
    if (response.ok && stored is List && stored.isNotEmpty) {
      final row = (stored.first as Map).cast<String, Object?>();
      await db.transaction(() async {
        await store.upsertRow(target.table, row);
        await (db.delete(db.billQueue)..where((q) => q.id.equals(job.id))).go();
      });
      await files.adopt(file, job.id, '${row['content_type'] ?? job.contentType}');
      return true;
    }
    switch (response.statusCode) {
      case 402:
        await _mark(job, refused, body is Map ? '${body['feature'] ?? ''}' : null);
        if (body is Map) onPlanLimit?.call(body.cast<String, dynamic>());
      case 400 || 409 || 413:
        await _mark(job, failed, body is Map ? '${body['code'] ?? 'bill_refused'}' : 'bill_refused');
      case 403:
        await _mark(job, failed, 'bill_forbidden');
      case 404:
        await _mark(job, failed, 'bill_gone');
      default:
        await _later(job); // the server is having trouble: try again in a while
    }
    return false;
  }

  Future<bool> _remove(BillQueueData job) async {
    final target = BillTarget.ofJob(job);
    final response = await api.delete(target.removePath(job.id));
    if (response.ok || response.statusCode == 404) {
      await db.transaction(() async {
        final now = nowIso();
        await db.customUpdate(
          'UPDATE ${target.table} SET deleted_at = ?1, updated_at = ?1 WHERE id = ?2',
          variables: [Variable<String>(now), Variable<String>(job.id)],
          updates: {db.tableByName(target.table)},
        );
        await (db.delete(db.billQueue)..where((q) => q.id.equals(job.id))).go();
      });
      await files.drop([job.id]);
      return true;
    }
    if (response.statusCode == 403) {
      // Not this person's to remove after all: the file shows again
      await (db.delete(db.billQueue)..where((q) => q.id.equals(job.id))).go();
      return false;
    }
    await _later(job);
    return false;
  }

  Future<bool> _ownerWaiting(String rowId) async =>
      await (db.select(db.outbox)..where((o) => o.rowId.equals(rowId))..limit(1)).getSingleOrNull() != null;

  /// Every file the phone should keep: stored bills and receipts, and what is queued.
  Future<Set<String>> _billsOnPhone() async {
    final rows = await db.customSelect(
      'SELECT id FROM entry_bills WHERE deleted_at IS NULL '
      'UNION SELECT id FROM transaction_receipts WHERE deleted_at IS NULL '
      'UNION SELECT id FROM bill_queue',
    ).get();
    return {for (final row in rows) row.read<String>('id')};
  }

  Future<void> _mark(BillQueueData job, String state, String? error) =>
      (db.update(db.billQueue)..where((q) => q.id.equals(job.id)))
          .write(BillQueueCompanion(state: Value(state), error: Value(error)));

  /// Waits twice as long as last time before trying again, up to half an hour.
  Future<void> _later(BillQueueData job) {
    final attempts = job.attempts + 1;
    final seconds = math.min(_firstWait.inSeconds * math.pow(2, attempts - 1), _longestWait.inSeconds).toInt();
    return (db.update(db.billQueue)..where((q) => q.id.equals(job.id))).write(BillQueueCompanion(
      attempts: Value(attempts),
      nextTryAt: Value(_clock().add(Duration(seconds: seconds)).toUtc().toIso8601String()),
    ));
  }

  Future<void> _forget(BillQueueData job) async {
    await (db.delete(db.billQueue)..where((q) => q.id.equals(job.id))).go();
    await files.drop([job.id]);
  }
}
