import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../cashbook/cashbook_repository.dart';
import '../personal/spending_breakdown.dart' show localDigits;
import '../plan/upgrade_sheet.dart';
import '../profile/profile_repository.dart';
import '../team/team_repository.dart';
import '../team/team_roles.dart';
import '../team/team_widgets.dart';
import 'history_repository.dart';
import 'history_text.dart';
import 'history_widgets.dart';

/// Opens the edit history, narrowed to a [book], a [person] (a user id) or one [entry].
void openHistory(BuildContext context, {String? book, String? person, String? entry}) {
  HapticFeedback.selectionClick();
  context.push(Uri(path: '/history', queryParameters: {
    if (book != null) 'book': book,
    if (person != null) 'person': person,
    if (entry != null) 'entry': entry,
  }).toString());
}

/// Whether [workspace] shows the way to its edit history: only its owner
/// sees one, and never in the demo.
bool showsHistory(Workspace? workspace) =>
    workspace != null && workspace.kind == 'business' && !workspace.isDemo && workspace.role == TeamRole.owner;

/// The end of a way into the edit history: a chevron, or a lock while the
/// owner's plan has no edit history (the page then shows what it would).
class HistoryTrailing extends ConsumerWidget {
  const HistoryTrailing({super.key, required this.workspace, this.chevron = true});

  final Workspace workspace;
  final bool chevron;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entitlementsProvider);
    if (featureLocked(ref, workspace, F.auditTrail)) {
      return Icon(Icons.lock_outline_rounded, size: 20, color: context.colors.gold);
    }
    return chevron ? const Icon(Icons.chevron_right_rounded) : const SizedBox.shrink();
  }
}

