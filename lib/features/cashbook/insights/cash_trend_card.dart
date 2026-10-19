import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/money.dart';
import '../../../core/ui.dart';
import '../../personal/ledger_repository.dart';
import '../../personal/overview_charts.dart' show TrendLengthPicker, niceStep, shortMonth;

/// A book's or a business's months side by side: cash in rising above the
/// line, cash out falling below it, the month in view lit up and the others
/// dimmed. Above, what an ordinary month brings in and pays out, and the best
/// one. Tapping a month says how it went and offers to go to it.
class CashTrendCard extends StatefulWidget {
  const CashTrendCard({
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
  final int length;
  final int? limit;
  final ValueChanged<int> onLengthChanged;

  @override
  State<CashTrendCard> createState() => _CashTrendCardState();
}

class _CashTrendCardState extends State<CashTrendCard> {
  DateTime? _focus;

  static const _plot = 180.0;
  static const _axis = 40.0;
  static const _inView = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final trend = widget.trend;
    final active = trend.where((m) => m.incomeMinor > 0 || m.expenseMinor > 0).toList();
    final avgIn = active.isEmpty ? 0 : active.fold<int>(0, (s, m) => s + m.incomeMinor) ~/ active.length;
    final avgOut = active.isEmpty ? 0 : active.fold<int>(0, (s, m) => s + m.expenseMinor) ~/ active.length;
    final best = active.isEmpty
        ? null
        : active.reduce((a, b) => (a.incomeMinor - a.expenseMinor) >= (b.incomeMinor - b.expenseMinor) ? a : b);
    final highIn = trend.fold<int>(1, (m, t) => math.max(m, t.incomeMinor)).toDouble();
    final highOut = trend.fold<int>(1, (m, t) => math.max(m, t.expenseMinor)).toDouble();
    final step = niceStep(math.max(highIn, highOut));
    final maxY = math.max((highIn / step).ceil(), 1) * step;
    final minY = -math.max((highOut / step).ceil(), 1) * step;
    final focusIndex = trend.indexWhere((m) => m.month == _focus);
    final focus = focusIndex < 0 ? null : trend[focusIndex];
    String compact(num value) => Money.compact(value.round(), widget.currency, locale: context.languageCode);

    return SectionCard(
      title: l10n.cashFlow,
      trailing: TrendLengthPicker(value: widget.length, limit: widget.limit, onChanged: widget.onLengthChanged),
      children: [
        FactRow(children: [
          FactTile(label: l10n.insAvgIn, value: context.money(avgIn, widget.currency), color: colors.moneyIn),
          const SizedBox(width: AppSpace.sm),
          FactTile(label: l10n.insAvgOut, value: context.money(avgOut, widget.currency), color: colors.moneyOut),
          const SizedBox(width: AppSpace.sm),
          FactTile(
            label: l10n.insBestMonth,
            value: best == null ? '–' : shortMonth(context, best.month),
            detail: best == null ? null : '+${compact(math.max(best.incomeMinor - best.expenseMinor, 0))}',
            onTap: best == null ? null : () => setState(() => _focus = best.month),
          ),
        ]),
        const SizedBox(height: AppSpace.lg),
        LayoutBuilder(builder: (context, box) {
          final scrolls = trend.length > _inView;
          final perMonth = (box.maxWidth - _axis) / math.min(math.max(trend.length, 1), _inView);
          final barWidth = math.min(perMonth * 0.46, 22.0);
          final chart = SizedBox(
            width: scrolls ? perMonth * trend.length : box.maxWidth - _axis,
            height: _plot + 28,
            child: BarChart(
              BarChartData(
                minY: minY,
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: step,
                  getDrawingHorizontalLine: (value) => value == 0
                      ? FlLine(color: scheme.onSurface.withValues(alpha: 0.35), strokeWidth: 1.2)
                      : FlLine(color: colors.hairline, strokeWidth: 1, dashArray: const [3, 4]),
                ),
                barTouchData: BarTouchData(
                  handleBuiltInTouches: false,
                  allowTouchBarBackDraw: true,
                  touchCallback: (event, response) {
                    final index = response?.spot?.touchedBarGroupIndex;
                    if (event is FlTapUpEvent && index != null && index < trend.length) {
                      HapticFeedback.selectionClick();
                      setState(() => _focus = _focus == trend[index].month ? null : trend[index].month);
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= trend.length) return const SizedBox.shrink();
                        final month = trend[index].month;
                        final current = month == widget.selectedMonth;
                        final lit = index == focusIndex || (focusIndex < 0 && current);
                        return SideTitleWidget(
                          meta: meta,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: lit
                                ? BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(AppRadius.pill))
                                : null,
                            child: Text(
                              shortMonth(context, month),
                              style: text.labelSmall?.copyWith(
                                color: lit ? scheme.onPrimary : null,
                                fontWeight: lit ? FontWeight.w700 : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (final (index, m) in trend.indexed)
                    () {
                      // The month in focus, or else the month in view, stands out
                      final dim = focusIndex >= 0 ? index != focusIndex : m.month != widget.selectedMonth;
                      final alpha = dim ? 0.38 : 1.0;
                      final empty = m.incomeMinor == 0 && m.expenseMinor == 0;
                      return BarChartGroupData(x: index, barRods: [
                        BarChartRodData(
                          fromY: empty ? -step * 0.03 : -m.expenseMinor.toDouble(),
                          toY: empty ? step * 0.03 : m.incomeMinor.toDouble(),
                          // A month with nothing is a small dot on the line, not a gap
                          width: empty ? 6 : barWidth,
                          borderRadius: BorderRadius.circular(empty ? 3 : barWidth / 2.4),
                          color: empty ? colors.hairline : null,
                          rodStackItems: empty
                              ? const []
                              : [
                                  BarChartRodStackItem(-m.expenseMinor.toDouble(), 0, colors.moneyOut.withValues(alpha: alpha)),
                                  BarChartRodStackItem(0, m.incomeMinor.toDouble(), colors.moneyIn.withValues(alpha: alpha)),
                                ],
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            fromY: minY,
                            toY: maxY,
                            color: !dim ? scheme.primary.withValues(alpha: 0.06) : Colors.transparent,
                          ),
                        ),
                      ]);
                    }(),
                ],
              ),
              duration: context.motion(AppMotion.emphasised),
            ),
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _axis,
                height: _plot,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var value = minY; value <= maxY + 0.1; value += step)
                      if (value != 0)
                        Positioned(
                          top: _plot * (maxY - value) / (maxY - minY) - 8,
                          left: 0,
                          right: 6,
                          height: 16,
                          child: Text(
                            '${value < 0 ? '−' : ''}${compact(value.abs())}',
                            textAlign: TextAlign.end,
                            style: text.labelSmall?.copyWith(fontSize: 10, color: value < 0 ? colors.moneyOut : colors.moneyIn),
                          ),
                        ),
                  ],
                ),
              ),
              Expanded(
                child: scrolls ? SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: chart) : chart,
              ),
            ],
          );
        }),
        const SizedBox(height: AppSpace.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LegendKey(color: colors.moneyIn, label: '${l10n.cashIn} ↑'),
            const SizedBox(width: 20),
            LegendKey(color: colors.moneyOut, label: '${l10n.cashOut} ↓'),
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
                  child: _MonthFocus(
                    totals: focus,
                    currency: widget.currency,
                    average: avgIn - avgOut,
                    onClose: () => setState(() => _focus = null),
                    onGoTo: focus.month == widget.selectedMonth
                        ? null
                        : () {
                            widget.onGoToMonth(focus.month);
                            setState(() => _focus = null);
                          },
                  ),
                ),
        ),
      ],
    );
  }
}

