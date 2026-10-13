import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/money.dart';
import '../../core/ui.dart';
import '../personal/ledger_repository.dart';
import '../personal/personal_pages.dart' show accountKindIcon, monthSummaryProvider;
import '../personal/spending_breakdown.dart' show localDigits;
import '../plan/upgrade_sheet.dart';
import 'goal_math.dart';
import 'goal_ring.dart';
import 'goal_style.dart';
import 'goals_repository.dart';

/// Accounts money can move between with this goal: open ones, in its currency,
/// and not read-only since a downgrade (the server would refuse that half of the transfer).
List<AccountBalance> _accountsFor(WidgetRef ref, SavingsGoal goal) {
  final plan = ref.watch(entitlementsProvider).value;
  return (ref.watch(accountsProvider(goal.workspaceId)).value ?? const <AccountBalance>[])
      .where((a) => !a.account.isArchived && a.account.currency == goal.currency)
      .where((a) => !(plan?.isLocked(a.account.id) ?? false))
      .toList();
}

/// Puts money into the goal. Returns the quarters of the way the money passed,
/// for the screen behind to celebrate; null when nothing was saved.
Future<List<int>?> showContributeSheet(BuildContext context, GoalView view) => showAppSheet<List<int>>(
      context,
      title: context.l10n.goalAddMoneyTo(view.goal.name),
      builder: (_) => _ContributeForm(view: view),
    );

class _ContributeForm extends ConsumerStatefulWidget {
  const _ContributeForm({required this.view});

  final GoalView view;

  @override
  ConsumerState<_ContributeForm> createState() => _ContributeFormState();
}

class _ContributeFormState extends ConsumerState<_ContributeForm> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  String? _accountId;
  String _date = todayIso();
  int _refused = 0;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save(List<AccountBalance> accounts) => guarded(context, () async {
        if (!_formKey.currentState!.validate()) return setState(() => _refused++);
        final goal = widget.view.goal;
        final from = accounts.firstWhere((a) => a.account.id == _accountId);
        final amount = Money.evaluate(_amount.text, goal.currency)!;
        if (amount > from.balanceMinor && from.balanceMinor >= 0) {
          // Allowed, as an account may run below zero, but said so
          context.showMessage(context.l10n.goalMoreThanBalance(from.account.name));
        }
        await ref.read(goalsRepositoryProvider).contribute(goal, from.account, amountMinor: amount, occurredOn: _date);
        if (!mounted) return;
        final before = widget.view.progressOn(DateTime.now()).percent;
        final after = math.max(widget.view.savedMinor + amount, 0) * 100 ~/ goal.targetMinor;
        showEventBurst(context, AppEvent.moneyIn, label: '+${context.money(amount, goal.currency)}');
        Navigator.pop(context, marksCrossed(before, after));
      });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final goal = widget.view.goal;
    final accounts = _accountsFor(ref, goal);
    if (accounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpace.xl),
        child: Text(l10n.goalNoAccountInCurrency(goal.currency), style: text.bodyMedium),
      );
    }
    _accountId ??= (accounts.toList()..sort((a, b) => b.balanceMinor.compareTo(a.balanceMinor))).first.account.id;
    final progress = widget.view.progressOn(DateTime.now());
    final income = ref.watch(monthSummaryProvider((goal.workspaceId, goal.currency))).value?.incomeMinor ?? 0;

    // Amounts worth a single tap: what this month needs, a tenth of the income, all that is left
    final quick = <(String, int)>[
      if (progress.neededPerMonthMinor != null) (l10n.goalQuickNeeded, progress.neededPerMonthMinor!),
      if (income > 0) (l10n.goalQuickTenth, (income / 10).round()),
      if (progress.remainingMinor > 0) (l10n.goalQuickRest, progress.remainingMinor),
    ];

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AmountField(controller: _amount, currency: goal.currency, hero: true, autofocus: true, color: goalColor(goal)),
          if (quick.isNotEmpty) ...[
            const SizedBox(height: AppSpace.sm),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final (label, amount) in quick)
                  ActionChip(
                    avatar: const Icon(Icons.bolt_rounded, size: 16),
                    label: Text('$label · ${context.money(amount, goal.currency)}'),
                    onPressed: () => setState(() => _amount.text = Money.toInput(amount, goal.currency)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpace.lg),
          SelectField<String>(
            label: l10n.fromAccount,
            value: _accountId,
            options: [
              for (final a in accounts)
                SelectOption(
                  a.account.id,
                  a.account.name,
                  icon: accountKindIcon(a.account.kind),
                  detail: context.money(a.balanceMinor, a.account.currency),
                ),
            ],
            onChanged: (value) => setState(() => _accountId = value),
          ),
          const SizedBox(height: AppSpace.md),
          DateField(value: _date, onChanged: (value) => setState(() => _date = value)),
          const SizedBox(height: AppSpace.xl),
          Shake(
            trigger: _refused,
            child: BusyButton(
              label: l10n.goalAddMoney,
              icon: Icons.savings_rounded,
              color: goalColor(goal),
              onPressed: () => _save(accounts),
            ),
          ),
        ],
      ),
    );
  }
}

