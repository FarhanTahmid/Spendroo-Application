import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../goals/goal_celebration.dart';
import '../goals/goal_math.dart';
import '../goals/goal_style.dart';
import '../goals/goals_overview_card.dart';
import '../goals/goals_page.dart' show byUrgency, newGoal;
import '../goals/goals_repository.dart';
import '../plan/plan_page.dart';
import '../plan/plan_text.dart';
import '../plan/upgrade_sheet.dart';
import '../recurring/recurring_pages.dart';
import '../recurring/recurring_repository.dart';
import 'budget_widgets.dart';
import 'allocations.dart';
import 'ledger_repository.dart';
import 'overview_charts.dart';
import 'spending_breakdown.dart';
import 'split_editor.dart';
import 'transaction_sheets.dart';

String accountKindLabel(BuildContext context, String kind) => switch (kind) {
      'bank' => context.l10n.kindBank,
      'savings' => context.l10n.kindSavings,
      'mobile_money' => context.l10n.kindMobileMoney,
      'card' => context.l10n.kindCard,
      'goal' => context.l10n.goalKind,
      _ => context.l10n.kindCash,
    };

IconData accountKindIcon(String kind) => switch (kind) {
      'bank' => Icons.account_balance_rounded,
      'savings' => Icons.savings_rounded,
      'mobile_money' => Icons.phone_android_rounded,
      'card' => Icons.credit_card_rounded,
      'goal' => Icons.savings_rounded,
      _ => Icons.payments_rounded,
    };

/// [date] (ISO) preselects the day of a new transaction, e.g. from the budget
/// calendar; [accountId] its account, from that account's screen.
/// With [occurrence] the form records a date of a recurring rule: it opens
/// filled in from the rule, and what is saved settles that date.
/// [goalId] opens it on "Save", putting money into that goal.
void openTransactionForm(BuildContext context, Workspace workspace,
        {TransactionView? existing, String? date, String? accountId, OccurrenceView? occurrence, String? goalId}) =>
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => TransactionFormPage(
          workspace: workspace,
          existing: existing,
          initialDate: date,
          initialAccountId: accountId,
          initialGoalId: goalId,
          occurrence: occurrence),
    ));

/// The kind the form shows for putting money into a savings goal. It is saved
/// as a transfer into the goal's account (features/goals).
const saveKind = 'save';

final monthSummaryProvider = StreamProvider.family<MonthSummary, (String, String)>(
  (ref, key) => ref.watch(ledgerRepositoryProvider).watchMonth(key.$1, ref.watch(selectedMonthProvider), key.$2),
);

final monthlyTotalsProvider = StreamProvider.family<List<MonthTotals>, (String, String)>(
  (ref, key) =>
      ref.watch(ledgerRepositoryProvider).watchMonthlyTotals(key.$1, ref.watch(selectedMonthProvider), key.$2),
);

