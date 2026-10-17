import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/money.dart';
import '../../core/ui.dart';
import '../personal/ledger_repository.dart';
import '../personal/personal_pages.dart' show monthlyTotalsProvider;
import '../plan/upgrade_sheet.dart';
import 'goal_math.dart';
import 'goal_ring.dart';
import 'goal_style.dart';
import 'goals_repository.dart';

/// Opens the new-goal screen, or the goal's own when [existing] is given.
/// [template] preselects what the goal is for.
void openGoalForm(BuildContext context, Workspace workspace, {SavingsGoal? existing, String? template}) =>
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => GoalFormPage(workspace: workspace, existing: existing, template: template),
    ));

/// Name, target, an optional date, an icon and a colour. A preview under the
/// form shows what it takes each month, week and day.
class GoalFormPage extends ConsumerStatefulWidget {
  const GoalFormPage({super.key, required this.workspace, this.existing, this.template});

  final Workspace workspace;
  final SavingsGoal? existing;
  final String? template;

  @override
  ConsumerState<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends ConsumerState<GoalFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final SavingsGoal? _original = widget.existing;
  late String _icon = _original?.icon ?? widget.template ?? '';
  late String? _color = _original?.color;
  late String _currency = _original?.currency ?? widget.workspace.defaultCurrency;
  late final _name = TextEditingController(text: _original?.name ?? '');
  late final _target = TextEditingController(
    text: _original == null ? '' : Money.toInput(_original.targetMinor, _original.currency),
  );
  late String? _targetOn = _original?.targetOn;

  /// The user typed the name themselves: picking a template leaves it alone.
  late bool _named = _original != null;
  bool _seeded = false;
  int _refused = 0;

