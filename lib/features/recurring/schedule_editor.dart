import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/ui.dart';
import '../../l10n/app_localizations.dart';
import '../../core/money.dart';
import '../personal/ledger_repository.dart' show isoDate;
import '../personal/spending_breakdown.dart' show localDigits;
import 'recurrence.dart';

/// "Mon", "Tue"... in the user's language; [weekday] has Monday as 0.
String weekdayName(BuildContext context, int weekday, {bool long = false}) {
  // 1 January 2024 was a Monday
  final day = DateTime(2024, 1, 1 + weekday);
  return (long ? DateFormat.EEEE(context.languageCode) : DateFormat.E(context.languageCode)).format(day);
}

String ordinalName(AppLocalizations l10n, int position) => switch (position) {
      1 => l10n.ordinalFirst,
      2 => l10n.ordinalSecond,
      3 => l10n.ordinalThird,
      4 => l10n.ordinalFourth,
      _ => l10n.ordinalLast,
    };

/// One line saying when a schedule falls due: "Every 2 weeks · Sat, Tue".
String describeSchedule(BuildContext context, Schedule s) {
  final l10n = context.l10n;
  final n = localDigits(context, '${s.interval}');
  final often = switch (s.freq) {
    'once' => l10n.freqOnce,
    'daily' => s.interval == 1 ? l10n.freqDaily : l10n.freqDailyN(n),
    'weekly' => s.interval == 1 ? l10n.freqWeekly : l10n.freqWeeklyN(n),
    'yearly' => s.interval == 1 ? l10n.freqYearly : l10n.freqYearlyN(n),
    _ => s.interval == 1 ? l10n.freqMonthly : l10n.freqMonthlyN(n),
  };
  String dayOfMonth() {
    if (s.setPos != null) {
      return l10n.theNthWeekday(
          ordinalName(l10n, s.setPos!), s.weekdays.map((day) => weekdayName(context, day, long: true)).join(', '));
    }
    final day = s.monthDay ?? s.startOn.day;
    return day == lastPosition ? l10n.onLastDay : l10n.onDayOfMonth(localDigits(context, '$day'));
  }

  final when = switch (s.freq) {
    'weekly' => s.weekdays.map((day) => weekdayName(context, day)).join(', '),
    'monthly' => dayOfMonth(),
    'yearly' => '${dayOfMonth()}, ${DateFormat.MMMM(context.languageCode).format(s.startOn)}',
    _ => null,
  };
  return when == null ? often : '$often · $when';
}

/// The schedule of a rule while it is being edited.
class ScheduleDraft {
  ScheduleDraft({
    this.freq = 'monthly',
    this.interval = 1,
    this.weekdayMask = 0,
    this.monthDay,
    this.setPos,
    this.weekStart = 5,
    String? startOn,
    this.endOn,
    this.maxCount,
  }) : startOn = startOn ?? todayIso();

  String freq;
  int interval;
  int weekdayMask;
  int? monthDay;
  int? setPos;
  int weekStart;
  String startOn;
  String? endOn;
  int? maxCount;

  /// day: the day of the month it starts on. last: the last day. weekday: "the first Friday".
  String get monthMode => setPos != null ? 'weekday' : (monthDay == lastPosition ? 'last' : 'day');

  String get endMode => maxCount != null ? 'count' : (endOn != null ? 'date' : 'never');

  Schedule get schedule => Schedule(
        freq: freq,
        interval: interval < 1 ? 1 : interval,
        // Only what the frequency reads is sent, so a stale choice from another one cannot linger
        weekdayMask: freq == 'weekly' || setPos != null ? weekdayMask : 0,
        monthDay: freq == 'monthly' || freq == 'yearly' ? monthDay : null,
        setPos: freq == 'monthly' || freq == 'yearly' ? setPos : null,
        weekStart: weekStart,
        startOn: parseDay(startOn),
        endOn: endOn == null ? null : parseDay(endOn!),
      );
}

/// How often, on which days, from when and until when. Shows the next dates
/// the choice gives, worked out the way the server will.
class ScheduleEditor extends StatefulWidget {
  const ScheduleEditor({super.key, required this.draft, required this.onChanged});

  final ScheduleDraft draft;

  /// The draft changed in place: rebuild.
  final VoidCallback onChanged;

