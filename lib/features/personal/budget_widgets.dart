import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/money.dart';
import '../../core/ui.dart';
import 'budget_calendar_page.dart';
import 'ledger_repository.dart';
import 'overview_charts.dart';
import 'spending_breakdown.dart';
import 'transaction_sheets.dart';

/// A share with its amount under it: "Spent · 60%" over "৳600.00".
class _ShareFigure extends StatelessWidget {
  const _ShareFigure({required this.label, required this.amount, this.color, this.end = false});

  final String label;
  final String amount;
  final Color? color;

  /// Set against the right edge.
  final bool end;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: text.labelSmall?.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(amount, style: text.titleSmall?.copyWith(color: color, fontFeatures: tabularFigures)),
      ],
    );
  }
}

/// "Spent · 60%" on the left and "Left · 40%" on the right, or "Over · 12%" once past the limit.
class _SpentAndLeft extends StatelessWidget {
  const _SpentAndLeft({
    required this.spentMinor,
    required this.leftMinor,
    required this.usedPercent,
    required this.currency,
  });

  final int spentMinor;
  final int leftMinor;
  final int usedPercent;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final over = leftMinor < 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ShareFigure(
            label: l10n.spentShare(localDigits(context, '$usedPercent')),
            amount: context.money(spentMinor, currency),
          ),
        ),
        const SizedBox(width: 12),
        _ShareFigure(
          label: over
              ? l10n.overShare(localDigits(context, '${usedPercent - 100}'))
              : l10n.leftShare(localDigits(context, '${(100 - usedPercent).clamp(0, 100)}')),
          amount: context.money(leftMinor.abs(), currency),
          color: over ? context.colors.moneyOut : null,
          end: true,
        ),
      ],
    );
  }
}

/// The month's budgets as one gauge: how much is used, how much is left, and
/// whether spending is keeping to the calendar.
class BudgetGaugeCard extends StatelessWidget {
  const BudgetGaugeCard({super.key, required this.pace, required this.currency});

  final SpendPace pace;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final projected = pace.projectedMinor;
    final (icon, tint, verdict) = pace.isOver
        ? (Icons.error_outline_rounded, colors.moneyOut, l10n.paceOver(context.money(-pace.leftMinor, currency)))
        : pace.isAhead
            ? (Icons.speed_rounded, colors.moneyOut, l10n.verdictAhead)
            : pace.isCurrent
                ? (Icons.check_circle_outline_rounded, colors.moneyIn, l10n.verdictOnTrack)
                : (Icons.check_circle_outline_rounded, colors.moneyIn, l10n.verdictWithin);

