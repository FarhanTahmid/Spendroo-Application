import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/db/local_store.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../personal/spending_breakdown.dart' show localDigits;
import '../personal/personal_pages.dart' show openTransactionForm;
import 'recurring_repository.dart';

/// What the server has to tell the user: made there, read and marked read here.
class InboxRepository {
  InboxRepository(this.db, this.store);

  final AppDatabase db;
  final LocalStore store;

  /// Newest first.
  Stream<List<InboxItem>> watchItems(String workspaceId) => (db.select(db.inboxItems)
        ..where((i) => i.workspaceId.equals(workspaceId) & i.deletedAt.isNull())
        ..orderBy([(i) => OrderingTerm.desc(i.createdAt), (i) => OrderingTerm.desc(i.id)]))
      .watch();

  Stream<int> watchUnread(String workspaceId) => db
      .customSelect(
        'SELECT COUNT(*) AS n FROM inbox_items WHERE workspace_id = ? AND deleted_at IS NULL AND read_at IS NULL',
        variables: [Variable<String>(workspaceId)],
        readsFrom: {db.inboxItems},
      )
      .watchSingle()
      .map((row) => row.read<int>('n'));

  Future<void> markAllRead(String workspaceId) async {
    final unread = await (db.select(db.inboxItems)
          ..where((i) => i.workspaceId.equals(workspaceId) & i.deletedAt.isNull() & i.readAt.isNull()))
        .get();
    final now = nowIso();
    for (final item in unread) {
      await store.update('inbox_items', item.id, {'read_at': now});
    }
  }
}

final inboxRepositoryProvider =
    Provider<InboxRepository>((ref) => InboxRepository(ref.watch(databaseProvider), ref.watch(localStoreProvider)));

final inboxProvider = StreamProvider.family<List<InboxItem>, String>(
  (ref, workspaceId) => ref.watch(inboxRepositoryProvider).watchItems(workspaceId),
);

final unreadInboxProvider = StreamProvider.family<int, String>(
  (ref, workspaceId) => ref.watch(inboxRepositoryProvider).watchUnread(workspaceId),
);

Map<String, dynamic> inboxParams(InboxItem item) {
  try {
    return (jsonDecode(item.params) as Map).cast<String, dynamic>();
  } on Object {
    return const {};
  }
}

IconData inboxIcon(String type) => switch (type) {
      'posted' => Icons.check_circle_outline_rounded,
      'income_expected' => Icons.south_west_rounded,
      'rule_blocked' => Icons.error_outline_rounded,
      'budget_80' => Icons.data_usage_rounded,
      'budget_over' => Icons.warning_amber_rounded,
      'goal_milestone' => Icons.stars_rounded,
      'goal_reached' => Icons.emoji_events_rounded,
      'goal_behind' => Icons.trending_down_rounded,
      'goal_idle' => Icons.savings_outlined,
      'overdue' => Icons.hourglass_bottom_rounded,
      _ => Icons.notifications_none_rounded,
    };

/// One sentence for an item, in the user's language, from what the server sent.
/// A push notification from the server says the same (notifications/words.py there).
String inboxTitle(BuildContext context, InboxItem item) {
  final l10n = context.l10n;
  final params = inboxParams(item);
  final named = (params['title'] as String?) ?? '';
  final title = named.isEmpty ? l10n.untitledRule : named;
  final days = (params['days'] as int?) ?? 0;
  final count = localDigits(context, '$days');
  return switch (item.type) {
    'upcoming' => days <= 1 ? l10n.inboxUpcomingTomorrow(title) : l10n.inboxUpcoming(title, count),
    'income_expected' => params.containsKey('days')
        ? (days <= 1 ? l10n.inboxIncomeTomorrow(title) : l10n.inboxIncomeComing(title, count))
        : l10n.inboxIncomeDue(title),
    'due' => l10n.inboxDue(title),
    'overdue' => l10n.inboxOverdue(title),
    'posted' => l10n.inboxPosted(title),
    'rule_blocked' => l10n.inboxBlocked(title),
    'budget_80' =>
      l10n.inboxBudget80((params['category'] as String?) ?? '', localDigits(context, '${params['percent'] ?? 80}')),
    'budget_over' => l10n.inboxBudgetOver((params['category'] as String?) ?? ''),
    'goal_milestone' => l10n.inboxGoalMilestone(localDigits(context, '${params['mark'] ?? params['percent'] ?? 0}'), title),
    'goal_reached' => l10n.inboxGoalReached(title),
    'goal_behind' => l10n.inboxGoalBehind(title),
    'goal_idle' => l10n.inboxGoalIdle(title, count),
    // A reminder says what the user wrote, and anything newer than this version says its title
    _ => title,
  };
}