/// The month in focus: in, out, what was left, and against an ordinary month.
class _MonthFocus extends StatelessWidget {
  const _MonthFocus({
    required this.totals,
    required this.currency,
    required this.average,
    required this.onClose,
    required this.onGoTo,
  });

  final MonthTotals totals;
  final String currency;

  /// An ordinary month's net, to compare with.
  final int average;
  final VoidCallback onClose;
  final VoidCallback? onGoTo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final net = totals.incomeMinor - totals.expenseMinor;
    final month = MaterialLocalizations.of(context).formatMonthYear(totals.month);
    final better = net >= average;

    Widget stat(String label, int amount, Color color) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: text.labelSmall),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(context.money(amount, currency),
                    style: text.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w700, fontFeatures: tabularFigures)),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 10),
      decoration: BoxDecoration(
        color: colors.field,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border(left: BorderSide(color: context.amountColor(net >= 0), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(month, style: text.titleSmall)),
              Icon(better ? Icons.north_east_rounded : Icons.south_east_rounded,
                  size: 14, color: context.amountColor(better)),
              const SizedBox(width: 4),
              Text(better ? l10n.insAboveUsual : l10n.insBelowUsual,
                  style: text.labelSmall?.copyWith(color: context.amountColor(better), fontWeight: FontWeight.w700)),
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
                stat(l10n.cashIn, totals.incomeMinor, colors.moneyIn),
                const SizedBox(width: 8),
                stat(l10n.cashOut, totals.expenseMinor, colors.moneyOut),
                const SizedBox(width: 8),
                stat(l10n.net, net, context.amountColor(net >= 0)),
              ],
            ),
          ),
          if (onGoTo != null)
            TextButton.icon(
              onPressed: onGoTo,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(l10n.goToMonth(month)),
            ),
        ],
      ),
    );
  }
}
