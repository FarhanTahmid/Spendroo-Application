import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/ui.dart';
import '../plan/upgrade_sheet.dart';
import 'field_inputs.dart';
import 'field_repository.dart';
import 'field_text.dart';

/// Make a field for [book], or change [field]. [name] and [kind] start a new
/// one off (the suggestions on an empty page). With [locked] the field can
/// only be looked at and deleted: the plan no longer covers changing it.
Future<void> showFieldSheet(
  BuildContext context, {
  required Cashbook book,
  EntryField? field,
  String name = '',
  String kind = FieldKind.text,
  bool locked = false,
}) =>
    showAppSheet<void>(
      context,
      title: field == null ? context.l10n.fieldNew : context.l10n.fieldEdit,
      builder: (_) => _FieldSheet(book: book, field: field, name: name, kind: kind, locked: locked),
    );

class _FieldSheet extends ConsumerStatefulWidget {
  const _FieldSheet({required this.book, required this.field, required this.name, required this.kind, required this.locked});

  final Cashbook book;
  final EntryField? field;
  final String name;
  final String kind;
  final bool locked;

  @override
  ConsumerState<_FieldSheet> createState() => _FieldSheetState();
}

class _FieldSheetState extends ConsumerState<_FieldSheet> {
  late final _name = TextEditingController(text: widget.field?.name ?? widget.name);
  final _option = TextEditingController();
  final _optionFocus = FocusNode();
  late String _kind = widget.field?.kind ?? widget.kind;
  late final List<String> _options = widget.field == null ? [] : optionsOf(widget.field!);
  late bool _required = widget.field?.isRequired ?? false;
  late bool _showInList = widget.field?.showInList ?? false;
  String? _nameError;
  String? _optionsError;
  int _refused = 0;

  bool get _editing => widget.field != null;

  @override
  void dispose() {
    _name.dispose();
    _option.dispose();
    _optionFocus.dispose();
    super.dispose();
  }