/// Who changed what in the business, and when, newest first, by day. The
/// owner's alone, on a plan with the edit history; others see why not.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key, this.bookId, this.personId, this.entryId});

  final String? bookId;
  final String? personId;
  final String? entryId;

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  /// How close to the end of the list the next page is asked for.
  static const _loadAhead = 600.0;

  late HistoryFilter _filter =
      HistoryFilter(cashbookId: widget.bookId, personId: widget.personId, entryId: widget.entryId);
  final _scroll = ScrollController();
  final _open = <String>{};

  /// Rows already on screen once: only ones new to it slide in.
  final _shown = <String>{};
  var _farDown = false;

  /// The list shown while another filter's first page is on its way.
  HistoryFeed? _previous;

  bool get _entryMode => _filter.entryId != null;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  HistoryQuery? _query;

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final far = _scroll.offset > 1200;
    if (far != _farDown) setState(() => _farDown = far);
    _loadIfNearEnd();
  }

  void _loadIfNearEnd() {
    final query = _query;
    if (query == null || !_scroll.hasClients || _scroll.position.extentAfter > _loadAhead) return;
    ref.read(historyFeedProvider(query).notifier).loadMore();
  }

  void _narrow(HistoryFilter next) {
    if (next == _filter) return;
    final query = _query;
    setState(() {
      _previous = query == null ? null : ref.read(historyFeedProvider(query));
      _filter = next;
      _open.clear();
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workspace = ref.watch(currentWorkspaceProvider);
    final title = Text(_entryMode ? l10n.historyOfEntry : l10n.historyTitle);
    if (workspace == null || workspace.kind != 'business' || workspace.isDemo) {
      return Scaffold(
        appBar: AppBar(title: title),
        body: EmptyState(icon: Icons.history_rounded, message: l10n.historyBusinessOnly),
      );
    }
    if (workspace.role != TeamRole.owner) {
      return Scaffold(
        appBar: AppBar(title: title),
        body: EmptyState(icon: Icons.lock_person_outlined, message: l10n.historyOwnerOnly),
      );
    }
    final plan = ref.watch(entitlementsProvider);
    // Until the phone knows its plan it cannot tell whether to ask at all
    final planKnown = plan.hasValue || !plan.isLoading;
    final query = (workspaceId: workspace.id, filter: _filter);
    final lockedHere = featureLocked(ref, workspace, F.auditTrail);
    _query = lockedHere || !planKnown ? null : query;
    final feed = _query == null ? null : ref.watch(historyFeedProvider(query));
    final locked = lockedHere || feed?.problem == HistoryProblem.locked;
    if (feed != null) {
      // A short page may leave room for the next one without any scrolling
      ref.listen(historyFeedProvider(query), (_, next) {
        if (!next.loading) _previous = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadIfNearEnd();
        });
      });
    }
    final team = ref.watch(teamProvider(workspace.id)).value;
    final me = ref.watch(profileProvider).value?.id;
    // While another filter loads, the last list stays, faded
    final shown = feed != null && feed.loading && _previous != null ? _previous! : feed;
    final refreshing = feed != null && feed.loading && _previous != null;

    return PassbookScaffold(
      title: title,
      header: locked
          ? _LockedHeader(workspace: workspace)
          : _entryMode
              ? _EntryHeader(feed: feed)
              : _Header(
                  workspace: workspace,
                  filter: _filter,
                  team: team,
                  onChanged: _narrow,
                ),
      floatingActionButton: AnimatedScale(
        scale: _farDown && !locked ? 1 : 0,
        duration: context.motion(AppMotion.standard),
        curve: AppMotion.spring,
        child: FloatingActionButton.small(
          heroTag: 'history-top',
          tooltip: l10n.historyBackToTop,
          onPressed: () => _scroll.animateTo(0, duration: context.motion(AppMotion.count), curve: AppMotion.ease),
          child: const Icon(Icons.arrow_upward_rounded),
        ),
      ),
      body: AnimatedSwitcher(
        duration: context.motion(AppMotion.emphasised),
        child: locked
            ? LockedHistory(
                key: const ValueKey('locked'),
                onSeePlans: () => showUpgradeSheet(
                  context,
                  refusal: const PlanLimitException(F.auditTrail, reason: PlanLimitException.reasonFeature),
                ),
              )
            : shown == null || (shown.loading && shown.events.isEmpty)
                ? const Padding(
                    key: ValueKey('loading'),
                    padding: EdgeInsets.only(top: AppSpace.lg),
                    child: SkeletonList(rows: 6),
                  )
                : shown.problem != null && shown.events.isEmpty
                    ? _Problem(
                        key: ValueKey(shown.problem),
                        problem: shown.problem!,
                        onRetry: () => ref.read(historyFeedProvider(query).notifier).refresh(),
                      )
                    : shown.events.isEmpty
                        ? _Empty(
                            key: ValueKey('empty-${_filter.isNarrowed}'),
                            filter: _filter,
                            onClear: () => _narrow(_filter.cleared()),
                          )
                        : Stack(
                            key: const ValueKey('list'),
                            children: [
                              RefreshIndicator(
                                onRefresh: () => ref.read(historyFeedProvider(query).notifier).refresh(),
                                child: AnimatedOpacity(
                                  opacity: refreshing ? 0.45 : 1,
                                  duration: context.motion(AppMotion.standard),
                                  child: _Timeline(
                                    controller: _scroll,
                                    feed: shown,
                                    me: me,
                                    open: _open,
                                    shown: _shown,
                                    showBook: _filter.cashbookId == null && !_entryMode,
                                    entryMode: _entryMode,
                                    onToggle: (id) => setState(() => _open.contains(id) ? _open.remove(id) : _open.add(id)),
                                    onRetryMore: () => ref.read(historyFeedProvider(query).notifier).loadMore(),
                                  ),
                                ),
                              ),
                              if (refreshing) const LinearProgressIndicator(minHeight: 2),
                            ],
                          ),
      ),
    );
  }
}

