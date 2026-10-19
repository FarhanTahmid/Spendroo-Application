import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../core/ui.dart';
import '../../fields/field_repository.dart';
import '../../personal/ledger_repository.dart';
import '../../personal/personal_pages.dart' show pickTrendLength;
import '../../personal/spending_breakdown.dart';
import '../../profile/profile_repository.dart';
import '../../team/team_repository.dart';
import '../book_access.dart';
import '../cashbook_pages.dart' show showEntryDetails;
import '../cashbook_repository.dart';
import 'cash_heatmap.dart';
import 'cash_trend_card.dart';
import 'insights_cards.dart';
import 'insights_providers.dart';
import 'insights_repository.dart';

/// The two halves of a business's home, on the navy field.
class BusinessTabs extends StatelessWidget {
  const BusinessTabs({super.key, required this.insights, required this.onChanged});

  final bool insights;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SlidingSegmented<bool>(
        onHeader: true,
        segments: {false: context.l10n.booksTab, true: context.l10n.insights},
        value: insights,
        onChanged: onChanged,
      );
}

/// How many months the trend charts, held to the plan; puts the choice back
/// within it after a downgrade.
int _trendMonths(WidgetRef ref) {
  final limit = ref.watch(trendLimitProvider);
  final length = ref.watch(trendLengthProvider);
  if (limit != null && length > limit) {
    final allowed = trendLengths.lastWhere((l) => l <= limit, orElse: () => trendLengths.first);
    if (allowed != length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(trendLengthProvider.notifier).set(allowed));
    }
  }
  return trendMonths(length, limit);
}

/// One advanced chart: its name and icon for the list of what Business adds.
typedef _Advanced = ({IconData icon, String name, Widget card});

/// The Business plan's charts, or (without it) the first two blurred over
/// what unlocks them and the rest named.
List<Widget> _advancedCards(BuildContext context, WidgetRef ref, Workspace? workspace, List<_Advanced> cards) {
  if (cards.isEmpty) return const [];
  if (workspace == null || !advancedLocked(ref, workspace)) return [for (final c in cards) c.card];
  const teasers = 2;
  return [
    for (final c in cards.take(teasers)) LockedInsight(workspace: workspace, child: c.card),
    if (cards.length > teasers)
      MoreInsightsTile(workspace: workspace, items: [for (final c in cards.skip(teasers)) (c.icon, c.name)]),
  ];
}

Widget _staggered(List<Widget> cards) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final (index, card) in cards.indexed) Entrance(index: index, child: card)],
    );

/// A book in numbers, for the period chosen on the header: the pulse, the
/// trend and where the money went for everyone; with the Business plan also
/// its balance day by day, a calendar of activity, its cash health, the
/// biggest entries, who recorded what, the bills kept, and its own fields.
class BookInsightsView extends ConsumerWidget {
  const BookInsightsView({super.key, required this.book, required this.workspace, required this.access});

  final Cashbook book;
  final Workspace? workspace;
  final BookAccess access;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = book.currency;
    final scope = InsightsScope.book(book.id);
    final period = ref.watch(insightsPeriodProvider(book.id));
    final key = (scope, period);
    final months = _trendMonths(ref);
    final trend = ref.watch(insightsMonthlyProvider((scope, period.month, months))).value ?? const <MonthTotals>[];
    final categories = ref.watch(categorySplitProvider(key)).value ?? const <SplitRow>[];
    final payments = ref.watch(paymentSplitProvider(key)).value ?? const <SplitRow>[];
    final workspace = this.workspace;
    final team = workspace != null && workspace.kind == 'business' && seesTeam(workspace);
    final fields = ref.watch(entryFieldsProvider(book.id)).value ?? const <EntryField>[];

    return RefreshIndicator(
      onRefresh: ref.read(syncControllerProvider.notifier).syncNow,
      child: AsyncView(
        value: ref.watch(periodFlowProvider(key)),
        builder: (flow) {
          final spent = spendSummary(categories);
          final cards = <Widget>[
            PulseHeroCard(flow: flow, currency: currency),
            if (flow.isEmpty) const InsightsEmpty(),
            if (trend.any((m) => m.incomeMinor > 0 || m.expenseMinor > 0))
              CashTrendCard(
                trend: trend,
                currency: currency,
                selectedMonth: period.month,
                length: ref.watch(trendLengthProvider),
                limit: ref.watch(trendLimitProvider),
                onLengthChanged: (length) => pickTrendLength(context, ref, length),
                onGoToMonth: ref.read(insightsPeriodProvider(book.id).notifier).month,
              ),
            if (spent.byCategory.isNotEmpty)
              SectionCard(title: l10n.insWhereMoneyWent, children: [
                SpendingBreakdown(month: spent, currency: currency, overRange: !period.isMonth),
              ]),
            IncomeSourcesCard(rows: categories, currency: currency),
            PaymentSplitCard(rows: payments, currency: currency),
            if (!flow.isEmpty)
              ..._advancedCards(context, ref, workspace, [
                (icon: Icons.show_chart_rounded, name: l10n.insBalanceTrend, card: BalanceLineCard(flow: flow, currency: currency)),
                (icon: Icons.calendar_view_month_rounded, name: l10n.insActivity, card: ActivityHeatmapCard(flow: flow, currency: currency)),
                (icon: Icons.monitor_heart_outlined, name: l10n.insHealth, card: CashHealthCard(flow: flow, currency: currency)),
                (
                  icon: Icons.format_list_numbered_rounded,
                  name: l10n.insTopEntries,
                  card: TopEntriesCard(
                    scope: scope,
                    period: period,
                    currency: currency,
                    onOpen: (item) => showEntryDetails(
                      context,
                      EntryView(item.entry, item.categoryName, item.paymentMethodName, categoryColor: item.categoryColor),
                      workspace: workspace,
                      access: access,
                    ),
                  ),
                ),
                if (team)
                  (
                    icon: Icons.groups_2_outlined,
                    name: l10n.insTeam,
                    card: TeamActivityCard(
                      members: ref.watch(memberFlowProvider(key)).value ?? const [],
                      team: ref.watch(teamProvider(workspace.id)).value,
                      me: ref.watch(profileProvider).value?.id,
                      currency: currency,
                    ),
                  ),
                (
                  icon: Icons.receipt_long_outlined,
                  name: l10n.insBills,
                  card: BillCoverageCard(
                    coverage: ref.watch(billCoverageProvider(key)).value ?? const BillCoverage(0, 0),
                    currency: currency,
                  ),
                ),
                if (fields.isNotEmpty)
                  (
                    icon: Icons.tune_rounded,
                    name: l10n.insByField,
                    card: FieldSplitCard(bookId: book.id, fields: fields, period: period, currency: currency),
                  ),
              ]),
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.xl),
            children: [_staggered(cards)],
          );
        },
      ),
    );
  }
}

