import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/money.dart';
import '../../../core/ui.dart';
import '../../fields/field_repository.dart';
import '../../personal/ledger_repository.dart' show isoDate;
import '../../personal/spending_breakdown.dart' show localDigits;
import 'insights_cards.dart';
import 'insights_providers.dart';
import 'insights_repository.dart';

enum HeatBy { cashOut, cashIn, entries }

/// When the money moves: the period as a calendar, each day as deep as how
/// much went out (or came in, or how many entries), its busiest day marked,
/// and the shape of the week underneath. A long range is drawn as a compact
/// strip of weeks that scrolls. Tapping a day says what it held.
class ActivityHeatmapCard extends StatefulWidget {
  const ActivityHeatmapCard({super.key, required this.flow, required this.currency});

  final PeriodFlow flow;
  final String currency;

  @override
  State<ActivityHeatmapCard> createState() => _ActivityHeatmapCardState();
}

class _ActivityHeatmapCardState extends State<ActivityHeatmapCard> {
  HeatBy _by = HeatBy.cashOut;
  DateTime? _focus;

  /// Up to six weeks reads as a calendar; longer as a strip.
  static const _calendarDays = 42;

  int _value(FlowTotals day) => switch (_by) {
        HeatBy.cashOut => day.outMinor,
        HeatBy.cashIn => day.inMinor,
        HeatBy.entries => day.count,
      };

  String _show(BuildContext context, int value, {bool compact = false}) => _by == HeatBy.entries
      ? localDigits(context, '$value')
      : compact
          ? Money.compact(value, widget.currency, locale: context.languageCode)
          : context.money(value, widget.currency);

  void _tap(DateTime day) {
    HapticFeedback.selectionClick();
    setState(() => _focus = _focus != null && isoDate(_focus!) == isoDate(day) ? null : day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final flow = widget.flow;
    final tint = switch (_by) {
      HeatBy.cashOut => colors.moneyOut,
      HeatBy.cashIn => colors.moneyIn,
      HeatBy.entries => Theme.of(context).colorScheme.primary,
    };
    final elapsed = flow.dates.take(math.max(flow.period.daysElapsed(flow.today), 1)).toList();
    final values = {for (final day in flow.dates) isoDate(day): _value(flow.on(day))};
    final highest = values.values.fold<int>(0, math.max);
    final peak = highest == 0 ? null : flow.dates.firstWhere((d) => values[isoDate(d)] == highest);
    final total = values.values.fold<int>(0, (sum, v) => sum + v);
    final quiet = elapsed.where((d) => values[isoDate(d)] == 0).length;
    final average = elapsed.isEmpty ? 0 : total / elapsed.length;
    final heat = _Heat(tint: tint, empty: colors.field, highest: highest);

    final focus = _focus;
    final focusFlow = focus == null ? null : flow.on(focus);

    return SectionCard(
      title: l10n.insActivity,
      trailing: InsightToggle<HeatBy>(
        options: {HeatBy.cashOut: l10n.insOut, HeatBy.cashIn: l10n.insIn, HeatBy.entries: l10n.entriesTab},
        value: _by,
        onChanged: (by) => setState(() => _by = by),
      ),
      children: [
        // The period in three figures
        Row(
          children: [
            _Pill(icon: Icons.functions_rounded, label: l10n.insPeriodTotal, value: _show(context, total, compact: true), color: tint),
            const SizedBox(width: AppSpace.sm),
            _Pill(
              icon: Icons.local_fire_department_rounded,
              label: l10n.insPeakDay,
              value: peak == null ? '–' : formatDay(context, peak),
              color: colors.gold,
              onTap: peak == null ? null : () => _tap(peak),
            ),
            const SizedBox(width: AppSpace.sm),
            _Pill(
              icon: Icons.bedtime_outlined,
              label: l10n.insQuietDays,
              value: localDigits(context, '$quiet'),
              color: colors.muted,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        AnimatedSwitcher(
          duration: context.motion(AppMotion.emphasised),
          child: KeyedSubtree(
            key: ValueKey(_by),
            child: flow.period.days <= _calendarDays
                ? _Calendar(
                    flow: flow,
                    values: values,
                    heat: heat,
                    peak: peak,
                    focus: focus,
                    label: (v) => _show(context, v, compact: true),
                    onTap: _tap,
                  )
                : _Strip(flow: flow, values: values, heat: heat, focus: focus, onTap: _tap),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            Icon(Icons.touch_app_rounded, size: 14, color: colors.muted),
            const SizedBox(width: 6),
            Expanded(child: Text(l10n.insTapDay, style: text.labelSmall)),
            Text(l10n.insLess, style: text.labelSmall),
            const SizedBox(width: 6),
            Container(
              width: 64,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(colors: [colors.field, heat.color(1), heat.color(highest)]),
              ),
            ),
            const SizedBox(width: 6),
            Text(l10n.insMore, style: text.labelSmall),
          ],
        ),
        AnimatedSize(
          duration: context.motion(AppMotion.emphasised),
          curve: AppMotion.ease,
          alignment: Alignment.topCenter,
          child: focus == null || focusFlow == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpace.md),
                  child: _DayPanel(
                    day: focus,
                    flow: focusFlow,
                    currency: widget.currency,
                    tint: tint,
                    times: average <= 0 || values[isoDate(focus)] == 0 ? null : values[isoDate(focus)]! / average,
                    onClose: () => setState(() => _focus = null),
                  ),
                ),
        ),
        if (total > 0) ...[
          const SizedBox(height: AppSpace.lg),
          _WeekRhythm(flow: flow, value: _value, tint: tint, label: (v) => _show(context, v, compact: true)),
        ],
      ],
    );
  }
}

/// How deep a day's colour runs: four steps from a faint wash to the full tint.
class _Heat {
  const _Heat({required this.tint, required this.empty, required this.highest});

