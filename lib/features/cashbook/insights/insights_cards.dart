import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/entitlements/entitlements.dart';
import '../../../core/money.dart';
import '../../../core/ui.dart';
import '../../personal/overview_charts.dart' show niceStep;
import '../../personal/spending_breakdown.dart' show localDigits;
import '../../plan/upgrade_sheet.dart';
import '../../team/team_repository.dart';
import 'insights_providers.dart';
import 'insights_repository.dart';

/// "1 Oct – 19 Oct" or "October 2026".
String periodLabel(BuildContext context, InsightsPeriod period) => period.isMonth
    ? MaterialLocalizations.of(context).formatMonthYear(period.month)
    : '${formatDate(context, period.from)} – ${formatDate(context, period.to)}';

String weekdayName(BuildContext context, int weekday) =>
    DateFormat.EEEE(context.languageCode).format(DateTime(2024, 1, weekday)); // 1 Jan 2024 was a Monday

String _percent(BuildContext context, num value) => localDigits(context, '${value.round()}');

/// The month (or chosen days) on the navy field, with the way to choose days
/// in its place: a plan feature, wearing a padlock without it.
class InsightsPeriodBar extends ConsumerWidget {
  const InsightsPeriodBar({super.key, required this.workspace, required this.scopeId});

  final Workspace workspace;
  final String scopeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final period = ref.watch(insightsPeriodProvider(scopeId));
    final controller = ref.read(insightsPeriodProvider(scopeId).notifier);
    final locked = featureLocked(ref, workspace, F.insightsCustomRange);
    if (!period.isMonth && locked) {
      // The plan no longer has it, after a downgrade
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.clearRange());
    }
    return Row(
      children: [
        Expanded(
          child: period.isMonth
              ? MonthSwitcher(month: period.month, onChanged: controller.month)
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 48),
                      Expanded(
                        child: Text(
                          periodLabel(context, period),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colors.onHeader),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.backToMonths,
                        visualDensity: VisualDensity.compact,
                        color: colors.onHeader,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          controller.clearRange();
                        },
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(width: AppSpace.sm),
        IconButton(
          tooltip: l10n.chooseDates,
          color: colors.onHeader,
          style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.1)),
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.date_range_rounded),
          onPressed: () => pickInsightsRange(context, ref, workspace, scopeId),
        ),
      ],
    );
  }
}

/// The period at a glance: what is left after cash out and how that compares
/// with the period before, how much of what came in was kept, cash in and
/// out with their own changes, and a pulse of every day underneath: cash in
/// rising above the line, cash out falling below it. Its colour says how the
/// period went.
class PulseHeroCard extends StatelessWidget {
  const PulseHeroCard({super.key, required this.flow, required this.currency});

  final PeriodFlow flow;
  final String currency;

  static const _ahead = [Color(0xFF0B5E3A), Color(0xFF14874F), Color(0xFF2DB86F)];
  static const _behind = [Color(0xFF7E1F2C), Color(0xFFB0323F), Color(0xFFE0606B)];
  static const _even = [Color(0xFF0B2D5E), Color(0xFF153F7E), Color(0xFF2558A8)];

