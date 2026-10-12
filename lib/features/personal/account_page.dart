import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../plan/upgrade_sheet.dart';
import 'account_ledger.dart';
import 'ledger_repository.dart';
import 'personal_pages.dart';
import 'spending_breakdown.dart';

const _tooltipColor = Color(0xFF0E1B30);
const _tooltipStyle = TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600);

/// One account as a statement: its balance, what came in and went out, and
/// every transaction on it, a page at a time. The period, the filters and the
/// search narrow the list, the totals and the charts together; the balance at
/// the top is always today's.
class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key, required this.accountId});

  final String accountId;

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  /// How close to the end of the list the next page is asked for.
  static const _loadAhead = 600.0;

  final _scroll = ScrollController();
  Timer? _typing;
  bool _insights = false;

  // Changes when the search box must start empty again
  int _searchEpoch = 0;

  String get _id => widget.accountId;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_loadIfNearEnd);
  }

  @override
  void dispose() {
    _typing?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _loadIfNearEnd() {
    if (_insights || !_scroll.hasClients || _scroll.position.extentAfter > _loadAhead) return;
    ref.read(accountFeedProvider(_id).notifier).loadMore();
  }

  AccountFilterController get _filters => ref.read(accountFilterProvider(_id).notifier);

  void _search(String value) {
    _typing?.cancel();
    // Each keystroke would otherwise run the queries again
    _typing = Timer(const Duration(milliseconds: 250), () {
      if (mounted) _filters.set(ref.read(accountFilterProvider(_id)).copyWith(query: value));
    });
  }

  void _clearNarrowing() {
    _typing?.cancel();
    _filters.clearNarrowing();
    setState(() => _searchEpoch++);
  }

  Future<void> _pickPeriod(AccountPeriod period) async {
    HapticFeedback.selectionClick();
    if (period != AccountPeriod.custom) return _filters.setPeriod(period);
    final filter = ref.read(accountFilterProvider(_id));
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: filter.from != null && filter.to != null
          ? DateTimeRange(start: DateTime.parse(filter.from!), end: DateTime.parse(filter.to!))
          : DateTimeRange(start: DateTime(now.year, now.month), end: DateTime(now.year, now.month, now.day)),
    );
    if (picked != null) {
      _filters.setPeriod(AccountPeriod.custom, from: isoDate(picked.start), to: isoDate(picked.end));
    }
  }

  Future<void> _openFilters(Workspace workspace) async {
    final current = ref.read(accountFilterProvider(_id));
    final chosen = await showAppSheet<AccountFilter>(
      context,
      title: context.l10n.filters,
      builder: (_) => _FilterSheet(workspace: workspace, filter: current),
    );
    // The search box may have moved on while the sheet was open
    if (chosen != null) _filters.set(chosen.copyWith(query: ref.read(accountFilterProvider(_id)).query));
  }

  /// A locked account says so before the form opens, not after it is filled in.
  Future<void> _add(Workspace workspace, Account account) async {
    final allowed =
        await guarded(context, () async => ref.read(planGuardProvider).writable(F.personalAccounts, account.id));
    if (allowed && mounted) openTransactionForm(context, workspace, accountId: account.id);
  }

  void _showCategory(CategorySpend category) {
    final filter = ref.read(accountFilterProvider(_id));
    _filters.set(filter.copyWith(
      categoryIds: {?category.categoryId},
      uncategorised: category.categoryId == null,
    ));
    setState(() => _insights = false);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  String _periodLabel(AccountFilter filter, AccountPeriod period) {
    final l10n = context.l10n;
    return switch (period) {
      AccountPeriod.thisMonth => l10n.thisMonth,
      AccountPeriod.lastMonth => l10n.periodLastMonth,
      AccountPeriod.last3Months => l10n.periodLast3Months,
      AccountPeriod.thisYear => l10n.periodThisYear,
      AccountPeriod.allTime => l10n.periodAllTime,
      AccountPeriod.custom => filter.period == AccountPeriod.custom && filter.from != null && filter.to != null
          ? '${formatDate(context, filter.from!)} – ${formatDate(context, filter.to!)}'
          : l10n.periodCustom,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loaded = ref.watch(accountProvider(_id));
    final item = loaded.value;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: loaded.isLoading
            ? const Center(child: AppLoader())
            // Deleted here or on another device
            : EmptyState(icon: Icons.account_balance_wallet_outlined, message: l10n.accountGone),
      );
    }
    final account = item.account;
    final workspace = (ref.watch(workspacesProvider).value ?? const <Workspace>[])
        .where((w) => w.id == account.workspaceId)
        .firstOrNull;
    final locked = !account.isArchived && (ref.watch(entitlementsProvider).value?.isLocked(account.id) ?? false);
    final filter = ref.watch(accountFilterProvider(_id));
    final summary = ref.watch(accountSummaryProvider(_id)).value;
    final series = ref.watch(accountSeriesProvider(_id)).value;
    final feed = ref.watch(accountFeedProvider(_id));
    // A short page may leave room for the next one without any scrolling
    ref.listen(accountFeedProvider(_id), (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadIfNearEnd();
      });
    });

    return PassbookScaffold(
      title: Text(account.name),
      actions: [
        if (workspace != null)
          IconButton(
            tooltip: l10n.editAccount,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showAccountForm(context, workspace, existing: account),
          ),
      ],
      header: _Header(
        item: item,
        locked: locked,
        summary: summary,
        series: series,
        periodLabel: _periodLabel(filter, filter.period),
      ),
      floatingActionButton: workspace == null || account.isArchived
          ? null
          : AddButton(tooltip: l10n.addTransaction, onPressed: () => _add(workspace, account)),
      body: RefreshIndicator(
        onRefresh: ref.read(syncControllerProvider.notifier).syncNow,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // The period stays in reach however far the list has scrolled
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedBar(
                color: context.colors.paper,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.md, AppSpace.page, AppSpace.sm),
                  children: [
                    for (final period in AccountPeriod.values)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpace.sm),
                        child: _Pill(
                          label: _periodLabel(filter, period),
                          icon: period == AccountPeriod.custom ? Icons.date_range_rounded : null,
                          selected: filter.period == period,
                          onTap: () => _pickPeriod(period),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.page, 0, AppSpace.page, AppSpace.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Theme(
                            // On the pale sheet the search pill is white
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme:
                                  Theme.of(context).inputDecorationTheme.copyWith(fillColor: context.colors.sheet),
                            ),
                            child: AppSearchField(
                              key: ValueKey(_searchEpoch),
                              hint: l10n.searchTransactions,
                              onChanged: _search,
                            ),
                          ),
                        ),
                        if (workspace != null) ...[
                          const SizedBox(width: AppSpace.sm),
                          _FilterButton(count: filter.sheetCount, onTap: () => _openFilters(workspace)),
                        ],
                      ],
                    ),
                    if (filter.sheetCount > 0 && workspace != null)
                      _ActiveFilters(workspace: workspace, filter: filter, onChanged: _filters.set),
                    const SizedBox(height: AppSpace.sm),
                    SlidingSegmented<bool>(
                      segments: {false: l10n.transactions, true: l10n.insights},
                      value: _insights,
                      onChanged: (value) => setState(() => _insights = value),
                    ),
                  ],
                ),
              ),
            ),
            if (_insights)
              ..._insightSlivers(account, filter, summary, series)
            else
              ..._listSlivers(workspace, account, filter, summary, feed),
            // Room for the add button
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }

  List<Widget> _listSlivers(
      Workspace? workspace, Account account, AccountFilter filter, AccountSummary? summary, AccountFeed feed) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    if (feed.loading) return const [SliverToBoxAdapter(child: SkeletonList())];
    if (feed.rows.isEmpty) {
      final query = filter.query.trim();
      return [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 300,
            child: filter.isNarrowed
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EmptyState(
                        icon: Icons.search_off_rounded,
                        message: query.isNotEmpty ? l10n.noResultsFor(query) : l10n.noMatches,
                      ),
                      TextButton(onPressed: _clearNarrowing, child: Text(l10n.clearFilters)),
                    ],
                  )
                : EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: filter.period == AccountPeriod.allTime ? l10n.noTransactions : l10n.nothingInPeriod,
                  ),
          ),
        ),
      ];
    }

    // A heading before the first row of each day; with every row shown it
    // carries the balance the day ended on
    final items = <Object>[];
    String? day;
    for (final row in feed.rows) {
      if (row.transaction.occurredOn != day) {
        day = row.transaction.occurredOn;
        items.add((day, row.balanceAfterMinor));
      }
      items.add(row);
    }

    return [
      SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item case (final String date, final int? closing)) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.page, 14, AppSpace.page, 4),
              child: Row(
                children: [
                  Expanded(child: Text(friendlyDate(context, date), style: text.titleSmall)),
                  if (closing != null)
                    Text(
                      context.money(closing, account.currency),
                      style: text.bodySmall?.copyWith(fontFeatures: tabularFigures),
                    ),
                ],
              ),
            );
          }
          final row = item as AccountFeedRow;
          final t = row.transaction;
          final other = row.otherAccountName;
          return TransactionTile(
            view: row.view,
            showDate: false,
            showAccount: false,
            transferLabel:
                other == null ? null : (t.amountMinor < 0 ? l10n.transferTo(other) : l10n.transferFrom(other)),
            balance: row.balanceAfterMinor == null ? null : context.money(row.balanceAfterMinor!, t.currency),
            onTap: () {
              if (workspace != null) openTransactionForm(context, workspace, existing: row.view);
            },
          );
        },
      ),
      if (feed.loadingMore)
        const SliverToBoxAdapter(child: SkeletonList(rows: 3))
      else if (!feed.hasMore && !filter.isNarrowed && summary != null)
        // Where the statement started from
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, 0),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, size: 18, color: context.colors.muted),
                const SizedBox(width: AppSpace.sm),
                Expanded(child: Text(l10n.openingBalance, style: text.bodySmall?.copyWith(fontSize: 13))),
                Text(
                  context.money(summary.openingMinor, account.currency),
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontFeatures: tabularFigures),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  List<Widget> _insightSlivers(Account account, AccountFilter filter, AccountSummary? summary, AccountSeries? series) {
    final l10n = context.l10n;
    if (summary == null || series == null) return const [SliverToBoxAdapter(child: SkeletonList(rows: 4))];
    if (summary.count == 0) {
      return [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 300,
            child: EmptyState(icon: Icons.insights_rounded, message: l10n.nothingInPeriod),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, 0),
        sliver: SliverList.list(children: [
          SectionCard(children: [_Figures(summary: summary, filter: filter, currency: account.currency)]),
          SectionCard(title: l10n.balanceOverTime, children: [
            _BalanceChart(series: series, currency: account.currency),
          ]),
          SectionCard(title: l10n.cashInAndOut, children: [
            _FlowChart(series: series, currency: account.currency),
          ]),
          _CategoryCard(accountId: _id, currency: account.currency, onPick: _showCategory),
        ]),
      ),
    ];
  }
}

