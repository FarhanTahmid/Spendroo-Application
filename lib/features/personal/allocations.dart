import 'dart:convert';

import '../../core/db/database.dart';

// How a transaction is filed: under one category, or split into parts that
// each have their own. Everything that adds up or picks by category reads it
// here, so a split is counted the same way in a list, a total and a budget.
// The server does the same over its own copy (ledger_personal/allocations.py).

const minSplitParts = 2;
const maxSplitParts = 20;
const maxSplitNote = 100;

/// One part of a split transaction. A part with no category is money not yet filed.
class SplitPart {
  const SplitPart(this.categoryId, this.amountMinor, {this.note = ''});

  final String? categoryId;

  /// Always positive; the sign is the transaction's.
  final int amountMinor;
  final String note;

  /// As the server stores it.
  Map<String, Object?> toJson() => {'category_id': categoryId, 'amount_minor': amountMinor, 'note': note};

  SplitPart withCategory(String? id) => SplitPart(id, amountMinor, note: note);

  @override
  bool operator ==(Object other) =>
      other is SplitPart && other.categoryId == categoryId && other.amountMinor == amountMinor && other.note == note;

  @override
  int get hashCode => Object.hash(categoryId, amountMinor, note);

  /// The parts held in a `splits` column; none when the text is not a split.
  static List<SplitPart> decode(String splits) {
    if (splits.isEmpty || splits == '[]') return const [];
    try {
      return [
        for (final part in (jsonDecode(splits) as List).cast<Map<String, dynamic>>())
          SplitPart(part['category_id'] as String?, part['amount_minor'] as int, note: (part['note'] as String?) ?? ''),
      ];
    } on Object {
      return const [];
    }
  }

  static List<Map<String, Object?>> encode(List<SplitPart> parts) => [for (final part in parts) part.toJson()];

  static bool same(List<SplitPart> a, List<SplitPart> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

extension TransactionParts on Transaction {
  List<SplitPart> get parts => SplitPart.decode(splits);
  bool get isSplit => splits != '[]' && splits.isNotEmpty;
}

/// Joined after `transactions t`: one row `p` for each part of the
/// transaction, an unsplit one being its own single part.
const partsJoin = "JOIN json_each(CASE WHEN t.splits = '[]' THEN "
    "json_array(json_object('category_id', t.category_id, 'amount_minor', ABS(t.amount_minor))) "
    'ELSE t.splits END) p ';

/// With [partsJoin]: the category of the part, and its amount carrying the transaction's sign.
const partCategory = r"json_extract(p.value, '$.category_id')";
const partAmount = r"((CASE WHEN t.amount_minor < 0 THEN -1 ELSE 1 END) * json_extract(p.value, '$.amount_minor'))";

final _id = RegExp(r'^[0-9a-fA-F-]{1,40}$');

/// Ids as a SQL list. They are written into the statement, so anything that
/// is not an id is dropped.
String _idList(Iterable<String> ids) => ids.where(_id.hasMatch).map((id) => "'$id'").join(', ');

/// Whether the part in [category] (an expression) is one a choice of categories keeps.
String _chosen(String category, Iterable<String> categoryIds, bool uncategorised) {
  final ids = _idList(categoryIds);
  return [
    if (ids.isNotEmpty) '$category IN ($ids)',
    if (uncategorised) '$category IS NULL',
    if (ids.isEmpty && !uncategorised) '0',
  ].join(' OR ');
}

/// With [partsJoin]: the parts a choice of categories keeps.
String partChosen(Iterable<String> categoryIds, {bool uncategorised = false}) =>
    '(${_chosen(partCategory, categoryIds, uncategorised)})';

/// Over `t`: the transactions with at least one part a choice of categories
/// keeps. A transfer never has a category, so "uncategorised" means income
/// and expenses.
String filedUnder(Iterable<String> categoryIds, {bool uncategorised = false}) {
  const inner = r"json_extract(s.value, '$.category_id')";
  return "((t.splits = '[]' AND t.kind != 'transfer' AND (${_chosen('t.category_id', categoryIds, uncategorised)})) "
      "OR (t.splits != '[]' AND EXISTS (SELECT 1 FROM json_each(t.splits) s "
      'WHERE ${_chosen(inner, categoryIds, uncategorised)})))';
}

/// Over `t`: what the transaction counts for under a choice of categories,
/// signed. A split counts for its chosen parts only.
String countedAmount(Iterable<String> categoryIds, {bool uncategorised = false}) {
  const inner = r"json_extract(s.value, '$.category_id')";
  return "(CASE WHEN t.splits = '[]' THEN t.amount_minor ELSE (CASE WHEN t.amount_minor < 0 THEN -1 ELSE 1 END) * "
      r"(SELECT COALESCE(SUM(json_extract(s.value, '$.amount_minor')), 0) FROM json_each(t.splits) s "
      'WHERE ${_chosen(inner, categoryIds, uncategorised)}) END)';
}