  /// Cash out on the hero: a soft coral that reads on green, red and navy alike.
  static const _outInk = Color(0xFFFFC2C7);
  static const _inInk = Color(0xFFB9F5D4);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final total = flow.total;
    final net = total.netMinor;
    final gradient = total.count == 0 || net == 0 ? _even : (net > 0 ? _ahead : _behind);
    final change = flow.netChange;
    final white = Colors.white;
    final soft = Colors.white.withValues(alpha: 0.78);
    final kept = total.inMinor == 0 ? null : net / total.inMinor;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
        borderRadius: BorderRadius.circular(AppRadius.card + 4),
        boxShadow: [BoxShadow(color: gradient[1].withValues(alpha: 0.35), blurRadius: 28, offset: const Offset(0, 12))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Light falling across the card
          Positioned(
            right: -60,
            top: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Colors.white.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0)]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), shape: BoxShape.circle),
                      child: Icon(net >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 16, color: white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.insNetFlow, style: text.bodyMedium?.copyWith(color: soft))),
                    if (change != null) _DeltaPill(percent: change, overRange: !flow.period.isMonth),
                  ],
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: MoneyText(
                    net,
                    currency,
                    prefix: net > 0 ? '+' : '',
                    style: text.displaySmall?.copyWith(color: white, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '${l10n.insClosingBalance}  '),
                    TextSpan(
                      text: context.money(flow.closingMinor, currency),
                      style: TextStyle(color: white, fontWeight: FontWeight.w700),
                    ),
                  ]),
                  style: text.bodySmall?.copyWith(color: soft, fontFeatures: tabularFigures),
                ),
                if (kept != null) ...[
                  const SizedBox(height: AppSpace.md),
                  _KeptBar(inMinor: total.inMinor, outMinor: total.outMinor, inInk: _inInk, outInk: _outInk),
                  const SizedBox(height: 6),
                  Text(
                    kept >= 0
                        ? l10n.insKept(localDigits(context, '${(kept * 100).round()}'))
                        : l10n.insOverspent(localDigits(context, '${(-kept * 100).round()}')),
                    style: text.labelSmall?.copyWith(color: soft),
                  ),
                ],
                const SizedBox(height: AppSpace.md),
                Row(
                  children: [
                    _GlassStat(
                      icon: Icons.south_west_rounded,
                      label: l10n.cashIn,
                      value: context.money(total.inMinor, currency),
                      dot: _inInk,
                      change: flow.inChange,
                      risingIsGood: true,
                    ),
                    const SizedBox(width: AppSpace.sm),
                    _GlassStat(
                      icon: Icons.north_east_rounded,
                      label: l10n.cashOut,
                      value: context.money(total.outMinor, currency),
                      dot: _outInk,
                      change: flow.outChange,
                      risingIsGood: false,
                    ),
                  ],
                ),
                if (total.count > 0) ...[
                  const SizedBox(height: AppSpace.lg),
                  SizedBox(height: 46, child: _PulseStrip(flow: flow, inInk: _inInk, outInk: _outInk)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(formatDay(context, flow.period.start), style: text.labelSmall?.copyWith(color: soft, fontSize: 10)),
                      Expanded(
                        child: Text(
                          '${l10n.entriesCount(total.count)} · ${l10n.insActiveDaysCount(flow.activeDays)}',
                          textAlign: TextAlign.center,
                          style: text.labelSmall?.copyWith(color: white, fontWeight: FontWeight.w600, fontSize: 11),
                        ),
                      ),
                      Text(formatDay(context, flow.period.end), style: text.labelSmall?.copyWith(color: soft, fontSize: 10)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.percent, required this.overRange});

  final int percent;
  final bool overRange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signed = localDigits(context, '${percent > 0 ? '+' : ''}$percent');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        overRange ? l10n.changeVsPeriodBefore(signed) : l10n.changeVsLastMonth(signed),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Cash in as one bar, the part that went out again cut from its end.
class _KeptBar extends StatelessWidget {
  const _KeptBar({required this.inMinor, required this.outMinor, required this.inInk, required this.outInk});

  final int inMinor;
  final int outMinor;
  final Color inInk;
  final Color outInk;

  @override
  Widget build(BuildContext context) {
    final whole = math.max(inMinor, outMinor).toDouble();
    final kept = math.max(inMinor - outMinor, 0) / whole;
    final out = math.min(outMinor, inMinor) / whole;
    final over = math.max(outMinor - inMinor, 0) / whole;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: context.motion(const Duration(milliseconds: 700)),
      curve: AppMotion.ease,
      builder: (context, t, _) => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 10,
          color: Colors.white.withValues(alpha: 0.14),
          child: Row(
            children: [
              if (kept > 0) Expanded(flex: (kept * t * 1000).round().clamp(1, 1000), child: Container(color: inInk)),
              if (out > 0) ...[
                const SizedBox(width: 2),
                Expanded(flex: (out * t * 1000).round().clamp(1, 1000), child: Container(color: outInk.withValues(alpha: 0.75))),
              ],
              if (over > 0) ...[
                const SizedBox(width: 2),
                Expanded(flex: (over * t * 1000).round().clamp(1, 1000), child: Container(color: outInk)),
              ],
              Expanded(flex: ((1 - t) * 1000).round().clamp(0, 1000), child: const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  const _GlassStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.dot,
    required this.change,
    required this.risingIsGood,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color dot;
  final int? change;
  final bool risingIsGood;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final change = this.change;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(AppRadius.control + 2),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: dot.withValues(alpha: 0.25), shape: BoxShape.circle),
                  child: Icon(icon, size: 12, color: dot),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                ),
                if (change != null && change != 0)
                  Text(
                    '${change > 0 ? '▲' : '▼'} ${localDigits(context, '${change.abs()}')}%',
                    style: text.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: (change > 0) == risingIsGood ? const Color(0xFFB9F5D4) : const Color(0xFFFFC2C7),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: text.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontFeatures: tabularFigures)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Every day of the period as a thin bar around a centre line: cash in up,
/// cash out down, days still to come as faint dots.
class _PulseStrip extends StatelessWidget {
  const _PulseStrip({required this.flow, required this.inInk, required this.outInk});

  final PeriodFlow flow;
  final Color inInk;
  final Color outInk;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: context.motion(const Duration(milliseconds: 800)),
        curve: AppMotion.ease,
        builder: (context, t, _) => CustomPaint(
          size: Size.infinite,
          painter: _PulsePainter(
            days: [for (final day in flow.dates) flow.on(day)],
            elapsed: flow.period.daysElapsed(flow.today),
            inInk: inInk,
            outInk: outInk,
            grow: t,
          ),
        ),
      );
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.days, required this.elapsed, required this.inInk, required this.outInk, required this.grow});

  final List<FlowTotals> days;
  final int elapsed;
  final Color inInk;
  final Color outInk;
  final double grow;

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final mid = size.height / 2;
    final top = days.fold<int>(1, (m, d) => math.max(m, math.max(d.inMinor, d.outMinor))).toDouble();
    final slot = size.width / days.length;
    final width = math.max(math.min(slot * 0.62, 7.0), 1.5);
    canvas.drawLine(
      Offset(0, mid),
      Offset(size.width, mid),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..strokeWidth = 1,
    );
    final radius = Radius.circular(width / 2);
    for (final (i, day) in days.indexed) {
      final x = slot * i + slot / 2;
      if (i >= elapsed) {
        canvas.drawCircle(Offset(x, mid), 1.2, Paint()..color = Colors.white.withValues(alpha: 0.3));
        continue;
      }
      final up = day.inMinor / top * (mid - 2) * grow;
      final down = day.outMinor / top * (mid - 2) * grow;
      if (up > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(Rect.fromLTRB(x - width / 2, mid - math.max(up, 2), x + width / 2, mid - 1),
              topLeft: radius, topRight: radius),
          Paint()..color = inInk,
        );
      }
      if (down > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(Rect.fromLTRB(x - width / 2, mid + 1, x + width / 2, mid + math.max(down, 2)),
              bottomLeft: radius, bottomRight: radius),
          Paint()..color = outInk,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.grow != grow || old.days != days || old.elapsed != elapsed;
}

/// Nothing recorded in the period: says so, kindly, instead of empty charts.
class InsightsEmpty extends StatelessWidget {
  const InsightsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return SectionCard(children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.insights_rounded, size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: AppSpace.md),
              Text(l10n.insNoActivity, style: text.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpace.xs),
              Text(l10n.insNoActivityHint, style: text.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ]);
  }
}

