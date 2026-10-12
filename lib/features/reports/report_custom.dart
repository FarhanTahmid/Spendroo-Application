import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/ui.dart';
import '../../l10n/app_localizations.dart';
import '../personal/ledger_repository.dart' show isoDate;
import 'report_repository.dart';

/// What a custom report is made of: its dates, and optionally only some kinds
/// of line and some categories. Nothing chosen for either means all of them.
class ReportCustom {
  const ReportCustom({
    required this.range,
    this.types = const {},
    this.categories = const [],
    this.uncategorised = false,
  });

  final DateTimeRange range;

  /// As the server names them: income, expense, transfer; or cash_in, cash_out.
  final Set<String> types;
  final List<ReportCategoryOption> categories;

  /// Lines filed under no category, alongside [categories].
  final bool uncategorised;

  String get from => isoDate(range.start);
  String get to => isoDate(range.end);
  List<String> get categoryIds => [for (final category in categories) ...category.ids];
  bool get hasCategories => categories.isNotEmpty || uncategorised;
}

/// A category the report can be narrowed to. A business has one "Sales" in
/// each cashbook: there it is offered once and stands for all of them.
class ReportCategoryOption {
  const ReportCategoryOption({required this.label, required this.ids, this.kind});

  final String label;
  final List<String> ids;

  /// 'income' or 'expense' for a personal category; null in a cashbook.
  final String? kind;

  String get key => ids.first;
}

/// The kinds of line a report of [scope] has, in the order they are offered.
List<String> reportTypes(ReportScope scope) => switch (scope) {
  ReportScope.personal || ReportScope.account => const ['income', 'expense', 'transfer'],
  ReportScope.cashbook || ReportScope.business => const ['cash_in', 'cash_out'],
};

String reportTypeLabel(AppLocalizations l10n, String type) => switch (type) {
  'income' => l10n.income,
  'expense' => l10n.expense,
  'transfer' => l10n.transfer,
  'cash_in' => l10n.cashIn,
  _ => l10n.cashOut,
};

/// (what the report is about, its workspace, the account or cashbook if any)
typedef ReportSubject = (ReportScope scope, String workspaceId, String? subjectId);

/// The categories a report of this subject can be narrowed to, by name.
final reportCategoriesProvider = StreamProvider.autoDispose.family<List<ReportCategoryOption>, ReportSubject>((
  ref,
  subject,
) {
  final db = ref.watch(databaseProvider);
  final (scope, workspaceId, subjectId) = subject;
  if (scope == ReportScope.personal || scope == ReportScope.account) {
    final query = db.select(db.categories)
      ..where((c) => c.workspaceId.equals(workspaceId) & c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows) ReportCategoryOption(label: row.name, ids: [row.id], kind: row.kind),
      ],
    );
  }
  final query = db.select(db.entryCategories)
    ..where(
      (c) =>
          (scope == ReportScope.cashbook ? c.cashbookId.equals(subjectId!) : c.workspaceId.equals(workspaceId)) &
          c.deletedAt.isNull(),
    )
    ..orderBy([(c) => OrderingTerm.asc(c.categoryName)]);
  return query.watch().map((rows) {
    final byName = <String, List<String>>{};
    for (final row in rows) {
      byName.putIfAbsent(row.categoryName, () => []).add(row.id);
    }
    return [for (final MapEntry(:key, :value) in byName.entries) ReportCategoryOption(label: key, ids: value)];
  });
});

/// Asks what a custom report should hold. Null when the sheet is closed without applying.
Future<ReportCustom?> showReportCustomSheet(
  BuildContext context, {
  required ReportSubject subject,
  ReportCustom? initial,
}) => showAppSheet<ReportCustom>(
  context,
  title: context.l10n.reportCustomTitle,
  builder: (_) => _CustomSheet(subject: subject, initial: initial),
);

class _CustomSheet extends ConsumerStatefulWidget {
  const _CustomSheet({required this.subject, this.initial});

  final ReportSubject subject;
  final ReportCustom? initial;

  @override
  ConsumerState<_CustomSheet> createState() => _CustomSheetState();
}

