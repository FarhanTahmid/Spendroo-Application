import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui.dart';
import '../personal/ledger_repository.dart';
import '../personal/spending_breakdown.dart' show localDigits;
import 'year_review.dart';

/// "2025", or "2026 so far" while the year is under way.
String reviewYearLabel(BuildContext context, YearReview review) {
  final year = localDigits(context, '${review.year}');
  return review.isPartial ? context.l10n.reviewYearSoFar(year) : year;
}

String _month(BuildContext context, DateTime month, {bool long = false}) =>
    (long ? DateFormat.MMMM(context.languageCode) : DateFormat.MMM(context.languageCode)).format(month);

String _signed(BuildContext context, int percent) => localDigits(context, '${percent > 0 ? '+' : ''}$percent');

/// The year on one card, on the navy field and in the brand, made to be
/// shared as a picture: what was kept, what came in and went out, and a strip
/// of the months.
class ReviewHeroCard extends StatelessWidget {
  const ReviewHeroCard({super.key, required this.review, required this.currency});

  final YearReview review;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final kept = review.netMinor >= 0;
    final rate = review.savingsRate;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.lg, AppSpace.xl, AppSpace.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.header, colors.headerEnd],
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.onHeader),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const BrandLogo(height: 26, layout: BrandLayout.horizontal, onDark: true),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.xs),
                  decoration: BoxDecoration(color: colors.gold, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(
                    reviewYearLabel(context, review),
                    style: text.labelLarge?.copyWith(color: colors.onGold, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            Text(
              kept ? l10n.reviewKept : l10n.reviewOverspent,
              style: text.bodyMedium?.copyWith(color: colors.onHeaderMuted),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: MoneyText(
                review.netMinor.abs(),
                currency,
                style: text.displaySmall?.copyWith(color: kept ? colors.mint : colors.moneyOut),
              ),
            ),
            if (rate != null && kept)
              Text(
                l10n.reviewRate(localDigits(context, '$rate')),
                style: text.bodyMedium?.copyWith(color: colors.onHeaderMuted),
              ),
            const SizedBox(height: AppSpace.lg),
            Row(
              children: [
                Expanded(
                  child: _HeroFigure(
                    label: l10n.reviewCameIn,
                    amountMinor: review.incomeMinor,
                    currency: currency,
                    color: colors.mint,
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: _HeroFigure(
                    label: l10n.reviewWentOut,
                    amountMinor: review.expenseMinor,
                    currency: currency,
                    color: colors.onHeader,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.lg),
            SizedBox(height: 56, child: _MonthStrip(review: review)),
          ],
        ),
      ),
    );
  }
}

class _HeroFigure extends StatelessWidget {
  const _HeroFigure({required this.label, required this.amountMinor, required this.currency, required this.color});

  final String label;
  final int amountMinor;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.labelMedium?.copyWith(color: context.colors.onHeaderMuted)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: MoneyText(amountMinor, currency, style: text.titleMedium?.copyWith(color: color)),
        ),
      ],
    );
  }
}

/// Twelve small pairs of bars on the navy card: money in beside money out.
class _MonthStrip extends StatelessWidget {
  const _MonthStrip({required this.review});

  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final top = review.months.fold<int>(1, (a, m) => math.max(a, math.max(m.incomeMinor, m.expenseMinor)));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final month in review.months)
          Expanded(
            child: Opacity(
              opacity: review.isPartial && review.isOpen(month.month) ? 0.45 : 1,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _bar(month.incomeMinor / top, colors.mint),
                        const SizedBox(width: 2),
                        _bar(month.expenseMinor / top, colors.onHeaderMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMMMM', context.languageCode).format(month.month),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onHeaderMuted, fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _bar(double share, Color color) => FractionallySizedBox(
    heightFactor: share <= 0 ? 0.02 : math.max(share, 0.04),
    child: Container(
      width: 5,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    ),
  );
}

/// Income, spending and what was kept, each against the year before.
class ReviewVersusCard extends StatelessWidget {
  const ReviewVersusCard({super.key, required this.review, required this.currency});

  final YearReview review;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final before = localDigits(context, '${review.year - 1}');
    return SectionCard(
      title: l10n.reviewAgainst(before),
      children: [
        _VersusRow(
          label: l10n.income,
          amountMinor: review.incomeMinor,
          currency: currency,
          change: review.incomeChange,
          before: before,
          riseIsGood: true,
        ),
        _VersusRow(
          label: l10n.expense,
          amountMinor: review.expenseMinor,
          currency: currency,
          change: review.expenseChange,
          before: before,
          riseIsGood: false,
        ),
        _VersusRow(
          label: l10n.net,
          amountMinor: review.netMinor,
          currency: currency,
          change: review.netChange,
          before: before,
          riseIsGood: true,
        ),
      ],
    );
  }
}