/// Balances, the selected month's income and expense, how spending is adding
/// up against last month and the budgets, where the money went and how the
/// last six months compare. Every chart opens what it is made of on a tap.
/// Figures are in the workspace currency; accounts in other currencies are listed, not added up.
class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key, required this.workspace, this.onOpenBudgets, this.onOpenGoals});

  final Workspace workspace;

  /// Moves to the budgets screen; without it the overview offers no way there.
  final VoidCallback? onOpenBudgets;

  /// Moves to the goals in the Planner tab; without it the goals screen is pushed.
  final VoidCallback? onOpenGoals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final currency = workspace.defaultCurrency;
    final key = (workspace.id, currency);
    final accounts = (ref.watch(accountsProvider(workspace.id)).value ?? const <AccountBalance>[])
        .where((a) => !a.account.isArchived)
        .toList();
    final total =
        accounts.where((a) => a.account.currency == currency).fold<int>(0, (sum, a) => sum + a.balanceMinor);
    // Money set aside in goals is not there to spend, but it is still the user's
    final goals = ref.watch(goalsProvider(workspace.id)).value ?? const <GoalView>[];
    final inGoals = goals.where((g) => g.goal.currency == currency).fold<int>(0, (sum, g) => sum + g.savedMinor);
    final month = ref.watch(monthSummaryProvider(key)).value;
    final trend = ref.watch(monthlyTotalsProvider(key)).value ?? const <MonthTotals>[];
    final budgets = (ref.watch(budgetsProvider(workspace.id)).value ?? const <BudgetProgress>[])
        .where((b) => b.budget.currency == currency)
        .toList();
    final budgetTotal = budgets.fold<int>(0, (sum, b) => sum + b.budget.amountMinor);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final net = month == null ? 0 : month.incomeMinor - month.expenseMinor;
    final saved = month == null || month.incomeMinor <= 0 || net < 0 ? null : (net * 100 / month.incomeMinor).round();
    // What a recurring rule is waiting on, then what the coming week brings
    final open = ref.watch(openOccurrencesProvider(workspace.id)).value ?? const <OccurrenceView>[];
    final waiting = open.where((o) => o.isDue).length;

    return PassbookBody(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeaderFigure(label: goals.isEmpty ? l10n.totalBalance : l10n.available, amountMinor: total, currency: currency),
          if (goals.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            GoalsWorthPanel(
              availableMinor: total,
              inGoalsMinor: inGoals,
              currency: currency,
              onOpenGoals: onOpenGoals ?? () => context.push('/goals'),
            ),
          ],
          const SizedBox(height: 12),
          MonthSwitcher(month: selectedMonth, onChanged: ref.read(selectedMonthProvider.notifier).set),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: ref.read(syncControllerProvider.notifier).syncNow,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.xl),
          children: [
            if (open.isNotEmpty)
              Entrance(
                child: SectionCard(
                  title: waiting > 0 ? l10n.waitingForYou : l10n.comingUp,
                  trailing: TextButton(onPressed: () => context.push('/recurring'), child: Text(l10n.seeAllRecurring)),
                  padding: const EdgeInsets.fromLTRB(0, AppSpace.md, 0, AppSpace.sm),
                  children: [
                    for (final occurrence in open.take(3)) OccurrenceTile(occurrence: occurrence, workspace: workspace),
                  ],
                ),
              ),
            if (month != null) ...[
              Entrance(
                child: SectionCard(
                  title: MaterialLocalizations.of(context).formatMonthYear(selectedMonth),
                  trailing: saved == null
                      ? null
                      : Text(l10n.savedPercent(localDigits(context, '$saved')),
                          style: text.bodySmall?.copyWith(color: colors.muted)),
                  children: [
                    Row(
                      children: [
                        StatTile(
                          label: l10n.income,
                          amountMinor: month.incomeMinor,
                          currency: currency,
                          color: context.amountColor(true),
                          icon: Icons.south_west_rounded,
                        ),
                        StatTile(
                          label: l10n.expense,
                          amountMinor: month.expenseMinor,
                          currency: currency,
                          color: context.amountColor(false),
                          icon: Icons.north_east_rounded,
                        ),
                      ],
                    ),
                    const Divider(height: AppSpace.lg * 2),
                    Row(
                      children: [
                        Expanded(child: Text(l10n.netRemaining, style: text.bodyMedium)),
                        MoneyText(net, currency,
                            style: text.titleMedium?.copyWith(color: context.amountColor(net >= 0))),
                      ],
                    ),
                  ],
                ),
              ),
              // Straight after the month: what is left over has somewhere to go
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.sm),
                child: GoalsStrip(workspace: workspace, onOpenGoals: onOpenGoals),
              ),
              Entrance(child: SpendingPaceCard(workspace: workspace, budgetMinor: budgetTotal)),
              if (budgetTotal > 0)
                Entrance(
                  index: 1,
                  child: BudgetHealthCard(
                    budgets: budgets,
                    pace: SpendPace(month: selectedMonth, spentMinor: month.expenseMinor, limitMinor: budgetTotal),
                    currency: currency,
                    onOpenAll: onOpenBudgets,
                    onOpenBudget: (item) => showBudgetDetail(context, ref, workspace, item, month: selectedMonth),
                  ),
                ),
              Entrance(
                index: 2,
                child: SectionCard(title: l10n.spendingByCategory, children: [
                  if (month.byCategory.isEmpty)
                    Text(l10n.noSpendingYet, style: text.bodyMedium?.copyWith(color: colors.muted))
                  else
                    SpendingBreakdown(
                      month: month,
                      currency: currency,
                      budgets: budgets,
                      onSeeTransactions: (slice) => showCategoryTransactions(context, workspace,
                          categoryId: slice.categoryId, title: slice.name ?? l10n.uncategorised),
                    ),
                ]),
              ),
            ],
            if (trend.any((m) => m.incomeMinor > 0 || m.expenseMinor > 0))
              CashFlowCard(
                trend: trend,
                currency: currency,
                selectedMonth: selectedMonth,
                onGoToMonth: ref.read(selectedMonthProvider.notifier).set,
              ),
            if (accounts.isNotEmpty)
              SectionCard(
                title: l10n.accountBalances,
                padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.sm),
                children: [
                  if (total > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.sm),
                      child: Text(l10n.shareOfTotalBalance, style: text.bodySmall?.copyWith(color: colors.muted)),
                    ),
                  for (final item in accounts)
                    _AccountRow(
                      item: item,
                      // A share of the total only means something for money that is there, in its currency
                      share: item.account.currency == currency && total > 0 && item.balanceMinor > 0
                          ? item.balanceMinor / total
                          : null,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// An account on the overview: its balance, and how much of the total it holds. Opens the account.
class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.item, required this.share});

  final AccountBalance item;
  final double? share;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final share = this.share;
    return Pressable(
      scale: 0.98,
      onTap: () => context.push('/account/${item.account.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            IconBadge(accountKindIcon(item.account.kind), size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.account.name, overflow: TextOverflow.ellipsis)),
                      Text(
                        context.money(item.balanceMinor, item.account.currency),
                        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontFeatures: tabularFigures),
                      ),
                    ],
                  ),
                  if (share != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: share.clamp(0.0, 1.0),
                              minHeight: 4,
                              color: scheme.primary,
                              backgroundColor: scheme.surfaceContainerHighest,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: Text(
                            localDigits(context, '${(share * 100).round()}%'),
                            textAlign: TextAlign.end,
                            style: text.labelSmall?.copyWith(fontFeatures: tabularFigures),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: context.colors.muted),
          ],
        ),
      ),
    );
  }
}

