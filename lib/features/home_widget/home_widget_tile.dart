import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/ui.dart';
import 'business/biz_widget_controller.dart';
import 'home_widget_bridge.dart';

/// The Settings row that puts the widget on the home screen: the launcher's
/// own prompt where it has one, else a line on how to do it by hand.
/// Android only; elsewhere it takes no room.
class HomeWidgetTile extends ConsumerWidget {
  const HomeWidgetTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (defaultTargetPlatform != TargetPlatform.android) return const SizedBox.shrink();
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.widgets_outlined),
      title: Text(l10n.widgetSettingsTitle),
      subtitle: Text(l10n.widgetSettingsBody),
      trailing: Tooltip(message: l10n.widgetAddToHome, child: const Icon(Icons.add_to_home_screen_rounded)),
      onTap: () async {
        final bridge = ref.read(homeWidgetBridgeProvider);
        if (await bridge.canPin()) {
          await bridge.requestPin();
        } else if (context.mounted) {
          context.showMessage(l10n.widgetPinManual);
        }
      },
    );
  }
}

/// The Settings row for the business and cashbook widgets, once the user has a
/// business: a sheet to pick one, then the launcher's own prompt. The widget asks
/// which business or book to show as it is placed.
class BizWidgetTile extends ConsumerWidget {
  const BizWidgetTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (defaultTargetPlatform != TargetPlatform.android) return const SizedBox.shrink();
    final hasBusiness = (ref.watch(workspacesProvider).value ?? const []).any((w) => w.kind == 'business');
    if (!hasBusiness) return const SizedBox.shrink();
    final l10n = context.l10n;

    Future<void> place(BizWidgetKind kind) async {
      final bridge = ref.read(bizWidgetBridgeProvider);
      if (await bridge.canPin()) {
        await bridge.requestPin(kind);
      } else if (context.mounted) {
        context.showMessage(l10n.widgetPinManual);
      }
    }

    return ListTile(
      leading: const Icon(Icons.storefront_outlined),
      title: Text(l10n.bizWidgetSettingsTitle),
      subtitle: Text(l10n.bizWidgetSettingsBody),
      trailing: Tooltip(message: l10n.widgetAddToHome, child: const Icon(Icons.add_to_home_screen_rounded)),
      onTap: () => showAppSheet<void>(
        context,
        title: l10n.bizWidgetSettingsTitle,
        builder: (sheet) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (kind, icon, title, body) in [
              (BizWidgetKind.business, Icons.storefront_rounded, l10n.bizWidgetAddBusiness, l10n.bizWidgetAddBusinessBody),
              (BizWidgetKind.book, Icons.menu_book_rounded, l10n.bizWidgetAddBook, l10n.bizWidgetAddBookBody),
            ])
              ListTile(
                leading: IconBadge(icon),
                title: Text(title),
                subtitle: Text(body),
                trailing: const Icon(Icons.add_to_home_screen_rounded),
                onTap: () {
                  Navigator.of(sheet).pop();
                  place(kind);
                },
              ),
          ],
        ),
      ),
    );
  }
}
