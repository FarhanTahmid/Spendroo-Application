// Who was paid, or who paid: the merchant of a transaction, the party of an
// entry. The server keeps a normalised copy for matching (spendroo/merchant.py);
// the app normalises the same way to group the names it suggests.

/// As long as the server takes.
const maxMerchantLength = 100;

final _spaces = RegExp(r'\s+');
// Punctuation and symbols, except '&' (as in "H&M")
final _marks = RegExp(r'(?!&)[\p{P}\p{S}]', unicode: true);

/// Trimmed, with runs of whitespace collapsed to one space.
String tidyMerchant(String value) => value.replaceAll(_spaces, ' ').trim();

/// Lower-cased with punctuation dropped, so "Foodpanda" and "foodpanda." are one.
String normaliseMerchant(String value) =>
    value.toLowerCase().replaceAll(_marks, ' ').replaceAll(_spaces, ' ').trim();

/// Names used before, most used first and then most recent, each once in its
/// latest spelling. [recentFirst] is every use, newest first.
List<String> rankMerchants(Iterable<String> recentFirst) {
  final spelling = <String, String>{};
  final uses = <String, int>{};
  final order = <String>[];
  for (final name in recentFirst) {
    final key = normaliseMerchant(name);
    if (key.isEmpty) continue;
    if (!spelling.containsKey(key)) {
      spelling[key] = tidyMerchant(name);
      order.add(key);
    }
    uses[key] = (uses[key] ?? 0) + 1;
  }
  final ranked = [...order]..sort((a, b) {
      final byUse = uses[b]!.compareTo(uses[a]!);
      return byUse != 0 ? byUse : order.indexOf(a).compareTo(order.indexOf(b));
    });
  return [for (final key in ranked) spelling[key]!];
}

/// The names worth offering for what is typed: those starting with it first,
/// then those containing it; not the name exactly as typed.
List<String> suggestMerchants(List<String> known, String typed, {int limit = 5}) {
  final query = normaliseMerchant(typed);
  if (query.isEmpty) return const [];
  final starts = <String>[];
  final contains = <String>[];
  for (final name in known) {
    final key = normaliseMerchant(name);
    if (key == query && name == tidyMerchant(typed)) continue;
    if (key.startsWith(query)) {
      starts.add(name);
    } else if (key.contains(query)) {
      contains.add(name);
    }
  }
  return [...starts, ...contains].take(limit).toList();
}
