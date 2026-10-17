import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui.dart';
import '../personal/personal_pages.dart';
import 'home_widget_providers.dart';
import 'widget_launch.dart';

/// The add form as a screen of its own (/add?kind=income), so a home-screen
/// widget button can open it straight away. It always writes to the personal
/// workspace, which is what the widget shows.
class QuickAddPage extends ConsumerWidget {
  const QuickAddPage({super.key, this.kind});

  /// 'expense', 'income' or 'transfer'; anything else opens on expense.
  final String? kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(widgetWorkspaceProvider);
    if (workspace == null) return Scaffold(appBar: AppBar(), body: const Center(child: AppLoader()));
    return TransactionFormPage(workspace: workspace, initialKind: widgetAddKinds.contains(kind) ? kind : null);
  }
}