/// The quieter second line: the amount, and when.
String inboxDetail(BuildContext context, InboxItem item) {
  final params = inboxParams(item);
  final currency = (params['currency'] as String?) ?? '';
  final amount = params['amount_minor'] as int?;
  final when = formatDate(context, item.createdAt.substring(0, 10));
  if (item.type.startsWith('goal_') && amount != null) {
    final needed = params['needed_minor'] as int?;
    if (item.type == 'goal_behind' && needed != null) {
      return '${context.l10n.inboxGoalNeeded(context.money(needed, currency))} · $when';
    }
    final saved = (params['saved_minor'] as int?) ?? 0;
    return '${context.l10n.inboxGoalDetail(context.money(saved, currency), context.money(amount, currency))} · $when';
  }
  if (item.type.startsWith('budget_') && amount != null) {
    final spent = (params['spent_minor'] as int?) ?? 0;
    return '${context.l10n.inboxBudgetDetail(context.money(spent, currency), context.money(amount, currency))} · $when';
  }
  return [if (amount != null && currency.isNotEmpty) context.money(amount, currency), when].join(' · ');
}

/// A bell for the header, with how many items have not been seen.
class InboxBell extends ConsumerWidget {
  const InboxBell({super.key, required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadInboxProvider(workspace.id)).value ?? 0;
    final colors = context.colors;
    return IconButton(
      tooltip: context.l10n.inbox,
      icon: Badge(
        isLabelVisible: unread > 0,
        backgroundColor: colors.gold,
        textColor: colors.onGold,
        label: Text(localDigits(context, '$unread')),
        child: Icon(unread > 0 ? Icons.notifications_active_outlined : Icons.notifications_none_rounded),
      ),
      onPressed: () => context.push('/inbox'),
    );
  }
}

/// Everything the server has said, newest first. What still waits for an
/// answer carries its buttons; opening the screen marks the rest as seen.
class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  // What was unread when the screen opened stays highlighted while it is looked at
  Set<String>? _fresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workspace = ref.watch(currentWorkspaceProvider);
    if (workspace == null) return Scaffold(appBar: AppBar(title: Text(l10n.inbox)));
    final open = {
      for (final occurrence in ref.watch(openOccurrencesProvider(workspace.id)).value ?? const <OccurrenceView>[])
        occurrence.occurrence.id: occurrence,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inbox),
        actions: [
          IconButton(
            tooltip: l10n.recurring,
            icon: const Icon(Icons.event_repeat_rounded),
            onPressed: () => context.push('/recurring'),
          ),
        ],
      ),
      body: AsyncView(
        value: ref.watch(inboxProvider(workspace.id)),
        builder: (items) {
          if (items.isEmpty) return EmptyState(icon: Icons.notifications_none_rounded, message: l10n.inboxEmpty);
          if (_fresh == null) {
            _fresh = {for (final item in items) if (item.readAt == null) item.id};
            if (_fresh!.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => ref.read(inboxRepositoryProvider).markAllRead(workspace.id));
            }
          }
          final today = todayIso();
          final groups = {
            l10n.today: [for (final item in items) if (item.createdAt.substring(0, 10) == today) item],
            l10n.inboxEarlier: [for (final item in items) if (item.createdAt.substring(0, 10) != today) item],
          };
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.xl),
            children: [
              for (final MapEntry(key: heading, value: group) in groups.entries)
                if (group.isNotEmpty)
                  SectionCard(
                    title: heading,
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                    children: [
                      for (final item in group)
                        _InboxTile(
                          item: item,
                          fresh: _fresh!.contains(item.id),
                          // Still unanswered: the same buttons as on the recurring screen
                          occurrence: item.resolvedAt == null ? open[item.subjectId] : null,
                          workspace: workspace,
                        ),
                    ],
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _InboxTile extends StatelessWidget {
  const _InboxTile({required this.item, required this.fresh, required this.occurrence, required this.workspace});

  final InboxItem item;
  final bool fresh;
  final OccurrenceView? occurrence;
  final Workspace workspace;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final waiting = occurrence;
    final problem = item.type == 'budget_over' || item.type == 'rule_blocked' || item.type == 'goal_behind';
    final goalId = item.subjectTable == 'savings_goals' ? item.subjectId : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          // News about a goal opens the goal
          onTap: goalId == null ? null : () => context.push('/goal/$goalId'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.page, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(inboxIcon(item.type), color: problem ? AppTheme.errorColor : null),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inboxTitle(context, item),
                          style: text.bodyLarge?.copyWith(fontWeight: fresh ? FontWeight.w600 : null)),
                      Text(inboxDetail(context, item), style: text.bodySmall?.copyWith(color: colors.muted)),
                    ],
                  ),
                ),
                if (fresh) Padding(padding: const EdgeInsets.only(top: 6), child: ColorDot(colors.gold)),
                if (goalId != null) Icon(Icons.chevron_right_rounded, size: 18, color: colors.muted),
              ],
            ),
          ),
        ),
        if (waiting != null) _Actions(occurrence: waiting, workspace: workspace),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.occurrence, required this.workspace});

  final OccurrenceView occurrence;
  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final repo = ref.read(recurringRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.page + 52, 0, AppSpace.page, 6),
      child: Wrap(
        spacing: 8,
        children: [
          if (occurrence.rule.isReminder)
            FilledButton.tonal(onPressed: () => repo.markDone(occurrence.occurrence), child: Text(l10n.doneIt))
          else
            FilledButton.tonal(
              onPressed: () => openTransactionForm(context, workspace, occurrence: occurrence),
              child: Text(l10n.recordIt),
            ),
          TextButton(onPressed: () => repo.skip(occurrence.occurrence), child: Text(l10n.skipIt)),
        ],
      ),
    );
  }
}
