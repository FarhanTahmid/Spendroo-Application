import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui.dart';
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
