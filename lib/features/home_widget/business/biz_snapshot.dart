import 'dart:convert';

/// The JSON the business and cashbook widgets read (android/.../widget/business/BizSnapshot.kt).
/// As with the personal widget, every amount and word is formatted here, so the
/// Android code never knows about money or languages.
///
/// Stored under three kinds of key in home_widget's preferences:
/// - [BizCatalog.key]: what the picker offers, the plan, and the widgets' words;
/// - `biz_<workspace id>`: one business, every book in its main currency;
/// - `book_<cashbook id>`: one cashbook.
abstract final class BizKeys {
  static const catalog = 'biz_catalog';

  /// The list of keys last published, so ones that are gone can be removed on the next start.
  static const published = 'biz_keys';

  static String business(String workspaceId) => 'biz_$workspaceId';
  static String book(String bookId) => 'book_$bookId';
}

/// Bumped when the shape changes in a way older widget code cannot read.
const bizSnapshotVersion = 1;

/// A tone the widget colours text by.
enum BizTone { good, warn, info }

/// Money in, out and net over one stretch of days, with how in and out compare
/// with the stretch before it.
class BizPeriod {
  const BizPeriod({
    required this.label,
    required this.compare,
    required this.inText,
    required this.outText,
    required this.netText,
    required this.netNegative,
    this.inChange,
    this.inChangeGood = true,
    this.outChange,
    this.outChangeGood = true,
  });

  /// "Today", "7 days", "October".
  final String label;

  /// "vs yesterday": what the changes are measured against.
  final String compare;
  final String inText;
  final String outText;

  /// In less out, signed ("+৳1,200", "-৳300").
  final String netText;
  final bool netNegative;

  /// "▲12%"; null without anything to compare with.
  final String? inChange;
  final bool inChangeGood;
  final String? outChange;
  final bool outChangeGood;

  Map<String, Object?> toJson() => {
    'label': label,
    'compare': compare,
    'in': inText,
    'out': outText,
    'net': netText,
    'netNegative': netNegative,
    'inChange': inChange,
    'inGood': inChangeGood,
    'outChange': outChange,
    'outGood': outChangeGood,
  };
}

/// One line of advice, picked and ranked by biz_insights.dart.
class BizInsight {
  const BizInsight({
    required this.kind,
    required this.text,
    required this.masked,
    required this.tone,
    required this.until,
    required this.score,
  });

  /// Which rule made it ('negative', 'idle', ...): for tests and the icon.
  final String kind;
  final String text;

  /// The same advice without amounts, for while amounts are hidden.
  final String masked;
  final BizTone tone;

  /// The last day (yyyy-MM-dd) it still holds without the app updating it.
  final String until;

  /// Higher first.
  final int score;

  Map<String, Object?> toJson() => {'kind': kind, 'text': text, 'masked': masked, 'tone': tone.name, 'until': until};
}

/// A line in the widget's list: a book of a business, or an entry of a book.
class BizRow {
  const BizRow({required this.title, required this.amount, required this.negative, this.detail, this.link});

  final String title;

  /// "12 Oct", or a book's entry count.
  final String? detail;
  final String amount;
  final bool negative;

  /// Where tapping the row leads (a spendroo:// link), if anywhere.
  final String? link;

  Map<String, Object?> toJson() => {
    'title': title,
    'detail': detail,
    'amount': amount,
    'negative': negative,
    'link': link,
  };
}

/// Everything one business or cashbook widget draws.
class BizSnapshot {
  const BizSnapshot({
    required this.kind,
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.subtitle,
    required this.date,
    required this.balance,
    required this.balanceNegative,
    required this.mask,
    required this.zero,
    required this.canAdd,
    required this.today,
    required this.week,
    required this.month,
    required this.weekRoll,
    required this.dailyIn,
    required this.dailyOut,
    required this.dayLabels,
    required this.insights,
    required this.rows,
    this.updated = '',
  });

  /// 'business' or 'book'.
  final String kind;

  /// The workspace id of a business, the cashbook id of a book.
  final String id;
  final String workspaceId;
  final String name;

  /// A book's business; a business's "3 books" (and "+1 in USD" when some are left out).
  final String subtitle;