/// The account's balance on the navy field, the way it moved over the period,
/// and what came in and went out. A tap on the totals opens their make-up.
class _Header extends StatelessWidget {
  const _Header({
    required this.item,
    required this.locked,
    required this.summary,
    required this.series,
    required this.periodLabel,
  });

  final AccountBalance item;
  final bool locked;
  final AccountSummary? summary;
  final AccountSeries? series;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final account = item.account;
    final muted = text.bodySmall?.copyWith(color: colors.onHeaderMuted);
    final totals = summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(accountKindIcon(account.kind), size: 16, color: colors.onHeaderMuted),
            const SizedBox(width: 6),
            Text(account.isArchived ? l10n.archived : accountKindLabel(context, account.kind), style: muted),
            if (locked) ...[
              const SizedBox(width: 10),
              // Read-only since a downgrade
              Icon(Icons.lock_outline_rounded, size: 14, color: colors.onHeaderMuted),
              const SizedBox(width: 3),
              Text(l10n.lockedTag, style: muted),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: HeaderFigure(label: l10n.currentBalance, amountMinor: item.balanceMinor, currency: account.currency),
            ),
            if (series != null && series!.points.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: SizedBox(width: 104, height: 42, child: _Sparkline(series: series!)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.control),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: totals == null
                ? null
                : () => showAppSheet<void>(
                      context,
                      title: l10n.inAndOutDetails,
                      builder: (_) => _TotalsSheet(summary: totals, currency: account.currency, period: periodLabel),
                    ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
              child: Row(
                children: [
                  HeaderStat(
                    label: l10n.cashIn,
                    amountMinor: totals?.cashInMinor ?? 0,
                    currency: account.currency,
                    color: colors.mint,
                  ),
                  HeaderStat(
                    label: l10n.cashOut,
                    amountMinor: totals?.cashOutMinor ?? 0,
                    currency: account.currency,
                    color: const Color(0xFFFF9AA2),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(periodLabel, style: muted),
                      Icon(Icons.chevron_right_rounded, color: colors.onHeaderMuted),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The balance through the period as a bare line: the shape, not the figures.
class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.series});

  final AccountSeries series;

  @override
  Widget build(BuildContext context) {
    final mint = context.colors.mint;
    final values = [series.openingMinor, for (final p in series.points) p.balanceMinor];
    final lowest = values.reduce((a, b) => a < b ? a : b).toDouble();
    final highest = values.reduce((a, b) => a > b ? a : b).toDouble();
    final room = highest == lowest ? 1.0 : (highest - lowest) * 0.1;
    return ExcludeSemantics(
      child: LineChart(
        LineChartData(
          minY: lowest - room,
          maxY: highest + room,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (final (index, value) in values.indexed) FlSpot(index.toDouble(), value.toDouble())],
              isCurved: true,
              preventCurveOverShooting: true,
              color: mint,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [mint.withValues(alpha: 0.3), mint.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
        duration: context.motion(AppMotion.emphasised),
      ),
    );
  }
}

/// Cash in and cash out taken apart, and the balance on either side of the period.
class _TotalsSheet extends StatelessWidget {
  const _TotalsSheet({required this.summary, required this.currency, required this.period});

  final AccountSummary summary;
  final String currency;
  final String period;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    Widget line(String label, int amountMinor, {Color? color, bool strong = false, IconData? icon}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: color), const SizedBox(width: 8)],
              Expanded(child: Text(label, style: strong ? text.titleSmall : text.bodyMedium)),
              Text(
                context.money(amountMinor, currency),
                style: (strong ? text.titleMedium : text.bodyMedium)
                    ?.copyWith(color: color, fontWeight: FontWeight.w600, fontFeatures: tabularFigures),
              ),
            ],
          ),
        );
    final green = context.amountColor(true), red = context.amountColor(false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(period, style: text.bodySmall),
        const SizedBox(height: AppSpace.sm),
        line(l10n.openingBalance, summary.openingMinor),
        Divider(color: context.colors.hairline),
        line(l10n.income, summary.incomeMinor, color: green, icon: Icons.south_west_rounded),
        line(l10n.transfersIn, summary.transferInMinor, color: green, icon: Icons.swap_horiz_rounded),
        line(l10n.cashIn, summary.cashInMinor, color: green, strong: true),
        Divider(color: context.colors.hairline),
        line(l10n.expense, summary.expenseMinor, color: red, icon: Icons.north_east_rounded),
        line(l10n.transfersOut, summary.transferOutMinor, color: red, icon: Icons.swap_horiz_rounded),
        line(l10n.cashOut, summary.cashOutMinor, color: red, strong: true),
        Divider(color: context.colors.hairline),
        line(l10n.net, summary.netMinor, color: context.amountColor(summary.netMinor >= 0), strong: true),
        line(l10n.closingBalance, summary.closingMinor, strong: true),
      ],
    );
  }
}

