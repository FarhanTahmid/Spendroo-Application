import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../goals/goal_style.dart';
import '../goals/goals_repository.dart';
import '../personal/allocations.dart';
import '../personal/ledger_repository.dart';
import '../personal/personal_pages.dart';
import '../personal/spending_breakdown.dart' show localDigits;
import '../plan/plan_text.dart';
import '../plan/upgrade_sheet.dart';
import 'recurrence.dart';
import 'recurring_repository.dart';
import 'schedule_editor.dart';

IconData ruleIcon(String kind) => switch (kind) {
      'income' => Icons.south_west_rounded,
      'transfer' => Icons.swap_horiz_rounded,
      reminderKind => Icons.notifications_none_rounded,
      _ => Icons.north_east_rounded,
    };

/// The amount of a rule with its sign, or nothing for a reminder without one.
String ruleAmount(BuildContext context, RecurringRule rule) {
  final amount = rule.amountMinor;
  if (amount == null) return '';
  return context.money(rule.kind == 'expense' ? -amount : amount, rule.currency);
}

void openRuleForm(BuildContext context, Workspace workspace,
        {RuleView? existing, RuleDraft? draft, bool reminder = false}) =>
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => RuleFormPage(workspace: workspace, existing: existing, initial: draft, reminder: reminder),
    ));