  @override
  void initState() {
    super.initState();
    _target.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A template picked on the way in names the goal, until the user types a name of their own
    if (!_seeded && !_named && (widget.template ?? '').isNotEmpty) {
      _name.text = goalTemplateOf(widget.template!).label(context);
    }
    _seeded = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  void _pickTemplate(GoalTemplate template) {
    setState(() {
      // A name that was only the template's follows the new template
      if (!_named) _name.text = template.key.isEmpty ? '' : template.label(context);
      _icon = template.key;
      _color = null;
    });
  }

  Future<void> _save() => guarded(context, () async {
        if (!_formKey.currentState!.validate()) return setState(() => _refused++);
        final repo = ref.read(goalsRepositoryProvider);
        final target = Money.evaluate(_target.text, _currency)!;
        final name = _name.text.trim();
        if (_original == null) {
          final id = await repo.createGoal(widget.workspace.id,
              name: name, targetMinor: target, currency: _currency, targetOn: _targetOn, icon: _icon, color: _color);
          if (!mounted) return;
          showEventBurst(context, AppEvent.saved);
          final router = GoRouter.of(context);
          Navigator.pop(context);
          router.push('/goal/$id');
        } else {
          await repo.updateGoal(_original,
              name: name, targetMinor: target, targetOn: _targetOn, icon: _icon, color: _color);
          if (!mounted) return;
          showEventBurst(context, AppEvent.saved);
          Navigator.pop(context);
        }
      });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final editing = _original != null;
    final template = goalTemplateOf(_icon);
    final color = parseHexColor(_color) ?? template.color;
    final target = Money.evaluate(_target.text, _currency);
    final today = DateTime.now();
    final targetOn = _targetOn == null ? null : DateTime.parse(_targetOn!);
    final perMonth = target == null || targetOn == null ? null : neededPerMonth(target, today, targetOn);

    // Three months of spending, the usual advice for a first cushion
    int? cushion;
    if (_icon == 'emergency') {
      final months = ref.watch(monthlyTotalsProvider((widget.workspace.id, _currency, 6))).value ?? const <MonthTotals>[];
      final spent = months.reversed.skip(1).take(3).where((m) => m.expenseMinor > 0).toList();
      if (spent.isNotEmpty) cushion = spent.fold<int>(0, (sum, m) => sum + m.expenseMinor) ~/ spent.length * 3;
    }

    return Scaffold(
      backgroundColor: colors.sheet,
      appBar: AppBar(
        backgroundColor: colors.sheet,
        title: Text(editing ? l10n.goalEdit : l10n.goalNew),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, AppSpace.md),
            child: Shake(
              trigger: _refused,
              child: BusyButton(label: editing ? l10n.save : l10n.goalCreate, color: color, onPressed: _save),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, AppSpace.lg),
          children: [
            Text(l10n.goalWhatFor, style: text.titleSmall),
            const SizedBox(height: AppSpace.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in goalTemplates)
                  ChoiceChip(
                    avatar: Icon(option.icon, size: 18, color: option.key == _icon ? null : option.color),
                    label: Text(option.label(context)),
                    selected: option.key == _icon,
                    onSelected: (_) => _pickTemplate(option),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
              buildCounter: quietCounter,
              onChanged: (value) => setState(() => _named = value.trim().isNotEmpty),
              decoration: InputDecoration(labelText: l10n.goalName, prefixIcon: Icon(template.icon, size: 20)),
              validator: (value) => (value ?? '').trim().isEmpty ? l10n.nameRequired : null,
            ),
            const SizedBox(height: AppSpace.md),
            AmountField(controller: _target, currency: _currency, label: l10n.goalTarget, hero: true, color: color),
            if (cushion != null && cushion > 0)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ActionChip(
                  avatar: const Icon(Icons.lightbulb_rounded, size: 16),
                  label: Text(l10n.goalEmergencySuggestion(context.money(cushion, _currency))),
                  onPressed: () => _target.text = Money.toInput(cushion!, _currency),
                ),
              ),
            if (!editing) ...[
              const SizedBox(height: AppSpace.md),
              SelectField<String>(
                label: l10n.currency,
                value: _currency,
                options: currencyOptions(include: _currency),
                onChanged: (value) => setState(() => _currency = value!),
              ),
            ],
            const SizedBox(height: AppSpace.md),
            SwitchField(
              title: l10n.goalHasDate,
              subtitle: l10n.goalHasDateHint,
              value: _targetOn != null,
              onChanged: (on) => setState(() {
                _targetOn = on ? isoDate(DateTime(today.year + 1, today.month, today.day)) : null;
              }),
            ),
            if (_targetOn != null) ...[
              const SizedBox(height: AppSpace.sm),
              DateField(
                label: l10n.goalTargetDate,
                value: _targetOn!,
                first: today.add(const Duration(days: 1)),
                last: DateTime(today.year + 40),
                onChanged: (value) => setState(() => _targetOn = value),
              ),
            ],
            const SizedBox(height: AppSpace.lg),
            ColorPicker(value: _color ?? toHexColor(template.color), onChanged: (value) => setState(() => _color = value)),
            const SizedBox(height: AppSpace.xl),
            _Preview(
              name: _name.text.trim().isEmpty ? template.label(context) : _name.text.trim(),
              icon: template.icon,
              color: color,
              currency: _currency,
              targetMinor: target,
              perMonthMinor: perMonth,
            ),
          ],
        ),
      ),
    );
  }
}

/// The goal as it will look, at nothing saved yet, and what reaching it takes.
class _Preview extends StatelessWidget {
  const _Preview({
    required this.name,
    required this.icon,
    required this.color,
    required this.currency,
    required this.targetMinor,
    required this.perMonthMinor,
  });

  final String name;
  final IconData icon;
  final Color color;
  final String currency;
  final int? targetMinor;
  final int? perMonthMinor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final perMonth = perMonthMinor;
    final (perWeek, perDay) = perMonth == null ? (0, 0) : weeklyAndDaily(perMonth);

    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          GoalRing(fraction: 0, color: color, size: 64, stroke: 7, child: Icon(icon, color: color)),
          const SizedBox(width: AppSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: text.titleMedium, overflow: TextOverflow.ellipsis),
                if (targetMinor != null && targetMinor! > 0)
                  Text(context.money(targetMinor!, currency), style: text.bodySmall),
                const SizedBox(height: 4),
                Text(
                  perMonth == null
                      ? l10n.goalPreviewNoDate
                      : l10n.goalPreviewPace(context.money(perMonth, currency), context.money(perWeek, currency),
                          context.money(perDay, currency)),
                  style: text.labelMedium?.copyWith(color: perMonth == null ? colors.muted : context.goalTintOf(color)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  Color goalTintOf(Color color) => categoryTint(toHexColor(color), null);
}
