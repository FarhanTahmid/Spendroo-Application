import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/local_store.dart';
import '../../core/providers.dart';
import 'merchants.dart';

/// As long as the server takes.
const maxTagName = 40;

/// The workspace's tags, and the merchants its rows were paid to or by.
class TagRepository {
  TagRepository(this.db, this.store);

  final AppDatabase db;
  final LocalStore store;

  Stream<List<Tag>> watchTags(String workspaceId) => (db.select(db.workspaceTags)
        ..where((t) => t.workspaceId.equals(workspaceId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm(expression: t.name.collate(Collate.noCase))]))
      .watch();

  /// A tag of that name already there is used rather than made twice; returns its id.
  Future<String> addTag(String workspaceId, String name, {String? color}) async {
    final clean = tidyMerchant(name);
    final same = await (db.select(db.workspaceTags)
          ..where((t) =>
              t.workspaceId.equals(workspaceId) & t.deletedAt.isNull() & t.name.lower().equals(clean.toLowerCase()))
          ..limit(1))
        .getSingleOrNull();
    if (same != null) return same.id;
    return store.create('tags', workspaceId, {'name': clean, if (color != null) 'color': color});
  }

  /// Sends only what differs from [tag]. A null [color] hands the choice back to the app.
  Future<void> updateTag(Tag tag, {required String name, required String? color}) async {
    final clean = tidyMerchant(name);
    final changes = {
      if (clean != tag.name) 'name': clean,
      if (color != tag.color) 'color': color,
    };
    if (changes.isEmpty) return;
    await store.update('tags', tag.id, changes);
  }

  /// Only the tag goes: rows that carry it keep their other tags, and skip this one.
  Future<void> deleteTag(Tag tag) => store.remove('tags', tag.id);

  /// Transactions and entries carrying the tag, for the warning before deleting it.
  Future<int> useCount(String tagId) async {
    const carries = 'deleted_at IS NULL AND EXISTS (SELECT 1 FROM json_each(tag_ids) j WHERE j.value = ?1)';
    final row = await db.customSelect(
      'SELECT (SELECT COUNT(*) FROM transactions WHERE $carries) + (SELECT COUNT(*) FROM entries WHERE $carries) AS n',
      variables: [Variable.withString(tagId)],
      readsFrom: {db.transactions, db.entries},
    ).getSingle();
    return row.read<int>('n');
  }

  /// Merchants of the workspace's transactions, or parties of its entries
  /// ([entries]), as [rankMerchants] orders them.
  Stream<List<String>> watchMerchants(String workspaceId, {bool entries = false}) {
    final (table, date) = entries ? ('entries', 'entry_date') : ('transactions', 'occurred_on');
    return db
        .customSelect(
          'SELECT merchant FROM $table WHERE workspace_id = ? AND deleted_at IS NULL AND merchant <> \'\' '
          'ORDER BY $date DESC, created_at DESC LIMIT 2000',
          variables: [Variable.withString(workspaceId)],
          readsFrom: {entries ? db.entries : db.transactions},
        )
        .watch()
        .map((rows) => rankMerchants(rows.map((row) => row.read<String>('merchant'))));
  }
}

final tagRepositoryProvider = Provider<TagRepository>(
  (ref) => TagRepository(ref.watch(databaseProvider), ref.watch(localStoreProvider)),
);

final tagsProvider = StreamProvider.family<List<Tag>, String>(
  (ref, workspaceId) => ref.watch(tagRepositoryProvider).watchTags(workspaceId),
);

/// Live tags by id: what a row's `tag_ids` are read through, so a deleted tag drops out.
final tagNamesProvider = Provider.family<Map<String, Tag>, String>(
  (ref, workspaceId) => {for (final tag in ref.watch(tagsProvider(workspaceId)).value ?? const <Tag>[]) tag.id: tag},
);

/// Merchant suggestions for a workspace; `entries` asks for the parties of its cashbook entries.
final merchantsProvider = StreamProvider.family<List<String>, (String, {bool entries})>(
  (ref, key) => ref.watch(tagRepositoryProvider).watchMerchants(key.$1, entries: key.entries),
);
