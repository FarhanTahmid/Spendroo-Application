import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import 'field_repository.dart';
import 'field_text.dart';

/// At most this many options show as chips; more open a searchable list.
const _chipLimit = 5;

/// The values as they are saved: numbers in the server's plain form. Values
/// of fields no longer in [fields] are kept as they were.
Map<String, String> valuesToSave(List<EntryField> fields, Map<String, String> typed) {
  final kinds = {for (final field in fields) field.id: field.kind};
  return cleanValues({
    for (final MapEntry(:key, :value) in typed.entries)
      key: kinds[key] == FieldKind.number ? (canonicalNumber(value) ?? value) : value,
  });
}

/// The book's own fields in the entry form, each with the input its kind
/// needs. Every input is a form field, so the form's validate() covers them.
class EntryFieldsSection extends StatefulWidget {
  const EntryFieldsSection({
    super.key,
    required this.fields,
    required this.values,
    required this.onChanged,
    required this.mustFill,
    this.readOnly = false,
  });

  final List<EntryField> fields;
  final Map<String, String> values;
  final void Function(String fieldId, String? value) onChanged;

  /// Whether the form may not be saved without this field.
  final bool Function(EntryField field) mustFill;

  /// The plan keeps the values as they are: shown, not changed.
  final bool readOnly;

  @override
  State<EntryFieldsSection> createState() => _EntryFieldsSectionState();
}

class _EntryFieldsSectionState extends State<EntryFieldsSection> {
  final _controllers = <String, TextEditingController>{};

  TextEditingController _controller(EntryField field) =>
      _controllers.putIfAbsent(field.id, () => TextEditingController(text: _initialText(field)));

  String _initialText(EntryField field) {
    final value = widget.values[field.id] ?? '';
    return field.kind == FieldKind.number && value.isNotEmpty ? fieldDisplay(context, field.kind, value) : value;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    if (widget.fields.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.dashboard_customize_outlined, size: 16, color: context.colors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.fieldsDetails.toUpperCase(),
                style: text.labelSmall?.copyWith(color: context.colors.muted, letterSpacing: 0.8, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        if (widget.readOnly) ...[
          _ReadOnlyNote(message: l10n.fieldsReadOnly),
          const SizedBox(height: AppSpace.sm),
          FieldValueLines(fields: widget.fields, values: widget.values, showEmpty: true),
        ] else
          for (final (index, field) in widget.fields.indexed) ...[
            if (index > 0) const SizedBox(height: 12),
            Entrance(index: index, child: _input(field)),
          ],
      ],
    );
  }

  Widget _input(EntryField field) {
    final mustFill = widget.mustFill(field);
    final label = mustFill ? '${field.name} *' : field.name;
    final value = widget.values[field.id];
    return switch (field.kind) {
      FieldKind.number => _NumberInput(
          label: label,
          controller: _controller(field),
          mustFill: mustFill,
          onChanged: (typed) => widget.onChanged(field.id, typed),
        ),
      FieldKind.date => _DateInput(
          label: label,
          value: value,
          mustFill: mustFill,
          onChanged: (picked) => widget.onChanged(field.id, picked),
        ),
      FieldKind.choice => _ChoiceInput(
          label: label,
          options: optionsOf(field),
          value: value,
          mustFill: mustFill,
          onChanged: (picked) => widget.onChanged(field.id, picked),
        ),
      _ => TextFormField(
          controller: _controller(field),
          textCapitalization: TextCapitalization.sentences,
          maxLength: FieldLimits.text,
          buildCounter: quietCounter,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[\n\r]'))],
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(kindIcon(field.kind), size: 22)),
          validator: (typed) => mustFill && (typed ?? '').trim().isEmpty ? context.l10n.fieldFillIn : null,
          onChanged: (typed) => widget.onChanged(field.id, typed),
        ),
    };
  }
}

