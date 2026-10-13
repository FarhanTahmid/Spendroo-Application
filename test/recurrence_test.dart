import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/features/personal/ledger_repository.dart' show isoDate;
import 'package:spendroo/features/recurring/recurrence.dart';

void main() {
  // The server's own tests read the same file (reminders/tests/recurrence_cases.json)
  final cases = ((jsonDecode(File('test/fixtures/recurrence_cases.json').readAsStringSync()) as Map)['cases'] as List)
      .cast<Map<String, dynamic>>();

  test('the app and the server agree on when every kind of schedule falls due', () {
    expect(cases.length, greaterThan(20));
    for (final c in cases) {
      final rule = c['rule'] as Map<String, dynamic>;
      final schedule = Schedule(
        freq: rule['freq'] as String,
        interval: rule['interval'] as int,
        weekdayMask: rule['weekday_mask'] as int,
        monthDay: rule['month_day'] as int?,
        setPos: rule['set_pos'] as int?,
        weekStart: rule['week_start'] as int,
        startOn: parseDay(rule['start_on'] as String),
        endOn: rule['end_on'] == null ? null : parseDay(rule['end_on'] as String),
      );
      final expected = (c['expect'] as List).cast<String>();
      final found = occurrencesOf(schedule, parseDay(c['from'] as String), expected.length + 1).map(isoDate).toList();
      expect(found.take(expected.length).toList(), expected, reason: c['name'] as String);
    }
  });

  test('a clock change does not move a date', () {
    // Dates are counted in UTC, whatever zone the phone is in
    final daily = Schedule(freq: 'daily', startOn: parseDay('2026-03-27'));
    expect(occurrencesOf(daily, parseDay('2026-03-28'), 3).map(isoDate).toList(),
        ['2026-03-28', '2026-03-29', '2026-03-30']);
  });
}