/// Holds a row of fixed height at the top of the scrolling sheet.
class _PinnedBar extends SliverPersistentHeaderDelegate {
  _PinnedBar({required this.child, required this.color});

  final Widget child;
  final Color color;

  @override
  double get minExtent => 58;

  @override
  double get maxExtent => 58;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      ColoredBox(color: color, child: child);

  @override
  bool shouldRebuild(_PinnedBar oldDelegate) => true;
}

/// A choice in a row of choices: filled when it is the one in force.
class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap, this.icon, this.color});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  /// Fill when selected; the primary colour when null.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final fill = color ?? scheme.primary;
    final ink = selected ? (color == null ? scheme.onPrimary : Colors.white) : scheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? fill : colors.sheet,
        shape: StadiumBorder(side: BorderSide(color: selected ? fill : colors.hairline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 16, color: ink), const SizedBox(width: 6)],
                Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ink, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final active = count > 0;
    return Tooltip(
      message: context.l10n.filters,
      child: Material(
        color: active ? scheme.primary : colors.sheet,
        borderRadius: BorderRadius.circular(AppRadius.control),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Badge(
              isLabelVisible: active,
              label: Text(localDigits(context, '$count')),
              backgroundColor: colors.gold,
              textColor: colors.onGold,
              alignment: const Alignment(0.55, -0.55),
              child: Center(child: Icon(Icons.tune_rounded, color: active ? scheme.onPrimary : scheme.onSurface)),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the filter sheet has in force, each removable on its own.
class _ActiveFilters extends ConsumerWidget {
  const _ActiveFilters({required this.workspace, required this.filter, required this.onChanged});

  final Workspace workspace;
  final AccountFilter filter;
  final ValueChanged<AccountFilter> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categories = ref.watch(categoriesProvider(workspace.id)).value ?? const <Category>[];
    Widget chip(String label, VoidCallback onRemove, {Color? dot}) => InputChip(
          label: Text(label),
          avatar: dot == null ? null : Center(child: ColorDot(dot)),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onDeleted: onRemove,
        );
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: Wrap(
        spacing: AppSpace.sm,
        runSpacing: AppSpace.xs,
        children: [
          if (filter.kind case final kind?)
            chip(
              switch (kind) { 'income' => l10n.income, 'transfer' => l10n.transfer, _ => l10n.expense },
              () => onChanged(filter.copyWith(kind: () => null)),
            ),
          for (final category in categories.where((c) => filter.categoryIds.contains(c.id)))
            chip(
              category.name,
              () => onChanged(filter.copyWith(categoryIds: {...filter.categoryIds}..remove(category.id))),
              dot: categoryFill(category.color, category.id),
            ),
          if (filter.uncategorised)
            chip(l10n.uncategorised, () => onChanged(filter.copyWith(uncategorised: false)),
                dot: categoryFill(null, null)),
        ],
      ),
    );
  }
}

/// Kind and categories, chosen together and applied in one go.
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.workspace, required this.filter});

  final Workspace workspace;
  final AccountFilter filter;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late AccountFilter _draft = widget.filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final all = ref.watch(categoriesProvider(widget.workspace.id)).value ?? const <Category>[];
    // A transfer has no category; income and expense each have their own
    final categories = [
      for (final c in all)
        if (_draft.kind == null || c.kind == _draft.kind) c,
    ];
    void toggle(String id) => setState(() {
          final ids = {..._draft.categoryIds};
          ids.contains(id) ? ids.remove(id) : ids.add(id);
          _draft = _draft.copyWith(categoryIds: ids);
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.accountKind, style: text.titleSmall),
        const SizedBox(height: AppSpace.sm),
        SlidingSegmented<String>(
          segments: {
            'all': l10n.filterAll,
            'expense': l10n.expense,
            'income': l10n.income,
            'transfer': l10n.transfer,
          },
          value: _draft.kind ?? 'all',
          onChanged: (value) => setState(() {
            final kind = value == 'all' ? null : value;
            // Categories of the other kind could match nothing
            final kept = {
              for (final c in all)
                if (_draft.categoryIds.contains(c.id) && (kind == null || c.kind == kind)) c.id,
            };
            _draft = _draft.copyWith(
              kind: () => kind,
              categoryIds: kept,
              uncategorised: kind != 'transfer' && _draft.uncategorised,
            );
          }),
        ),
        if (_draft.kind != 'transfer') ...[
          const SizedBox(height: AppSpace.xl),
          Text(l10n.categories, style: text.titleSmall),
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final c in categories)
                SizedBox(
                  height: 36,
                  child: _Pill(
                    label: c.name,
                    selected: _draft.categoryIds.contains(c.id),
                    color: categoryFill(c.color, c.id),
                    onTap: () => toggle(c.id),
                  ),
                ),
              SizedBox(
                height: 36,
                child: _Pill(
                  label: l10n.uncategorised,
                  selected: _draft.uncategorised,
                  color: categoryFill(null, null),
                  onTap: () => setState(() => _draft = _draft.copyWith(uncategorised: !_draft.uncategorised)),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpace.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(
                  context,
                  _draft.copyWith(kind: () => null, categoryIds: const {}, uncategorised: false),
                ),
                child: Text(l10n.resetFilters),
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              flex: 2,
              child: FilledButton(onPressed: () => Navigator.pop(context, _draft), child: Text(l10n.applyFilters)),
            ),
          ],
        ),
      ],
    );
  }
}

