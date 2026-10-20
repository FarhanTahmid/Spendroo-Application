import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/local_store.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/entitlements/plan_guard.dart';
import '../../core/money.dart';
import '../../core/providers.dart';

/// What a field holds. Fixed once the field exists: values already kept
/// would not fit another kind.
abstract final class FieldKind {
  static const text = 'text';
  static const number = 'number';
  static const date = 'date';
  static const choice = 'choice';
  static const all = [text, number, date, choice];
}

/// The same limits the server keeps (cashbook/custom_fields.py).
abstract final class FieldLimits {
  static const fields = 20;
  static const name = 60;
  static const options = 30;
  static const text = 500;
}

/// What a choice field offers, in order. Bad JSON reads as none.
List<String> optionsOf(EntryField field) {
  try {
    return [for (final option in jsonDecode(field.options) as List) option as String];
  } on Object {
    return const [];
  }
}

/// An entry's values for its book's fields: {field id: value as text}.
Map<String, String> customValuesOf(Entry entry) => decodeValues(entry.customValues);

Map<String, String> decodeValues(String? json) {
  if (json == null || json.isEmpty) return const {};
  try {
    return {
      for (final MapEntry(:key, :value) in (jsonDecode(json) as Map).entries)
        if (value is String && value.trim().isNotEmpty) key as String: value,
    };
  } on Object {
    return const {};
  }
}

/// The map as kept: blank values dropped.
Map<String, String> cleanValues(Map<String, String> values) => {
      for (final MapEntry(:key, :value) in values.entries)
        if (value.trim().isNotEmpty) key: value.trim(),
    };

bool sameValues(Map<String, String> a, Map<String, String> b) =>
    a.length == b.length && a.entries.every((entry) => b[entry.key] == entry.value);

final _number = RegExp(r'^-?(0|[1-9]\d{0,14})(\.\d{0,5}[1-9])?$');

/// A typed number as the server keeps it ("1,200.50" or "১২০০.৫" → "1200.5"),
/// or null when it is not one.
String? canonicalNumber(String input) {
  var text = Money.toAsciiDigits(input).replaceAll(RegExp(r'[,\s]'), '').replaceAll('−', '-');
  if (text.isEmpty) return null;
  final match = RegExp(r'^(-?)(\d+)?(?:\.(\d*))?$').firstMatch(text);
  if (match == null || (match[2] == null && (match[3] ?? '').isEmpty)) return null;
  var whole = (match[2] ?? '0').replaceFirst(RegExp(r'^0+(?=\d)'), '');
  var fraction = (match[3] ?? '').replaceFirst(RegExp(r'0+$'), '');
  final negative = match[1] == '-' && !(whole == '0' && fraction.isEmpty);
  text = '${negative ? '-' : ''}$whole${fraction.isEmpty ? '' : '.$fraction'}';
  return _number.hasMatch(text) ? text : null;
}

class FieldRepository {
  FieldRepository(this.db, this.store, [this.plan]);

  final AppDatabase db;
  final LocalStore store;

  /// Refuses what the plan does not allow before anything is written. The
  /// server asks again either way.
  final PlanGuard? plan;

  Stream<List<EntryField>> watchFields(String bookId) => (db.select(db.entryFields)
        ..where((f) => f.cashbookId.equals(bookId) & f.deletedAt.isNull())
        ..orderBy([(f) => OrderingTerm.asc(f.position), (f) => OrderingTerm.asc(f.createdAt)]))
      .watch();

  Future<List<EntryField>> fieldsOf(String bookId) => (db.select(db.entryFields)
        ..where((f) => f.cashbookId.equals(bookId) & f.deletedAt.isNull())
        ..orderBy([(f) => OrderingTerm.asc(f.position), (f) => OrderingTerm.asc(f.createdAt)]))
      .get();

  /// Whether another live field of the book already goes by [name], whatever the case.
  Future<bool> nameTaken(String bookId, String name, {String? except}) async {
    final wanted = name.trim().toLowerCase();
    return (await fieldsOf(bookId)).any((f) => f.id != except && f.name.toLowerCase() == wanted);
  }

  Future<void> _allowed(Cashbook book) async {
    plan?.writable(F.businessCashbooks, book.id);
    await plan?.require(F.customFields, book.workspaceId);
  }

  Future<String> add(
    Cashbook book, {
    required String name,
    required String kind,
    List<String> options = const [],
    bool isRequired = false,
    bool showInList = false,
  }) async {
    await _allowed(book);
    final fields = await fieldsOf(book.id);
    return db.transaction(() async {
      if (showInList) await _unpin(fields);
      return store.create('entry_fields', book.workspaceId, {
        'cashbook_id': book.id,
        'name': name.trim(),
        'kind': kind,
        'options': kind == FieldKind.choice ? options : <String>[],
        'required': isRequired,
        'show_in_list': showInList,
        'position': fields.isEmpty ? 0 : fields.map((f) => f.position).reduce((a, b) => a > b ? a : b) + 1,
      });
    });
  }

  /// Sends only what differs from [field]. Pinning a field unpins the one before.
  Future<void> update(
    Cashbook book,
    EntryField field, {
    required String name,
    List<String> options = const [],
    required bool isRequired,
    required bool showInList,
  }) async {
    final changes = <String, Object?>{
      if (name.trim() != field.name) 'name': name.trim(),
      if (field.kind == FieldKind.choice && !_sameList(options, optionsOf(field))) 'options': options,
      if (isRequired != field.isRequired) 'required': isRequired,
      if (showInList != field.showInList) 'show_in_list': showInList,
    };
    if (changes.isEmpty) return;
    await _allowed(book);
    final others = (await fieldsOf(book.id)).where((f) => f.id != field.id).toList();
    await db.transaction(() async {
      if (showInList && !field.showInList) await _unpin(others);
      await store.update('entry_fields', field.id, changes);
    });
  }

  /// Puts [ordered] in that order, sending only the fields that moved.
  Future<void> reorder(Cashbook book, List<EntryField> ordered) async {
    final moved = [
      for (final (index, field) in ordered.indexed)
        if (field.position != index) (field, index),
    ];
    if (moved.isEmpty) return;
    await _allowed(book);
    await db.transaction(() async {
      for (final (field, index) in moved) {
        await store.update('entry_fields', field.id, {'position': index});
      }
    });
  }

  /// Never refused by the plan: removing is how a downgraded book is tidied.
  /// Entries keep their values; they are no longer shown.
  Future<void> delete(EntryField field) => store.remove('entry_fields', field.id);

  Future<void> _unpin(List<EntryField> fields) async {
    for (final other in fields.where((f) => f.showInList)) {
      await store.update('entry_fields', other.id, {'show_in_list': false});
    }
  }

  static bool _sameList(List<String> a, List<String> b) =>
      a.length == b.length && [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((same) => same);
}

final fieldRepositoryProvider = Provider<FieldRepository>(
  (ref) => FieldRepository(ref.watch(databaseProvider), ref.watch(localStoreProvider), ref.watch(planGuardProvider)),
);

final entryFieldsProvider = StreamProvider.family<List<EntryField>, String>(
  (ref, bookId) => ref.watch(fieldRepositoryProvider).watchFields(bookId),
);