  /// The day the figures are for, yyyy-MM-dd.
  final String date;
  final String balance;
  final bool balanceNegative;
  final String mask;

  /// Nothing, formatted the same way: what today reads once the day is over.
  final String zero;

  /// The user may add entries here (any one book, for a business).
  final bool canAdd;

  final BizPeriod today;

  /// The seven days ending [date].
  final BizPeriod week;

  /// The month so far.
  final BizPeriod month;

  /// The seven days ending each of the next six days, if nothing more is added:
  /// what the widget shows for "7 days" after midnight while the app stays closed.
  final List<BizPeriod> weekRoll;

  /// Money in and out on each of the 14 days ending [date] (index 13 is that day).
  final List<int> dailyIn;
  final List<int> dailyOut;

  /// Day-of-month labels for the 14 days ending [date] and the 6 after it.
  final List<String> dayLabels;

  /// Ranked, best first.
  final List<BizInsight> insights;

  /// A business's books by balance, or a book's latest entries.
  final List<BizRow> rows;

  /// When the figures last changed, as the clock shows it.
  final String updated;

  BizSnapshot stamped(String time) => BizSnapshot(
    kind: kind,
    id: id,
    workspaceId: workspaceId,
    name: name,
    subtitle: subtitle,
    date: date,
    balance: balance,
    balanceNegative: balanceNegative,
    mask: mask,
    zero: zero,
    canAdd: canAdd,
    today: today,
    week: week,
    month: month,
    weekRoll: weekRoll,
    dailyIn: dailyIn,
    dailyOut: dailyOut,
    dayLabels: dayLabels,
    insights: insights,
    rows: rows,
    updated: time,
  );

  Map<String, Object?> toJson() => {
    'v': bizSnapshotVersion,
    'kind': kind,
    'id': id,
    'workspaceId': workspaceId,
    'name': name,
    'subtitle': subtitle,
    'date': date,
    'balance': balance,
    'balanceNegative': balanceNegative,
    'mask': mask,
    'zero': zero,
    'canAdd': canAdd,
    'today': today.toJson(),
    'week': week.toJson(),
    'month': month.toJson(),
    'weekRoll': [for (final period in weekRoll) period.toJson()],
    'dailyIn': dailyIn,
    'dailyOut': dailyOut,
    'dayLabels': dayLabels,
    'insights': [for (final insight in insights) insight.toJson()],
    'rows': [for (final row in rows) row.toJson()],
    'updated': updated,
  };

  String encode() => jsonEncode(toJson());

  /// The same figures, whatever time they were stamped with.
  String get fingerprint => stamped('').encode();
}

/// A book as the picker lists it.
class BizCatalogBook {
  const BizCatalogBook({required this.id, required this.name, required this.detail});

  final String id;
  final String name;

  /// "৳12,400 · 38 entries".
  final String detail;

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'detail': detail};
}

class BizCatalogBusiness {
  const BizCatalogBusiness({required this.id, required this.name, required this.detail, required this.books});

  final String id;
  final String name;

  /// "3 books".
  final String detail;
  final List<BizCatalogBook> books;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'detail': detail,
    'books': [for (final book in books) book.toJson()],
  };
}

/// What every business widget shares: who is signed in, the plan, the words,
/// and the businesses and books the picker offers.
class BizCatalog {
  const BizCatalog({required this.signedIn, required this.unlocked, required this.strings, this.businesses = const []});

  final bool signedIn;

  /// The plan has the big sizes (widget.business).
  final bool unlocked;
  final Map<String, String> strings;
  final List<BizCatalogBusiness> businesses;

  Map<String, Object?> toJson() => {
    'v': bizSnapshotVersion,
    'signedIn': signedIn,
    'unlocked': unlocked,
    'strings': strings,
    'businesses': [for (final business in businesses) business.toJson()],
  };

  String encode() => jsonEncode(toJson());
}

/// The catalog and every snapshot, by key: what one publish hands the widgets.
class BizPublication {
  const BizPublication(this.catalog, this.snapshots);

  final BizCatalog catalog;
  final Map<String, BizSnapshot> snapshots;
}