/// Small chips to switch what a card shows.
class InsightToggle<T> extends StatelessWidget {
  const InsightToggle({super.key, required this.options, required this.value, required this.onChanged});

  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final MapEntry(:key, value: label) in options.entries)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Semantics(
              button: true,
              selected: key == value,
              child: Material(
                color: key == value ? scheme.primary : colors.field,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  onTap: key == value
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          onChanged(key);
                        },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 32, minWidth: 40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          label,
                          style: text.labelSmall?.copyWith(
                            color: key == value ? scheme.onPrimary : colors.muted,
                            fontWeight: key == value ? FontWeight.w700 : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A bar that grows to [value] (0 to 1) when it appears or changes.
class GrowBar extends StatelessWidget {
  const GrowBar({super.key, required this.value, required this.color, this.height = 8});

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.isFinite ? value.clamp(0.0, 1.0) : 0),
        duration: context.motion(const Duration(milliseconds: 550)),
        curve: AppMotion.ease,
        builder: (context, fill, _) => Container(
          height: height,
          decoration: BoxDecoration(color: context.colors.field, borderRadius: BorderRadius.circular(height)),
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: math.max(fill, fill > 0 ? 0.015 : 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withValues(alpha: 0.75), color]),
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ),
      );
}

/// A ranked row: a colour, a name, an amount and its share as a bar.
class RankedRow extends StatelessWidget {
  const RankedRow({
    super.key,
    required this.name,
    required this.amount,
    required this.share,
    required this.color,
    this.detail,
    this.amountColor,
    this.leading,
  });

