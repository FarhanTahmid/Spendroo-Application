import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/ui.dart';
import '../plan/upgrade_sheet.dart';
import 'tag_repository.dart';

/// The current workspace's tags: add, rename, recolour, delete. Only the
/// people who run the workspace come here; others make tags from a form.
class TagsPage extends ConsumerWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final workspace = ref.watch(currentWorkspaceProvider);
    if (workspace == null) return Scaffold(appBar: AppBar(title: Text(l10n.tags)));
    final repo = ref.read(tagRepositoryProvider);

    Future<({String name, String? color})?> edit({required String title, String name = '', String? color}) =>
        showCategorySheet(context,
            title: title, initialName: name, initialColor: color, nameLabel: l10n.tagName, maxLength: maxTagName);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tags)),
      body: AsyncView(
        value: ref.watch(tagsProvider(workspace.id)),
        builder: (tags) => tags.isEmpty
            ? EmptyState(icon: Icons.local_offer_outlined, message: l10n.noTags)
            : ListView(
                padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, 96),
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (final (index, tag) in tags.indexed) ...[
                          if (index > 0) const Divider(indent: 68),
                          ListTile(
                            leading: IconBadge(Icons.local_offer_outlined,
                                color: context.categoryTint(tag.color, tag.id), size: 36),
                            title: Text(tag.name),
                            onTap: () async {
                              final edited = await edit(title: l10n.editTag, name: tag.name, color: tag.color);
                              if (edited != null && context.mounted) {
                                await guarded(
                                    context, () => repo.updateTag(tag, name: edited.name, color: edited.color));
                              }
                            },
                            trailing: IconButton(
                              tooltip: l10n.delete,
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () async {
                                final count = await repo.useCount(tag.id);
                                if (!context.mounted) return;
                                if (await confirm(context, l10n.deleteTagConfirm(tag.name, count))) {
                                  await repo.deleteTag(tag);
                                  if (context.mounted) showEventBurst(context, AppEvent.deleted);
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newTag),
        onPressed: () async {
          final edited = await edit(title: l10n.newTag);
          if (edited == null || !context.mounted) return;
          final added = await guarded(context, () => repo.addTag(workspace.id, edited.name, color: edited.color));
          if (added && context.mounted) showEventBurst(context, AppEvent.saved);
        },
      ),
    );
  }
}