/// How many transactions, the average spent per day, and the biggest expense.
class _Figures extends StatelessWidget {
  const _Figures({required this.summary, required this.filter, required this.currency});

  final AccountSummary summary;
  final AccountFilter filter;
  final String currency;

  /// Days the period covers so far: an open or future end stops at today.
  int get _days {
    final today = DateTime.parse(todayIso());
    final start = DateTime.parse(filter.from ?? summary.firstDay ?? todayIso());
    var end = DateTime.parse(filter.to ?? todayIso());
    if (end.isAfter(today)) end = today;
    final last = DateTime.parse(summary.lastDay ?? todayIso());
    if (last.isAfter(end)) end = last;
    return end.difference(start).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    Widget tile(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: text.titleMedium?.copyWith(fontFeatures: tabularFigures)),
              ),
            ],
          ),
        );
    final days = _days < 1 ? 1 : _days;
    return Row(
      children: [
        tile(l10n.transactions, localDigits(context, '${summary.count}')),
        const SizedBox(width: AppSpace.md),
        tile(l10n.averagePerDay, context.money((summary.expenseMinor / days).round(), currency)),
        const SizedBox(width: AppSpace.md),
        tile(l10n.largestExpense, context.money(summary.largestExpenseMinor, currency)),
      ],
    );
  }
}