    return SectionCard(
      children: [
        Center(
          child: PercentRing(
            key: const ValueKey('budget-gauge'),
            value: pace.spentMinor / pace.limitMinor,
            marker: pace.dayFraction,
            size: 212,
            stroke: 16,
            half: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localDigits(context, '${pace.usedPercent}%'),
                  style: text.headlineMedium?.copyWith(fontFeatures: tabularFigures),
                ),
                Text(l10n.usedLabel, style: text.labelMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: tint),
            const SizedBox(width: 6),
            Flexible(child: Text(verdict, style: text.bodyMedium, textAlign: TextAlign.center)),
          ],
        ),
        const SizedBox(height: 14),
        _SpentAndLeft(
          spentMinor: pace.spentMinor,
          leftMinor: pace.leftMinor,
          usedPercent: pace.usedPercent,
          currency: currency,
        ),
        const SizedBox(height: 14),
        FactRow(
          children: [
            if (pace.isCurrent) ...[
              FactTile(
                label: l10n.safePerDay,
                value: context.money(pace.safePerDayMinor, currency),
                detail: '${l10n.daysLeft}: ${localDigits(context, '${pace.daysLeft}')}',
              ),
              const SizedBox(width: 8),
            ],
            FactTile(label: l10n.dailyAverage, value: context.money(pace.averageMinor, currency)),
            if (projected != null) ...[
              const SizedBox(width: 8),
              FactTile(
                label: l10n.monthEndForecast,
                value: context.money(projected, currency),
                color: projected > pace.limitMinor ? colors.moneyOut : null,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class BudgetTag extends StatelessWidget {
  const BudgetTag(this.label, this.color, {super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      );
}

/// One category's budget: how much of it is used and left, in money and in percent.
class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key, required this.item, required this.pace, required this.onTap});

  final BudgetProgress item;

  /// The month's calendar, for today's tick and the days left.
  final SpendPace pace;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final currency = item.budget.currency;
    final safe = pace.isCurrent && item.leftMinor > 0 ? item.leftMinor ~/ pace.daysLeft : 0;
    // Going over the limit while the card is on screen gives it a shake
    return Shake(
      trigger: item.isOver ? 1 : 0,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpace.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('budget-${item.budget.categoryId}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PercentRing(
                      value: item.spentMinor / item.budget.amountMinor,
                      color: categoryFill(item.categoryColor, item.budget.categoryId),
                      size: 48,
                      child: Text(
                        localDigits(context, '${item.usedPercent}%'),
                        style: text.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.categoryName, style: text.titleMedium, overflow: TextOverflow.ellipsis),
                          Text(
                            l10n.limitAmount(context.money(item.budget.amountMinor, currency)),
                            style: text.bodySmall?.copyWith(fontFeatures: tabularFigures),
                          ),
                        ],
                      ),
                    ),
                    if (item.isOverride) BudgetTag(l10n.thisMonthOnly, context.colors.muted),
                    if (item.isOver) BudgetTag(l10n.overBudget, context.colors.moneyOut),
                  ],
                ),
                const SizedBox(height: 10),
                LimitBar(value: item.spentMinor / item.budget.amountMinor, marker: pace.dayFraction),
                const SizedBox(height: 6),
                _SpentAndLeft(
                  spentMinor: item.spentMinor,
                  leftMinor: item.leftMinor,
                  usedPercent: item.usedPercent,
                  currency: currency,
                ),
                if (safe > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(l10n.keepsWithin(context.money(safe, currency)), style: text.bodySmall),
                  ),
                if (item.recurring != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      l10n.usualLimit(context.money(item.recurring!.amountMinor, item.recurring!.currency)),
                      style: text.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Categories that took money this month and have no limit, each a tap away from getting one.
class NotBudgetedCard extends StatelessWidget {
  const NotBudgetedCard({super.key, required this.categories, required this.currency, required this.onSetLimit});

  final List<CategorySpend> categories;
  final String currency;
  final ValueChanged<CategorySpend> onSetLimit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SectionCard(
      title: context.l10n.notBudgeted,
      children: [
        for (final item in categories)
          Row(
            children: [
              ColorDot(categoryFill(item.color, item.categoryId)),
              const SizedBox(width: 10),
              Expanded(child: Text(item.name ?? '', overflow: TextOverflow.ellipsis)),
              Text(
                context.money(item.amountMinor, currency),
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontFeatures: tabularFigures),
              ),
              TextButton(onPressed: () => onSetLimit(item), child: Text(context.l10n.setLimit)),
            ],
          ),
      ],
    );
  }
}

/// Everything about one budget for [month]: used and left, what each day cost,
/// and the expenses behind it. Changing the limit is one tap further.
/// [context] and [ref] are the screen's, which outlives the sheet.
Future<void> showBudgetDetail(BuildContext context, WidgetRef ref, Workspace workspace, BudgetProgress item,
        {required DateTime month}) =>
    showAppSheet<void>(
      context,
      title: item.categoryName,
      scrolls: false,
      trailing: Builder(
        builder: (sheet) => TextButton.icon(
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(sheet.l10n.edit),
          onPressed: () {
            Navigator.pop(sheet);
            showBudgetForm(context, ref, workspace, month: month, existing: item);
          },
        ),
      ),
      builder: (_) => _BudgetDetail(workspace: workspace, item: item, month: month),
    );

class _BudgetDetail extends ConsumerStatefulWidget {
  const _BudgetDetail({required this.workspace, required this.item, required this.month});

  final Workspace workspace;
  final BudgetProgress item;
  final DateTime month;