/// Why money is taken out, kept in the transfer's note.
enum WithdrawReason { emergency, reached, changedPlans, other }

/// Takes money out of a goal. On purpose slower than a transfer: it shows what
/// the goal loses, and staying put is the bigger button. A goal that is
/// reached gives its money up with no such pause.
class WithdrawPage extends ConsumerStatefulWidget {
  const WithdrawPage({super.key, required this.view, required this.stats});

  final GoalView view;
  final GoalStats stats;

  @override
  ConsumerState<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends ConsumerState<WithdrawPage> {
  final _formKey = GlobalKey<FormState>();
  late final bool _reached = widget.view.progressOn(DateTime.now()).isReached;
  late final _amount = TextEditingController(
    text: _reached ? Money.toInput(widget.view.savedMinor, widget.view.goal.currency) : '',
  );
  String? _accountId;
  WithdrawReason? _reason;
  int _refused = 0;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  String _reasonLabel(WithdrawReason reason) {
    final l10n = context.l10n;
    return switch (reason) {
      WithdrawReason.emergency => l10n.withdrawEmergency,
      WithdrawReason.reached => l10n.withdrawReached,
      WithdrawReason.changedPlans => l10n.withdrawChangedPlans,
      WithdrawReason.other => l10n.withdrawOther,
    };
  }

  Future<void> _withdraw(List<AccountBalance> accounts) async {
    if (!_formKey.currentState!.validate()) return setState(() => _refused++);
    final goal = widget.view.goal;
    final amount = Money.evaluate(_amount.text, goal.currency)!;
    final to = accounts.firstWhere((a) => a.account.id == _accountId).account;
    final reason = _reason ?? (_reached ? WithdrawReason.reached : null);
    await ref.read(goalsRepositoryProvider).withdraw(goal, to,
        amountMinor: amount, occurredOn: todayIso(), note: reason == null ? '' : _reasonLabel(reason));
    if (!mounted) return;
    showEventBurst(context, AppEvent.transfer, label: context.money(amount, goal.currency));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final goal = widget.view.goal;
    final saved = widget.view.savedMinor;
    final accounts = _accountsFor(ref, goal);
    // Back where most of it came from, when that account is still open
    final usual = widget.stats.sourceIds.where((id) => accounts.any((a) => a.account.id == id)).firstOrNull;
    _accountId ??= usual ?? accounts.firstOrNull?.account.id;
    final today = DateTime.now();
    final now = widget.view.progressOn(today);
    final typed = math.min(Money.evaluate(_amount.text, goal.currency) ?? 0, saved);
    final after = GoalProgress.of(
      savedMinor: saved - typed,
      targetMinor: goal.targetMinor,
      createdOn: widget.view.createdOn,
      today: today,
      targetOn: widget.view.targetOn,
    );
    final pace = widget.stats.averagePerMonthMinor;
    // No finish dates from a goal too young to have a pace: the detail screen shows none either
    final young = widget.stats.tooEarly;
    final finishNow = young ? null : GoalStats.finishAt(now.remainingMinor, pace, today);
    final finishAfter = young ? null : GoalStats.finishAt(after.remainingMinor, pace, today);
    final color = goalColor(goal);
    String day(DateTime date) => formatDay(context, date);

    final ringsRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GoalRingPercent(progress: now, color: color, size: 96, stroke: 9),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
          child: Icon(Icons.arrow_forward_rounded, color: colors.muted),
        ),
        GoalRingPercent(progress: after, color: color, size: 96, stroke: 9, faded: true),
      ],
    );

    final cost = typed <= 0 || _reached
        ? null
        : (finishNow != null && finishAfter != null && dayOf(finishAfter).isAfter(dayOf(finishNow))
            ? l10n.withdrawFinishMoves(day(finishNow), day(finishAfter))
            : l10n.withdrawSetsBack(context.money(typed, goal.currency)));

    final withdrawButton = _reached
        ? BusyButton(
            label: l10n.withdrawMove(context.money(typed, goal.currency)),
            icon: Icons.shopping_bag_rounded,
            color: color,
            onPressed: accounts.isEmpty ? null : () => _withdraw(accounts),
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: colors.moneyOut, minimumSize: const Size.fromHeight(52)),
            onPressed: accounts.isEmpty ? null : () => _withdraw(accounts),
            child: Text(l10n.withdrawConfirm(context.money(typed, goal.currency))),
          );

    return Scaffold(
      backgroundColor: colors.sheet,
      appBar: AppBar(backgroundColor: colors.sheet),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, AppSpace.md),
            child: Shake(
              trigger: _refused,
              child: _reached
                  ? withdrawButton
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Staying put is the easy choice
                        BusyButton(label: l10n.goalKeepSaving, color: color, onPressed: () => Navigator.pop(context)),
                        const SizedBox(height: AppSpace.sm),
                        withdrawButton,
                      ],
                    ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, 0, AppSpace.page, AppSpace.lg),
          children: [
            Text(
              _reached ? l10n.withdrawReachedTitle : l10n.withdrawTitle(goal.name),
              style: text.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.xl),
            ringsRow,
            // Always there, so the amount below keeps its place in the list, and its focus, as this changes
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.md),
              child: Text(cost ?? '', textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: colors.moneyOut)),
            ),
            const SizedBox(height: AppSpace.lg),
            AmountField(controller: _amount, currency: goal.currency, hero: true),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => _amount.text = Money.toInput(saved, goal.currency),
                child: Text(l10n.withdrawAll(context.money(saved, goal.currency))),
              ),
            ),
            if (accounts.isEmpty)
              Text(l10n.goalNoAccountInCurrency(goal.currency), style: text.bodyMedium)
            else
              SelectField<String>(
                label: l10n.toAccount,
                value: _accountId,
                options: [
                  for (final a in accounts)
                    SelectOption(a.account.id, a.account.name, icon: accountKindIcon(a.account.kind)),
                ],
                onChanged: (value) => setState(() => _accountId = value),
              ),
            if (!_reached) ...[
              const SizedBox(height: AppSpace.lg),
              Text(l10n.withdrawWhy, style: text.titleSmall),
              const SizedBox(height: AppSpace.sm),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final reason in WithdrawReason.values)
                    ChoiceChip(
                      label: Text(_reasonLabel(reason)),
                      selected: _reason == reason,
                      onSelected: (on) => setState(() => _reason = on ? reason : null),
                    ),
                ],
              ),
            ],
            // Checked here rather than in the field: the field does not know the goal's balance
            FormField<void>(
              validator: (_) {
                final amount = Money.evaluate(_amount.text, goal.currency);
                if (amount == null || amount <= 0) return l10n.goalEnterAmount;
                if (amount > saved) return l10n.withdrawTooMuch(context.money(saved, goal.currency));
                return null;
              },
              builder: (field) => field.errorText == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: AppSpace.md),
                      child: Text(field.errorText!, style: text.bodySmall?.copyWith(color: colors.moneyOut)),
                    ),
            ),
            const SizedBox(height: AppSpace.lg),
            Text(
              l10n.withdrawNote(localDigits(context, '${now.percent}')),
              style: text.bodySmall?.copyWith(color: colors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
