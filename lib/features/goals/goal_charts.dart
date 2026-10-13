import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../core/ui.dart';
import '../personal/overview_charts.dart' show niceStep, shortMonth;
import '../personal/spending_breakdown.dart' show localDigits;
import 'goal_math.dart';

TextStyle _tooltipStyle(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onInverseSurface,
      fontFamily: AppTheme.fontFamily,
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w600,
    );

/// The goal's story on one chart: what was saved, step by step (filled, in the
/// goal's colour); the steady line from the first day to the target date
/// (dashed navy); where the recent pace leads (dashed mint); the target itself
/// (gold). Gold dots mark each quarter passed, red ticks money taken out.
class GoalTrajectoryChart extends StatelessWidget {
  const GoalTrajectoryChart({
    super.key,
    required this.stats,
    required this.moves,
    required this.targetMinor,
    required this.currency,
    required this.createdOn,
    required this.color,
    this.targetOn,
  });

  final GoalStats stats;
  final List<GoalMove> moves;
  final int targetMinor;
  final String currency;
  final DateTime createdOn;
  final DateTime? targetOn;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final locale = context.languageCode;
    final dates = MaterialLocalizations.of(context);
    final l10n = context.l10n;

    final start = dayOf(createdOn);
    final today = stats.today;
    double x(DateTime day) => daysBetween(start, day).toDouble();
    final finish = stats.projectedFinish;
    // Far enough to show the date and the forecast, but a forecast years away does not squash the past
    final horizon = [
      x(today) + 14,
      if (targetOn != null) x(targetOn!),
      if (finish != null) math.min(x(finish), math.max(x(today) * 3, x(today) + 365)),
    ].reduce(math.max);

    // A step for each day money moved: the balance holds until the next one
    final actual = <FlSpot>[const FlSpot(0, 0)];
    var last = 0;
    for (final (day, balance) in stats.cumulative) {
      final at = math.max(x(day), 0.0);
      actual
        ..add(FlSpot(at, last.toDouble()))
        ..add(FlSpot(at, balance.toDouble()));
      last = balance;
    }
    actual.add(FlSpot(x(today), last.toDouble()));

    final highest = [targetMinor, ...stats.cumulative.map((point) => point.$2)].reduce(math.max).toDouble();
    final step = niceStep(highest);
    final top = (highest / step).ceil() * step;

    LineChartBarData dashed(List<FlSpot> spots, Color color) => LineChartBarData(
          spots: spots,
          color: color,
          barWidth: 1.6,
          dashArray: const [5, 4],
          dotData: const FlDotData(show: false),
        );
    LineChartBarData dots(List<FlSpot> spots, Color fill, double radius) => LineChartBarData(
          spots: spots,
          barWidth: 0,
          color: Colors.transparent,
          dotData: FlDotData(
            getDotPainter: (_, _, _, _) =>
                FlDotCirclePainter(radius: radius, color: fill, strokeWidth: 2, strokeColor: colors.sheet),
          ),
        );

    double balanceOn(DateTime day) {
      var balance = 0;
      for (final (at, value) in stats.cumulative) {
        if (at.isAfter(day)) break;
        balance = value;
      }
      return balance.toDouble();
    }

    final milestones = [for (final day in stats.milestoneDays.values) FlSpot(math.max(x(day), 0), balanceOn(day))];
    final withdrawals = [
      for (final move in moves.where((move) => !move.isIn)) FlSpot(math.max(x(move.day), 0), balanceOn(move.day)),
    ];

    final lines = [
      if (targetOn != null && x(targetOn!) > 0)
        dashed([const FlSpot(0, 0), FlSpot(x(targetOn!), targetMinor.toDouble())], scheme.primary.withValues(alpha: 0.7)),
      if (finish != null && last < targetMinor)
        dashed([FlSpot(x(today), last.toDouble()), FlSpot(x(finish), targetMinor.toDouble())], colors.mint),
      LineChartBarData(
        spots: actual,
        color: color,
        barWidth: 2.6,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
          ),
        ),
      ),
      if (milestones.isNotEmpty) dots(milestones, colors.gold, 4.5),
      if (withdrawals.isNotEmpty) dots(withdrawals, colors.moneyOut, 3.5),
    ];
    final actualIndex = lines.indexWhere((line) => line.barWidth > 2.5);

    // Month starts along the bottom, few enough to read
    final spanMonths = math.max(1, (horizon / daysPerMonth).ceil());
    final every = (spanMonths / 5).ceil();

    return SizedBox(
      key: const ValueKey('goal-trajectory'),
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(horizon, 1),
          minY: 0,
          maxY: top,
          borderData: FlBorderData(show: false),
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: step,
            getDrawingHorizontalLine: (_) => FlLine(color: colors.hairline, strokeWidth: 1),
          ),
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(
              y: targetMinor.toDouble(),
              color: colors.gold,
              strokeWidth: 1.4,
              dashArray: const [2, 3],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                style: text.labelSmall?.copyWith(color: colors.gold, fontWeight: FontWeight.w700),
                labelResolver: (_) => l10n.goalTargetLine,
              ),
            ),
          ], verticalLines: [
            VerticalLine(x: x(today), color: colors.muted.withValues(alpha: 0.35), strokeWidth: 1, dashArray: const [2, 3]),
          ]),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: step,
                getTitlesWidget: (value, meta) => value == 0
                    ? const SizedBox.shrink()
                    : SideTitleWidget(
                        meta: meta,
                        child: Text(Money.compact(value.round(), currency, locale: locale), style: text.labelSmall),
                      ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final day = start.add(Duration(days: value.round()));
                  final previous = start.add(Duration(days: value.round() - 1));
                  final monthIndex = (day.year - start.year) * 12 + day.month - start.month;
                  // Only on the first day of a month, and only every few months
                  if (value <= 0 || day.month == previous.month || monthIndex % every != 0) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(meta: meta, child: Text(shortMonth(context, day), style: text.labelSmall));
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchSpotThreshold: 18,
            getTouchedSpotIndicator: (bar, indexes) => [
              for (final _ in indexes)
                TouchedSpotIndicatorData(
                  FlLine(color: colors.muted.withValues(alpha: 0.5), strokeWidth: 1),
                  FlDotData(
                    show: bar.barWidth > 2.5,
                    getDotPainter: (_, _, _, _) =>
                        FlDotCirclePainter(radius: 4, color: color, strokeWidth: 2, strokeColor: colors.sheet),
                  ),
                ),
            ],
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touched) => [
                for (final spot in touched)
                  spot.barIndex == actualIndex
                      ? LineTooltipItem(
                          '${dates.formatShortMonthDay(start.add(Duration(days: spot.x.round())))}\n'
                          '${Money.format(spot.y.round(), currency, locale: locale)}',
                          _tooltipStyle(context),
                        )
                      : null,
              ],
            ),
          ),
          lineBarsData: lines,
        ),
        duration: context.motion(AppMotion.emphasised),
      ),
    );
  }
}

