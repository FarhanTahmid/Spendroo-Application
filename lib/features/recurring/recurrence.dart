import '../../core/db/database.dart';

// When a rule falls due. The server decides (reminders/schedule.py there);
// the app works out the same dates only to show what a rule will do before
// it has been synced. Both are tested against test/fixtures/recurrence_cases.json:
// change them together.

const frequencies = ['once', 'daily', 'weekly', 'monthly', 'yearly'];
const lastPosition = -1;
const setPositions = [1, 2, 3, 4, lastPosition];

/// The fields of a rule that say when. Days are dates with no time, in UTC so
/// that adding days never trips over a clock change.
class Schedule {
  const Schedule({
    required this.freq,
    required this.startOn,
    this.interval = 1,
    this.weekdayMask = 0,
    this.monthDay,
    this.setPos,
    this.weekStart = 5,
    this.endOn,
  });

  factory Schedule.of(RecurringRule rule) => Schedule(
        freq: rule.freq,
        startOn: parseDay(rule.startOn),
        interval: rule.interval,
        weekdayMask: rule.weekdayMask,
        monthDay: rule.monthDay,
        setPos: rule.setPos,
        weekStart: rule.weekStart,
        endOn: rule.endOn == null ? null : parseDay(rule.endOn!),
      );

  final String freq;
  final int interval;

  /// Days of the week, Monday as bit 0; 0 means the weekday of [startOn].
  final int weekdayMask;

  /// 1-31 or -1 for the last day; null means the day of [startOn].
  final int? monthDay;

  /// With [weekdayMask]: the first (1) to fourth (4) or last (-1) of those weekdays in the month.
  final int? setPos;

  /// The day weeks start on, Monday as 0.
  final int weekStart;
  final DateTime startOn;
  final DateTime? endOn;

  /// Weekdays it falls on, Monday as 0.
  List<int> get weekdays {
    final mask = weekdayMask == 0 ? 1 << (startOn.weekday - 1) : weekdayMask;
    return [for (var day = 0; day < 7; day++) if (mask & (1 << day) != 0) day];
  }
}

DateTime parseDay(String iso) {
  final date = DateTime.parse(iso);
  return DateTime.utc(date.year, date.month, date.day);
}

DateTime _addDays(DateTime day, int days) => DateTime.utc(day.year, day.month, day.day + days);

int _daysBetween(DateTime from, DateTime to) => to.difference(from).inDays;

int _monthLength(int year, int month) => DateTime.utc(year, month + 1, 0).day;

DateTime _weekOf(DateTime day, int weekStart) => _addDays(day, -((day.weekday - 1 - weekStart) % 7));

DateTime _dayInMonth(Schedule s, int year, int month) {
  final length = _monthLength(year, month);
  if (s.setPos != null) {
    final wanted = s.weekdays;
    final days = [
      for (var day = 1; day <= length; day++)
        if (wanted.contains(DateTime.utc(year, month, day).weekday - 1)) day,
    ];
    return DateTime.utc(year, month, s.setPos == lastPosition ? days.last : days[s.setPos! - 1]);
  }
  final wanted = s.monthDay ?? s.startOn.day;
  // A month too short for the day uses its last day
  return DateTime.utc(year, month, wanted == lastPosition || wanted > length ? length : wanted);
}

DateTime _daily(Schedule s, DateTime day) {
  final behind = _daysBetween(s.startOn, day) % s.interval;
  return _addDays(day, (s.interval - behind) % s.interval);
}

DateTime _weekly(Schedule s, DateTime day) {
  final wanted = s.weekdays;
  final firstWeek = _weekOf(s.startOn, s.weekStart);
  var week = _weekOf(day, s.weekStart);
  final behind = (_daysBetween(firstWeek, week) ~/ 7) % s.interval;
  if (behind != 0) {
    // A week the schedule skips: on to the next one it keeps
    week = _addDays(week, 7 * (s.interval - behind));
    day = week;
  }
  while (true) {
    for (var offset = 0; offset < 7; offset++) {
      final candidate = _addDays(week, offset);
      if (!candidate.isBefore(day) && wanted.contains(candidate.weekday - 1)) return candidate;
    }
    week = _addDays(week, 7 * s.interval);
    day = week;
  }
}

DateTime _monthly(Schedule s, DateTime day) {
  final start = s.startOn;
  var months = (day.year - start.year) * 12 + day.month - start.month;
  months += (s.interval - months % s.interval) % s.interval;
  while (true) {
    final index = start.year * 12 + start.month - 1 + months;
    final candidate = _dayInMonth(s, index ~/ 12, index % 12 + 1);
    if (!candidate.isBefore(day)) return candidate;
    months += s.interval;
  }
}

DateTime _yearly(Schedule s, DateTime day) {
  final start = s.startOn;
  var years = day.year - start.year;
  years += (s.interval - years % s.interval) % s.interval;
  while (true) {
    final candidate = _dayInMonth(s, start.year + years, start.month);
    if (!candidate.isBefore(day)) return candidate;
    years += s.interval;
  }
}

/// The first day on or after [day] the schedule falls on, or null when there is none.
DateTime? nextOnOrAfter(Schedule s, DateTime day) {
  if (day.isBefore(s.startOn)) day = s.startOn;
  final DateTime? found = switch (s.freq) {
    'once' => day == s.startOn ? s.startOn : null,
    'daily' => _daily(s, day),
    'weekly' => _weekly(s, day),
    'yearly' => _yearly(s, day),
    _ => _monthly(s, day),
  };
  if (found != null && s.endOn != null && found.isAfter(s.endOn!)) return null;
  return found;
}

/// Up to [count] days the schedule falls on, from [since] on.
List<DateTime> occurrencesOf(Schedule s, DateTime since, int count) {
  final found = <DateTime>[];
  DateTime? day = since;
  while (found.length < count) {
    day = nextOnOrAfter(s, day!);
    if (day == null) break;
    found.add(day);
    day = _addDays(day, 1);
  }
  return found;
}