/// One transaction row: what, when, from which account, how much.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.view,
    required this.onTap,
    this.showDate = true,
    this.showAccount = true,
    this.transferLabel,
    this.balance,
  });

  final TransactionView view;
  final VoidCallback onTap;
  final bool showDate;

  /// False on the account's own screen, where every row is on it.
  final bool showAccount;

  /// Says where a transfer went or came from, in place of "Transfer".
  final String? transferLabel;

  /// The account's balance after this transaction, already formatted.
  final String? balance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = view.transaction;
    final isTransfer = t.kind == 'transfer';
    final isIn = t.amountMinor > 0;
    final goal = view.goalName;
    final label = isTransfer
        ? (goal != null ? (isIn ? l10n.fromGoal(goal) : l10n.toGoal(goal)) : (transferLabel ?? l10n.transfer))
        : (t.isSplit
            ? l10n.splitInParts(localDigits(context, '${t.parts.length}'))
            : (view.categoryName ?? l10n.uncategorised));
    return MoneyRow(
      icon: isTransfer
          ? (goal != null ? Icons.savings_rounded : Icons.swap_horiz_rounded)
          : (t.isSplit ? Icons.call_split_rounded : (isIn ? Icons.south_west_rounded : Icons.north_east_rounded)),
      // The badge wears the category's colour; the arrow and the amount still say which way the money went
      tint: isTransfer
          ? null
          : (t.categoryId == null ? context.amountColor(isIn) : context.categoryTint(view.categoryColor, t.categoryId)),
      title: t.note.isNotEmpty ? t.note : label,
      detail: [
        if (showDate) formatDate(context, t.occurredOn),
        if (showAccount) view.accountName,
        if (t.note.isNotEmpty) label,
      ].join(' · '),
      amount: context.money(t.amountMinor, t.currency),
      amountColor: isTransfer ? null : context.amountColor(isIn),
      amountDetail: balance,
      onTap: onTap,
    );
  }
}

