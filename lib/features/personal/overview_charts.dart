import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/money.dart';
import '../../core/ui.dart';
import 'ledger_repository.dart';
import 'spending_breakdown.dart';
import 'transaction_sheets.dart';

/// "Oct" from "October 2026"; Bangla month names are short enough whole.
String shortMonth(BuildContext context, DateTime month) {
  final label = MaterialLocalizations.of(context).formatMonthYear(month).split(' ').first;
  return label.length > 3 && context.languageCode != 'bn' ? label.substring(0, 3) : label;
}

/// A round figure to space an axis by, so that [highest] takes three or four steps.
double niceStep(double highest) {
  if (highest <= 0) return 1;
  final rough = highest / 4;
  final power = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  for (final factor in const [1, 2, 5, 10]) {
    if (factor * power >= rough) return factor * power;
  }
  return 10 * power;
}

TextStyle _tooltipStyle(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onInverseSurface,
      fontFamily: AppTheme.fontFamily,
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w600,
    );

/// The month's spending as it added up, day by day, beside the month before
/// and (with a budget) the line it would follow if spread evenly. Tapping a
/// day opens what was spent on it.
class SpendingPaceCard extends ConsumerWidget {
  const SpendingPaceCard({super.key, required this.workspace, this.budgetMinor = 0});

  final Workspace workspace;

  /// The month's budgets added up; zero draws no budget line.
  final int budgetMinor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final currency = workspace.defaultCurrency;
    final key = (workspace.id, currency);
    final month = ref.watch(selectedMonthProvider);
    final daily = ref.watch(dailySpendProvider(key)).value ?? const <int, int>{};
    final before = ref.watch(previousDailySpendProvider(key)).value ?? const <int, int>{};
    final spent = daily.values.fold<int>(0, (sum, value) => sum + value);
    if (spent == 0) return const SizedBox.shrink();

    final pace = SpendPace(month: month, spentMinor: spent, limitMinor: budgetMinor);
    final days = pace.days;
    final lastDay = pace.isCurrent ? pace.today.day : days;
    List<int> running(Map<int, int> perDay, int upTo) {
      var sum = 0;
      return [for (var day = 1; day <= upTo; day++) sum += perDay[day] ?? 0];
    }

    final previousMonth = DateTime(month.year, month.month - 1);
    final current = running(daily, lastDay);
    final previous = before.isEmpty ? const <int>[] : running(before, math.min(daysInMonth(previousMonth), days));
    final atSamePoint = previous.isEmpty ? null : previous[math.min(lastDay, previous.length) - 1];
    final difference = atSamePoint == null || atSamePoint == 0 ? 0 : spent - atSamePoint;
    final biggest = daily.entries.reduce((a, b) => b.value > a.value ? b : a);
    final quietDays = lastDay - daily.keys.where((day) => day <= lastDay).length;
    final projected = pace.projectedMinor;
    void openDay(int day) => showDaySheet(context, workspace, DateTime(month.year, month.month, day));

