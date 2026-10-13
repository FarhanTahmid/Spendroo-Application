import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../core/ui.dart';
import 'allocations.dart';

/// One part of a split while it is being typed.
class SplitDraft {
  SplitDraft({this.categoryId, String amount = ''}) : amount = TextEditingController(text: amount);

  String? categoryId;
  final TextEditingController amount;

  /// Null while the amount is not one yet.
  int? minor(String currency) => Money.evaluate(amount.text, currency);

  void dispose() => amount.dispose();
}

/// The parts typed so far, as they are saved; null when one has no amount.
List<SplitPart>? splitParts(List<SplitDraft> drafts, String currency) {
  final parts = <SplitPart>[];
  for (final draft in drafts) {
    final amount = draft.minor(currency);
    if (amount == null || amount <= 0) return null;
    parts.add(SplitPart(draft.categoryId, amount));
  }
  return parts;
}

/// Files one amount under several categories. Shows what is still to be
/// filed as the parts are typed, and offers the rest to whichever part is added next.
class SplitEditor extends StatelessWidget {
  const SplitEditor({
    super.key,
    required this.drafts,
    required this.currency,
    required this.totalMinor,
    required this.categories,
    required this.onChanged,
    required this.onRemove,
    this.onCreateCategory,
  });

  final List<SplitDraft> drafts;
  final String currency;

  /// The transaction's amount; null while it is not typed yet.
  final int? totalMinor;
  final List<SelectOption<String>> categories;

  /// The drafts changed in place: rebuild.
  final VoidCallback onChanged;

  /// Back to one category.
  final VoidCallback onRemove;
  final Future<String?> Function(String name)? onCreateCategory;

  int get _filed => drafts.fold(0, (sum, draft) => sum + (draft.minor(currency) ?? 0));

  void _add({String? categoryId}) {
    final left = (totalMinor ?? 0) - _filed;
    drafts.add(SplitDraft(categoryId: categoryId, amount: left > 0 ? Money.toInput(left, currency) : ''));
    onChanged();
  }

  /// Shares the amount out equally; the first parts take the odd units.
  void _even() {
    final total = totalMinor;
    if (total == null || drafts.isEmpty) return;
    final share = total ~/ drafts.length, odd = total % drafts.length;
    for (var i = 0; i < drafts.length; i++) {
      drafts[i].amount.text = Money.toInput(share + (i < odd ? 1 : 0), currency);
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final total = totalMinor;
    final left = total == null ? null : total - _filed;
    final status = left == null
        ? null
        : (left == 0
            ? l10n.splitDone
            : (left > 0
                ? l10n.splitLeft(context.money(left, currency))
                : l10n.splitOver(context.money(-left, currency))));
    final statusColor = left == 0 ? AppTheme.successColor : (left != null && left < 0 ? AppTheme.errorColor : null);

    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: context.colors.field,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: context.colors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.call_split_rounded, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.splitTitle, style: theme.textTheme.titleSmall)),
              TextButton(onPressed: onRemove, child: Text(l10n.splitRemove)),
            ],
          ),
          if (total != null && total > 0) ...[
            LimitBar(value: _filed / total, height: 6),
            const SizedBox(height: 6),
            Text(
              status!,
              key: const Key('split-status'),
              style: theme.textTheme.bodySmall?.copyWith(color: statusColor ?? context.colors.muted),
            ),
          ],
          const SizedBox(height: 12),
          for (final (index, draft) in drafts.indexed) ...[
            Row(
              key: ObjectKey(draft),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SelectField<String>(
                    label: l10n.category,
                    value: draft.categoryId,
                    noneLabel: l10n.uncategorised,
                    options: categories,
                    createLabel: l10n.newCategory,
                    onCreate: onCreateCategory,
                    onChanged: (value) {
                      draft.categoryId = value;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: AmountField(
                    key: Key('split-amount-$index'),
                    controller: draft.amount,
                    currency: currency,
                    label: l10n.amount,
                  ),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  // A split of one part is just a category
                  onPressed: drafts.length <= minSplitParts
                      ? null
                      : () {
                          drafts.removeAt(index).dispose();
                          onChanged();
                        },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (drafts.length < maxSplitParts)
                ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.splitAddPart),
                  onPressed: _add,
                ),
              if (total != null && total > 0)
                ActionChip(
                  avatar: const Icon(Icons.balance_rounded, size: 18),
                  label: Text(l10n.splitEvenly),
                  onPressed: _even,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