class _NumberInput extends StatelessWidget {
  const _NumberInput({required this.label, required this.controller, required this.mustFill, required this.onChanged});

  final String label;
  final TextEditingController controller;
  final bool mustFill;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Focus(
        // Grouped once the field is left: "1250000" reads as "1,250,000"
        onFocusChange: (focused) {
          final canonical = canonicalNumber(controller.text);
          if (focused || canonical == null) return;
          controller.text = fieldDisplay(context, FieldKind.number, canonical);
        },
        child: TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(kindIcon(FieldKind.number), size: 22)),
          validator: (typed) {
            final text = (typed ?? '').trim();
            if (text.isEmpty) return mustFill ? context.l10n.fieldFillIn : null;
            return canonicalNumber(text) == null ? context.l10n.fieldNeedsNumber : null;
          },
          onChanged: onChanged,
        ),
      );
}

/// A date that may be left empty: picked from the calendar, cleared with a tap.
class _DateInput extends StatelessWidget {
  const _DateInput({required this.label, required this.value, required this.mustFill, required this.onChanged});

  final String label;
  final String? value;
  final bool mustFill;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => FormField<String>(
        initialValue: value,
        validator: (_) => mustFill && (value ?? '').isEmpty ? context.l10n.fieldFillIn : null,
        builder: (state) {
          final shown = value != null && DateTime.tryParse(value!) != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  PickerField(
                    label: label,
                    icon: kindIcon(FieldKind.date),
                    text: shown ? formatDate(context, value!) : null,
                    onOpen: () async {
                      // Otherwise the keyboard comes back for the field typed in last
                      FocusScope.of(context).unfocus();
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: shown ? DateTime.parse(value!) : now,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(now.year + 10),
                      );
                      if (picked == null) return;
                      HapticFeedback.selectionClick();
                      onChanged(picked.toIso8601String().substring(0, 10));
                      state.didChange(value);
                    },
                  ),
                  // Over the arrow, once there is a date to take away
                  AnimatedSwitcher(
                    duration: context.motion(AppMotion.fast),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: shown
                        ? Padding(
                            padding: const EdgeInsets.only(right: 36),
                            child: IconButton(
                              key: const ValueKey('clear'),
                              tooltip: context.l10n.fieldClear,
                              icon: Icon(Icons.close_rounded, size: 18, color: context.colors.muted),
                              onPressed: () => onChanged(null),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              _ErrorLine(text: state.errorText),
            ],
          );
        },
      );
}

/// A few options as chips to tap; many as a list to search.
class _ChoiceInput extends StatelessWidget {
  const _ChoiceInput({
    required this.label,
    required this.options,
    required this.value,
    required this.mustFill,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String? value;
  final bool mustFill;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // A value whose option was removed since is still shown, so it is not lost by accident
    final all = [...options, if (value != null && !options.contains(value)) value!];
    return FormField<String>(
      initialValue: value,
      validator: (_) => mustFill && (value ?? '').isEmpty ? context.l10n.fieldFillIn : null,
      builder: (state) {
        final Widget input;
        if (all.length <= _chipLimit) {
          input = _ChipChoice(label: label, options: all, value: value, onChanged: onChanged);
        } else {
          input = PickerField(
            label: label,
            icon: kindIcon(FieldKind.choice),
            text: value,
            onOpen: () async {
              FocusScope.of(context).unfocus();
              final picked = await showSelectSheet<String>(
                context,
                title: label,
                value: value,
                noneLabel: context.l10n.none,
                options: [for (final option in all) SelectOption(option, option)],
              );
              if (picked == null) return;
              HapticFeedback.selectionClick();
              onChanged(picked.value);
            },
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [input, _ErrorLine(text: state.errorText)],
        );
      },
    );
  }
}

class _ChipChoice extends StatelessWidget {
  const _ChipChoice({required this.label, required this.options, required this.value, required this.onChanged});

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    return InputDecorator(
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(kindIcon(FieldKind.choice), size: 22)),
      isEmpty: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              _Chip(
                label: option,
                selected: option == value,
                tint: scheme.primary,
                background: colors.sheet,
                // A second tap takes the choice back
                onTap: () {
                  FocusScope.of(context).unfocus();
                  HapticFeedback.selectionClick();
                  onChanged(option == value ? null : option);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// A pill that fills with colour and gains a tick when chosen.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.tint,
    required this.background,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color tint;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(AppMotion.standard);
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.ease,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? tint : background,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: selected ? tint : context.colors.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: duration,
                curve: AppMotion.spring,
                child: selected
                    ? const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      )
                    : const SizedBox.shrink(),
              ),
              AnimatedDefaultTextStyle(
                duration: duration,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) => AnimatedSize(
        duration: context.motion(AppMotion.fast),
        alignment: Alignment.topLeft,
        child: text == null
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Text(
                  text!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
      );
}

class _ReadOnlyNote extends StatelessWidget {
  const _ReadOnlyNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: context.colors.gold),
          const SizedBox(width: 6),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodySmall)),
        ],
      );
}