  void _addOption() {
    final typed = _option.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    _option.clear();
    _optionFocus.requestFocus();
    if (typed.isEmpty || _options.any((o) => o.toLowerCase() == typed.toLowerCase())) return;
    if (_options.length >= FieldLimits.options) {
      setState(() => _optionsError = context.l10n.fieldOptionsFull(FieldLimits.options));
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _options.add(typed.length > FieldLimits.name ? typed.substring(0, FieldLimits.name) : typed);
      _optionsError = null;
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final repo = ref.read(fieldRepositoryProvider);
    // An option typed but not yet added counts
    if (_option.text.trim().isNotEmpty) _addOption();
    final name = _name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final nameError = name.isEmpty
        ? l10n.fieldNameNeeded
        : await repo.nameTaken(widget.book.id, name, except: widget.field?.id)
            ? l10n.fieldNameTaken
            : null;
    final optionsError = _kind == FieldKind.choice && _options.isEmpty ? l10n.fieldOptionsNeeded : null;
    if (!mounted) return;
    if (nameError != null || optionsError != null) {
      return setState(() {
        _nameError = nameError;
        _optionsError = optionsError;
        _refused++;
      });
    }
    final saved = await guarded(context, () async {
      if (_editing) {
        await repo.update(widget.book, widget.field!,
            name: name, options: _options, isRequired: _required, showInList: _showInList);
      } else {
        await repo.add(widget.book,
            name: name, kind: _kind, options: _options, isRequired: _required, showInList: _showInList);
      }
    });
    if (!saved || !mounted) return;
    showEventBurst(context, AppEvent.saved);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (!await confirm(context, context.l10n.fieldDeleteConfirm)) return;
    await ref.read(fieldRepositoryProvider).delete(widget.field!);
    if (!mounted) return;
    showEventBurst(context, AppEvent.deleted);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final enabled = !widget.locked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _name,
          enabled: enabled,
          autofocus: !_editing && widget.name.isEmpty,
          maxLength: FieldLimits.name,
          buildCounter: quietCounter,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.fieldName, errorText: _nameError),
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
            setState(() {}); // the preview follows the name
          },
        ),
        const SizedBox(height: AppSpace.md),
        _Label(l10n.fieldKind),
        const SizedBox(height: AppSpace.sm),
        _KindGrid(
          value: _kind,
          onChanged: _editing || !enabled
              ? null
              : (kind) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _kind = kind;
                    _optionsError = null;
                  });
                },
        ),
        if (_editing) ...[
          const SizedBox(height: 6),
          Text(l10n.fieldKindFixed, style: text.bodySmall),
        ],
        AnimatedSize(
          duration: context.motion(AppMotion.emphasised),
          curve: AppMotion.ease,
          alignment: Alignment.topCenter,
          child: _kind != FieldKind.choice
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpace.lg),
                  child: _OptionsEditor(
                    options: _options,
                    controller: _option,
                    focus: _optionFocus,
                    error: _optionsError,
                    enabled: enabled,
                    onAdd: _addOption,
                    onRemove: (option) => setState(() => _options.remove(option)),
                    onReorder: (from, to) => setState(() => _options.insert(to, _options.removeAt(from))),
                  ),
                ),
        ),
        const SizedBox(height: AppSpace.lg),
        SwitchField(
          title: l10n.fieldRequired,
          subtitle: l10n.fieldRequiredDetail,
          value: _required,
          onChanged: enabled ? (value) => setState(() => _required = value) : null,
        ),
        const SizedBox(height: AppSpace.sm),
        SwitchField(
          title: l10n.fieldShowInList,
          subtitle: l10n.fieldShowInListDetail,
          value: _showInList,
          onChanged: enabled ? (value) => setState(() => _showInList = value) : null,
        ),
        const SizedBox(height: AppSpace.lg),
        _Label(l10n.fieldPreview),
        const SizedBox(height: AppSpace.sm),
        _Preview(name: _name.text.trim().isEmpty ? l10n.fieldName : _name.text.trim(), kind: _kind, options: _options, isRequired: _required),
        const SizedBox(height: AppSpace.xl),
        if (enabled)
          Shake(trigger: _refused, child: BusyButton(label: l10n.save, onPressed: _save)),
        if (_editing) ...[
          const SizedBox(height: AppSpace.sm),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l10n.fieldDelete),
          ),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.muted,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
      );
}

/// The four kinds as tiles, two by two. The chosen one fills with its colour.
class _KindGrid extends StatelessWidget {
  const _KindGrid({required this.value, required this.onChanged});

  final String value;

  /// Null once the field exists: its kind is fixed.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - AppSpace.sm) / 2;
          return Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final kind in FieldKind.all)
                SizedBox(
                  width: width,
                  child: _KindTile(
                    kind: kind,
                    selected: kind == value,
                    onTap: onChanged == null ? null : () => onChanged!(kind),
                  ),
                ),
            ],
          );
        },
      );
}

class _KindTile extends StatelessWidget {
  const _KindTile({required this.kind, required this.selected, required this.onTap});

