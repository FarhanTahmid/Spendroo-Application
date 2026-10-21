import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/ui.dart';
import '../plan/upgrade_sheet.dart';
import 'tag_ids.dart';
import 'tag_repository.dart';

/// The tags on a transaction or entry: chips to take one off, and one to add
/// another, picked from the workspace's tags or made on the spot.
class TagField extends ConsumerWidget {
  const TagField({super.key, required this.workspaceId, required this.value, required this.onChanged});

  final String workspaceId;

  /// Tag ids in the order they were put on. Ids of deleted tags are kept but not shown.
  final List<String> value;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tags = ref.watch(tagsProvider(workspaceId)).value ?? const <Tag>[];
    final byId = {for (final tag in tags) tag.id: tag};
    final shown = [for (final id in value) if (byId[id] case final tag?) tag];

    Future<void> add() async {
      FocusScope.of(context).unfocus();
      final picked = await showSelectSheet<String>(
        context,
        title: l10n.addTag,
        options: [
          for (final tag in tags)
            if (!value.contains(tag.id)) SelectOption(tag.id, tag.name, color: categoryFill(tag.color, tag.id)),
        ],
        createLabel: l10n.newTag,
        onCreate: (name) async {
          String? id;
          await guarded(context, () async {
            id = await ref.read(tagRepositoryProvider).addTag(workspaceId, name.substring(0, name.length.clamp(0, maxTagName)));
          });
          return id;
        },
      );
      final id = picked?.value;
      if (id != null && !value.contains(id)) onChanged([...value, id]);
    }

    return InputDecorator(
      decoration: InputDecoration(labelText: l10n.tags, prefixIcon: const Icon(Icons.local_offer_outlined, size: 20)),
      isEmpty: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.xs,
          children: [
            for (final tag in shown)
              InputChip(
                key: ValueKey('tag-${tag.id}'),
                label: Text(tag.name),
                avatar: Center(child: ColorDot(categoryFill(tag.color, tag.id))),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                deleteButtonTooltipMessage: l10n.removeTag(tag.name),
                onDeleted: () => onChanged([...value]..remove(tag.id)),
              ),
            if (shown.length < maxTagsPerRow)
              ActionChip(
                key: const ValueKey('add-tag'),
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.addTag),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: add,
              ),
          ],
        ),
      ),
    );
  }
}