  @override
  State<ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<ScheduleEditor> {
  late final _interval = TextEditingController(text: '${widget.draft.interval}');
  late final _count = TextEditingController(text: '${widget.draft.maxCount ?? 12}');

  @override
  void dispose() {
    _interval.dispose();
    _count.dispose();
    super.dispose();
  }

  void _change(VoidCallback change) {
    change();
    widget.onChanged();
  }

  int get _startWeekday => DateTime.parse(widget.draft.startOn).weekday - 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;
    final text = Theme.of(context).textTheme;
    final unit = switch (draft.freq) {
      'daily' => l10n.unitDays,
      'weekly' => l10n.unitWeeks,
      'yearly' => l10n.unitYears,
      _ => l10n.unitMonths,
    };
    final repeats = draft.freq != 'once';
    final byMonth = draft.freq == 'monthly' || draft.freq == 'yearly';
    final next = occurrencesOf(draft.schedule, parseDay(todayIso()), 3);
    String? number(String? value) => (int.tryParse(Money.toAsciiDigits(value ?? '')) ?? 0) < 1 ? l10n.numberRequired : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectField<String>(
          label: l10n.repeats,
          icon: Icons.event_repeat_rounded,
          value: draft.freq,
          options: [
            SelectOption('once', l10n.freqOptOnce),
            SelectOption('daily', l10n.freqOptDaily),
            SelectOption('weekly', l10n.freqOptWeekly),
            SelectOption('monthly', l10n.freqOptMonthly),
            SelectOption('yearly', l10n.freqOptYearly),
          ],
          onChanged: (value) => _change(() => draft.freq = value ?? 'monthly'),
        ),
        const SizedBox(height: 12),
        if (repeats) ...[
          TextFormField(
            key: const Key('schedule-interval'),
            controller: _interval,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
            decoration: InputDecoration(labelText: l10n.repeatEvery, suffixText: unit),
            validator: number,
            onChanged: (value) => _change(() => draft.interval = int.tryParse(value) ?? 1),
          ),
          const SizedBox(height: 12),
        ],
        if (draft.freq == 'weekly') ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              // In the order of the user's own week
              for (var offset = 0; offset < 7; offset++)
                () {
                  final day = (draft.weekStart + offset) % 7;
                  final mask = draft.weekdayMask == 0 ? 1 << _startWeekday : draft.weekdayMask;
                  final chosen = mask & (1 << day) != 0;
                  return FilterChip(
                    key: Key('weekday-$day'),
                    label: Text(weekdayName(context, day)),
                    selected: chosen,
                    showCheckmark: false,
                    // The last day cannot be taken away: a week with no day is no schedule
                    onSelected: (on) => _change(() {
                      final changed = on ? mask | (1 << day) : mask & ~(1 << day);
                      if (changed != 0) draft.weekdayMask = changed;
                    }),
                  );
                }(),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (byMonth) ...[
          SelectField<String>(
            label: l10n.monthlyOn,
            value: draft.monthMode,
            options: [
              SelectOption('day', l10n.onDayOfMonth(localDigits(context, '${DateTime.parse(draft.startOn).day}'))),
              SelectOption('last', l10n.onLastDay),
              SelectOption('weekday', l10n.onWeekdayOfMonth),
            ],
            onChanged: (value) => _change(() {
              draft.monthDay = value == 'last' ? lastPosition : null;
              draft.setPos = value == 'weekday' ? (draft.setPos ?? 1) : null;
              if (value == 'weekday' && draft.weekdayMask == 0) draft.weekdayMask = 1 << _startWeekday;
            }),
          ),
          const SizedBox(height: 12),
          if (draft.monthMode == 'weekday') ...[
            Row(
              children: [
                Expanded(
                  child: SelectField<int>(
                    label: l10n.whichOne,
                    value: draft.setPos,
                    options: [for (final position in setPositions) SelectOption(position, ordinalName(l10n, position))],
                    onChanged: (value) => _change(() => draft.setPos = value ?? 1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectField<int>(
                    label: l10n.weekday,
                    value: draft.schedule.weekdays.first,
                    options: [
                      for (var offset = 0; offset < 7; offset++)
                        SelectOption((draft.weekStart + offset) % 7,
                            weekdayName(context, (draft.weekStart + offset) % 7, long: true)),
                    ],
                    onChanged: (value) => _change(() => draft.weekdayMask = 1 << (value ?? _startWeekday)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ],
        DateField(
          label: repeats ? l10n.startsOn : l10n.date,
          value: draft.startOn,
          last: DateTime.now().add(const Duration(days: 3660)),
          onChanged: (value) => _change(() => draft.startOn = value),
        ),
        const SizedBox(height: 12),
        if (repeats) ...[
          SelectField<String>(
            label: l10n.ends,
            value: draft.endMode,
            options: [
              SelectOption('never', l10n.endsNever),
              SelectOption('date', l10n.endsOnDate),
              SelectOption('count', l10n.endsAfterTimes),
            ],
            onChanged: (value) => _change(() {
              final start = DateTime.parse(draft.startOn);
              draft.endOn = value == 'date' ? (draft.endOn ?? isoDate(DateTime(start.year + 1, start.month, start.day))) : null;
              draft.maxCount = value == 'count' ? (int.tryParse(_count.text) ?? 12) : null;
            }),
          ),
          const SizedBox(height: 12),
          if (draft.endMode == 'date') ...[
            DateField(
              label: l10n.endsOn,
              value: draft.endOn!,
              first: DateTime.parse(draft.startOn),
              last: DateTime.now().add(const Duration(days: 36600)),
              onChanged: (value) => _change(() => draft.endOn = value),
            ),
            const SizedBox(height: 12),
          ],
          if (draft.endMode == 'count') ...[
            TextFormField(
              key: const Key('schedule-count'),
              controller: _count,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
              decoration: InputDecoration(labelText: l10n.timesCount),
              validator: number,
              onChanged: (value) => _change(() => draft.maxCount = int.tryParse(value) ?? 1),
            ),
            const SizedBox(height: 12),
          ],
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            next.isEmpty
                ? l10n.noMoreDates
                : l10n.nextDates(next.map((day) => formatDate(context, isoDate(day))).join(' · ')),
            key: const Key('schedule-preview'),
            style: text.bodySmall?.copyWith(color: next.isEmpty ? AppTheme.errorColor : context.colors.muted),
          ),
        ),
      ],
    );
  }
}