/// The changes, grouped by day under headers that stay put while they scroll.
class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.controller,
    required this.feed,
    required this.me,
    required this.open,
    required this.shown,
    required this.showBook,
    required this.entryMode,
    required this.onToggle,
    required this.onRetryMore,
  });

  final ScrollController controller;
  final HistoryFeed feed;
  final String? me;
  final Set<String> open;
  final Set<String> shown;
  final bool showBook;
  final bool entryMode;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetryMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = <(DateTime, List<HistoryEvent>)>[];
    for (final event in feed.events) {
      if (days.isEmpty || days.last.$1 != event.day) {
        days.add((event.day, [event]));
      } else {
        days.last.$2.add(event);
      }
    }
    // The first screenful rises in with the page; later pages slide in as they come
    final firstLook = shown.isEmpty;
    var index = 0;
    final slivers = <Widget>[
      const SliverToBoxAdapter(child: SizedBox(height: AppSpace.sm)),
      for (final (i, (day, events)) in days.indexed)
        SliverMainAxisGroup(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: DayHeaderDelegate(
                label: historyDay(context, day),
                // The last day may go on in the next page
                count: feed.hasMore && i == days.length - 1 ? null : events.length,
                background: context.colors.paper,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.page, 0, AppSpace.page, AppSpace.md),
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final (i, event) in events.indexed)
                        () {
                          final tile = HistoryTile(
                            event: event,
                            me: me,
                            first: i == 0,
                            last: i == events.length - 1,
                            expanded: open.contains(event.id),
                            showBook: showBook,
                            onToggle: () => onToggle(event.id),
                            onOpenEntry: event.kind == HistoryKind.entry && !entryMode
                                ? () => openHistory(context, entry: event.objectId)
                                : null,
                          );
                          final fresh = shown.add(event.id);
                          // One shape whichever way it arrives, so an open row keeps its state
                          return Entrance(
                            key: ValueKey(event.id),
                            index: firstLook ? index++ : 0,
                            child: ArriveOnce(animate: fresh && !firstLook, child: tile),
                          );
                        }(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, 0, AppSpace.page, 96),
          child: AnimatedSwitcher(
            duration: context.motion(AppMotion.standard),
            child: feed.loadingMore
                ? const Padding(
                    key: ValueKey('more'),
                    padding: EdgeInsets.all(AppSpace.lg),
                    child: Center(child: AppLoader()),
                  )
                : feed.moreFailed
                    ? Column(
                        key: const ValueKey('failed'),
                        children: [
                          Text(l10n.historyMoreFailed, style: Theme.of(context).textTheme.bodySmall),
                          TextButton.icon(
                            onPressed: onRetryMore,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(l10n.retry),
                          ),
                        ],
                      )
                    : feed.hasMore
                        ? const SizedBox(key: ValueKey('gap'), height: 64)
                        : const HistoryEnd(key: ValueKey('end')),
          ),
        ),
      ),
    ];
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: slivers,
    );
  }
}

/// The business, what the page is for, and the filters, on the navy field.
class _Header extends ConsumerWidget {
  const _Header({required this.workspace, required this.filter, required this.team, required this.onChanged});

  final Workspace workspace;
  final HistoryFilter filter;
  final Team? team;
  final ValueChanged<HistoryFilter> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final books = ref.watch(cashbooksProvider(workspace.id)).value ?? const <CashbookSummary>[];
    final book = books.where((b) => b.book.id == filter.cashbookId).firstOrNull?.book;
    final person = team?.byUser(filter.personId);
    final from = filter.from;
    final to = filter.to;

    Future<void> pickBook() async {
      final picked = await showSelectSheet<String>(
        context,
        title: l10n.historyPickBook,
        value: filter.cashbookId,
        noneLabel: l10n.historyAnyBook,
        options: [for (final b in books) SelectOption(b.book.id, b.book.bookName, icon: Icons.menu_book_outlined)],
      );
      if (picked != null) onChanged(filter.copyWith(cashbookId: () => picked.value));
    }

    Future<void> pickPerson() async {
      final members = team?.members ?? const <TeamMember>[];
      final picked = await showSelectSheet<String>(
        context,
        title: l10n.historyPickPerson,
        value: filter.personId,
        noneLabel: l10n.historyAnyone,
        options: [
          for (final m in members)
            SelectOption(m.userId, m.displayName, icon: roleIcon(m.role), color: faceTint(m.email), detail: roleLabel(context, m.role)),
        ],
      );
      if (picked != null) onChanged(filter.copyWith(personId: () => picked.value));
    }

