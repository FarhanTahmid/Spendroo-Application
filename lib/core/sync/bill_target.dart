import 'package:drift/drift.dart';

import '../db/database.dart';

/// What a file is attached to: a business entry (a bill) or a personal
/// expense or income (a receipt). The pipeline (BillOutbox here, and
/// BillRepository and BillsSection in features/bills/) is the same for both;
/// this says where each one's files go on the server and where its stored
/// rows sit on the phone.
sealed class BillTarget {
  const BillTarget(this.workspaceId);

  /// The target a queued upload or removal was made for.
  factory BillTarget.ofJob(BillQueueData job) => job.transactionId == null
      ? EntryTarget(workspaceId: job.workspaceId, cashbookId: job.cashbookId, entryId: job.entryId)
      : TransactionTarget(workspaceId: job.workspaceId, transactionId: job.transactionId!);

  final String workspaceId;

  /// The row the files belong to.
  String get ownerId;

  /// The local table of that row. A file is sent once the server has the row.
  String get ownerTable;

  /// The local table of the files already on the server, and its column naming the owner.
  String get table;
  String get ownerColumn;

  bool get isReceipt => this is TransactionTarget;

  /// Where a file is sent, under which form fields, and the key of the answer's list.
  String get uploadPath;
  String get fileField;
  String get idField;
  String get responseKey;

  String removePath(String id);
  String linkPath(String id);

  /// The bill_queue row for an upload or removal of [id] for this target.
  BillQueueCompanion queueRow(String id, String op, {required String createdAt});

  /// The bill_queue rows of this target.
  Expression<bool> queued(BillQueue q);
}

final class EntryTarget extends BillTarget {
  const EntryTarget({required String workspaceId, required this.cashbookId, required this.entryId}) : super(workspaceId);

  EntryTarget.of(Entry entry) : this(workspaceId: entry.workspaceId, cashbookId: entry.cashbookId, entryId: entry.id);

  final String cashbookId;
  final String entryId;

  String get _entry => '/api/v1/cashbooks/$cashbookId/entries/$entryId';

  @override
  String get ownerId => entryId;
  @override
  String get ownerTable => 'entries';
  @override
  String get table => 'entry_bills';
  @override
  String get ownerColumn => 'entry_id';
  @override
  String get uploadPath => '$_entry/add-bill/';
  @override
  String get fileField => 'bill_file';
  @override
  String get idField => 'bill_id';
  @override
  String get responseKey => 'bills';
  @override
  String removePath(String id) => '$_entry/remove-bill/$id/';
  @override
  String linkPath(String id) => '$_entry/bills/$id/link/';

  @override
  BillQueueCompanion queueRow(String id, String op, {required String createdAt}) => BillQueueCompanion.insert(
        id: id,
        op: op,
        workspaceId: workspaceId,
        cashbookId: cashbookId,
        entryId: entryId,
        createdAt: createdAt,
      );

  @override
  Expression<bool> queued(BillQueue q) => q.entryId.equals(entryId) & q.transactionId.isNull();

  @override
  bool operator ==(Object other) => other is EntryTarget && other.entryId == entryId && other.cashbookId == cashbookId;

  @override
  int get hashCode => Object.hash('entry', entryId);
}

final class TransactionTarget extends BillTarget {
  const TransactionTarget({required String workspaceId, required this.transactionId}) : super(workspaceId);

  TransactionTarget.of(Transaction transaction) : this(workspaceId: transaction.workspaceId, transactionId: transaction.id);

  final String transactionId;

  String get _receipts => '/api/v1/ledger/transactions/$transactionId/receipts/';

  @override
  String get ownerId => transactionId;
  @override
  String get ownerTable => 'transactions';
  @override
  String get table => 'transaction_receipts';
  @override
  String get ownerColumn => 'transaction_id';
  @override
  String get uploadPath => _receipts;
  @override
  String get fileField => 'receipt_file';
  @override
  String get idField => 'receipt_id';
  @override
  String get responseKey => 'receipts';
  @override
  String removePath(String id) => '$_receipts$id/';
  @override
  String linkPath(String id) => '$_receipts$id/link/';

  @override
  BillQueueCompanion queueRow(String id, String op, {required String createdAt}) => BillQueueCompanion.insert(
        id: id,
        op: op,
        workspaceId: workspaceId,
        cashbookId: '',
        entryId: '',
        transactionId: Value(transactionId),
        createdAt: createdAt,
      );

  @override
  Expression<bool> queued(BillQueue q) => q.transactionId.equals(transactionId);

  @override
  bool operator ==(Object other) => other is TransactionTarget && other.transactionId == transactionId;

  @override
  int get hashCode => Object.hash('transaction', transactionId);
}