  final String name;
  final String amount;
  final double share;
  final Color color;
  final String? detail;
  final Color? amountColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          leading ?? ColorDot(color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(name, style: text.bodyMedium, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text(
                      amount,
                      style: text.bodyMedium?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w600,
                        fontFeatures: tabularFigures,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(child: GrowBar(value: share, color: color, height: 6)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${_percent(context, share * 100)}%',
                        textAlign: TextAlign.end,
                        style: text.labelSmall,
                      ),
                    ),
                  ],
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(detail!, style: text.labelSmall, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Where the cash in came from, category by category.
class IncomeSourcesCard extends StatefulWidget {
  const IncomeSourcesCard({super.key, required this.rows, required this.currency});

  final List<SplitRow> rows;
  final String currency;

  @override
  State<IncomeSourcesCard> createState() => _IncomeSourcesCardState();
}

class _IncomeSourcesCardState extends State<IncomeSourcesCard> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = widget.rows.where((r) => r.inMinor > 0).toList()..sort((a, b) => b.inMinor.compareTo(a.inMinor));
    if (rows.isEmpty) return const SizedBox.shrink();
    final total = rows.fold<int>(0, (sum, r) => sum + r.inMinor);
    final shown = _all ? rows : rows.take(5).toList();
    return SectionCard(
      title: l10n.insWhereMoneyCame,
      children: [
        for (final row in shown)
          RankedRow(
            name: row.name ?? l10n.uncategorised,
            amount: context.money(row.inMinor, widget.currency),
            amountColor: context.amountColor(true),
            share: row.inMinor / total,
            color: categoryFill(row.color, row.key),
            detail: l10n.entriesCount(row.inCount),
          ),
        if (rows.length > 5)
          TextButton(
            onPressed: () => setState(() => _all = !_all),
            child: Text(_all ? l10n.showLess : l10n.moreCategories(localDigits(context, '${rows.length - 5}'))),
          ),
      ],
    );
  }
}

/// How the money moved: cash, card, mobile money… one bar split by method,
/// for cash out or cash in.
class PaymentSplitCard extends StatefulWidget {
  const PaymentSplitCard({super.key, required this.rows, required this.currency});

  final List<SplitRow> rows;
  final String currency;

  @override
  State<PaymentSplitCard> createState() => _PaymentSplitCardState();
}

class _PaymentSplitCardState extends State<PaymentSplitCard> {
  bool _out = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    int amount(SplitRow r) => _out ? r.outMinor : r.inMinor;
    final rows = widget.rows.where((r) => amount(r) > 0).toList()..sort((a, b) => amount(b).compareTo(amount(a)));
    final total = rows.fold<int>(0, (sum, r) => sum + amount(r));
    if (widget.rows.every((r) => r.inMinor == 0 && r.outMinor == 0)) return const SizedBox.shrink();
    Color colorOf(int index) => categoryPalette[(index * 3 + 1) % categoryPalette.length];

