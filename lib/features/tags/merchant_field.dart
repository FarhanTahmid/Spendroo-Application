import 'package:flutter/material.dart';

import '../../core/ui.dart';
import 'merchants.dart';

/// A text field for who was paid, offering names used before as they are typed.
class MerchantField extends StatefulWidget {
  const MerchantField({
    super.key,
    required this.controller,
    required this.label,
    required this.known,
    this.icon = Icons.storefront_outlined,
  });

  final TextEditingController controller;
  final String label;

  /// Names used before, best first (rankMerchants).
  final List<String> known;
  final IconData icon;

  @override
  State<MerchantField> createState() => _MerchantFieldState();
}

class _MerchantFieldState extends State<MerchantField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<String>(
        textEditingController: widget.controller,
        focusNode: _focus,
        optionsBuilder: (value) => suggestMerchants(widget.known, value.text),
        fieldViewBuilder: (context, controller, focus, onSubmitted) => TextFormField(
          key: const ValueKey('merchant-field'),
          controller: controller,
          focusNode: focus,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: widget.label, prefixIcon: Icon(widget.icon, size: 20)),
          maxLength: maxMerchantLength,
          buildCounter: quietCounter,
          onFieldSubmitted: (_) => onSubmitted(),
        ),
        optionsViewBuilder: (context, onSelected, options) => Align(
          alignment: AlignmentDirectional.topStart,
          child: Material(
            elevation: 6,
            color: context.colors.sheet,
            borderRadius: BorderRadius.circular(AppRadius.control),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth, maxHeight: 240),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                children: [
                  for (final name in options)
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.history_rounded, size: 18, color: scheme.primary),
                      title: Text(name),
                      onTap: () => onSelected(name),
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
