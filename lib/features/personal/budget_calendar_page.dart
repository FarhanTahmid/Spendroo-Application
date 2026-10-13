import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/money.dart';
import '../../core/ui.dart';
import '../plan/upgrade_sheet.dart';
import 'budget_widgets.dart';
import 'ledger_repository.dart';
import 'personal_pages.dart';
import 'transaction_sheets.dart';

/// The month at a glance: what the budgets allow, what each day cost, and how
/// each category is doing. Days are coloured against the daily allowance
/// (the month's total budget spread evenly over its days).
class BudgetCalendarPage extends ConsumerWidget {
  const BudgetCalendarPage({super.key, required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final month = ref.watch(selectedMonthProvider);
    final currency = workspace.defaultCurrency;
    final budgets = ref.watch(budgetsProvider(workspace.id)).value ?? const <BudgetProgress>[];
    final daily = ref.watch(dailySpendProvider((workspace.id, currency))).value ?? const <int, int>{};

    final own = budgets.where((b) => b.budget.currency == currency).toList();
    final totalBudget = own.fold<int>(0, (sum, b) => sum + b.budget.amountMinor);
    final spent = daily.values.fold<int>(0, (sum, value) => sum + value);
    final allowance = totalBudget ~/ daysInMonth(month);
    final remaining = totalBudget - spent;
    final pace = SpendPace(month: month, spentMinor: spent, limitMinor: totalBudget);
    // The ones nearest their limit first
    final ranked = [...budgets]..sort((a, b) => b.usedPercent.compareTo(a.usedPercent));
    final budgeted = {for (final b in budgets) b.budget.categoryId};
    final unbudgeted = (ref.watch(monthSummaryProvider((workspace.id, currency))).value?.byCategory ?? const <CategorySpend>[])
        .where((c) => c.categoryId != null && !budgeted.contains(c.categoryId))
        .take(4)
        .toList();
    void addBudget() => showBudgetForm(context, ref, workspace, month: month);

    return PassbookBody(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Without a budget there is nothing to have left; show what was spent
          if (totalBudget > 0) ...[
            HeaderFigure(
              label: l10n.remaining,
              amountMinor: remaining,
              currency: currency,
              color: remaining < 0 ? const Color(0xFFFF9AA2) : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                HeaderStat(label: l10n.budgetThisMonth, amountMinor: totalBudget, currency: currency),
                const SizedBox(width: 12),
                HeaderStat(label: l10n.spent, amountMinor: spent, currency: currency),
              ],
            ),
          ] else
            HeaderFigure(label: l10n.spent, amountMinor: spent, currency: currency),
          const SizedBox(height: 12),
          MonthSwitcher(month: month, onChanged: ref.read(selectedMonthProvider.notifier).set),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.xl),
        children: [
          if (totalBudget > 0) Entrance(child: BudgetGaugeCard(pace: pace, currency: currency)),
          Entrance(
            index: 1,
            child: SectionCard(
              padding: const EdgeInsets.all(AppSpace.md),
              children: [
                if (allowance > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Text('${l10n.dailyAllowance}: ${l10n.perDay(context.money(allowance, currency))}',
                        style: text.bodySmall),
                  ),
                _CalendarGrid(
                  month: month,
                  daily: daily,
                  allowance: allowance,
                  currency: currency,
                  onDayTap: (day) => showDaySheet(context, workspace, DateTime(month.year, month.month, day)),
                ),
                if (allowance > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
                    child: Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        LegendKey(color: AppTheme.successColor.withValues(alpha: 0.5), label: l10n.legendWithin),
                        LegendKey(color: AppTheme.warningColor.withValues(alpha: 0.7), label: l10n.legendNear),
                        LegendKey(color: AppTheme.errorColor.withValues(alpha: 0.6), label: l10n.legendOver),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (budgets.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(l10n.noBudgets, textAlign: TextAlign.center, style: TextStyle(color: context.colors.muted)),
            )
          else
            for (final item in ranked)
              BudgetCard(
                item: item,
                pace: pace,
                onTap: () => showBudgetDetail(context, ref, workspace, item, month: month),
              ),
          AddRowButton(label: l10n.addBudget, onPressed: addBudget),
          if (unbudgeted.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.md),
              child: NotBudgetedCard(
                categories: unbudgeted,
                currency: currency,
                onSetLimit: (category) =>
                    showBudgetForm(context, ref, workspace, month: month, categoryId: category.categoryId),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.daily,
    required this.allowance,
    required this.currency,
    required this.onDayTap,
  });

  final DateTime month;
  final Map<int, int> daily;
  final int allowance;
  final String currency;
  final ValueChanged<int> onDayTap;

  /// No spending: plain. Within the allowance: green. Up to half again over: amber. Beyond: red.
  Color? _shade(BuildContext context, int spent) {
    if (spent == 0) return null;
    if (allowance == 0) return Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    if (spent <= allowance) return AppTheme.successColor.withValues(alpha: 0.18);
    if (spent * 2 <= allowance * 3) return AppTheme.warningColor.withValues(alpha: 0.28);
    return AppTheme.errorColor.withValues(alpha: 0.25);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final locale = context.languageCode;
    final text = Theme.of(context).textTheme;
    final firstWeekday = localizations.firstDayOfWeekIndex; // 0 = Sunday
    final leading = (DateTime(month.year, month.month, 1).weekday % 7 - firstWeekday + 7) % 7;
    final days = daysInMonth(month);
    final now = DateTime.now();
    final isCurrentMonth = now.year == month.year && now.month == month.month;
    String digits(String text) => locale == 'bn' ? Money.toBengaliDigits(text) : text;

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(localizations.narrowWeekdays[(firstWeekday + i) % 7], style: text.labelSmall),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.8,
          children: [
            for (var i = 0; i < leading; i++) const SizedBox.shrink(),
            for (var day = 1; day <= days; day++)
              Padding(
                padding: const EdgeInsets.all(2),
                child: Material(
                  key: ValueKey('day-$day'),
                  color: _shade(context, daily[day] ?? 0) ?? Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isCurrentMonth && now.day == day
                        ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onDayTap(day),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          digits('$day'),
                          style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontFeatures: tabularFigures),
                        ),
                        if ((daily[day] ?? 0) > 0)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              Money.compact(daily[day]!, currency, locale: locale),
                              style: text.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Add or change a budget. "This month only" sets an override for [month]
/// and leaves the category's usual limit as it is. A new budget opens on [categoryId] when given.
Future<void> showBudgetForm(BuildContext context, WidgetRef ref, Workspace workspace,
    {required DateTime month, BudgetProgress? existing, String? categoryId}) async {
  final l10n = context.l10n;
  final repo = ref.read(ledgerRepositoryProvider);
  final currency = existing?.budget.currency ?? workspace.defaultCurrency;
  final categories = (await repo.watchCategories(workspace.id).first).where((c) => c.kind == 'expense').toList();
  if (!context.mounted) return;

  final formKey = GlobalKey<FormState>();
  final amount = TextEditingController(
    text: existing == null ? '' : Money.toInput(existing.budget.amountMinor, currency),
  );
  final options = [for (final c in categories) SelectOption(c.id, c.name, color: categoryFill(c.color, c.id))];
  var chosen = existing?.budget.categoryId ?? categoryId ?? categories.firstOrNull?.id;
  var thisMonthOnly = existing?.isOverride ?? false;
  var refused = 0;

  await showAppSheet<void>(
    context,
    title: existing == null ? l10n.addBudget : existing.categoryName,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AmountField(controller: amount, currency: currency, label: l10n.monthlyLimit, hero: true),
            const SizedBox(height: 16),
            if (existing == null) ...[
              SelectField<String>(
                label: l10n.category,
                icon: Icons.sell_outlined,
                value: chosen,
                options: options,
                createLabel: l10n.newCategory,
                onCreate: (name) async {
                  String? id;
                  await guarded(context, () async => id = await repo.addCategory(workspace.id, name, 'expense'));
                  if (id != null) options.add(SelectOption(id!, name, color: categoryFill(null, id)));
                  return id;
                },
                onChanged: (value) => setState(() => chosen = value),
              ),
              const SizedBox(height: 12),
            ],
            SwitchField(
              title: l10n.thisMonthOnly,
              subtitle: '${MaterialLocalizations.of(context).formatMonthYear(month)} · ${l10n.thisMonthOnlyHint}',
              value: thisMonthOnly,
              // An override stays an override; remove it to go back to the usual limit
              onChanged: existing?.isOverride == true ? null : (value) => setState(() => thisMonthOnly = value),
            ),
            const SizedBox(height: 20),
            Shake(
              trigger: refused,
              child: FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate() || chosen == null) return setState(() => refused++);
                  final saved = await guarded(
                    context,
                    () => repo.setBudget(workspace.id, chosen!, Money.evaluate(amount.text, currency)!, currency,
                        month: thisMonthOnly ? monthKey(month) : null),
                  );
                  if (!saved || !context.mounted) return;
                  showEventBurst(context, AppEvent.saved);
                  Navigator.pop(context);
                },
                child: Text(l10n.save),
              ),
            ),
            if (existing != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: () async {
                    await repo.deleteBudget(existing.budget.id);
                    if (!context.mounted) return;
                    showEventBurst(context, AppEvent.deleted);
                    Navigator.pop(context);
                  },
                  child: Text(existing.isOverride && existing.recurring != null ? l10n.useUsualLimit : l10n.delete),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