    return SectionCard(
      title: l10n.insPaymentMethods,
      trailing: InsightToggle<bool>(
        options: {true: l10n.cashOut, false: l10n.cashIn},
        value: _out,
        onChanged: (value) => setState(() => _out = value),
      ),
      children: [
        if (rows.isEmpty)
          Text(l10n.insNothingHere, style: Theme.of(context).textTheme.bodySmall)
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  for (final (index, row) in rows.indexed)
                    Flexible(
                      flex: math.max((amount(row) * 1000 / total).round(), 1),
                      child: Container(
                        margin: EdgeInsets.only(right: index == rows.length - 1 ? 0 : 2),
                        color: colorOf(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          for (final (index, row) in rows.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  ColorDot(colorOf(index)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(row.name ?? l10n.insNoPaymentMethod, overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    '${_percent(context, amount(row) * 100 / total)}%',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.money(amount(row), widget.currency),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: tabularFigures,
                          color: context.amountColor(!_out),
                        ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// A card kept for the Business plan: it shows through, blurred, under what
/// unlocks it.
class LockedInsight extends ConsumerWidget {
  const LockedInsight({super.key, required this.workspace, required this.child});

  final Workspace workspace;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: SizedBox(
          height: 230,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ExcludeSemantics(
                child: IgnorePointer(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: double.infinity,
                    child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: child),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colors.paper.withValues(alpha: 0.15), colors.paper.withValues(alpha: 0.92)],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BusinessChip(),
                    const SizedBox(height: AppSpace.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                      child: Text(l10n.insUnlockBody, textAlign: TextAlign.center, style: text.bodySmall),
                    ),
                    const SizedBox(height: AppSpace.md),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: colors.gold, foregroundColor: colors.onGold),
                      onPressed: () => unlockFeature(context, ref, workspace, F.insightsBusinessAdvanced),
                      icon: const Icon(Icons.lock_open_rounded, size: 18),
                      label: Text(l10n.insUnlockAction),
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

/// The rest of the Business plan's charts, by name, after the ones shown blurred.
class MoreInsightsTile extends ConsumerWidget {
  const MoreInsightsTile({super.key, required this.workspace, required this.items});

  final Workspace workspace;

  /// Icon and name of each chart.
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => unlockFeature(context, ref, workspace, F.insightsBusinessAdvanced),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l10n.insMoreWithBusiness(items.length), style: text.titleMedium)),
                  const BusinessChip(),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: [
                  for (final (icon, name) in items)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 15, color: colors.muted),
                          const SizedBox(width: 6),
                          Text(name, style: text.labelMedium),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Business", in gold: what a locked chart comes with.
class BusinessChip extends StatelessWidget {
  const BusinessChip({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.gold, const Color(0xFFFFD27A)]),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 14, color: colors.onGold),
          const SizedBox(width: 4),
          Text(
            context.l10n.insBusinessChip,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onGold, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// The balance at the end of each day of the period, from the opening one.
class BalanceLineCard extends StatelessWidget {
  const BalanceLineCard({super.key, required this.flow, required this.currency});

  final PeriodFlow flow;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final balances = [flow.openingMinor, ...flow.runningBalance];
    final low = balances.reduce(math.min).toDouble();
    final high = balances.reduce(math.max).toDouble();
    final step = niceStep(math.max((high - low).abs(), 1));
    final minY = (low / step).floor() * step;
    final maxY = math.max((high / step).ceil() * step, minY + step);
    final line = flow.closingMinor >= flow.openingMinor ? colors.moneyIn : colors.moneyOut;
    final lowest = balances.indexOf(low.toInt());
    String day(int index) => index == 0 ? l10n.insOpening : formatDay(context, flow.dates[index - 1]);

    return SectionCard(
      title: l10n.insBalanceTrend,
      children: [
        SizedBox(
          height: 170,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: step,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: value == 0 ? scheme.onSurface.withValues(alpha: 0.35) : colors.hairline,
                  strokeWidth: 1,
                  dashArray: value == 0 ? [4, 4] : null,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                bottomTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: step,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        '${value < 0 ? '−' : ''}${Money.compact(value.round(), currency, locale: context.languageCode)}',
                        style: text.labelSmall,
                      ),
                    ),
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => scheme.inverseSurface,
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      LineTooltipItem(
                        '${day(spot.x.toInt())}\n${context.money(spot.y.round(), currency)}',
                        TextStyle(color: scheme.onInverseSurface, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (final (i, v) in balances.indexed) FlSpot(i.toDouble(), v.toDouble())],
                  isCurved: true,
                  curveSmoothness: 0.2,
                  preventCurveOverShooting: true,
                  barWidth: 3,
                  color: line,
                  dotData: FlDotData(
                    checkToShowDot: (spot, _) => spot.x == balances.length - 1,
                    getDotPainter: (_, _, _, _) =>
                        FlDotCirclePainter(radius: 4.5, color: line, strokeWidth: 2.5, strokeColor: colors.sheet),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [line.withValues(alpha: 0.28), line.withValues(alpha: 0.0)],
                    ),
                  ),
                ),
              ],
            ),
            duration: context.motion(AppMotion.emphasised),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        FactRow(children: [
          FactTile(label: l10n.insOpening, value: context.money(flow.openingMinor, currency)),
          const SizedBox(width: AppSpace.sm),
          FactTile(
            label: l10n.insLowest,
            value: context.money(low.round(), currency),
            detail: day(lowest),
            color: low < 0 ? colors.moneyOut : null,
          ),
          const SizedBox(width: AppSpace.sm),
          FactTile(
            label: l10n.insClosing,
            value: context.money(flow.closingMinor, currency),
            color: context.amountColor(flow.closingMinor >= 0),
          ),
        ]),
      ],
    );
  }
}

/// How healthy the period's cash is: how much of what came in went out, the
/// daily rate, how long the money lasts, and when the business is busiest.
class CashHealthCard extends StatelessWidget {
  const CashHealthCard({super.key, required this.flow, required this.currency});

  final PeriodFlow flow;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final ratio = flow.outRatio;
    final ratioColor = ratio == null
        ? colors.muted
        : ratio > 1
            ? colors.moneyOut
            : ratio > 0.85
                ? colors.gold
                : colors.moneyIn;
    final runway = flow.runwayDays;
    final busiest = flow.busiestWeekday;

    return SectionCard(
      title: l10n.insHealth,
      children: [
        Row(
          children: [
            PercentRing(
              value: ratio ?? 0,
              size: 120,
              stroke: 12,
              half: true,
              color: ratioColor,
              child: Text(
                ratio == null ? '–' : '${_percent(context, ratio * 100)}%',
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontFeatures: tabularFigures),
              ),
            ),
            const SizedBox(width: AppSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.insOutRatio, style: text.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    switch (ratio) {
                      null => l10n.insOutRatioNone,
                      > 1 => l10n.insOutRatioOver(_percent(context, (ratio - 1) * 100)),
                      _ => l10n.insOutRatioKept(_percent(context, (1 - ratio) * 100)),
                    },
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        FactRow(children: [
          FactTile(
            label: l10n.insAvgDailyOut,
            value: context.money(flow.averageDailyOutMinor, currency),
            color: colors.moneyOut,
          ),
          const SizedBox(width: AppSpace.sm),
          FactTile(
            label: l10n.insRunway,
            value: runway == null ? l10n.insRunwaySafe : l10n.insDays(runway),
            detail: runway == null ? l10n.insRunwaySafeDetail : l10n.insRunwayDetail,
            color: runway == null ? colors.moneyIn : (runway < 30 ? colors.moneyOut : null),
          ),
        ]),
        const SizedBox(height: AppSpace.sm),
        FactRow(children: [
          FactTile(label: l10n.insBusiestDay, value: busiest == null ? '–' : weekdayName(context, busiest)),
          const SizedBox(width: AppSpace.sm),
          FactTile(label: l10n.insAvgEntry, value: context.money(flow.averageEntryMinor, currency)),
          const SizedBox(width: AppSpace.sm),
          FactTile(
            label: l10n.insActiveDays,
            value: l10n.insActiveDaysValue(
              localDigits(context, '${flow.activeDays}'),
              localDigits(context, '${math.max(flow.period.daysElapsed(flow.today), 1)}'),
            ),
          ),
        ]),
      ],
    );
  }
}

/// The period's biggest entries, cash out or cash in.
class TopEntriesCard extends ConsumerStatefulWidget {
  const TopEntriesCard({
    super.key,
    required this.scope,
    required this.period,
    required this.currency,
    this.onOpen,
  });

  final InsightsScope scope;
  final InsightsPeriod period;
  final String currency;
  final ValueChanged<TopEntry>? onOpen;

  @override
  ConsumerState<TopEntriesCard> createState() => _TopEntriesCardState();
}

class _TopEntriesCardState extends ConsumerState<TopEntriesCard> {
  String _type = 'cash_out';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final isIn = _type == 'cash_in';
    final entries = ref.watch(topEntriesProvider((widget.scope, widget.period, _type))).value ?? const <TopEntry>[];
    final top = entries.firstOrNull?.entry.amountMinor ?? 1;

    return SectionCard(
      title: l10n.insTopEntries,
      trailing: InsightToggle<String>(
        options: {'cash_out': l10n.cashOut, 'cash_in': l10n.cashIn},
        value: _type,
        onChanged: (value) => setState(() => _type = value),
      ),
      padding: const EdgeInsets.fromLTRB(0, AppSpace.lg, 0, AppSpace.sm),
      children: [
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.lg, 0, AppSpace.lg, AppSpace.md),
            child: Text(l10n.insNothingHere, style: text.bodySmall),
          ),
        for (final (index, item) in entries.indexed)
          InkWell(
            onTap: widget.onOpen == null ? null : () => widget.onOpen!(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? context.amountColor(isIn).withValues(alpha: 0.16)
                          : colors.field,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      localDigits(context, '${index + 1}'),
                      style: text.labelLarge?.copyWith(
                        color: index == 0 ? context.amountColor(isIn) : colors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (item.entry.title?.isNotEmpty ?? false)
                              ? item.entry.title!
                              : (item.categoryName ?? (isIn ? l10n.cashIn : l10n.cashOut)),
                          style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          [
                            formatDate(context, item.entry.entryDate),
                            if (!widget.scope.isBook) item.bookName,
                            item.categoryName,
                          ].whereType<String>().join(' · '),
                          style: text.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        GrowBar(value: item.entry.amountMinor / top, color: context.amountColor(isIn), height: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${isIn ? '+' : '−'}${context.money(item.entry.amountMinor, widget.currency)}',
                    style: text.bodyMedium?.copyWith(
                      color: context.amountColor(isIn),
                      fontWeight: FontWeight.w700,
                      fontFeatures: tabularFigures,
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

/// Who recorded what: each person's entries, with what they brought in and
/// paid out. The busiest wears a crown.
class TeamActivityCard extends StatelessWidget {
  const TeamActivityCard({
    super.key,
    required this.members,
    required this.team,
    required this.me,
    required this.currency,
    this.flow,
  });

  final List<MemberFlow> members;
  final Team? team;
  final String? me;
  final String currency;

  /// The period's flow, for the streak; a book's card leaves it out.
  final PeriodFlow? flow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    if (members.isEmpty) return const SizedBox.shrink();
    final most = members.first.flow.count;
    final total = members.fold<int>(0, (sum, m) => sum + m.flow.count);
    String nameOf(MemberFlow m) {
      if (m.userId != null && m.userId == me) return l10n.insYou;
      return team?.byUser(m.userId)?.displayName ?? l10n.insSomeone;
    }

    final flow = this.flow;
    return SectionCard(
      title: l10n.insTeam,
      children: [
        if (flow != null) ...[
          FactRow(children: [
            FactTile(
              label: l10n.insMostActive,
              value: nameOf(members.first),
              detail: l10n.entriesCount(members.first.flow.count),
            ),
            const SizedBox(width: AppSpace.sm),
            FactTile(
              label: l10n.insStreak,
              value: l10n.insDays(flow.streakDays),
              color: flow.streakDays >= 3 ? colors.gold : null,
            ),
            const SizedBox(width: AppSpace.sm),
            FactTile(label: l10n.insPeople, value: localDigits(context, '${members.length}')),
          ]),
          const SizedBox(height: AppSpace.md),
        ],
        for (final (index, member) in members.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AvatarCircle(initials: initialsOf(nameOf(member)), size: 38),
                    if (index == 0 && members.length > 1)
                      Positioned(
                        top: -9,
                        right: -6,
                        child: Icon(Icons.emoji_events_rounded, size: 18, color: colors.gold),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(nameOf(member),
                                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            '${_percent(context, member.flow.count * 100 / math.max(total, 1))}%',
                            style: text.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      GrowBar(
                        value: member.flow.count / math.max(most, 1),
                        color: Theme.of(context).colorScheme.primary,
                        height: 6,
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(text: l10n.entriesCount(member.flow.count)),
                          if (member.flow.inMinor > 0)
                            TextSpan(
                              text: '  +${Money.compact(member.flow.inMinor, currency, locale: context.languageCode)}',
                              style: TextStyle(color: colors.moneyIn),
                            ),
                          if (member.flow.outMinor > 0)
                            TextSpan(
                              text: '  −${Money.compact(member.flow.outMinor, currency, locale: context.languageCode)}',
                              style: TextStyle(color: colors.moneyOut),
                            ),
                        ]),
                        style: text.labelSmall,
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

/// How many of the period's cash-out entries keep a bill: proof for the books.
class BillCoverageCard extends StatelessWidget {
  const BillCoverageCard({super.key, required this.coverage, required this.currency});

  final BillCoverage coverage;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    if (coverage.total == 0) return const SizedBox.shrink();
    final share = coverage.share;
    final color = share >= 0.9 ? colors.moneyIn : (share >= 0.6 ? colors.gold : colors.moneyOut);
    return SectionCard(
      title: l10n.insBills,
      children: [
        Row(
          children: [
            PercentRing(
              value: share,
              size: 92,
              stroke: 10,
              color: color,
              child: Text(
                '${_percent(context, share * 100)}%',
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontFeatures: tabularFigures),
              ),
            ),
            const SizedBox(width: AppSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.insBillsShare(localDigits(context, '${coverage.withBill}'), localDigits(context, '${coverage.total}')),
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        coverage.missing == 0 ? Icons.verified_rounded : Icons.receipt_long_outlined,
                        size: 16,
                        color: coverage.missing == 0 ? colors.moneyIn : colors.muted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          coverage.missing == 0
                              ? l10n.insBillsAll
                              : l10n.insBillsMissing(context.money(coverage.missingMinor, currency)),
                          style: text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A book of a business against the others: its net, or what came in or went
/// out, its last months as a line, and its share. The top three wear medals.
class BookLeagueCard extends StatefulWidget {
  const BookLeagueCard({super.key, required this.books, required this.currency, this.onOpen});

  final List<BookStanding> books;
  final String currency;
  final ValueChanged<Cashbook>? onOpen;

  @override
  State<BookLeagueCard> createState() => _BookLeagueCardState();
}

enum _LeagueBy { net, cashIn, cashOut }

class _BookLeagueCardState extends State<BookLeagueCard> {
  _LeagueBy _by = _LeagueBy.net;

  static const _medals = [Color(0xFFF5B530), Color(0xFFA9B4C2), Color(0xFFCD8B52)];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    if (widget.books.isEmpty) return const SizedBox.shrink();
    int value(BookStanding b) => switch (_by) {
          _LeagueBy.net => b.flow.netMinor,
          _LeagueBy.cashIn => b.flow.inMinor,
          _LeagueBy.cashOut => b.flow.outMinor,
        };
    final books = [...widget.books]..sort((a, b) => value(b).compareTo(value(a)));
    final scale = books.fold<int>(1, (top, b) => math.max(top, value(b).abs()));
    final total = books.fold<int>(0, (sum, b) => sum + math.max(value(b), 0));

    return SectionCard(
      title: l10n.insBookLeague,
      trailing: InsightToggle<_LeagueBy>(
        options: {_LeagueBy.net: l10n.net, _LeagueBy.cashIn: l10n.insIn, _LeagueBy.cashOut: l10n.insOut},
        value: _by,
        onChanged: (by) => setState(() => _by = by),
      ),
      padding: const EdgeInsets.fromLTRB(0, AppSpace.lg, 0, AppSpace.sm),
      children: [
        for (final (index, book) in books.indexed)
          InkWell(
            onTap: widget.onOpen == null ? null : () => widget.onOpen!(book.book),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < 3 && value(book) != 0 ? _medals[index] : colors.field,
                    ),
                    child: index < 3 && value(book) != 0
                        ? const Icon(Icons.military_tech_rounded, size: 18, color: Colors.white)
                        : Text(localDigits(context, '${index + 1}'),
                            style: text.labelLarge?.copyWith(color: colors.muted, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(book.book.bookName,
                                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            SizedBox(width: 64, height: 24, child: _Sparkline(values: book.months)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: GrowBar(
                                value: value(book).abs() / scale,
                                color: switch (_by) {
                                  _LeagueBy.net => context.amountColor(value(book) >= 0),
                                  _LeagueBy.cashIn => colors.moneyIn,
                                  _LeagueBy.cashOut => colors.moneyOut,
                                },
                                height: 6,
                              ),
                            ),
                            if (_by != _LeagueBy.net && total > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                l10n.insShare(_percent(context, value(book) * 100 / total)),
                                style: text.labelSmall,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(l10n.entriesCount(book.flow.count), style: text.labelSmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_by == _LeagueBy.net && value(book) > 0 ? '+' : ''}${context.money(value(book), widget.currency)}',
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: tabularFigures,
                      color: switch (_by) {
                        _LeagueBy.net => context.amountColor(value(book) >= 0),
                        _LeagueBy.cashIn => colors.moneyIn,
                        _LeagueBy.cashOut => colors.moneyOut,
                      },
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

/// A tiny line of a book's last months, green when it ends up, red when down.
class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    if (values.every((v) => v == 0)) return const SizedBox.shrink();
    final color = context.amountColor(values.last >= values.first);
    return LineChart(
      LineChartData(
        lineTouchData: const LineTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [for (final (i, v) in values.indexed) FlSpot(i.toDouble(), v.toDouble())],
            isCurved: true,
            preventCurveOverShooting: true,
            barWidth: 2,
            color: color,
            dotData: FlDotData(
              checkToShowDot: (spot, _) => spot.x == values.length - 1,
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(radius: 2.5, color: color, strokeWidth: 0),
            ),
            belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}