class _VersusRow extends StatelessWidget {
  const _VersusRow({
    required this.label,
    required this.amountMinor,
    required this.currency,
    required this.change,
    required this.before,
    required this.riseIsGood,
  });

  final String label;
  final int amountMinor;
  final String currency;
  final int? change;
  final String before;

  /// More income is good news; more spending is not.
  final bool riseIsGood;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final rose = (change ?? 0) > 0;
    final color = change == null || change == 0 ? colors.muted : context.amountColor(rose == riseIsGood);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodyMedium),
                Row(
                  children: [
                    if (change != null && change != 0) ...[
                      Icon(rose ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 14, color: color),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        change == null
                            ? context.l10n.reviewNothingBefore(before)
                            : context.l10n.reviewChangeOn(_signed(context, change!), before),
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          MoneyText(amountMinor, currency, style: text.titleSmall),
        ],
      ),
    );
  }
}

/// Income and spending month by month, the months that spent most and least
/// marked. Months still to come are faded; tapping a month opens it.
class ReviewMonthsCard extends StatelessWidget {
  const ReviewMonthsCard({super.key, required this.review, required this.currency, this.onOpenMonth});

  final YearReview review;
  final String currency;
  final ValueChanged<DateTime>? onOpenMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final top = review.months.fold<int>(1, (a, m) => math.max(a, math.max(m.incomeMinor, m.expenseMinor)));
    final (most, least) = (review.biggestMonth, review.smallestMonth);
    return SectionCard(
      title: l10n.reviewMonthByMonth,
      children: [
        Wrap(
          spacing: AppSpace.lg,
          children: [
            LegendKey(color: colors.moneyIn, label: l10n.income),
            LegendKey(color: colors.moneyOut, label: l10n.expense),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final month in review.months)
                Expanded(
                  child: _MonthColumn(
                    key: ValueKey('review-month-${monthKey(month.month)}'),
                    month: month,
                    top: top,
                    faded: review.isOpen(month.month),
                    mark: month.month == most?.month
                        ? Icons.arrow_drop_up_rounded
                        : month.month == least?.month
                        ? Icons.arrow_drop_down_rounded
                        : null,
                    onTap: onOpenMonth == null ? null : () => onOpenMonth!(month.month),
                  ),
                ),
            ],
          ),
        ),
        if (most != null || least != null) ...[
          const SizedBox(height: AppSpace.md),
          FactRow(
            children: [
              if (most != null)
                FactTile(
                  label: l10n.reviewSpentMost,
                  value: _month(context, most.month, long: true),
                  detail: context.money(most.amountMinor, currency),
                  color: colors.moneyOut,
                ),
              if (most != null && least != null) const SizedBox(width: AppSpace.sm),
              if (least != null)
                FactTile(
                  label: l10n.reviewSpentLeast,
                  value: _month(context, least.month, long: true),
                  detail: context.money(least.amountMinor, currency),
                  color: colors.moneyIn,
                ),
            ],
          ),
        ],
        if (onOpenMonth != null) ...[
          const SizedBox(height: AppSpace.sm),
          Text(l10n.reviewMonthHint, style: text.bodySmall?.copyWith(color: colors.muted)),
        ],
      ],
    );
  }
}

class _MonthColumn extends StatelessWidget {
  const _MonthColumn({super.key, required this.month, required this.top, required this.faded, this.mark, this.onTap});