String _stepLabel(BuildContext context, AccountSeries series, DateTime date) {
  final material = MaterialLocalizations.of(context);
  return series.monthly ? material.formatMonthYear(date) : material.formatShortMonthDay(date);
}

/// First and last step under a chart: enough to place it in time.
Widget _ends(BuildContext context, AccountSeries series) {
  final style = Theme.of(context).textTheme.labelSmall;
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_stepLabel(context, series, series.points.first.date), style: style),
        if (series.points.length > 1) Text(_stepLabel(context, series, series.points.last.date), style: style),
      ],
    ),
  );
}

/// The balance after each day (or month) of the period. Touch it for the figure.
class _BalanceChart extends StatelessWidget {
  const _BalanceChart({required this.series, required this.currency});

  final AccountSeries series;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = context.languageCode;
    final points = series.points;
    final values = [series.openingMinor, for (final p in points) p.balanceMinor];
    final lowest = values.reduce((a, b) => a < b ? a : b).toDouble();
    final highest = values.reduce((a, b) => a > b ? a : b).toDouble();
    final room = highest == lowest ? 1.0 : (highest - lowest) * 0.12;
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: LineChart(
            LineChartData(
              minY: lowest - room,
              maxY: highest + room,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => _tooltipColor,
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      LineTooltipItem(
                        // Spot 0 is the balance the period opened with
                        '${spot.x == 0 ? context.l10n.openingBalance : _stepLabel(context, series, points[spot.x.toInt() - 1].date)}\n'
                        '${Money.format(spot.y.round(), currency, locale: locale)}',
                        _tooltipStyle,
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (final (index, value) in values.indexed) FlSpot(index.toDouble(), value.toDouble())],
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: scheme.primary,
                  barWidth: 2.5,
                  dotData: FlDotData(show: values.length <= 12),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [scheme.primary.withValues(alpha: 0.22), scheme.primary.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ],
            ),
            duration: context.motion(AppMotion.emphasised),
          ),
        ),
        _ends(context, series),
      ],
    );
  }
}