  @override
  ConsumerState<_BudgetDetail> createState() => _BudgetDetailState();
}

class _BudgetDetailState extends ConsumerState<_BudgetDetail> {
  /// The day whose expenses alone are listed; null lists the month's.
  int? _day;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final workspace = widget.workspace;
    final month = widget.month;
    // The figures move if an expense is edited from here
    final item = (ref.watch(budgetsProvider(workspace.id)).value ?? const <BudgetProgress>[])
            .where((b) => b.budget.id == widget.item.budget.id)
            .firstOrNull ??
        widget.item;
    final currency = item.budget.currency;
    final categoryId = item.budget.categoryId;
    final fill = categoryFill(item.categoryColor, categoryId);
    final daily = ref.watch(categoryDailySpendProvider((workspace.id, currency, categoryId))).value ?? const <int, int>{};
    final all = ref.watch(categoryTransactionsProvider((workspace.id, categoryId))).value;
    final day = _day;
    final shown = day == null
        ? all
        : all?.where((v) => v.transaction.occurredOn == isoDate(DateTime(month.year, month.month, day))).toList();
    final pace = SpendPace(month: month, spentMinor: item.spentMinor, limitMinor: item.budget.amountMinor);

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PercentRing(
                    value: item.spentMinor / item.budget.amountMinor,
                    marker: pace.dayFraction,
                    size: 88,
                    stroke: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(localDigits(context, '${item.usedPercent}%'),
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
                        _SpentAndLeft(
                          spentMinor: item.spentMinor,
                          leftMinor: item.leftMinor,
                          usedPercent: item.usedPercent,
                          currency: currency,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.limitAmount(context.money(item.budget.amountMinor, currency)),
                          style: text.bodySmall?.copyWith(fontFeatures: tabularFigures),
                        ),
                        if (pace.isCurrent && pace.safePerDayMinor > 0)
                          Text(l10n.keepsWithin(context.money(pace.safePerDayMinor, currency)), style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              if (daily.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l10n.dayByDay, style: text.titleSmall),
                const SizedBox(height: 8),
                _DailyBars(
                  month: month,
                  daily: daily,
                  fill: fill,
                  selected: day,
                  currency: currency,
                  onDayTap: (tapped) => setState(() => _day = tapped == _day ? null : tapped),
                ),
              ],
              if (day != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    label: Text(
                      '${MaterialLocalizations.of(context).formatShortMonthDay(DateTime(month.year, month.month, day))}'
                      ' · ${context.money(daily[day] ?? 0, currency)}',
                    ),
                    onDeleted: () => setState(() => _day = null),
                    backgroundColor: colors.field,
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
        ),
        if (shown == null)
          const SizedBox(height: 72)
        else if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Text(l10n.noTransactionsHere, textAlign: TextAlign.center, style: TextStyle(color: colors.muted)),
          )
        else
          TransactionSheetList(
            workspace: workspace,
            transactions: shown,
            emptyMessage: l10n.noTransactionsHere,
            embedded: true,
          ),
      ],
    );
  }
}

/// What the category cost on each day of the month. A tapped day is kept in focus.
class _DailyBars extends StatelessWidget {
  const _DailyBars({
    required this.month,
    required this.daily,
    required this.fill,
    required this.selected,
    required this.currency,
    required this.onDayTap,
  });

  final DateTime month;
  final Map<int, int> daily;
  final Color fill;
  final int? selected;
  final String currency;
  final ValueChanged<int> onDayTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final days = daysInMonth(month);
    final highest = daily.values.fold<int>(1, math.max).toDouble();
    final step = niceStep(highest);
    final top = (highest / step).ceil() * step;
    return SizedBox(
      key: const ValueKey('budget-days'),
      height: 120,
      child: LayoutBuilder(
        builder: (context, box) => BarChart(
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
              touchExtraThreshold: const EdgeInsets.symmetric(horizontal: 3),
              touchCallback: (event, response) {
                final index = response?.spot?.touchedBarGroupIndex;
                if (event is FlTapUpEvent && index != null && (daily[index + 1] ?? 0) > 0) onDayTap(index + 1);
              },
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: step,
                  // The top label would sit half above the chart, against the heading
                  getTitlesWidget: (value, meta) => value == 0 || value == meta.max
                      ? const SizedBox.shrink()
                      : SideTitleWidget(
                          meta: meta,
                          child: Text(
                            Money.compact(value.round(), currency, locale: context.languageCode),
                            style: text.labelSmall,
                          ),
                        ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (value, meta) {
                    final day = value.toInt() + 1;
                    if ((day - 1) % 7 != 0) return const SizedBox.shrink();
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(localDigits(context, '$day'), style: text.labelSmall),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var day = 1; day <= days; day++)
                BarChartGroupData(x: day - 1, barRods: [
                  BarChartRodData(
                    toY: (daily[day] ?? 0).toDouble(),
                    color: fill.withValues(alpha: selected != null && selected != day ? 0.3 : 1),
                    width: math.max(3, (box.maxWidth - 40) / days - 3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    backDrawRodData: BackgroundBarChartRodData(show: true, toY: top, color: Colors.transparent),
                  ),
                ]),
            ],
          ),
          duration: context.motion(AppMotion.standard),
        ),
      ),
    );
  }
}