/// The values an entry holds, one line each with its field's name, in the
/// book's order. Fields without a value are left out unless [showEmpty].
class FieldValueLines extends StatelessWidget {
  const FieldValueLines({super.key, required this.fields, required this.values, this.showEmpty = false});

  final List<EntryField> fields;
  final Map<String, String> values;
  final bool showEmpty;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final shown = [for (final field in fields) if (showEmpty || values.containsKey(field.id)) field];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final field in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(kindIcon(field.kind), size: 18, color: kindTint(context, field.kind)),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '${field.name}  ', style: text.bodyMedium?.copyWith(color: context.colors.muted)),
                      TextSpan(
                        text: values[field.id] == null ? '—' : fieldDisplay(context, field.kind, values[field.id]!),
                        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// On a new entry in a book without fields: a quiet card that tells whoever
/// runs the business that fields exist. Closed once, it stays closed.
class FieldsHintCard extends ConsumerStatefulWidget {
  const FieldsHintCard({super.key, required this.book, required this.workspace});

  final Cashbook book;
  final Workspace workspace;

  static const setting = 'hint.custom_fields';

  @override
  ConsumerState<FieldsHintCard> createState() => _FieldsHintCardState();
}

class _FieldsHintCardState extends ConsumerState<FieldsHintCard> {
  late final Future<String?> _dismissed = ref.read(databaseProvider).getSetting(FieldsHintCard.setting);
  bool _closed = false;

  bool get _applies =>
      widget.workspace.kind == 'business' &&
      !widget.workspace.isDemo &&
      (widget.workspace.role == 'owner' || widget.workspace.role == 'admin');

  void _close() {
    setState(() => _closed = true);
    ref.read(databaseProvider).setSetting(FieldsHintCard.setting, '1');
  }

  @override
  Widget build(BuildContext context) {
    if (!_applies) return const SizedBox(width: double.infinity);
    return FutureBuilder<String?>(
      future: _dismissed,
      builder: (context, snapshot) {
        final show = snapshot.connectionState == ConnectionState.done && snapshot.data == null && !_closed;
        return AnimatedSwitcher(
          duration: context.motion(AppMotion.standard),
          child: !show ? const SizedBox(width: double.infinity) : _card(context),
        );
      },
    );
  }

  Widget _card(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final tint = kindTint(context, FieldKind.choice);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.xl),
      child: Entrance(
        child: Material(
          color: tint.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: () => context.push('/cashbook/${widget.book.id}/fields'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.md, 4, AppSpace.md),
              child: Row(
                children: [
                  IconBadge(Icons.dashboard_customize_outlined, color: tint, size: 40),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.fieldsHintTitle, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(l10n.fieldsHintBody, style: text.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    icon: Icon(Icons.close_rounded, size: 18, color: context.colors.muted),
                    onPressed: _close,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