  final Color tint;
  final Color empty;
  final int highest;

  static const levels = 4;

  int level(int value) => value <= 0 || highest == 0 ? 0 : (value * levels / highest).ceil().clamp(1, levels);

  Color color(int value) {
    final step = level(value);
    return step == 0 ? empty : Color.lerp(tint.withValues(alpha: 0.18), tint, (step - 1) / (levels - 1))!;
  }

  /// Text on a deep cell is white; on a pale one it keeps the card's colour.
  bool isDeep(int value) => level(value) >= 3;
}

/// A small figure with an icon, in a soft pill.
class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.value, required this.color, this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.16), shape: BoxShape.circle),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(value,
                          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontFeatures: tabularFigures)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The period as a month calendar, Monday first: each day its date, its
/// amount when there is room, and a colour as deep as the day was busy.
class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.flow,
    required this.values,
    required this.heat,
    required this.peak,
    required this.focus,
    required this.label,
    required this.onTap,
  });

  final PeriodFlow flow;
  final Map<String, int> values;
  final _Heat heat;
  final DateTime? peak;
  final DateTime? focus;
  final String Function(int value) label;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final start = flow.period.start;
    final end = flow.period.end;
    final first = DateTime(start.year, start.month, start.day - (start.weekday - 1));
    final weeks = (DateTime.utc(end.year, end.month, end.day).difference(DateTime.utc(first.year, first.month, first.day)).inDays ~/ 7) + 1;
    final today = isoDate(flow.today);
    final weekday = DateFormat.E(context.languageCode);
    const gap = 6.0;

    return LayoutBuilder(builder: (context, box) {
      final cell = (box.maxWidth - gap * 6) / 7;
      final height = math.min(cell, 56.0);
      final roomy = height >= 44;
      var index = 0;
      return Column(
        children: [
          Row(
            children: [
              for (var d = 0; d < 7; d++) ...[
                if (d > 0) const SizedBox(width: gap),
                SizedBox(
                  width: cell,
                  child: Text(
                    weekday.format(DateTime(2024, 1, d + 1)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: d >= 5 ? colors.muted.withValues(alpha: 0.7) : colors.muted,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          for (var w = 0; w < weeks; w++)
            Padding(
              padding: EdgeInsets.only(bottom: w == weeks - 1 ? 0 : gap),
              child: Row(
                children: [
                  for (var d = 0; d < 7; d++) ...[
                    if (d > 0) const SizedBox(width: gap),
                    () {
                      final day = DateTime(first.year, first.month, first.day + w * 7 + d);
                      final key = isoDate(day);
                      final inside = !day.isBefore(start) && !day.isAfter(end);
                      if (!inside) return SizedBox(width: cell, height: height);
                      final value = values[key] ?? 0;
                      final ahead = key.compareTo(today) > 0;
                      final selected = focus != null && isoDate(focus!) == key;
                      final isPeak = peak != null && isoDate(peak!) == key;
                      final deep = heat.isDeep(value);
                      final ink = deep ? Colors.white : scheme.onSurface;
                      return _Pop(
                        index: index++,
                        child: GestureDetector(
                          onTap: ahead ? null : () => onTap(day),
                          child: AnimatedContainer(
                            duration: context.motion(AppMotion.standard),
                            width: cell,
                            height: height,
                            padding: const EdgeInsets.fromLTRB(6, 4, 5, 4),
                            decoration: BoxDecoration(
                              color: ahead ? Colors.transparent : heat.color(value),
                              borderRadius: BorderRadius.circular(12),
                              border: selected
                                  ? Border.all(color: scheme.onSurface, width: 2)
                                  : key == today
                                      ? Border.all(color: scheme.primary, width: 1.5)
                                      : ahead
                                          ? Border.all(color: colors.hairline)
                                          : null,
                              boxShadow: isPeak && !selected
                                  ? [BoxShadow(color: heat.tint.withValues(alpha: 0.45), blurRadius: 12, offset: const Offset(0, 4))]
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: roomy ? Alignment.topLeft : Alignment.center,
                                  child: Text(
                                    localDigits(context, '${day.day}'),
                                    style: text.labelSmall?.copyWith(
                                      fontSize: 11,
                                      fontWeight: value > 0 ? FontWeight.w700 : FontWeight.w500,
                                      color: ahead ? colors.muted.withValues(alpha: 0.5) : (value > 0 ? ink : colors.muted),
                                    ),
                                  ),
                                ),
                                if (isPeak)
                                  const Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(Icons.local_fire_department_rounded, size: 12, color: Color(0xFFFFD27A)),
                                  ),
                                if (roomy && value > 0)
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        label(value),
                                        style: text.labelSmall?.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: ink.withValues(alpha: deep ? 0.95 : 0.75),
                                          fontFeatures: tabularFigures,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }(),
                  ],
                ],
              ),
            ),
        ],
      );
    });
  }
}

/// A long range: weeks as narrow columns, Monday at the top, the latest in view.
class _Strip extends StatelessWidget {
  const _Strip({required this.flow, required this.values, required this.heat, required this.focus, required this.onTap});

  final PeriodFlow flow;
  final Map<String, int> values;
  final _Heat heat;
  final DateTime? focus;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final start = flow.period.start;
    final end = flow.period.end;
    final first = DateTime(start.year, start.month, start.day - (start.weekday - 1));
    final weeks = (DateTime.utc(end.year, end.month, end.day).difference(DateTime.utc(first.year, first.month, first.day)).inDays ~/ 7) + 1;
    final narrow = DateFormat.E(context.languageCode);
    const cell = 15.0, gap = 3.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 16),
            for (var d = 0; d < 7; d++)
              SizedBox(
                height: cell + gap,
                width: 30,
                child: d.isEven ? Text(narrow.format(DateTime(2024, 1, d + 1)), style: text.labelSmall?.copyWith(fontSize: 10)) : null,
              ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var w = 0; w < weeks; w++)
                  Padding(
                    padding: const EdgeInsets.only(right: gap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 16,
                          // The month's short name over its first week
                          child: () {
                            final monday = DateTime(first.year, first.month, first.day + w * 7);
                            final opens = w == 0 || monday.day <= 7;
                            return opens
                                ? Text(DateFormat.MMM(context.languageCode).format(monday.add(const Duration(days: 6))),
                                    softWrap: false, overflow: TextOverflow.visible, style: text.labelSmall?.copyWith(fontSize: 10))
                                : null;
                          }(),
                        ),
                        for (var d = 0; d < 7; d++)
                          () {
                            final day = DateTime(first.year, first.month, first.day + w * 7 + d);
                            final inside = !day.isBefore(start) && !day.isAfter(end);
                            final selected = focus != null && isoDate(focus!) == isoDate(day);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: gap),
                              child: GestureDetector(
                                onTap: inside ? () => onTap(day) : null,
                                child: Container(
                                  width: cell,
                                  height: cell,
                                  decoration: BoxDecoration(
                                    color: inside ? heat.color(values[isoDate(day)] ?? 0) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: selected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1.5) : null,
                                  ),
                                ),
                              ),
                            );
                          }(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A day's cell growing in, a little after the one before it.
class _Pop extends StatelessWidget {
  const _Pop({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + index * 14),
      curve: Interval(math.min(index * 14 / (260 + index * 14), 0.9), 1, curve: AppMotion.spring),
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
      ),
      child: child,
    );
  }
}

/// The tapped day: what came in, what went out, and how it compares with an ordinary day.
class _DayPanel extends StatelessWidget {
  const _DayPanel({
    required this.day,
    required this.flow,
    required this.currency,
    required this.tint,
    required this.times,
    required this.onClose,
  });

  final DateTime day;
  final FlowTotals flow;
  final String currency;
  final Color tint;

  /// The day against the period's daily average; null with nothing to compare.
  final double? times;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final times = this.times;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 12),
      decoration: BoxDecoration(
        color: colors.field,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border(left: BorderSide(color: tint, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${weekdayName(context, day.weekday)}, ${formatDay(context, day)}', style: text.titleSmall),
              ),
              if (times != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: tint.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(
                    l10n.insTimesAverage(localDigits(context, times.toStringAsFixed(times >= 10 ? 0 : 1))),
                    style: text.labelSmall?.copyWith(color: tint, fontWeight: FontWeight.w700),
                  ),
                ),
              IconButton(
                onPressed: onClose,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                _DayStat(label: l10n.cashIn, value: context.money(flow.inMinor, currency), color: colors.moneyIn),
                _DayStat(label: l10n.cashOut, value: context.money(flow.outMinor, currency), color: colors.moneyOut),
                _DayStat(label: l10n.net, value: context.money(flow.netMinor, currency), color: context.amountColor(flow.netMinor >= 0)),
                _DayStat(label: l10n.entriesTab, value: localDigits(context, '${flow.count}')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The shape of the week: each weekday's total over the period, the busiest standing out.
class _WeekRhythm extends StatelessWidget {
  const _WeekRhythm({required this.flow, required this.value, required this.tint, required this.label});

  final PeriodFlow flow;
  final int Function(FlowTotals day) value;
  final Color tint;
  final String Function(int value) label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final totals = List.filled(7, 0);
    for (final day in flow.dates) {
      totals[day.weekday - 1] += value(flow.on(day));
    }
    final top = totals.fold<int>(1, math.max);
    final busiest = totals.indexOf(top);
    final weekday = DateFormat.E(context.languageCode);
    const barHeight = 64.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.insWeekRhythm, style: text.titleSmall),
            const Spacer(),
            Text(l10n.insBusiestOn(weekdayName(context, busiest + 1)), style: text.labelSmall),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var d = 0; d < 7; d++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 14,
                        child: d == busiest
                            ? FittedBox(
                                child: Text(label(totals[d]),
                                    style: text.labelSmall?.copyWith(color: tint, fontWeight: FontWeight.w700)),
                              )
                            : null,
                      ),
                      const SizedBox(height: 2),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: totals[d] / top),
                        duration: context.motion(Duration(milliseconds: 500 + d * 40)),
                        curve: AppMotion.ease,
                        builder: (context, t, _) => Container(
                          height: barHeight,
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(8)),
                          child: FractionallySizedBox(
                            heightFactor: math.max(t, totals[d] > 0 ? 0.06 : 0),
                            widthFactor: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: d == busiest
                                      ? [tint.withValues(alpha: 0.7), tint]
                                      : [tint.withValues(alpha: 0.2), tint.withValues(alpha: 0.4)],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        weekday.format(DateTime(2024, 1, d + 1)),
                        maxLines: 1,
                        style: text.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: d == busiest ? FontWeight.w700 : null,
                          color: d == busiest ? tint : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DayStat extends StatelessWidget {
  const _DayStat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelSmall),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: text.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600, fontFeatures: tabularFigures)),
          ),
        ],
      ),
    );
  }
}