/// The month's transactions under day headings, with a search box and a
/// filter by kind. Both work on the device, over what is already loaded.
class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key, required this.workspace});

  final Workspace workspace;

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  String _query = '';
  String _kind = 'all';

  bool _matches(TransactionView view) {
    final t = view.transaction;
    if (_kind != 'all' && t.kind != _kind) return false;
    final query = Money.toAsciiDigits(_query.trim().toLowerCase());
    if (query.isEmpty) return true;
    return [
      t.note,
      view.categoryName ?? '',
      view.accountName,
      Money.toInput(t.amountMinor.abs(), t.currency),
    ].any((field) => field.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workspace = widget.workspace;
    final text = Theme.of(context).textTheme;

    Widget list(List<TransactionView> all) {
      final shown = all.where(_matches).toList();
      if (shown.isEmpty) {
        final searching = _query.trim().isNotEmpty;
        return ListView(children: [
          SizedBox(
            height: 340,
            child: all.isEmpty
                ? EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: l10n.noTransactions,
                    actionLabel: l10n.addTransaction,
                    onAction: () => openTransactionForm(context, workspace),
                  )
                : EmptyState(
                    icon: Icons.search_off_rounded,
                    message: searching ? l10n.noResultsFor(_query.trim()) : l10n.noMatches,
                  ),
          ),
        ]);
      }

      // A heading before the first row of each day, carrying the day's net in the workspace currency
      final rows = <Widget>[];
      String? day;
      for (final view in shown) {
        final t = view.transaction;
        if (t.occurredOn != day) {
          day = t.occurredOn;
          final net = shown
              .where((v) =>
                  v.transaction.occurredOn == day &&
                  v.transaction.kind != 'transfer' &&
                  v.transaction.currency == workspace.defaultCurrency)
              .fold<int>(0, (sum, v) => sum + v.transaction.amountMinor);
          rows.add(Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, 14, AppSpace.page, 4),
            child: Row(
              children: [
                Expanded(child: Text(friendlyDate(context, t.occurredOn), style: text.titleSmall)),
                Text(
                  context.money(net, workspace.defaultCurrency),
                  style: text.bodySmall?.copyWith(fontFeatures: tabularFigures),
                ),
              ],
            ),
          ));
        }
        rows.add(TransactionTile(
          view: view,
          showDate: false,
          // Money into or out of a goal is the goal's to show and to take back
          onTap: view.goalId != null
              ? () => context.push('/goal/${view.goalId}')
              : () => openTransactionForm(context, workspace, existing: view),
        ));
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: AppSpace.xl),
        itemCount: rows.length,
        itemBuilder: (context, index) => rows[index],
      );
    }

    return PassbookBody(
      header: MonthSwitcher(
        month: ref.watch(selectedMonthProvider),
        onChanged: ref.read(selectedMonthProvider.notifier).set,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.sm),
            child: Theme(
              // On the pale sheet the search pill is white
              data: Theme.of(context).copyWith(
                inputDecorationTheme:
                    Theme.of(context).inputDecorationTheme.copyWith(fillColor: context.colors.sheet),
              ),
              child: AppSearchField(
                hint: l10n.searchTransactions,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.page),
            child: SlidingSegmented<String>(
              segments: {
                'all': l10n.filterAll,
                'expense': l10n.expense,
                'income': l10n.income,
                'transfer': l10n.transfer,
              },
              value: _kind,
              onChanged: (value) => setState(() => _kind = value),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: ref.read(syncControllerProvider.notifier).syncNow,
              child: AsyncView(value: ref.watch(transactionsProvider(workspace.id)), builder: list),
            ),
          ),
        ],
      ),
    );
  }
}

