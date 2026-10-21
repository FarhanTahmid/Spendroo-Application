import 'dart:convert';

// The `tag_ids` column of transactions and entries: a JSON list of the
// workspace's tag ids. The server keeps only live tags of the workspace when
// the list is sent (tags/cleaning.py); a tag deleted since stays named until
// the row is next edited, and every reader skips it.

/// At most this many tags on one row, as on the server.
const maxTagsPerRow = 10;

/// The ids held in a `tag_ids` column; none when the text is not a list.
List<String> decodeTagIds(String text) {
  if (text.isEmpty || text == '[]') return const [];
  try {
    return [for (final id in jsonDecode(text) as List) if (id is String) id];
  } on Object {
    return const [];
  }
}

/// Same tags in the same order.
bool sameTagIds(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