    return SectionCard(
      title: l10n.spendingPace,
      children: [
        Text(l10n.spentSoFar(context.money(spent, currency)), style: text.titleLarge),
        if (difference != 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Icon(
                  difference > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 16,
                  color: context.amountColor(difference < 0),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    difference > 0
                        ? l10n.paceMore(context.money(difference, currency))
                        : l10n.paceLess(context.money(-difference, currency)),
                    style: text.bodySmall?.copyWith(color: context.amountColor(difference < 0)),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        _PaceChart(
          month: month,
          previousMonth: previousMonth,
          daily: daily,
          current: current,
          previous: previous,
          budgetMinor: budgetMinor,
          currency: currency,
          onDayTap: openDay,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            LegendKey(
              color: Theme.of(context).colorScheme.primary,
              label: MaterialLocalizations.of(context).formatMonthYear(month),
            ),
            if (previous.isNotEmpty)
              LegendKey(
                color: context.colors.muted,
                label: MaterialLocalizations.of(context).formatMonthYear(previousMonth),
                dashed: true,
              ),
            if (budgetMinor > 0) LegendKey(color: context.colors.moneyOut, label: l10n.budgetEvenPace, dashed: true),
          ],
        ),
        const SizedBox(height: 14),
        FactRow(
          children: [
            FactTile(label: l10n.dailyAverage, value: context.money(pace.averageMinor, currency)),
            const SizedBox(width: 8),
            if (projected != null)
              FactTile(
                label: l10n.monthEndForecast,
                value: context.money(projected, currency),
                color: budgetMinor > 0 && projected > budgetMinor ? context.colors.moneyOut : null,
              )
            else
              FactTile(label: l10n.noSpendDays, value: localDigits(context, '$quietDays')),
            const SizedBox(width: 8),
            FactTile(
              key: const ValueKey('biggest-day'),
              label: l10n.biggestDay,
              value: context.money(biggest.value, currency),
              detail: MaterialLocalizations.of(context)
                  .formatShortMonthDay(DateTime(month.year, month.month, biggest.key)),
              onTap: () => openDay(biggest.key),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded, size: 14, color: context.colors.muted),
              const SizedBox(width: 6),
              Flexible(child: Text(l10n.tapDayHint, style: text.bodySmall)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaceChart extends StatelessWidget {
  const _PaceChart({
    required this.month,
    required this.previousMonth,
    required this.daily,
    required this.current,
    required this.previous,
    required this.budgetMinor,
    required this.currency,
    required this.onDayTap,
  });

  final DateTime month;
  final DateTime previousMonth;
  final Map<int, int> daily;

  /// Spent up to and including each day, from day 1.
  final List<int> current;
  final List<int> previous;
  final int budgetMinor;
  final String currency;
  final ValueChanged<int> onDayTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final locale = context.languageCode;
    final dates = MaterialLocalizations.of(context);
    final days = daysInMonth(month);
    final highest = [current.last, if (previous.isNotEmpty) previous.last, budgetMinor].reduce(math.max).toDouble();
    final step = niceStep(highest);
    final top = (highest / step).ceil() * step;

    List<FlSpot> spots(List<int> sums) =>
        [const FlSpot(0, 0), for (final (index, sum) in sums.indexed) FlSpot(index + 1, sum.toDouble())];
    LineChartBarData reference(List<FlSpot> spots, Color color, List<int> dashes) => LineChartBarData(
          spots: spots,
          color: color,
          barWidth: 1.5,
          dashArray: dashes,
          dotData: const FlDotData(show: false),
        );

    final lines = [
      if (budgetMinor > 0)
        reference([const FlSpot(0, 0), FlSpot(days.toDouble(), budgetMinor.toDouble())], colors.moneyOut, const [2, 4]),
      if (previous.isNotEmpty) reference(spots(previous), colors.muted, const [5, 4]),
      LineChartBarData(
        spots: spots(current),
        color: scheme.primary,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.primary.withValues(alpha: 0.22), scheme.primary.withValues(alpha: 0)],
          ),
        ),
      ),
    ];

    /// What there is to say about [day]: the date, what it cost and where the month stood after it.
    LineTooltipItem describe(int day) {
      final style = _tooltipStyle(context);
      return LineTooltipItem(
        dates.formatShortMonthDay(DateTime(month.year, month.month, math.max(day, 1))),
        style,
        textAlign: TextAlign.left,
        children: [
          if (day >= 1 && day <= current.length) ...[
            TextSpan(text: '\n${l10n.thatDay(Money.format(daily[day] ?? 0, currency, locale: locale))}'),
            TextSpan(text: '\n${l10n.soFar(Money.format(current[day - 1], currency, locale: locale))}'),
          ],
          if (day >= 1 && day <= previous.length)
            TextSpan(
              text: '\n${shortMonth(context, previousMonth)}: '
                  '${Money.format(previous[day - 1], currency, locale: locale)}',
              style: style.copyWith(fontWeight: FontWeight.w400),
            ),
        ],
      );
    }

    return SizedBox(
      key: const ValueKey('pace-chart'),
      height: 170,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: days.toDouble(),
          minY: 0,
          maxY: top,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: step,
            getDrawingHorizontalLine: (_) => FlLine(color: colors.hairline, strokeWidth: 1),
          ),
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
                  final day = value.round();
                  if (day < 1 || (day - 1) % 7 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(localDigits(context, '$day'), style: text.labelSmall),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchSpotThreshold: 16,
            touchCallback: (event, response) {
              final touched = response?.lineBarSpots;
              if (event is! FlTapUpEvent || touched == null || touched.isEmpty) return;
              final day = touched.first.x.round();
              if (day >= 1 && day <= current.length) onDayTap(day);
            },
            getTouchedSpotIndicator: (bar, indexes) => [
              for (final _ in indexes)
                TouchedSpotIndicatorData(
                  FlLine(color: colors.muted.withValues(alpha: 0.5), strokeWidth: 1),
                  FlDotData(
                    show: bar.barWidth > 2,
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 4,
                      color: scheme.primary,
                      strokeWidth: 2,
                      strokeColor: colors.sheet,
                    ),
                  ),
                ),
            ],
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              // One box for the day, whichever of its lines the finger is nearest
              getTooltipItems: (touched) => [
                for (final (index, spot) in touched.indexed) index == 0 ? describe(spot.x.round()) : null,
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

/// How the month's budgets stand together, and the ones nearest their limit.
class BudgetHealthCard extends StatelessWidget {
  const BudgetHealthCard({
    super.key,
    required this.budgets,
    required this.pace,
    required this.currency,
    required this.onOpenAll,
    required this.onOpenBudget,
  });

  /// The budgets in [currency].
  final List<BudgetProgress> budgets;
  final SpendPace pace;
  final String currency;
  final VoidCallback? onOpenAll;
  final ValueChanged<BudgetProgress> onOpenBudget;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final left = pace.leftMinor;
    final safe = pace.safePerDayMinor;
    final tightest = [...budgets]..sort((a, b) => b.usedPercent.compareTo(a.usedPercent));

    return SectionCard(
      title: l10n.budgetHealth,
      trailing: onOpenAll == null
          ? null
          : TextButton(
              onPressed: onOpenAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(l10n.allBudgets), const Icon(Icons.chevron_right_rounded, size: 18)],
              ),
            ),
      children: [
        Row(
          children: [
            PercentRing(
              value: pace.spentMinor / pace.limitMinor,
              marker: pace.dayFraction,
              size: 92,
              stroke: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localDigits(context, '${pace.usedPercent}%'),
                      style: text.titleLarge?.copyWith(fontFeatures: tabularFigures)),
                  Text(l10n.usedLabel, style: text.labelSmall),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    left >= 0
                        ? l10n.paceLeft(context.money(left, currency))
                        : l10n.paceOver(context.money(-left, currency)),
                    style: text.titleMedium?.copyWith(color: left >= 0 ? null : colors.moneyOut),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.spentOf(context.money(pace.spentMinor, currency), context.money(pace.limitMinor, currency)),
                    style: text.bodySmall?.copyWith(fontFeatures: tabularFigures),
                  ),
                  if (pace.isCurrent && safe > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(l10n.keepsWithinBudget(context.money(safe, currency)), style: text.bodySmall),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in tightest.take(3))
          Pressable(
            scale: 0.98,
            onTap: () => onOpenBudget(item),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.categoryName, style: text.bodyMedium, overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        l10n.percentUsed(localDigits(context, '${item.usedPercent}')),
                        style: text.bodySmall?.copyWith(
                          color: item.isOver ? colors.moneyOut : null,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 16, color: colors.muted),
                    ],
                  ),
                  LimitBar(value: item.spentMinor / item.budget.amountMinor, marker: pace.dayFraction, height: 6),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Months that fit the card side by side; a longer trend scrolls, latest first.
const _monthsInView = 8;

/// Room the amounts axis takes on the left of the chart.
const _axisWidth = 44.0;

/// Height of the bars' area, above the month names.
const _plotHeight = 144.0;

/// Room the month names take under the bars; a trend longer than a year
/// also names the year under its first month and each January.
const _monthLabelsHeight = 26.0;
const _monthAndYearHeight = 40.0;

/// Income beside expense for each of the last months. Tapping a month puts it
/// in focus and says how it went; from there the screens can move to it.
/// How many months is the user's choice of [trendLengths], held to the plan.
class CashFlowCard extends StatefulWidget {
  const CashFlowCard({
    super.key,
    required this.trend,
    required this.currency,
    required this.selectedMonth,
    required this.onGoToMonth,
    required this.length,
    required this.limit,
    required this.onLengthChanged,
  });

  /// Oldest first.
  final List<MonthTotals> trend;
  final String currency;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onGoToMonth;

  /// The length chosen, of [trendLengths].
  final int length;

  /// The most months the plan charts; null for no limit.
  final int? limit;
  final ValueChanged<int> onLengthChanged;

  @override
  State<CashFlowCard> createState() => _CashFlowCardState();
}

class _CashFlowCardState extends State<CashFlowCard> {
  /// The month in focus, as a date so it survives the months shifting under it.
  DateTime? _focus;

  void _select(DateTime month) {
    HapticFeedback.selectionClick();
    setState(() => _focus = _focus == month ? null : month);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final trend = widget.trend;
    final inFill = dark ? colors.moneyIn : AppTheme.successColor;
    final outFill = dark ? colors.moneyOut : AppTheme.errorColor;
    final focusIndex = trend.indexWhere((m) => m.month == _focus);
    final focus = focusIndex < 0 ? null : trend[focusIndex];
    final active = trend.where((m) => m.incomeMinor > 0 || m.expenseMinor > 0).toList();
    final ahead = active.where((m) => m.incomeMinor > m.expenseMinor).length;
    final highest = trend.fold<int>(1, (top, m) => math.max(top, math.max(m.incomeMinor, m.expenseMinor))).toDouble();
    final step = niceStep(highest);
    final top = (highest / step).ceil() * step;
    const rounded = BorderRadius.vertical(top: Radius.circular(4));
    // Thinner bars once the months are packed closer
    final barWidth = trend.length > 6 ? 9.0 : 12.0;

    BarChartRodData rod(int amount, Color fill, bool dimmed) => BarChartRodData(
          toY: amount.toDouble(),
          color: fill.withValues(alpha: dimmed ? 0.3 : 1),
          width: barWidth,
          borderRadius: rounded,
          // The whole column answers a tap, not just the ink
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: top, color: Colors.transparent),
        );

    return SectionCard(
      title: l10n.cashFlow,
      trailing: TrendLengthPicker(value: widget.length, limit: widget.limit, onChanged: widget.onLengthChanged),
      children: [
        if (active.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.savedInMonths(localDigits(context, '$ahead'), localDigits(context, '${active.length}')),
              style: text.bodyMedium,
            ),
          ),
        LayoutBuilder(builder: (context, box) {
          final perMonth = (box.maxWidth - _axisWidth) / math.min(math.max(trend.length, 1), _monthsInView);
          final scrolls = trend.length > _monthsInView;
          final withYears = trend.length > 12;
          final labelsHeight = withYears ? _monthAndYearHeight : _monthLabelsHeight;
          String amount(double value) => Money.compact(value.round(), widget.currency, locale: context.languageCode);

          // A long trend scrolls under an axis that stays put, so the amounts are always there to read by
          final chart = SizedBox(
            key: const ValueKey('cash-flow-chart'),
            width: scrolls ? perMonth * trend.length : box.maxWidth,
            height: _plotHeight + labelsHeight,
            child: BarChart(
              BarChartData(
                maxY: top,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: step,
                  getDrawingHorizontalLine: (_) => FlLine(color: colors.hairline, strokeWidth: 1),
                ),
                barTouchData: BarTouchData(
                  handleBuiltInTouches: false,
                  allowTouchBarBackDraw: true,
                  touchExtraThreshold: const EdgeInsets.symmetric(horizontal: 10),
                  touchCallback: (event, response) {
                    final index = response?.spot?.touchedBarGroupIndex;
                    if (event is FlTapUpEvent && index != null && index < trend.length) _select(trend[index].month);
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  leftTitles: scrolls
                      ? const AxisTitles()
                      : AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: _axisWidth,
                            interval: step,
                            getTitlesWidget: (value, meta) => value == 0
                                ? const SizedBox.shrink()
                                : SideTitleWidget(meta: meta, child: Text(amount(value), style: text.labelSmall)),
                          ),
                        ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: labelsHeight,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= trend.length) return const SizedBox.shrink();
                        final inFocus = index == focusIndex;
                        final month = trend[index].month;
                        final style = text.labelSmall?.copyWith(
                          color: inFocus ? Theme.of(context).colorScheme.onSurface : null,
                          fontWeight: inFocus ? FontWeight.w700 : null,
                        );
                        final label = Text(shortMonth(context, month), style: style);
                        return SideTitleWidget(
                          meta: meta,
                          child: !withYears || (index > 0 && month.month != 1)
                              ? label
                              : Column(mainAxisSize: MainAxisSize.min, children: [
                                  label,
                                  Text(localDigits(context, '${month.year}'),
                                      style: text.labelSmall?.copyWith(color: colors.muted, fontSize: 10)),
                                ]),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (final (index, m) in trend.indexed)
                    BarChartGroupData(x: index, barsSpace: 2, barRods: [
                      rod(m.incomeMinor, inFill, focus != null && index != focusIndex),
                      rod(m.expenseMinor, outFill, focus != null && index != focusIndex),
                    ]),
                ],
              ),
              duration: context.motion(AppMotion.standard),
            ),
          );
          if (!scrolls) return chart;
          const plot = _plotHeight;
          return Row(
            children: [
              SizedBox(
                key: const ValueKey('cash-flow-axis'),
                width: _axisWidth,
                height: _plotHeight + labelsHeight,
                child: Stack(
                  // The top label sits half above the chart, as the chart's own does
                  clipBehavior: Clip.none,
                  children: [
                    for (var value = step; value <= top; value += step)
                      Positioned(
                        // Centred on its grid line, as the chart places its own labels
                        top: plot * (1 - value / top) - 8,
                        left: 0,
                        right: 6,
                        height: 16,
                        child: Text(amount(value), style: text.labelSmall, textAlign: TextAlign.end),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('cash-flow-scroll'),
                  scrollDirection: Axis.horizontal,
                  // Opens on the latest months; older ones are a swipe back
                  reverse: true,
                  child: chart,
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LegendKey(color: inFill, label: l10n.income),
            const SizedBox(width: 20),
            LegendKey(color: outFill, label: l10n.expense),
          ],
        ),
        AnimatedSize(
          duration: context.motion(AppMotion.emphasised),
          curve: AppMotion.ease,
          alignment: Alignment.topCenter,
          child: focus == null
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 14, color: colors.muted),
                      const SizedBox(width: 6),
                      Flexible(child: Text(l10n.tapMonthHint, style: text.bodySmall)),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _MonthPanel(
                    totals: focus,
                    currency: widget.currency,
                    onClose: () => _select(focus.month),
                    onGoTo: focus.month == widget.selectedMonth
                        ? null
                        : () {
                            widget.onGoToMonth(focus.month);
                            setState(() => _focus = null);
                            // The month's own figures head the page: take the user up to them
                            final page = Scrollable.maybeOf(context)?.position;
                            final duration = context.motion(AppMotion.emphasised);
                            if (page == null) return;
                            duration == Duration.zero
                                ? page.jumpTo(0)
                                : page.animateTo(0, duration: duration, curve: AppMotion.ease);
                          },
                  ),
                ),
        ),
      ],
    );
  }
}

/// The trend lengths as small chips. A length the plan does not chart wears a
/// padlock; choosing it still calls [onChanged], which says so on the upgrade sheet.
class TrendLengthPicker extends StatelessWidget {
  const TrendLengthPicker({super.key, required this.value, required this.limit, required this.onChanged});

  final int value;

  /// The most months the plan charts; null for no limit.
  final int? limit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final shown = trendMonths(value, limit);
    return Semantics(
      label: l10n.trendLength,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final length in trendLengths)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: () {
                final locked = limit != null && length > limit!;
                final selected = !locked && length == shown;
                final ink = selected ? scheme.onPrimary : colors.muted;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: locked ? '${l10n.lastMonthsCount(length)}, ${l10n.lockedTag}' : l10n.lastMonthsCount(length),
                  excludeSemantics: true,
                  child: Material(
                    key: ValueKey('trend-length-$length'),
                    color: selected ? scheme.primary : colors.field,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      onTap: selected ? null : () => onChanged(length),
                      child: ConstrainedBox(
                        // A comfortable target, though the chip looks small
                        constraints: const BoxConstraints(minHeight: 32, minWidth: 40),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (locked) ...[
                                Icon(Icons.lock_outline_rounded, size: 12, color: ink),
                                const SizedBox(width: 2),
                              ],
                              Text(
                                l10n.monthsShort(localDigits(context, '$length')),
                                style: text.labelSmall?.copyWith(
                                  color: ink,
                                  fontWeight: selected ? FontWeight.w700 : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }(),
            ),
        ],
      ),
    );
  }
}

/// How the month in focus went.
class _MonthPanel extends StatelessWidget {
  const _MonthPanel({required this.totals, required this.currency, required this.onClose, required this.onGoTo});

  final MonthTotals totals;
  final String currency;
  final VoidCallback onClose;

  /// Null when the screens already show this month.
  final VoidCallback? onGoTo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final month = MaterialLocalizations.of(context).formatMonthYear(totals.month);
    final net = totals.incomeMinor - totals.expenseMinor;
    final kept = totals.incomeMinor <= 0 ? null : (net * 100 / totals.incomeMinor).round();

    Widget stat(String label, int amount, Color? color) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  context.money(amount, currency),
                  style: text.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ),
            ],
          ),
        );

    return Container(
      decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(AppRadius.control)),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(month, style: text.titleSmall)),
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
                stat(l10n.income, totals.incomeMinor, context.amountColor(true)),
                const SizedBox(width: 8),
                stat(l10n.expense, totals.expenseMinor, context.amountColor(false)),
                const SizedBox(width: 8),
                stat(l10n.net, net, context.amountColor(net >= 0)),
              ],
            ),
          ),
          if (kept != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Text(
                kept >= 0 ? l10n.keptOfIncome(localDigits(context, '$kept')) : l10n.spentMoreThanEarned,
                style: text.bodySmall,
              ),
            ),
          if (onGoTo != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onGoTo,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(l10n.goToMonth(month)),
              ),
            ),
        ],
      ),
    );
  }
}