/// Cash in beside cash out for each day (or month) that had any.
class _FlowChart extends StatelessWidget {
  const _FlowChart({required this.series, required this.currency});

  final AccountSeries series;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.languageCode;
    final text = Theme.of(context).textTheme;
    final points = series.points;
    final highest = points.fold<int>(1, (max, p) => [max, p.inMinor, p.outMinor].reduce((a, b) => a > b ? a : b));
    Widget legend(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 6),
            Text(label, style: text.bodySmall),
          ],
        );
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: LayoutBuilder(
            builder: (context, box) {
              // Two bars and a gap per step, thinner as the steps multiply
              final width = (box.maxWidth / (points.length * 3)).clamp(1.5, 10.0);
              final top = BorderRadius.vertical(top: Radius.circular(width / 2));
              return BarChart(
                BarChartData(
                  maxY: highest * 1.15,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => _tooltipColor,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                        '${_stepLabel(context, series, points[group.x].date)}\n'
                        '${Money.format(rod.toY.round(), currency, locale: locale)}',
                        _tooltipStyle,
                      ),
                    ),
                  ),
                  barGroups: [
                    for (final (index, p) in points.indexed)
                      BarChartGroupData(x: index, barsSpace: width / 3, barRods: [
                        BarChartRodData(
                            toY: p.inMinor.toDouble(), color: AppTheme.successColor, width: width, borderRadius: top),
                        BarChartRodData(
                            toY: p.outMinor.toDouble(), color: AppTheme.errorColor, width: width, borderRadius: top),
                      ]),
                  ],
                ),
                duration: context.motion(AppMotion.emphasised),
              );
            },
          ),
        ),
        _ends(context, series),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            legend(AppTheme.successColor, l10n.cashIn),
            const SizedBox(width: 20),
            legend(AppTheme.errorColor, l10n.cashOut),
          ],
        ),
      ],
    );
  }
}