/// A business in numbers, across its books in its own currency: the pulse and
/// the trend for everyone; with the Business plan also the books against each
/// other, where the money went across them, and who recorded what.
class BusinessInsightsPage extends ConsumerWidget {
  const BusinessInsightsPage({super.key, required this.workspace, required this.tabs});

  final Workspace workspace;

  /// The Books / Insights switch, at the top of the header.
  final Widget tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final currency = workspace.defaultCurrency;
    final scope = InsightsScope.business(workspace.id, currency);
    final period = ref.watch(insightsPeriodProvider(workspace.id));
    final key = (scope, period);
    final months = _trendMonths(ref);
    final trend = ref.watch(insightsMonthlyProvider((scope, period.month, months))).value ?? const <MonthTotals>[];
    final others = ref.watch(otherCurrencyBooksProvider((workspace.id, currency))).value ?? 0;
    final team = seesTeam(workspace);

    return PassbookBody(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tabs,
          const SizedBox(height: AppSpace.md),
          InsightsPeriodBar(workspace: workspace, scopeId: workspace.id),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: ref.read(syncControllerProvider.notifier).syncNow,
        child: AsyncView(
          value: ref.watch(periodFlowProvider(key)),
          builder: (flow) {
            final categories = ref.watch(categorySplitProvider(key)).value ?? const <SplitRow>[];
            final spent = spendSummary(categories);
            final cards = <Widget>[
              PulseHeroCard(flow: flow, currency: currency),
              if (others > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, AppSpace.md),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: context.colors.muted),
                      const SizedBox(width: 6),
                      Expanded(child: Text(l10n.insOtherCurrencies(others), style: text.bodySmall)),
                    ],
                  ),
                ),
              if (flow.isEmpty) const InsightsEmpty(),
              if (trend.any((m) => m.incomeMinor > 0 || m.expenseMinor > 0))
                CashTrendCard(
                  trend: trend,
                  currency: currency,
                  selectedMonth: period.month,
                  length: ref.watch(trendLengthProvider),
                  limit: ref.watch(trendLimitProvider),
                  onLengthChanged: (length) => pickTrendLength(context, ref, length),
                  onGoToMonth: ref.read(insightsPeriodProvider(workspace.id).notifier).month,
                ),
              ..._advancedCards(context, ref, workspace, [
                (
                  icon: Icons.leaderboard_rounded,
                  name: l10n.insBookLeague,
                  card: BookLeagueCard(
                    books: ref.watch(bookStandingsProvider((workspace.id, currency, period))).value ?? const [],
                    currency: currency,
                    onOpen: (book) => context.push('/cashbook/${book.id}?tab=insights'),
                  ),
                ),
                if (spent.byCategory.isNotEmpty)
                  (
                    icon: Icons.donut_large_rounded,
                    name: l10n.insWhereMoneyWent,
                    card: SectionCard(title: l10n.insWhereMoneyWent, children: [
                      SpendingBreakdown(month: spent, currency: currency, overRange: !period.isMonth),
                    ]),
                  ),
                if (categories.any((r) => r.inMinor > 0))
                  (
                    icon: Icons.south_west_rounded,
                    name: l10n.insWhereMoneyCame,
                    card: IncomeSourcesCard(rows: categories, currency: currency),
                  ),
                (
                  icon: Icons.account_balance_wallet_outlined,
                  name: l10n.insPaymentMethods,
                  card: PaymentSplitCard(
                    rows: ref.watch(paymentSplitProvider(key)).value ?? const [],
                    currency: currency,
                  ),
                ),
                if (team && !flow.isEmpty)
                  (
                    icon: Icons.groups_2_outlined,
                    name: l10n.insTeam,
                    card: TeamActivityCard(
                      members: ref.watch(memberFlowProvider(key)).value ?? const [],
                      team: ref.watch(teamProvider(workspace.id)).value,
                      me: ref.watch(profileProvider).value?.id,
                      currency: currency,
                      flow: flow,
                    ),
                  ),
              ]),
            ];
            return ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.xl),
              children: [_staggered(cards)],
            );
          },
        ),
      ),
    );
  }
}