class _CustomSheetState extends ConsumerState<_CustomSheet> {
  late DateTimeRange _range = widget.initial?.range ?? _thisMonthSoFar();
  late Set<String> _types = {...?widget.initial?.types};
  late final Map<String, ReportCategoryOption> _categories = {
    for (final category in widget.initial?.categories ?? const <ReportCategoryOption>[]) category.key: category,
  };
  late bool _uncategorised = widget.initial?.uncategorised ?? false;

  static DateTimeRange _thisMonthSoFar() {
    final now = DateTime.now();
    return DateTimeRange(start: DateTime(now.year, now.month), end: DateTime(now.year, now.month, now.day));
  }

  /// A transfer has no category, and income and spending each have their own.
  bool _offered(ReportCategoryOption category) =>
      category.kind == null || _types.isEmpty || _types.contains(category.kind);

  bool get _categoriesApply => _types.length != 1 || _types.single != 'transfer';

  Future<void> _pickDates() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year, 12, 31),
      initialDateRange: _range,
    );
    if (picked != null && mounted) setState(() => _range = picked);
  }

  void _toggleType(String type) => setState(() {
    HapticFeedback.selectionClick();
    _types.contains(type) ? _types.remove(type) : _types.add(type);
    // Every kind chosen is the same as none
    if (_types.length == reportTypes(widget.subject.$1).length) _types = {};
    // Categories of a kind no longer shown could match nothing
    _categories.removeWhere((_, category) => !_offered(category));
    if (!_categoriesApply) _uncategorised = false;
  });

  void _toggleCategory(ReportCategoryOption category) => setState(() {
    HapticFeedback.selectionClick();
    _categories.containsKey(category.key) ? _categories.remove(category.key) : _categories[category.key] = category;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final categories = [
      for (final category
          in ref.watch(reportCategoriesProvider(widget.subject)).value ?? const <ReportCategoryOption>[])
        if (_offered(category)) category,
    ];
    final hint = text.bodySmall?.copyWith(color: colors.muted);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.reportCustomDates, style: text.titleSmall),
        const SizedBox(height: AppSpace.sm),
        OutlinedButton.icon(
          key: const ValueKey('report-custom-dates'),
          icon: const Icon(Icons.date_range_rounded),
          label: Text('${formatDate(context, isoDate(_range.start))} – ${formatDate(context, isoDate(_range.end))}'),
          onPressed: _pickDates,
        ),
        const SizedBox(height: AppSpace.lg),
        Text(l10n.reportCustomTypes, style: text.titleSmall),
        Text(l10n.reportCustomAllHint, style: hint),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            for (final type in reportTypes(widget.subject.$1))
              FilterChip(
                key: ValueKey('report-type-$type'),
                label: Text(reportTypeLabel(l10n, type)),
                selected: _types.contains(type),
                onSelected: (_) => _toggleType(type),
              ),
          ],
        ),
        if (_categoriesApply) ...[
          const SizedBox(height: AppSpace.lg),
          Text(l10n.categories, style: text.titleSmall),
          Text(l10n.reportCustomAllHint, style: hint),
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final category in categories)
                FilterChip(
                  label: Text(category.label),
                  selected: _categories.containsKey(category.key),
                  onSelected: (_) => _toggleCategory(category),
                ),
              FilterChip(
                label: Text(l10n.uncategorised),
                selected: _uncategorised,
                onSelected: (_) => setState(() => _uncategorised = !_uncategorised),
              ),
            ],
          ),
        ],
        if (_types.isNotEmpty || _categories.isNotEmpty || _uncategorised)
          Container(
            margin: const EdgeInsets.only(top: AppSpace.lg),
            padding: const EdgeInsets.all(AppSpace.md),
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 20),
                const SizedBox(width: 10),
                // Said before the download, so the missing balances are no surprise
                Expanded(child: Text(l10n.reportCustomNote, style: text.bodyMedium)),
              ],
            ),
          ),
        const SizedBox(height: AppSpace.xl),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            ReportCustom(
              range: _range,
              types: _types,
              categories: _categories.values.toList(),
              uncategorised: _uncategorised,
            ),
          ),
          child: Text(l10n.applyFilters),
        ),
      ],
    );
  }
}