  final MonthTotals month;
  final int top;
  final bool faded;
  final IconData? mark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget bar(int amount, Color color) => FractionallySizedBox(
      heightFactor: amount <= 0 ? 0.01 : math.max(amount / top, 0.03),
      child: Container(
        width: 7,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      label: _month(context, month.month, long: true),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Opacity(
          opacity: faded ? 0.4 : 1,
          child: Column(
            children: [
              SizedBox(
                height: 18,
                child: mark == null
                    ? null
                    : Icon(
                        mark,
                        size: 18,
                        color: mark == Icons.arrow_drop_up_rounded ? colors.moneyOut : colors.moneyIn,
                      ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    bar(month.incomeMinor, colors.moneyIn),
                    const SizedBox(width: 1),
                    bar(month.expenseMinor, colors.moneyOut),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.xs),
              // Bangla short names run longer than three letters: one line, shrunk to the column
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _month(context, month.month),
                    maxLines: 1,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: colors.muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The categories that took most of the year's spending, against the year before.
class ReviewCategoriesCard extends StatelessWidget {
  const ReviewCategoriesCard({super.key, required this.review, required this.currency});

  final YearReview review;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final top = review.topCategories;
    final rest = review.categories.skip(top.length).toList();
    final restMinor = rest.fold<int>(0, (a, c) => a + c.amountMinor);
    final before = localDigits(context, '${review.year - 1}');
    return SectionCard(
      title: l10n.reviewWhereItWent,
      children: [
        for (final (index, category) in top.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpace.md),
          _CategoryRow(
            category: category,
            currency: currency,
            share: review.expenseMinor == 0 ? 0 : category.amountMinor / review.expenseMinor,
            before: review.hasPrevious ? before : null,
          ),
        ],
        if (rest.isNotEmpty) ...[
          const SizedBox(height: AppSpace.md),
          Text(
            l10n.reviewMoreCategories(localDigits(context, '${rest.length}'), context.money(restMinor, currency)),
            style: text.bodySmall?.copyWith(color: colors.muted),
          ),
        ],
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.currency, required this.share, this.before});

  final CategorySpend category;
  final String currency;
  final double share;

  /// The year before, as shown; null when it had nothing to compare with.
  final String? before;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final fill = categoryFill(category.color, category.categoryId);
    final change = category.changePercent;
    final rose = (change ?? 0) > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(
                category.name ?? l10n.uncategorised,
                style: text.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            MoneyText(category.amountMinor, currency, style: text.titleSmall),
          ],
        ),
        const SizedBox(height: AppSpace.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: share.clamp(0, 1).toDouble(),
            minHeight: 6,
            color: fill,
            backgroundColor: colors.field,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.reviewShareOfSpending(localDigits(context, '${(share * 100).round()}')),
                style: text.labelSmall?.copyWith(color: colors.muted),
              ),
            ),
            if (before != null && change != null)
              Text(
                l10n.reviewChangeOn(_signed(context, change), before!),
                style: text.labelSmall?.copyWith(color: change == 0 ? colors.muted : context.amountColor(!rose)),
              ),
          ],
        ),
      ],
    );
  }
}

/// The figures worth a second look: the biggest expense, a usual month, the
/// best month for saving, months in the green and goals reached.
class ReviewHighlightsCard extends StatelessWidget {
  const ReviewHighlightsCard({super.key, required this.review, required this.currency});

  final YearReview review;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final best = review.bestMonth;
    final average = review.averageExpenseMinor;
    final tiles = <Widget>[
      if (review.largestExpenseMinor > 0)
        FactTile(
          label: l10n.reviewBiggestExpense,
          value: context.money(review.largestExpenseMinor, currency),
          color: colors.moneyOut,
        ),
      if (average != null) FactTile(label: l10n.reviewAverageMonth, value: context.money(average, currency)),
      if (best != null)
        FactTile(
          label: l10n.reviewBestMonth,
          value: _month(context, best.month, long: true),
          detail: l10n.reviewKeptAmount(context.money(best.amountMinor, currency)),
          color: colors.moneyIn,
        ),
      if (review.closedMonths > 0)
        FactTile(
          label: l10n.reviewMonthsInGreen,
          value: l10n.reviewMonthsOf(
            localDigits(context, '${review.monthsInGreen}'),
            localDigits(context, '${review.closedMonths}'),
          ),
        ),
      if (review.goalsReached > 0)
        FactTile(
          label: l10n.reviewGoalsReached,
          value: localDigits(context, '${review.goalsReached}'),
          color: colors.gold,
        ),
    ];
    if (tiles.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: l10n.reviewHighlights,
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpace.sm),
          FactRow(
            children: [
              tiles[i],
              const SizedBox(width: AppSpace.sm),
              if (i + 1 < tiles.length) tiles[i + 1] else const Spacer(),
            ],
          ),
        ],
      ],
    );
  }
}