  final String kind;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tint = kindTint(context, kind);
    final text = Theme.of(context).textTheme;
    final duration = context.motion(AppMotion.standard);
    final faded = onTap == null && !selected;
    return Semantics(
      selected: selected,
      button: onTap != null,
      child: AnimatedOpacity(
        duration: duration,
        opacity: faded ? 0.4 : 1,
        child: Pressable(
          onTap: onTap,
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.ease,
            padding: const EdgeInsets.all(AppSpace.md),
            decoration: BoxDecoration(
              color: selected ? tint.withValues(alpha: 0.12) : context.colors.field,
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: selected ? tint : context.colors.hairline, width: selected ? 1.6 : 1),
            ),
            child: Row(
              children: [
                AnimatedScale(
                  scale: selected ? 1.1 : 1,
                  duration: duration,
                  curve: AppMotion.spring,
                  child: IconBadge(kindIcon(kind), color: tint, size: 34),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kindLabel(context, kind),
                          style: text.titleSmall?.copyWith(color: selected ? tint : null, fontWeight: FontWeight.w700)),
                      Text(kindHint(context, kind), style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The options of a choice field: chips that can be dragged into order or
/// taken off, and a field to type the next one.
class _OptionsEditor extends StatelessWidget {
  const _OptionsEditor({
    required this.options,
    required this.controller,
    required this.focus,
    required this.error,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
  });

  final List<String> options;
  final TextEditingController controller;
  final FocusNode focus;
  final String? error;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final void Function(int from, int to) onReorder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tint = kindTint(context, FieldKind.choice);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Label(l10n.fieldOptions),
        const SizedBox(height: AppSpace.sm),
        if (options.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (index, option) in options.indexed)
                _OptionChip(
                  key: ValueKey(option),
                  label: option,
                  tint: tint,
                  index: index,
                  onRemove: enabled ? () => onRemove(option) : null,
                  onMoveTo: enabled ? (from) => onReorder(from, index) : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
        ],
        if (enabled)
          TextField(
            controller: controller,
            focusNode: focus,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            maxLength: FieldLimits.name,
            buildCounter: quietCounter,
            decoration: InputDecoration(
              labelText: l10n.fieldOptionAdd,
              errorText: error,
              suffixIcon: IconButton(
                tooltip: l10n.fieldOptionAdd,
                icon: Icon(Icons.add_circle_rounded, color: tint),
                onPressed: onAdd,
              ),
            ),
            onSubmitted: (_) => onAdd(),
          ),
      ],
    );
  }
}

/// One option: pops in when added; long-press and drag it onto another to move it there.
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    super.key,
    required this.label,
    required this.tint,
    required this.index,
    required this.onRemove,
    required this.onMoveTo,
  });

  final String label;
  final Color tint;
  final int index;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onMoveTo;

  Widget _chip(BuildContext context, {bool lifted = false}) => Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(12, 6, onRemove == null ? 12 : 4, 6),
          decoration: BoxDecoration(
            color: tint.withValues(alpha: lifted ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: lifted ? [BoxShadow(color: context.colors.shadow, blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: tint)),
              if (onRemove != null)
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onRemove,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, size: 16, color: tint),
                  ),
                ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final chip = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: context.motion(AppMotion.emphasised),
      curve: AppMotion.spring,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: _chip(context),
    );
    if (onMoveTo == null) return chip;
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) {
        HapticFeedback.selectionClick();
        onMoveTo!(details.data);
      },
      builder: (context, candidates, _) => LongPressDraggable<int>(
        data: index,
        hapticFeedbackOnStart: true,
        feedback: _chip(context, lifted: true),
        childWhenDragging: Opacity(opacity: 0.3, child: _chip(context)),
        child: AnimatedScale(
          scale: candidates.isEmpty ? 1 : 1.08,
          duration: context.motion(AppMotion.fast),
          child: chip,
        ),
      ),
    );
  }
}

/// The input exactly as the entry form will show it, switching as the kind does.
class _Preview extends StatelessWidget {
  const _Preview({required this.name, required this.kind, required this.options, required this.isRequired});

  final String name;
  final String kind;
  final List<String> options;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final field = EntryField(
      id: 'preview',
      workspaceId: '',
      version: 0,
      serverSeq: 0,
      createdAt: '',
      updatedAt: '',
      cashbookId: '',
      name: name,
      kind: kind,
      options: jsonEncode(options),
      isRequired: isRequired,
      showInList: false,
      position: 0,
    );
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: context.colors.paper,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.colors.hairline),
      ),
      child: AnimatedSwitcher(
        duration: context.motion(AppMotion.emphasised),
        switchInCurve: AppMotion.ease,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(animation),
            child: child,
          ),
        ),
        // Shows, never takes input
        child: IgnorePointer(
          key: ValueKey('$kind${options.length > 5}'),
          child: EntryFieldsSection(
            key: ValueKey('$kind|$name|${options.join('|')}|$isRequired'),
            fields: [field],
            values: const {},
            onChanged: (_, _) {},
            mustFill: (field) => field.isRequired,
          ),
        ),
      ),
    );
  }
}
