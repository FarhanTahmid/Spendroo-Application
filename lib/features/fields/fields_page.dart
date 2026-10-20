import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../cashbook/cashbook_repository.dart';
import '../plan/upgrade_sheet.dart';
import 'field_repository.dart';
import 'field_sheet.dart';
import 'field_text.dart';

/// The fields a book adds to its entries: made, changed, put in order and
/// removed here, by the people who may administer the book.
class FieldsPage extends ConsumerStatefulWidget {
  const FieldsPage({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<FieldsPage> createState() => _FieldsPageState();
}

class _FieldsPageState extends ConsumerState<FieldsPage> {
  /// The order as dragged, shown at once while the change is written.
  List<EntryField>? _dragged;

  Workspace? _workspaceOf(Cashbook book) =>
      (ref.watch(workspacesProvider).value ?? const <Workspace>[]).where((w) => w.id == book.workspaceId).firstOrNull;

  Future<void> _create(
    Cashbook book,
    Workspace? workspace,
    int count, {
    String name = '',
    String kind = FieldKind.text,
  }) async {
    if (workspace != null && !await unlockFeature(context, ref, workspace, F.customFields)) return;
    if (!mounted) return;
    if (count >= FieldLimits.fields) return context.showMessage(context.l10n.fieldsFull(FieldLimits.fields));
    await showFieldSheet(context, book: book, name: name, kind: kind);
  }

  Future<void> _reorder(Cashbook book, List<EntryField> fields, int from, int to) async {
    HapticFeedback.selectionClick();
    final ordered = [...fields];
    ordered.insert(to > from ? to - 1 : to, ordered.removeAt(from));
    setState(() => _dragged = ordered);
    await guarded(context, () => ref.read(fieldRepositoryProvider).reorder(book, ordered));
    if (mounted) setState(() => _dragged = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final book = ref.watch(cashbookProvider(widget.bookId)).value?.book;
    if (book == null) return Scaffold(appBar: AppBar(title: Text(l10n.fieldsTitle)));
    final workspace = _workspaceOf(book);
    // Read so the page follows a plan change while it is open
    ref.watch(entitlementsProvider);
    final locked = workspace != null && featureLocked(ref, workspace, F.customFields);
    final value = ref.watch(entryFieldsProvider(widget.bookId));
    final count = value.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fieldsTitle)),
      body: AsyncView(
        value: value,
        builder: (stored) {
          final fields = _dragged ?? stored;
          return EntranceScope(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (locked) ...[
                          Entrance(
                            child: _LockedCard(onUnlock: () => unlockFeature(context, ref, workspace, F.customFields)),
                          ),
                          const SizedBox(height: AppSpace.lg),
                        ],
                        if (fields.isNotEmpty)
                          Entrance(
                            index: 1,
                            child: _Header(count: fields.length, locked: locked),
                          ),
                      ],
                    ),
                  ),
                ),
                if (fields.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _Empty(
                      locked: locked,
                      onPick: (name, kind) => _create(book, workspace, 0, name: name, kind: kind),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.md, AppSpace.page, 112),
                    sliver: SliverReorderableList(
                      itemCount: fields.length,
                      // onReorderItem is not in the Flutter CI builds with (3.32)
                      // ignore: deprecated_member_use
                      onReorder: (from, to) => _reorder(book, fields, from, to),
                      proxyDecorator: (child, index, animation) => AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) => Transform.scale(
                          scale: 1 + 0.03 * Curves.easeOut.transform(animation.value),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 10 * animation.value,
                            shadowColor: context.colors.shadow,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            child: child,
                          ),
                        ),
                        child: child,
                      ),
                      itemBuilder: (context, index) {
                        final field = fields[index];
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(field.id),
                          index: index,
                          enabled: !locked,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpace.sm),
                            child: Entrance(
                              index: index + 2,
                              child: _FieldCard(
                                field: field,
                                index: index,
                                locked: locked,
                                onTap: () => showFieldSheet(context, book: book, field: field, locked: locked),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: count == 0 && !locked
          ? null
          : FloatingActionButton.extended(
              icon: Icon(locked ? Icons.lock_outline_rounded : Icons.add_rounded),
              label: Text(l10n.fieldNew),
              onPressed: () => _create(book, workspace, count),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.locked});

  final int count;

  /// Nothing can be moved while the plan keeps the fields as they are.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.fieldsIntro, style: text.bodyMedium?.copyWith(color: context.colors.muted)),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: count / FieldLimits.fields),
                  duration: context.motion(AppMotion.count),
                  curve: AppMotion.ease,
                  builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 6),
                ),
              ),
            ),
            const SizedBox(width: AppSpace.md),
            PopSwitcher(
              child: Text(
                l10n.fieldsCount(count, FieldLimits.fields),
                key: ValueKey(count),
                style: text.labelMedium?.copyWith(color: context.colors.muted),
              ),
            ),
          ],
        ),
        if (!locked) ...[
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              Icon(Icons.drag_indicator_rounded, size: 16, color: context.colors.muted),
              const SizedBox(width: 4),
              Expanded(child: Text(l10n.fieldsReorderHint, style: text.bodySmall)),
            ],
          ),
        ],
      ],
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.field, required this.index, required this.locked, required this.onTap});

  final EntryField field;
  final int index;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final tint = kindTint(context, field.kind);
    final options = optionsOf(field);
    final detail = field.kind == FieldKind.choice && options.isNotEmpty
        ? [...options.take(3), if (options.length > 3) l10n.fieldOptionsMore(options.length - 3)].join(' · ')
        : kindLabel(context, field.kind);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.md, 4, AppSpace.md),
          child: Row(
            children: [
              IconBadge(kindIcon(field.kind), color: tint, size: 40),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(field.name, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(detail, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (field.isRequired || field.showInList) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          if (field.isRequired)
                            _Tag(icon: Icons.emergency_outlined, label: l10n.fieldRequired, color: tint),
                          if (field.showInList)
                            PopSwitcher(
                              child: _Tag(
                                key: const ValueKey('pinned'),
                                icon: Icons.push_pin_rounded,
                                label: l10n.fieldPinned,
                                color: context.colors.gold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (locked)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.lock_outline_rounded, size: 18, color: context.colors.muted),
                )
              else
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.drag_handle_rounded, color: context.colors.muted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({super.key, required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

/// No fields yet: what they are for, and three to start from with a tap.
class _Empty extends StatelessWidget {
  const _Empty({required this.locked, required this.onPick});

  final bool locked;
  final void Function(String name, String kind) onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final suggestions = [
      (l10n.fieldsExampleInvoice, FieldKind.text),
      (l10n.fieldsExampleParty, FieldKind.text),
      (l10n.fieldsExampleDue, FieldKind.date),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.xl, AppSpace.page, 112),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Entrance(child: _Stack()),
          const SizedBox(height: AppSpace.xl),
          Entrance(
            index: 1,
            child: Text(l10n.fieldsEmptyTitle, style: text.titleLarge, textAlign: TextAlign.center),
          ),
          const SizedBox(height: AppSpace.sm),
          Entrance(
            index: 2,
            child: Text(
              l10n.fieldsEmptyBody,
              style: text.bodyMedium?.copyWith(color: context.colors.muted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          Entrance(
            index: 3,
            child: Text(
              l10n.fieldsTryOne.toUpperCase(),
              style: text.labelSmall?.copyWith(
                color: context.colors.muted,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final (index, (name, kind)) in suggestions.indexed)
                Entrance(
                  index: 4 + index,
                  child: ActionChip(
                    side: BorderSide(color: kindTint(context, kind).withValues(alpha: 0.4)),
                    backgroundColor: kindTint(context, kind).withValues(alpha: 0.08),
                    shape: const StadiumBorder(),
                    avatar: Icon(kindIcon(kind), size: 18, color: kindTint(context, kind)),
                    label: Text(name),
                    onPressed: () => onPick(name, kind),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          Entrance(
            index: 7,
            child: FilledButton.icon(
              onPressed: () => onPick('', FieldKind.text),
              icon: Icon(locked ? Icons.lock_outline_rounded : Icons.add_rounded),
              label: Text(l10n.fieldNew),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three ghost fields fanned out, the top one filled in: what a field adds to an entry.
class _Stack extends StatelessWidget {
  const _Stack();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget ghost(String name, String kind, String value, double angle, double dx, double opacity) =>
        Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.rotate(
            angle: angle,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 220,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  border: Border.all(color: context.colors.hairline),
                  boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    Icon(kindIcon(kind), size: 18, color: kindTint(context, kind)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(name, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                    ),
                    Text(value, style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
            ),
          ),
        );
    // A short run of fields as they would sit on an entry, a little askew, the first filled in
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ghost(l10n.fieldsExampleInvoice, FieldKind.text, '#1042', -0.025, -14, 1),
        const SizedBox(height: 10),
        ghost(l10n.fieldsExampleParty, FieldKind.text, 'Rahim', 0.02, 16, 0.75),
        const SizedBox(height: 10),
        ghost(l10n.fieldsExampleDue, FieldKind.date, '', -0.015, -4, 0.5),
      ],
    );
  }
}

/// What a downgrade left: the fields stay, changing them needs Business again.
class _LockedCard extends StatelessWidget {
  const _LockedCard({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final gold = context.colors.gold;
    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gold.withValues(alpha: 0.18), gold.withValues(alpha: 0.05)],
        ),
        border: Border.all(color: gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(Icons.workspace_premium_rounded, color: gold, size: 36),
              const SizedBox(width: AppSpace.md),
              Expanded(child: Text(l10n.fieldsLockedTitle, style: text.titleMedium)),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Text(l10n.fieldsLockedBody, style: text.bodyMedium),
          const SizedBox(height: AppSpace.md),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: context.colors.onGold),
            onPressed: onUnlock,
            child: Text(l10n.planSeePlans),
          ),
        ],
      ),
    );
  }
}