/// What waits to be answered, what is coming, and every rule behind them.
class RecurringPage extends ConsumerWidget {
  const RecurringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final workspace = ref.watch(currentWorkspaceProvider);
    if (workspace == null) return Scaffold(appBar: AppBar(title: Text(l10n.recurring)));
    final plan = ref.watch(entitlementsProvider).value;
    // Shown with a lock where the plan leaves recurring transactions out; saving one opens the upgrade sheet
    final locked = plan != null && plan.enforced && !plan.can(F.recurringTransactions) && workspace.role == 'owner';
    final open = ref.watch(openOccurrencesProvider(workspace.id)).value ?? const <OccurrenceView>[];
    final due = open.where((o) => o.isDue).toList();
    final coming = open.where((o) => !o.isDue).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurring)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addRecurring),
        onPressed: () => showAppSheet<void>(
          context,
          title: l10n.addRecurring,
          builder: (sheet) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const IconBadge(Icons.event_repeat_rounded),
                title: Text(l10n.newRecurring),
                trailing: locked ? const LockedTag() : null,
                onTap: () {
                  Navigator.pop(sheet);
                  openRuleForm(context, workspace);
                },
              ),
              ListTile(
                leading: const IconBadge(Icons.notifications_none_rounded),
                title: Text(l10n.newReminder),
                onTap: () {
                  Navigator.pop(sheet);
                  openRuleForm(context, workspace, reminder: true);
                },
              ),
            ],
          ),
        ),
      ),
      body: AsyncView(
        value: ref.watch(rulesProvider(workspace.id)),
        builder: (rules) {
          if (rules.isEmpty) {
            return EmptyState(icon: Icons.event_repeat_rounded, message: l10n.recurringEmpty);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, 96),
            children: [
              if (due.isNotEmpty)
                SectionCard(
                  title: l10n.waitingForYou,
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                  children: [for (final occurrence in due) OccurrenceTile(occurrence: occurrence, workspace: workspace)],
                ),
              if (coming.isNotEmpty)
                SectionCard(
                  title: l10n.comingUp,
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                  children: [for (final occurrence in coming) OccurrenceTile(occurrence: occurrence, workspace: workspace)],
                ),
              SectionCard(
                title: l10n.everythingThatRepeats,
                padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                children: [
                  for (final rule in rules)
                    _RuleTile(rule: rule, workspace: workspace, locked: locked && !rule.isReminder),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({required this.rule, required this.workspace, required this.locked});

  final RuleView rule;
  final Workspace workspace;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = rule.rule;
    final next = rule.nextDue(DateTime.now());
    final state = r.isPaused ? l10n.paused : (next == null ? l10n.ended : l10n.nextOn(formatDate(context, next)));
    return MoneyRow(
      icon: locked ? Icons.lock_outline_rounded : ruleIcon(r.kind),
      tint: r.kind == 'expense' || r.kind == 'income' ? context.amountColor(r.kind == 'income') : null,
      title: rule.label.isEmpty ? l10n.uncategorised : rule.label,
      detail: '${describeSchedule(context, Schedule.of(r))} · $state',
      amount: ruleAmount(context, r),
      amountColor: r.kind == 'expense' || r.kind == 'income' ? context.amountColor(r.kind == 'income') : null,
      amountDetail: rule.isReminder ? null : (r.mode == 'auto' ? l10n.recordsItself : l10n.asksFirst),
      onTap: () => openRuleForm(context, workspace, existing: rule),
    );
  }
}

/// One date of a rule. A due one carries what can be done about it: record
/// it, skip it, or be reminded later.
class OccurrenceTile extends ConsumerWidget {
  const OccurrenceTile({super.key, required this.occurrence, required this.workspace});

  final OccurrenceView occurrence;
  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rule = occurrence.rule;
    final r = rule.rule;
    final repo = ref.read(recurringRepositoryProvider);
    final o = occurrence.occurrence;
    final plain = r.kind == 'expense' || r.kind == 'income';

    Future<void> later() async {
      final days = await showAppSheet<int>(
        context,
        title: l10n.laterIt,
        builder: (sheet) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (label, days) in [(l10n.snoozeTomorrow, 1), (l10n.snoozeThreeDays, 3), (l10n.snoozeWeek, 7)])
              ListTile(title: Text(label), onTap: () => Navigator.pop(sheet, days)),
          ],
        ),
      );
      if (days == null) return;
      final now = DateTime.now();
      // The morning of that day, when a reminder is welcome
      await repo.snooze(o, DateTime(now.year, now.month, now.day + days, 9));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MoneyRow(
          icon: ruleIcon(r.kind),
          tint: plain ? context.amountColor(r.kind == 'income') : null,
          title: rule.label.isEmpty ? l10n.uncategorised : rule.label,
          detail: [
            l10n.dueOn(friendlyDate(context, o.dueOn)),
            if (rule.accountName != null) rule.accountName!,
          ].join(' · '),
          amount: ruleAmount(context, r),
          amountColor: plain ? context.amountColor(r.kind == 'income') : null,
          onTap: rule.isReminder ? null : () => openTransactionForm(context, workspace, occurrence: occurrence),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.page + 52, 0, AppSpace.page, 6),
          child: Wrap(
            spacing: 8,
            children: [
              if (rule.isReminder)
                // Nothing to record: the user says when it is done
                if (occurrence.isDue)
                  FilledButton.tonal(onPressed: () => repo.markDone(o), child: Text(l10n.doneIt))
                else
                  const SizedBox.shrink()
              else
                FilledButton.tonal(
                  onPressed: () => openTransactionForm(context, workspace, occurrence: occurrence),
                  child: Text(l10n.recordIt),
                ),
              TextButton(onPressed: () => repo.skip(o), child: Text(l10n.skipIt)),
              if (occurrence.isDue) TextButton(onPressed: later, child: Text(l10n.laterIt)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A field that opens the clock; null is "the usual time".
class TimeField extends StatelessWidget {
  const TimeField({super.key, required this.label, required this.value, required this.onChanged});

  final String label;

  /// HH:mm:ss, or null.
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final time = value == null
        ? null
        : TimeOfDay(hour: int.parse(value!.substring(0, 2)), minute: int.parse(value!.substring(3, 5)));
    return PickerField(
      label: label,
      icon: Icons.schedule_rounded,
      text: time == null ? context.l10n.usualTime : time.format(context),
      onOpen: () async {
        final picked = await showTimePicker(context: context, initialTime: time ?? const TimeOfDay(hour: 9, minute: 0));
        if (picked != null) {
          onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00');
        }
      },
    );
  }
}

/// Add or edit a rule: what to record (or what to be reminded of), when it
/// falls due, and whether the server records it by itself.
class RuleFormPage extends ConsumerStatefulWidget {
  const RuleFormPage({super.key, required this.workspace, this.existing, this.initial, this.reminder = false});

  final Workspace workspace;
  final RuleView? existing;

  /// A new rule started from a transaction: what the transaction held.
  final RuleDraft? initial;
  final bool reminder;

  @override
  ConsumerState<RuleFormPage> createState() => _RuleFormPageState();
}

class _RuleFormPageState extends ConsumerState<RuleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final RecurringRule? _original = widget.existing?.rule;
  late final RuleDraft? _from = _original == null ? widget.initial : draftOf(_original);
  late String _kind = _from?.kind ?? (widget.reminder ? reminderKind : 'expense');
  late final _title = TextEditingController(text: _from?.title ?? '');
  late final _note = TextEditingController(text: _from?.note ?? '');
  late final _amount = TextEditingController(
    text: _from?.amountMinor == null
        ? ''
        : Money.toInput(_from!.amountMinor!, _original?.currency ?? widget.workspace.defaultCurrency),
  );
  late String? _accountId = _from?.accountId;
  late String? _toAccountId = _from?.toAccountId;
  late String? _categoryId = _from?.categoryId;
  late List<SplitPart> _splits = _from?.splits ?? const [];
  late String _mode = _from?.mode ?? 'confirm';
  late int _remindDays = _from?.remindDaysBefore ?? 0;
  late String? _remindAt = _from?.remindAt;
  late bool _paused = _from?.isPaused ?? false;
  late final ScheduleDraft _schedule = ScheduleDraft(
    freq: _from?.freq ?? 'monthly',
    interval: _from?.interval ?? 1,
    weekdayMask: _from?.weekdayMask ?? 0,
    monthDay: _from?.monthDay,
    setPos: _from?.setPos,
    weekStart: _from?.weekStart ?? defaultWeekStart,
    startOn: _from?.startOn,
    endOn: _from?.endOn,
    maxCount: _from?.maxCount,
  );
  int _refused = 0;

  /// The savings goal the money goes into, when the rule saves for one: it
  /// takes the place of the account the transfer goes to.
  SavingsGoal? _goal;

  bool get _isReminder => _kind == reminderKind;

  @override
  void initState() {
    super.initState();
    if (_original == null) {
      // A new rule counts its weeks from the day the user's own week starts
      ref.read(recurringRepositoryProvider).weekStart().then((day) {
        if (mounted) setState(() => _schedule.weekStart = day);
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _refuse(String message) {
    setState(() => _refused++);
    context.showMessage(message);
  }

  Future<void> _save(List<AccountBalance> accounts) => guarded(context, () => _write(accounts));

  Future<void> _write(List<AccountBalance> accounts) async {
    if (!_formKey.currentState!.validate()) return setState(() => _refused++);
    final l10n = context.l10n;
    final repo = ref.read(recurringRepositoryProvider);
    Account? account, to;
    int? amount;
    if (!_isReminder) {
      account = accounts.firstWhere((a) => a.account.id == _accountId).account;
      amount = Money.evaluate(_amount.text, account.currency)!;
      if (_kind == 'transfer') {
        final goal = _goal;
        to = accounts.where((a) => a.account.id == _toAccountId).firstOrNull?.account ??
            (goal == null ? null : await ref.read(goalsRepositoryProvider).accountOf(goal));
        if (to == null) return _refuse(l10n.goalGone);
        if (to.id == account.id) return _refuse(l10n.sameAccountError);
        if (to.currency != account.currency) return _refuse(l10n.currencyMismatch);
      }
    }
    final s = _schedule.schedule;
    if (nextOnOrAfter(s, parseDay(_schedule.startOn)) == null) return _refuse(l10n.noMoreDates);
    final plain = _kind == 'expense' || _kind == 'income';
    // The parts were typed for another amount: a split that no longer adds up is dropped
    final splits = plain && _splits.fold(0, (sum, part) => sum + part.amountMinor) == amount ? _splits : const <SplitPart>[];
    final draft = RuleDraft(
      kind: _kind,
      title: _title.text.trim(),
      accountId: account?.id,
      toAccountId: to?.id,
      categoryId: plain ? _categoryId : null,
      amountMinor: amount,
      note: _note.text.trim(),
      splits: splits,
      freq: s.freq,
      interval: s.interval,
      weekdayMask: s.weekdayMask,
      monthDay: s.monthDay,
      setPos: s.setPos,
      weekStart: s.weekStart,
      startOn: _schedule.startOn,
      endOn: s.freq == 'once' ? null : _schedule.endOn,
      maxCount: s.freq == 'once' ? null : _schedule.maxCount,
      mode: _mode,
      remindDaysBefore: _remindDays,
      remindAt: _remindAt,
      isPaused: _paused,
    );
    if (_original == null) {
      await repo.addRule(widget.workspace.id, draft, currency: account?.currency ?? widget.workspace.defaultCurrency);
    } else {
      await repo.updateRule(_original, draft);
    }
    if (!mounted) return;
    showEventBurst(context, AppEvent.saved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accounts = (ref.watch(accountsProvider(widget.workspace.id)).value ?? const <AccountBalance>[])
        .where((a) => !a.account.isArchived || a.account.id == _accountId)
        .toList();
    final categories = (ref.watch(categoriesProvider(widget.workspace.id)).value ?? const <Category>[])
        .where((c) => c.kind == (_kind == 'income' ? 'income' : 'expense'))
        .toList();
    if (accounts.isEmpty) return Scaffold(appBar: AppBar(), body: const Center(child: AppLoader()));
    final editing = _original != null;
    final isTransfer = _kind == 'transfer';
    _goal = (ref.watch(goalsProvider(widget.workspace.id)).value ?? const <GoalView>[])
        .where((view) => view.goal.accountId == _toAccountId)
        .firstOrNull
        ?.goal;
    final goal = isTransfer ? _goal : null;
    if (!_isReminder) {
      _accountId ??= accounts.first.account.id;
      _toAccountId ??= accounts.firstWhere((a) => a.account.id != _accountId, orElse: () => accounts.first).account.id;
    }
    final account = accounts.firstWhere((a) => a.account.id == _accountId, orElse: () => accounts.first).account;

    Widget accountPicker(String label, String? value, ValueChanged<String?> onChanged) => SelectField<String>(
          label: label,
          value: value,
          options: [
            for (final a in accounts)
              SelectOption(a.account.id, a.account.name,
                  icon: accountKindIcon(a.account.kind),
                  detail: '${accountKindLabel(context, a.account.kind)} · ${a.account.currency}'),
          ],
          onChanged: onChanged,
        );

    return Scaffold(
      backgroundColor: context.colors.sheet,
      appBar: AppBar(
        backgroundColor: context.colors.sheet,
        title: Text(editing
            ? (_isReminder ? l10n.editReminder : l10n.editRecurring)
            : (_isReminder ? l10n.newReminder : l10n.newRecurring)),
        actions: [
          if (editing)
            IconButton(
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                if (await confirm(context, l10n.deleteRuleConfirm)) {
                  await ref.read(recurringRepositoryProvider).deleteRule(_original);
                  if (!context.mounted) return;
                  showEventBurst(context, AppEvent.deleted);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, AppSpace.md),
            child: Shake(
              trigger: _refused,
              child: BusyButton(label: l10n.save, onPressed: () => _save(accounts)),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, AppSpace.lg),
          children: [
            // A reminder does not turn into a transaction, nor the other way; saving for a goal stays a transfer
            if (!editing && !_isReminder && goal == null) ...[
              SlidingSegmented<String>(
                segments: {'expense': l10n.expense, 'income': l10n.income, 'transfer': l10n.transfer},
                value: _kind,
                onChanged: (value) => setState(() {
                  _kind = value;
                  _categoryId = null;
                  _splits = const [];
                }),
              ),
              const SizedBox(height: 20),
            ],
            if (!_isReminder) ...[
              AmountField(
                controller: _amount,
                currency: account.currency,
                hero: true,
                color: isTransfer ? null : context.amountColor(_kind == 'income'),
              ),
              const SizedBox(height: 20),
            ],
            TextFormField(
              key: const Key('rule-title'),
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
              buildCounter: quietCounter,
              decoration: InputDecoration(labelText: l10n.ruleTitle, prefixIcon: const Icon(Icons.title_rounded, size: 20)),
              // A transaction can go by its category; a reminder has only its title
              validator: (value) => _isReminder && (value ?? '').trim().isEmpty ? l10n.ruleTitleRequired : null,
            ),
            const SizedBox(height: 12),
            if (!_isReminder) ...[
              accountPicker(isTransfer ? l10n.fromAccount : l10n.account, _accountId,
                  (value) => setState(() => _accountId = value)),
              const SizedBox(height: 12),
              if (goal != null) ...[
                // Where the money goes is the goal's account, which is no account to pick
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.intoGoal,
                    prefixIcon: Icon(goalIcon(goal), size: 20, color: context.goalTint(goal)),
                  ),
                  child: Text(goal.name),
                ),
                const SizedBox(height: 12),
              ] else if (isTransfer) ...[
                accountPicker(l10n.toAccount, _toAccountId, (value) => setState(() => _toAccountId = value)),
                const SizedBox(height: 12),
              ],
            ],
            if (!_isReminder && !isTransfer) ...[
              if (_splits.isEmpty)
                SelectField<String>(
                  label: l10n.category,
                  icon: Icons.sell_outlined,
                  value: _categoryId,
                  noneLabel: l10n.none,
                  options: [for (final c in categories) SelectOption(c.id, c.name, color: categoryFill(c.color, c.id))],
                  onChanged: (value) => setState(() => _categoryId = value),
                )
              else
                // Carried over from the transaction it was made from
                InputChip(
                  avatar: const Icon(Icons.call_split_rounded, size: 18),
                  label: Text(l10n.splitKept(localDigits(context, '${_splits.length}'))),
                  onDeleted: () => setState(() => _splits = const []),
                ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.note, prefixIcon: const Icon(Icons.notes_rounded, size: 20)),
              maxLength: 200,
              buildCounter: quietCounter,
            ),
            const SizedBox(height: 20),
            ScheduleEditor(draft: _schedule, onChanged: () => setState(() {})),
            const SizedBox(height: 20),
            if (!_isReminder) ...[
              SwitchField(
                title: l10n.recordAutomatically,
                subtitle: l10n.recordAutomaticallyHint,
                value: _mode == 'auto',
                onChanged: (on) => setState(() => _mode = on ? 'auto' : 'confirm'),
              ),
              const SizedBox(height: 12),
            ],
            SelectField<int>(
              label: l10n.remindMe,
              icon: Icons.notifications_none_rounded,
              value: _remindDays,
              options: [
                SelectOption(0, l10n.remindOnTheDay),
                SelectOption(1, l10n.remindDayBefore),
                for (final days in {3, 7, if (_remindDays > 1) _remindDays})
                  SelectOption(days, l10n.remindDaysBefore(localDigits(context, '$days'))),
              ],
              onChanged: (value) => setState(() => _remindDays = value ?? 0),
            ),
            const SizedBox(height: 12),
            TimeField(label: l10n.remindAt, value: _remindAt, onChanged: (value) => setState(() => _remindAt = value)),
            if (editing) ...[
              const SizedBox(height: 12),
              SwitchField(
                title: l10n.paused,
                subtitle: l10n.pausedHint,
                value: _paused,
                onChanged: (on) => setState(() => _paused = on),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
