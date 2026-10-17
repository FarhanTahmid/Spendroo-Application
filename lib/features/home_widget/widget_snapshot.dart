import 'dart:convert';

/// How the widget reads the money in a snapshot.
enum PaceTone {
  /// Budget left: what can still go out each day.
  safe,

  /// The month's budgets are spent.
  over,

  /// No budget: the daily average, shown plainly.
  average,
}

/// A small figure on the widget with its caption.
class WidgetStat {
  const WidgetStat(this.label, this.value);

  final String label;
  final String value;

  Map<String, Object?> toJson() => {'label': label, 'value': value};
}

/// Everything the home-screen widget draws, worked out on the Dart side so
/// the Android code never formats money or picks words itself. The widget
/// reads it from the shared preferences home_widget writes to
/// (android/.../widget/WidgetSnapshot.kt parses it).
///
/// Figures belong to [date]. When the phone has moved on to another day the
/// widget shows [zero] for today, and in another month for the month too.
class HomeWidgetSnapshot {
  const HomeWidgetSnapshot.signedOut({required this.strings})
      : signedIn = false,
        unlocked = false,
        date = '',
        today = '',
        zero = '',
        mask = '',
        monthName = '',
        monthLabel = '',
        monthTotal = '',
        middle = null,
        left = const WidgetStat('', ''),
        leftNegative = false,
        pace = null,
        paceTone = PaceTone.average,
        daily = const [],
        budgetPerDayMinor = 0,
        axis = const [],
        updated = '';

  const HomeWidgetSnapshot({
    required this.unlocked,
    required this.date,
    required this.today,
    required this.zero,
    required this.mask,
    required this.monthName,
    required this.monthLabel,
    required this.monthTotal,
    required this.middle,
    required this.left,
    required this.leftNegative,
    required this.pace,
    required this.paceTone,
    required this.daily,
    required this.budgetPerDayMinor,
    required this.axis,
    required this.strings,
    this.updated = '',
  }) : signedIn = true;

  /// Bumped when the shape changes in a way older widget code cannot read.
  static const version = 1;

  final bool signedIn;

  /// The plan has the widget (widget.home). Without it the bigger sizes
  /// show what the plan would add in place of the month's figures.
  final bool unlocked;

  /// The day the figures are for, yyyy-MM-dd.
  final String date;

  /// Spent today, formatted: a small figure beside the month's.
  final String today;

  /// Nothing, formatted the same way: what today reads once the day is over.
  final String zero;

  /// What an amount reads while the user has hidden them.
  final String mask;

  /// "October".
  final String monthName;

  /// "Spent in October": the caption of the widget's main figure.
  final String monthLabel;

  /// Spent this month, formatted: the widget's main figure.
  final String monthTotal;

  /// Budget left, or the daily average when there is no budget.
  final WidgetStat? middle;

  /// What is left of this month's money: its income less its spending.
  final WidgetStat left;

  /// Spending has passed the month's income.
  final bool leftNegative;

  /// "Safe: ৳600/day", "Over budget" or "Avg ৳420/day"; null before anything is spent.
  final String? pace;
  final PaceTone paceTone;

  /// Spent on each day of the month (index 0 is the 1st), in minor units.
  final List<int> daily;

  /// The month's budgets shared over its days; zero without budgets.
  final int budgetPerDayMinor;

  /// Labels under the chart: the first day, the middle and the last.
  final List<String> axis;

  /// The widget's words, in the app's language rather than the phone's.
  final Map<String, String> strings;

  /// When the figures last changed, as the clock shows it ("10:42").
  final String updated;

  String get month => date.length >= 7 ? date.substring(0, 7) : '';

  HomeWidgetSnapshot stamped(String time) => signedIn
      ? HomeWidgetSnapshot(
          unlocked: unlocked,
          date: date,
          today: today,
          zero: zero,
          mask: mask,
          monthName: monthName,
          monthLabel: monthLabel,
          monthTotal: monthTotal,
          middle: middle,
          left: left,
          leftNegative: leftNegative,
          pace: pace,
          paceTone: paceTone,
          daily: daily,
          budgetPerDayMinor: budgetPerDayMinor,
          axis: axis,
          strings: strings,
          updated: time,
        )
      : this;

  Map<String, Object?> toJson() => {
        'v': version,
        'signedIn': signedIn,
        'unlocked': unlocked,
        'date': date,
        'month': month,
        'today': today,
        'zero': zero,
        'mask': mask,
        'monthName': monthName,
        'monthLabel': monthLabel,
        'monthTotal': monthTotal,
        'middle': middle?.toJson(),
        'left': left.toJson(),
        'leftNegative': leftNegative,
        'pace': pace,
        'paceTone': paceTone.name,
        'daily': daily,
        'budgetPerDay': budgetPerDayMinor,
        'axis': axis,
        'strings': strings,
        'updated': updated,
      };

  String encode() => jsonEncode(toJson());

  /// The same figures, whatever time they were stamped with.
  String get fingerprint => stamped('').encode();
}