/// What each of the last months put into the goal, net: a bar up in the
/// goal's colour, or down in red when more came out than went in.
class GoalMonthsChart extends StatelessWidget {
  const GoalMonthsChart({super.key, required this.months, required this.currency, required this.color});

  final List<GoalMonth> months;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locale = context.languageCode;
    final highest = months.map((month) => month.netMinor.abs()).fold<int>(0, math.max).toDouble();
    final step = niceStep(highest);
    final top = highest == 0 ? 1.0 : (highest / step).ceil() * step;
    final hasOut = months.any((month) => month.netMinor < 0);
    final now = DateTime.now();

    return SizedBox(
      key: const ValueKey('goal-months'),
      height: 150,
      child: BarChart(
        BarChartData(
          maxY: top,
          minY: hasOut ? -top : 0,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: step,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: value == 0 ? colors.muted.withValues(alpha: 0.4) : colors.hairline, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final month = months[value.toInt()].month;
                  final current = month.year == now.year && month.month == now.month;
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      shortMonth(context, month),
                      style: text.labelSmall?.copyWith(fontWeight: current ? FontWeight.w700 : null),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, _, rod, _) {
                final month = months[group.x];
                return BarTooltipItem(
                  '${MaterialLocalizations.of(context).formatMonthYear(month.month)}\n'
                  '+${Money.format(month.inMinor, currency, locale: locale)}'
                  '${month.outMinor > 0 ? '\n−${Money.format(month.outMinor, currency, locale: locale)}' : ''}',
                  _tooltipStyle(context),
                );
              },
            ),
          ),
          barGroups: [
            for (final (index, month) in months.indexed)
              BarChartGroupData(x: index, barRods: [
                BarChartRodData(
                  toY: month.netMinor.toDouble(),
                  width: 18,
                  color: month.netMinor >= 0 ? color : colors.moneyOut,
                  borderRadius: month.netMinor >= 0
                      ? const BorderRadius.vertical(top: Radius.circular(6))
                      : const BorderRadius.vertical(bottom: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: top,
                    color: colors.field,
                  ),
                ),
              ]),
          ],
        ),
        duration: context.motion(AppMotion.emphasised),
      ),
    );
  }
}

/// Which accounts the money came from, as a ring of slices with a legend beside it.
class GoalSourcesDonut extends StatelessWidget {
  const GoalSourcesDonut({super.key, required this.sources, required this.currency});

  /// Account name to amount put in, biggest first.
  final Map<String, int> sources;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final total = sources.values.fold<int>(0, (sum, value) => sum + value);
    if (total <= 0) return const SizedBox.shrink();
    final entries = sources.entries.toList();
    Color colorAt(int index) => categoryPalette[(index * 3) % categoryPalette.length];

    return Row(
      children: [
        SizedBox(
          width: 108,
          height: 108,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              startDegreeOffset: -90,
              sections: [
                for (final (index, entry) in entries.indexed)
                  PieChartSectionData(
                    value: entry.value.toDouble(),
                    color: colorAt(index),
                    radius: 20,
                    showTitle: false,
                  ),
              ],
            ),
            duration: context.motion(AppMotion.emphasised),
          ),
        ),
        const SizedBox(width: AppSpace.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, entry) in entries.take(5).indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      ColorDot(colorAt(index), size: 10),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key.isEmpty ? '—' : entry.key,
                          style: text.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        localDigits(context, '${(entry.value * 100 / total).round()}%'),
                        style: text.labelMedium?.copyWith(fontFeatures: tabularFigures),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