/// Add an expense, income or transfer; or edit the amount, date, category and note of an existing one.
class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({
    super.key,
    required this.workspace,
    this.existing,
    this.initialDate,
    this.initialAccountId,
    this.initialGoalId,
    this.occurrence,
  });

  final Workspace workspace;
  final TransactionView? existing;
  final String? initialDate;
  final String? initialAccountId;

  /// Opens on "Save", into this goal.
  final String? initialGoalId;

  /// The date of a recurring rule being recorded.
  final OccurrenceView? occurrence;

  @override
  ConsumerState<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final Transaction? _original = widget.existing?.transaction;
  // What a recurring rule says to record, when this form settles one of its dates
  late final RecurringRule? _rule = widget.occurrence?.rule.rule;
  late String _kind = _original?.kind ?? _rule?.kind ?? (widget.initialGoalId != null ? saveKind : 'expense');
  late String? _goalId = widget.initialGoalId;
  late final _amount = TextEditingController(
    text: _original != null
        ? Money.toInput(_original.amountMinor.abs(), _original.currency)
        : (_rule?.amountMinor == null ? '' : Money.toInput(_rule!.amountMinor!, _rule.currency)),
  );
  late final _note = TextEditingController(
    text: _original?.note ?? (_rule == null ? '' : (_rule.note.isNotEmpty ? _rule.note : _rule.title)),
  );
  late String _date = _original?.occurredOn ?? widget.initialDate ?? todayIso();
  late String? _accountId = _original?.accountId ?? _rule?.accountId ?? widget.initialAccountId;
  late String? _toAccountId = _rule?.toAccountId;
  late String? _categoryId = _original?.categoryId ?? _rule?.categoryId;
  // The parts of a split; empty while the transaction has one category
  late final List<SplitDraft> _split = [
    if (_original != null)
      for (final part in _original.parts)
        _draft(categoryId: part.categoryId, amount: Money.toInput(part.amountMinor, _original.currency))
    else if (_rule != null)
      for (final part in SplitPart.decode(_rule.splits))
        _draft(categoryId: part.categoryId, amount: Money.toInput(part.amountMinor, _rule.currency)),
  ];
  int _refused = 0;

  @override
  void initState() {
    super.initState();
    // What is left to file follows the amount as it is typed
    _amount.addListener(_typed);
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    for (final draft in _split) {
      draft.dispose();
    }
    super.dispose();
  }

  void _typed() {
    if (_split.isNotEmpty && mounted) setState(() {});
  }

  SplitDraft _draft({String? categoryId, String amount = ''}) =>
      SplitDraft(categoryId: categoryId, amount: amount)..amount.addListener(_typed);

  /// The category chosen so far becomes the first part.
  void _startSplit() => setState(() {
        _split.addAll([_draft(categoryId: _categoryId), _draft()]);
      });

  void _endSplit() => setState(() {
        _categoryId = _split.first.categoryId;
        for (final draft in _split) {
          draft.dispose();
        }
        _split.clear();
      });

  void _refuse(String message) {
    setState(() => _refused++);
    context.showMessage(message);
  }

  Future<void> _save(List<AccountBalance> accounts) => guarded(context, () => _write(accounts));

  Future<void> _write(List<AccountBalance> accounts) async {
    if (!_formKey.currentState!.validate()) return setState(() => _refused++);
    final l10n = context.l10n;
    final repo = ref.read(ledgerRepositoryProvider);
    final account = accounts.firstWhere((a) => a.account.id == _accountId).account;
    final amount = Money.evaluate(_amount.text, account.currency)!;
    var splits = const <SplitPart>[];
    if (_split.isNotEmpty && _kind != 'transfer') {
      final parts = splitParts(_split, account.currency);
      if (parts == null) return _refuse(l10n.splitNeedsAmounts);
      if (parts.fold(0, (sum, part) => sum + part.amountMinor) != amount) {
        return _refuse(l10n.splitMismatch(context.money(amount, account.currency)));
      }
      splits = parts;
    }

    if (_kind == saveKind) return _saveToGoal(account, amount);
    if (_original != null) {
      await repo.updateTransaction(_original,
          amountMinor: amount, occurredOn: _date, categoryId: _categoryId, note: _note.text.trim(), splits: splits);
    } else if (_kind == 'transfer') {
      final to = accounts.firstWhere((a) => a.account.id == _toAccountId).account;
      if (to.id == account.id) return _refuse(l10n.sameAccountError);
      if (to.currency != account.currency) return _refuse(l10n.currencyMismatch);
      await repo.addTransfer(account, to,
          amountMinor: amount, occurredOn: _date, note: _note.text.trim(), occurrenceId: widget.occurrence?.occurrence.id);
    } else {
      await repo.addTransaction(account,
          kind: _kind,
          amountMinor: amount,
          occurredOn: _date,
          categoryId: _categoryId,
          note: _note.text.trim(),
          splits: splits,
          occurrenceId: widget.occurrence?.occurrence.id);
    }
    if (!mounted) return;
    final formatted = context.money(amount, account.currency);
    switch (_kind) {
      case 'income':
        showEventBurst(context, AppEvent.moneyIn, label: '+$formatted');
      case 'transfer':
        showEventBurst(context, AppEvent.transfer, label: formatted);
      default:
        showEventBurst(context, AppEvent.moneyOut, label: '−$formatted');
    }
    Navigator.pop(context);
  }

  /// Puts the money into the chosen goal, and celebrates a quarter of the way passed.
  Future<void> _saveToGoal(Account account, int amount) async {
    final l10n = context.l10n;
    final goals = ref.read(goalsProvider(widget.workspace.id)).value ?? const <GoalView>[];
    final view = goals.where((g) => g.goal.id == _goalId).firstOrNull;
    if (view == null) return _refuse(l10n.goalPick);
    if (view.goal.currency != account.currency) return _refuse(l10n.currencyMismatch);
    if (ref.read(entitlementsProvider).value?.isLocked(account.id) ?? false) return _refuse(l10n.goalAccountLocked);
    await ref.read(goalsRepositoryProvider).contribute(view.goal, account,
        amountMinor: amount, occurredOn: _date, note: _note.text.trim());
    if (!mounted) return;
    final before = view.progressOn(DateTime.now()).percent;
    final after = math.max(view.savedMinor + amount, 0) * 100 ~/ view.goal.targetMinor;
    final crossed = marksCrossed(before, after);
    // The screen underneath stays: the celebration is shown there once this one closes
    final host = Navigator.of(context).context;
    showEventBurst(context, AppEvent.moneyIn, label: '+${context.money(amount, account.currency)}');
    Navigator.pop(context);
    if (crossed.isNotEmpty && host.mounted) celebrateMilestone(host, view.goal, crossed.last);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final accounts = (ref.watch(accountsProvider(widget.workspace.id)).value ?? const <AccountBalance>[])
        .where((a) => !a.account.isArchived || a.account.id == _accountId)
        .toList();
    final plan = ref.watch(entitlementsProvider).value;
    // Goals money can go into now: open, and not locked by a downgrade
    final goals = (ref.watch(goalsProvider(widget.workspace.id)).value ?? const <GoalView>[])
        .where((g) => !g.isArchived && !(plan?.isLocked(g.goal.id) ?? false))
        .toList();
    final saving = _kind == saveKind;
    // The most urgent goal is the likeliest one to save for
    if (saving && goals.every((g) => g.goal.id != _goalId)) {
      _goalId = byUrgency(goals, DateTime.now()).firstOrNull?.goal.id;
    }
    final goal = goals.where((g) => g.goal.id == _goalId).firstOrNull;
    final categories = (ref.watch(categoriesProvider(widget.workspace.id)).value ?? const <Category>[])
        .where((c) => c.kind == (_kind == 'income' ? 'income' : 'expense'))
        .toList();
    if (accounts.isEmpty) return Scaffold(appBar: AppBar(), body: const Center(child: AppLoader()));
    _accountId ??= accounts.first.account.id;
    // The first account that is not the one the money leaves
    _toAccountId ??= accounts.firstWhere((a) => a.account.id != _accountId, orElse: () => accounts.first).account.id;
    final account = accounts.firstWhere((a) => a.account.id == _accountId, orElse: () => accounts.first).account;
    final editing = _original != null;
    final isTransfer = _kind == 'transfer';
    Color kindColor(String kind) => switch (kind) {
          'income' => AppTheme.successColor,
          'transfer' => scheme.primary,
          saveKind => goal == null ? const Color(0xFF1FA6A0) : goalColor(goal.goal),
          _ => AppTheme.errorColor,
        };

    final categoryOptions = [
      for (final c in categories) SelectOption(c.id, c.name, color: categoryFill(c.color, c.id)),
    ];
    Future<String?> createCategory(String name) async {
      String? id;
      await guarded(context, () async {
        id = await ref
            .read(ledgerRepositoryProvider)
            .addCategory(widget.workspace.id, name, _kind == 'income' ? 'income' : 'expense');
      });
      return id;
    }

    Widget accountPicker(String label, String? value, ValueChanged<String?> onChanged) => SelectField<String>(
          label: label,
          value: value,
          options: [
            for (final a in accounts)
              SelectOption(
                a.account.id,
                a.account.name,
                icon: accountKindIcon(a.account.kind),
                detail: '${accountKindLabel(context, a.account.kind)} · ${a.account.currency}',
              ),
          ],
          // The account of a saved transaction is fixed: its currency came from it
          onChanged: editing ? null : onChanged,
        );

    return Scaffold(
      backgroundColor: context.colors.sheet,
      appBar: AppBar(
        backgroundColor: context.colors.sheet,
        title: Text(editing ? l10n.editTransaction : l10n.addTransaction),
        actions: [
          if (editing)
            IconButton(
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                if (await confirm(context, l10n.deleteConfirm)) {
                  await ref.read(ledgerRepositoryProvider).deleteTransaction(_original);
                  if (!context.mounted) return;
                  showEventBurst(context, AppEvent.deleted);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      // In the bottom slot, so it rides above the keyboard and messages float above it
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, AppSpace.md),
            child: Shake(
              trigger: _refused,
              child: BusyButton(label: l10n.save, color: kindColor(_kind), onPressed: () => _save(accounts)),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, AppSpace.lg),
          children: [
            // What a recurring rule records is the rule's to say
            if (!editing && _rule == null) ...[
              SlidingSegmented<String>(
                key: const ValueKey('kind-switch'),
                segments: {
                  'expense': l10n.expense,
                  'income': l10n.income,
                  'transfer': l10n.transfer,
                  // Saving is offered every time money is written down
                  saveKind: l10n.saveKind,
                },
                value: _kind,
                colorOf: kindColor,
                onChanged: (value) => setState(() {
                  _kind = value;
                  _categoryId = null;
                  // Its parts were filed under categories of the other kind
                  for (final draft in _split) {
                    draft.dispose();
                  }
                  _split.clear();
                }),
              ),
              const SizedBox(height: 20),
            ],
            AmountField(
              controller: _amount,
              currency: account.currency,
              hero: true,
              autofocus: !editing,
              color: saving ? kindColor(saveKind) : (isTransfer ? null : context.amountColor(_kind == 'income')),
            ),
            const SizedBox(height: 20),
            accountPicker(isTransfer || saving ? l10n.fromAccount : l10n.account, _accountId,
                (value) => setState(() => _accountId = value)),
            const SizedBox(height: 12),
            if (saving) ...[
              if (goals.isEmpty)
                // Nothing to save into yet: the first goal is one tap away
                OutlinedButton.icon(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    final host = navigator.context;
                    navigator.pop();
                    newGoal(host, ref, widget.workspace);
                  },
                  icon: const Icon(Icons.flag_rounded),
                  label: Text(l10n.goalStartFirst),
                )
              else
                SelectField<String>(
                  label: l10n.intoGoal,
                  icon: Icons.flag_rounded,
                  value: _goalId,
                  options: [
                    for (final g in goals)
                      SelectOption(
                        g.goal.id,
                        g.goal.name,
                        icon: goalIcon(g.goal),
                        color: goalColor(g.goal),
                        detail: '${localDigits(context, '${g.progressOn(DateTime.now()).percent}%')} · '
                            '${l10n.goalToGo(context.money(g.progressOn(DateTime.now()).remainingMinor, g.goal.currency))}',
                      ),
                  ],
                  onChanged: (value) => setState(() => _goalId = value),
                ),
              if (goal != null) ...[
                const SizedBox(height: 8),
                _GoalNudge(
                  view: goal,
                  onPick: (amount) => setState(() => _amount.text = Money.toInput(amount, goal.goal.currency)),
                ),
              ],
              const SizedBox(height: 12),
            ],
            if (isTransfer && !editing && !saving) ...[
              accountPicker(l10n.toAccount, _toAccountId, (value) => setState(() => _toAccountId = value)),
              const SizedBox(height: 12),
            ],
            if (!isTransfer && !saving && _split.isEmpty) ...[
              SelectField<String>(
                label: l10n.category,
                icon: Icons.sell_outlined,
                value: _categoryId,
                noneLabel: l10n.none,
                options: categoryOptions,
                createLabel: l10n.newCategory,
                onCreate: createCategory,
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: _startSplit,
                  icon: const Icon(Icons.call_split_rounded, size: 18),
                  label: Text(l10n.splitAction),
                ),
              ),
            ],
            if (!isTransfer && !saving && _split.isNotEmpty) ...[
              SplitEditor(
                drafts: _split,
                currency: account.currency,
                totalMinor: Money.evaluate(_amount.text, account.currency),
                categories: categoryOptions,
                onCreateCategory: createCategory,
                onChanged: () => setState(() {
                  // Parts added inside the editor report what is typed in them too
                  for (final draft in _split) {
                    draft.amount
                      ..removeListener(_typed)
                      ..addListener(_typed);
                  }
                }),
                onRemove: _endSplit,
              ),
              const SizedBox(height: 12),
            ],
            DateField(value: _date, onChanged: (value) => setState(() => _date = value)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.note,
                prefixIcon: const Icon(Icons.notes_rounded, size: 20),
              ),
              maxLength: 200,
              buildCounter: quietCounter,
            ),
            if (!editing && _rule == null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  // Carries over what is typed so far; the rule form takes it from here
                  onPressed: () {
                    final amount = Money.evaluate(_amount.text, account.currency);
                    final parts = _split.isEmpty ? null : splitParts(_split, account.currency);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => RuleFormPage(
                        workspace: widget.workspace,
                        initial: RuleDraft(
                          // A saving repeats as a transfer into the goal
                          kind: saving ? 'transfer' : _kind,
                          freq: 'monthly',
                          startOn: _date,
                          accountId: _accountId,
                          toAccountId: saving ? goal?.goal.accountId : (isTransfer ? _toAccountId : null),
                          categoryId: _categoryId,
                          amountMinor: amount == null || amount <= 0 ? null : amount,
                          note: _note.text.trim(),
                          splits: parts ?? const [],
                        ),
                      ),
                    ));
                  },
                  icon: const Icon(Icons.event_repeat_rounded, size: 18),
                  label: Text(l10n.repeatThis),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key, required this.workspace, this.onOpenGoals});

  final Workspace workspace;

  /// Moves to the goals in the Planner tab; without it the goals screen is pushed.
  final VoidCallback? onOpenGoals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final currency = workspace.defaultCurrency;
    final value = ref.watch(accountsProvider(workspace.id));
    final plan = ref.watch(entitlementsProvider).value;
    final total = (value.value ?? const <AccountBalance>[])
        .where((a) => a.account.currency == currency && !a.account.isArchived)
        .fold<int>(0, (sum, a) => sum + a.balanceMinor);

    final goals = ref.watch(goalsProvider(workspace.id)).value ?? const <GoalView>[];
    final inGoals = goals.where((g) => g.goal.currency == currency).fold<int>(0, (sum, g) => sum + g.savedMinor);

    return PassbookBody(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderFigure(label: goals.isEmpty ? l10n.totalBalance : l10n.available, amountMinor: total, currency: currency),
          if (goals.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            GoalsWorthPanel(
              availableMinor: total,
              inGoalsMinor: inGoals,
              currency: currency,
              onOpenGoals: onOpenGoals ?? () => context.push('/goals'),
            ),
          ],
        ],
      ),
      child: AsyncView(
        value: value,
        builder: (accounts) => ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.xl),
          children: [
            for (final (index, item) in accounts.indexed)
              Entrance(
                index: index,
                child: Opacity(
                  opacity: item.account.isArchived ? 0.55 : 1,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: AppSpace.md),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      // Its transactions; editing the account is one tap further, on that screen
                      onTap: () => context.push('/account/${item.account.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpace.lg),
                        child: Row(
                          children: [
                            IconBadge(accountKindIcon(item.account.kind)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.account.name, style: text.titleMedium, overflow: TextOverflow.ellipsis),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.account.isArchived
                                              ? l10n.archived
                                              : accountKindLabel(context, item.account.kind),
                                          style: text.bodySmall?.copyWith(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Read-only since a downgrade; archiving it is still allowed
                                      if (!item.account.isArchived && (plan?.isLocked(item.account.id) ?? false)) ...[
                                        const SizedBox(width: 8),
                                        const LockedTag(),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            MoneyText(item.balanceMinor, item.account.currency, style: text.titleMedium),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            AddRowButton(label: l10n.addAccount, onPressed: () => showAccountForm(context, workspace)),
            LimitHint(feature: F.personalAccounts, workspace: workspace),
            GoalsAccountsLink(workspace: workspace, onOpenGoals: onOpenGoals),
          ],
        ),
      ),
    );
  }
}

Future<void> showAccountForm(BuildContext context, Workspace workspace, {Account? existing}) => showAppSheet<void>(
      context,
      title: existing == null ? context.l10n.addAccount : context.l10n.editAccount,
      builder: (_) => _AccountForm(workspace: workspace, existing: existing),
    );

class _AccountForm extends ConsumerStatefulWidget {
  const _AccountForm({required this.workspace, this.existing});

  final Workspace workspace;
  final Account? existing;

  @override
  ConsumerState<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<_AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late String _kind = widget.existing?.kind ?? 'cash';
  late String _currency = widget.existing?.currency ?? widget.workspace.defaultCurrency;
  late final _opening = TextEditingController(
    text: Money.toInput(widget.existing?.openingBalanceMinor ?? 0, widget.existing?.currency ?? widget.workspace.defaultCurrency),
  );
  late bool _archived = widget.existing?.isArchived ?? false;
  int _refused = 0;

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
  }

  Future<void> _save() => guarded(context, _write);

  Future<void> _write() async {
    if (!_formKey.currentState!.validate()) return setState(() => _refused++);
    final repo = ref.read(ledgerRepositoryProvider);
    final opening = Money.evaluate(_opening.text, _currency)!;
    if (widget.existing == null) {
      await repo.addAccount(widget.workspace.id,
          name: _name.text.trim(), kind: _kind, currency: _currency, openingBalanceMinor: opening);
    } else {
      await repo.updateAccount(widget.existing!,
          name: _name.text.trim(), kind: _kind, openingBalanceMinor: opening, isArchived: _archived);
    }
    if (!mounted) return;
    showEventBurst(context, AppEvent.saved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = widget.existing != null;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.accountName),
            validator: (value) => (value ?? '').trim().isEmpty ? l10n.nameRequired : null,
          ),
          const SizedBox(height: 12),
          SelectField<String>(
            label: l10n.accountKind,
            value: _kind,
            options: [
              for (final kind in const ['cash', 'bank', 'savings', 'mobile_money', 'card'])
                SelectOption(kind, accountKindLabel(context, kind), icon: accountKindIcon(kind)),
            ],
            onChanged: (value) => setState(() => _kind = value!),
          ),
          const SizedBox(height: 12),
          SelectField<String>(
            label: l10n.currency,
            value: _currency,
            options: currencyOptions(include: _currency),
            // Fixed once the account exists: its transactions are in this currency
            onChanged: editing ? null : (value) => setState(() => _currency = value!),
          ),
          const SizedBox(height: 12),
          AmountField(controller: _opening, currency: _currency, label: l10n.openingBalance, allowZero: true),
          if (editing) ...[
            const SizedBox(height: 12),
            SwitchField(
              title: l10n.archive,
              value: _archived,
              onChanged: (value) => setState(() => _archived = value),
            ),
          ],
          const SizedBox(height: 20),
          Shake(trigger: _refused, child: BusyButton(label: l10n.save, onPressed: _save)),
        ],
      ),
    );
  }
}


/// Under the chosen goal on the "Save" form: how it stands, and the amount
/// that keeps it on pace, one tap away.
class _GoalNudge extends StatelessWidget {
  const _GoalNudge({required this.view, required this.onPick});

  final GoalView view;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final goal = view.goal;
    final progress = view.progressOn(DateTime.now());
    final needed = progress.neededPerMonthMinor;
    final color = goalColor(goal);
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          PercentRing(value: progress.fraction, size: 40, stroke: 4, color: color),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              l10n.goalSavedOf(context.money(view.savedMinor, goal.currency), context.money(goal.targetMinor, goal.currency)),
              style: text.bodySmall,
            ),
          ),
          if (needed != null)
            ActionChip(
              avatar: const Icon(Icons.bolt_rounded, size: 16),
              label: Text(context.money(needed, goal.currency)),
              tooltip: l10n.goalQuickNeeded,
              onPressed: () => onPick(needed),
            ),
        ],
      ),
    );
  }
}