    Future<void> pickDays() async {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: now,
        initialDateRange: from != null && to != null ? DateTimeRange(start: from, end: to) : null,
      );
      if (picked != null) onChanged(filter.copyWith(range: () => (from: picked.start, to: picked.end)));
    }

    final days = from == null || to == null
        ? l10n.historyAnyTime
        : from == to
            ? formatDay(context, from)
            : '${formatDay(context, from)} – ${formatDay(context, to)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AnimatedSwitcher(
              duration: context.motion(AppMotion.emphasised),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: person != null
                  ? MemberAvatar(
                      key: ValueKey(person.userId),
                      seed: person.email,
                      initials: person.initials,
                      size: 44,
                      hero: 'member-${person.membershipId}',
                    )
                  : Container(
                      key: const ValueKey('all'),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.gold.withValues(alpha: 0.18)),
                      child: Icon(Icons.history_rounded, color: colors.gold),
                    ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workspace.name,
                    style: text.headlineSmall?.copyWith(color: colors.onHeader),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AnimatedSwitcher(
                    duration: context.motion(AppMotion.standard),
                    child: Text(
                      person != null ? l10n.historyChangesBy(person.displayName) : l10n.historyHint,
                      key: ValueKey(person?.userId),
                      style: text.bodyMedium?.copyWith(color: colors.onHeaderMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              HistoryFilterChip(
                icon: Icons.menu_book_outlined,
                label: book?.bookName ?? l10n.historyAnyBook,
                active: filter.cashbookId != null,
                onTap: pickBook,
                onClear: () => onChanged(filter.copyWith(cashbookId: () => null)),
              ),
              const SizedBox(width: AppSpace.sm),
              HistoryFilterChip(
                icon: Icons.person_outline_rounded,
                label: person?.displayName ?? (filter.personId != null ? l10n.historySomeone : l10n.historyAnyone),
                active: filter.personId != null,
                onTap: pickPerson,
                onClear: () => onChanged(filter.copyWith(personId: () => null)),
              ),
              const SizedBox(width: AppSpace.sm),
              HistoryFilterChip(
                icon: Icons.date_range_outlined,
                label: days,
                active: from != null,
                onTap: pickDays,
                onClear: () => onChanged(filter.copyWith(range: () => null)),
              ),
              AnimatedSize(
                duration: context.motion(AppMotion.standard),
                curve: AppMotion.ease,
                child: filter.count >= 2
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(start: AppSpace.sm),
                        child: TextButton(
                          style: TextButton.styleFrom(foregroundColor: colors.onHeader),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            onChanged(filter.cleared());
                          },
                          child: Text(l10n.historyClearAll),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One entry's story: what it is now, and how many times it changed.
class _EntryHeader extends StatelessWidget {
  const _EntryHeader({required this.feed});

  final HistoryFeed? feed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final latest = feed?.events.firstOrNull;
    final amount = latest == null ? null : historyAmount(context, latest);
    return AnimatedSwitcher(
      duration: context.motion(AppMotion.emphasised),
      child: Row(
        key: ValueKey(latest?.id),
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle, color: colors.gold.withValues(alpha: 0.18)),
            child: Icon(Icons.receipt_long_outlined, color: colors.gold),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  latest == null ? context.l10n.historyOfEntry : historySubject(context, latest) ?? '',
                  style: text.headlineSmall?.copyWith(color: colors.onHeader),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (latest != null)
                  Text(
                    [
                      ?amount,
                      // Counted only once every change is in
                      if (!feed!.hasMore) localDigits(context, context.l10n.historyChangeCount(feed!.events.length)),
                    ].join(' · '),
                    style: text.bodyMedium?.copyWith(color: colors.onHeaderMuted, fontFeatures: tabularFigures),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedHeader extends StatelessWidget {
  const _LockedHeader({required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: colors.gold.withValues(alpha: 0.18)),
          child: Icon(Icons.lock_outline_rounded, color: colors.gold),
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(workspace.name, style: text.headlineSmall?.copyWith(color: colors.onHeader), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(context.l10n.historyHint, style: text.bodyMedium?.copyWith(color: colors.onHeaderMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({super.key, required this.filter, required this.onClear});

  final HistoryFilter filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (filter.entryId != null) {
      return EmptyState(icon: Icons.cloud_upload_outlined, message: l10n.historyEmptyEntry);
    }
    return filter.isNarrowed
        ? EmptyState(
            icon: Icons.filter_alt_off_outlined,
            message: l10n.historyEmptyFiltered,
            actionLabel: l10n.clearFilters,
            onAction: onClear,
          )
        : EmptyState(icon: Icons.history_toggle_off_rounded, message: l10n.historyEmpty);
  }
}

class _Problem extends StatelessWidget {
  const _Problem({super.key, required this.problem, required this.onRetry});

  final HistoryProblem problem;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (problem) {
      HistoryProblem.refused => EmptyState(icon: Icons.lock_person_outlined, message: l10n.historyOwnerOnly),
      _ => EmptyState(
          icon: Icons.cloud_off_outlined,
          message: l10n.needsConnectionRetry,
          actionLabel: l10n.retry,
          onAction: onRetry,
        ),
    };
  }
}