/// Where the money went, or came from: a ring of the categories and the
/// categories ranked. A tap on one shows its transactions.
class _CategoryCard extends ConsumerStatefulWidget {
  const _CategoryCard({required this.accountId, required this.currency, required this.onPick});

  final String accountId;
  final String currency;
  final ValueChanged<CategorySpend> onPick;

  @override
  ConsumerState<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends ConsumerState<_CategoryCard> {
  static const _collapsedRows = 6;

  bool _income = false;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final categories =
        ref.watch(accountCategoriesProvider((widget.accountId, _income))).value ?? const <CategorySpend>[];
    final total = categories.fold<int>(0, (sum, c) => sum + c.amountMinor);
    final shown = _expanded ? categories : categories.take(_collapsedRows).toList();

    return SectionCard(
      title: _income ? l10n.whereItCameFrom : l10n.whereItWent,
      children: [
        SlidingSegmented<bool>(
          segments: {false: l10n.expense, true: l10n.income},
          value: _income,
          colorOf: (income) => income ? AppTheme.successColor : AppTheme.errorColor,
          onChanged: (value) => setState(() {
            _income = value;
            _expanded = false;
          }),
        ),
        const SizedBox(height: AppSpace.lg),
        if (total == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
            child: Text(l10n.nothingInPeriod, style: text.bodyMedium?.copyWith(color: colors.muted)),
          )
        else ...[
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    startDegreeOffset: -90,
                    sections: [
                      for (final c in categories)
                        PieChartSectionData(
                          value: c.amountMinor.toDouble(),
                          color: categoryFill(c.color, c.categoryId),
                          radius: 20,
                          showTitle: false,
                        ),
                    ],
                  ),
                  duration: context.motion(AppMotion.emphasised),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    width: 88,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.money(total, widget.currency),
                        style: text.titleMedium?.copyWith(fontFeatures: tabularFigures),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          for (final c in shown)
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.control),
              onTap: () => widget.onPick(c),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ColorDot(categoryFill(c.color, c.categoryId)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(c.name ?? l10n.uncategorised, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                          localDigits(context, '${(c.amountMinor * 100 / total).round()}%'),
                          style: text.bodySmall,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.money(c.amountMinor, widget.currency),
                          style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontFeatures: tabularFigures),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 18, color: colors.muted),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: c.amountMinor / total,
                        minHeight: 5,
                        backgroundColor: colors.field,
                        color: categoryFill(c.color, c.categoryId),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (categories.length > _collapsedRows)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded
                    ? l10n.showLess
                    : l10n.moreCategories(localDigits(context, '${categories.length - _collapsedRows}'))),
              ),
            ),
        ],
      ],
    );
  }
}