/// The period by the value of one of the book's own fields: by party, by
/// project, by whatever the business tracks. Number fields are added up.
class FieldSplitCard extends ConsumerStatefulWidget {
  const FieldSplitCard({super.key, required this.bookId, required this.fields, required this.period, required this.currency});

  final String bookId;

  /// The book's fields that can be grouped or added up.
  final List<EntryField> fields;
  final InsightsPeriod period;
  final String currency;

  @override
  ConsumerState<FieldSplitCard> createState() => _FieldSplitCardState();
}

class _FieldSplitCardState extends ConsumerState<FieldSplitCard> {
  String? _fieldId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final field = widget.fields.where((f) => f.id == _fieldId).firstOrNull ?? widget.fields.first;
    final key = (widget.bookId, field.id, widget.period);

    final Widget body;
    if (field.kind == FieldKind.number) {
      final sum = ref.watch(fieldSumProvider(key)).value;
      String number(double value) => localDigits(context, NumberFormat.decimalPattern(context.languageCode).format(value));
      body = sum == null || sum.count == 0
          ? Text(l10n.insFieldEmpty, style: text.bodySmall)
          : FactRow(children: [
              FactTile(label: l10n.cashIn, value: number(sum.inSum), color: colors.moneyIn),
              const SizedBox(width: AppSpace.sm),
              FactTile(label: l10n.cashOut, value: number(sum.outSum), color: colors.moneyOut),
              const SizedBox(width: AppSpace.sm),
              FactTile(label: l10n.entriesTab, value: localDigits(context, '${sum.count}')),
            ]);
    } else {
      final rows = (ref.watch(fieldSplitProvider(key)).value ?? const <SplitRow>[]).where((r) => r.key != null).toList();
      final total = rows.fold<int>(0, (sum, r) => sum + r.inMinor + r.outMinor);
      body = rows.isEmpty
          ? Text(l10n.insFieldEmpty, style: text.bodySmall)
          : Column(
              children: [
                for (final (index, row) in rows.take(8).indexed)
                  RankedRow(
                    name: field.kind == FieldKind.date ? formatDate(context, row.name!) : row.name!,
                    amount: context.money(row.inMinor - row.outMinor, widget.currency),
                    amountColor: context.amountColor(row.inMinor >= row.outMinor),
                    share: (row.inMinor + row.outMinor) / math.max(total, 1),
                    color: categoryPalette[(index * 5 + 2) % categoryPalette.length],
                    detail: [
                      if (row.inMinor > 0) '+${context.money(row.inMinor, widget.currency)}',
                      if (row.outMinor > 0) '−${context.money(row.outMinor, widget.currency)}',
                      l10n.entriesCount(row.inCount + row.outCount),
                    ].join(' · '),
                  ),
              ],
            );
    }

    return SectionCard(
      title: l10n.insByField,
      children: [
        if (widget.fields.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: InsightToggle<String>(
                options: {for (final f in widget.fields) f.id: f.name},
                value: field.id,
                onChanged: (id) => setState(() => _fieldId = id),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: Text(field.name, style: text.labelLarge?.copyWith(color: colors.muted)),
          ),
        body,
      ],
    );
  }
}
