import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../personal/ledger_repository.dart';
import '../personal/spending_breakdown.dart' show localDigits;
import '../plan/upgrade_sheet.dart';
import 'year_review.dart';
import 'year_review_cards.dart';
import 'year_review_providers.dart';
import 'year_review_share.dart';

/// Opens the year in review, or says on the upgrade sheet that the plan lacks it.
/// When a month is opened from the review, the page it came from goes back to
/// the top, where that month's figures are.
Future<void> openYearReview(BuildContext context, WidgetRef ref, Workspace workspace) async {
  HapticFeedback.selectionClick();
  if (!await unlockFeature(context, ref, workspace, F.insightsYearReview) || !context.mounted) return;
  final month = await context.push<DateTime>('/year-review');
  if (month == null || !context.mounted) return;
  final page = Scrollable.maybeOf(context)?.position;
  final duration = context.motion(AppMotion.emphasised);
  if (page == null) return;
  duration == Duration.zero ? page.jumpTo(0) : page.animateTo(0, duration: duration, curve: AppMotion.ease);
}

/// A year looked back on ([F.insightsYearReview]): one card to share, the year
/// before beside it, month by month, where the money went and what stood out.
/// In the workspace currency, worked out from the phone's own data.
class YearReviewPage extends ConsumerStatefulWidget {
  const YearReviewPage({super.key});

  @override
  ConsumerState<YearReviewPage> createState() => _YearReviewPageState();
}

class _YearReviewPageState extends ConsumerState<YearReviewPage> {
  final _card = GlobalKey();
  var _sharing = false;

  Future<void> _share(YearReview review) async {
    if (_sharing) return;
    HapticFeedback.selectionClick();
    setState(() => _sharing = true);
    final l10n = context.l10n;
    final text = l10n.reviewShareText(localDigits(context, '${review.year}'));
    try {
      final png = await captureBoundary(_card);
      if (png == null) throw StateError('The card is not on screen');
      await ref.read(yearReviewSharerProvider).share(png, year: review.year, text: text);
    } catch (_) {
      if (mounted) context.showMessage(l10n.reviewShareFailed);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workspace = ref.watch(currentWorkspaceProvider);
    if (workspace == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: AppLoader()),
      );
    }
    ref.watch(entitlementsProvider);
    final locked = featureLocked(ref, workspace, F.insightsYearReview);
    final today = ref.watch(reviewTodayProvider);
    final years = ref.watch(reviewYearsProvider(workspace.id)).value ?? [defaultReviewYear(today)];
    final chosen = ref.watch(reviewYearProvider);
    final year = chosen != null && years.contains(chosen) ? chosen : defaultReviewYear(today);
    final currency = workspace.defaultCurrency;
    final review = locked ? null : ref.watch(yearReviewProvider((workspace.id, currency, year)));
    final shown = review?.value;

    return Scaffold(
      appBar: headerAppBar(
        context,
        title: Text(l10n.reviewTitle),
        actions: [
          if (shown != null && !shown.isEmpty)
            IconButton(
              tooltip: l10n.reviewShare,
              icon: SpinWhile(active: _sharing, child: Icon(_sharing ? Icons.sync_rounded : Icons.ios_share_rounded)),
              onPressed: _sharing ? null : () => _share(shown),
            ),
        ],
      ),
      body: PassbookBody(
        header: locked ? null : _YearSwitcher(year: year, years: years),
        child: locked
            ? _LockedReview(onUpgrade: () => openYearReviewUpgrade(context))
            : AsyncView<YearReview>(
                value: review!,
                builder: (review) => _ReviewBody(
                  review: review,
                  currency: currency,
                  cardKey: _card,
                  onOpenMonth: (month) {
                    ref.read(overviewRangeProvider.notifier).set(null);
                    ref.read(selectedMonthProvider.notifier).set(month);
                    Navigator.of(context).maybePop(month);
                  },
                ),
              ),
      ),
    );
  }
}

/// What the plan lacks, on the upgrade sheet.
Future<void> openYearReviewUpgrade(BuildContext context) => showUpgradeSheet(
  context,
  refusal: const PlanLimitException(F.insightsYearReview, reason: PlanLimitException.reasonFeature),
);

/// ‹ 2026 › on the navy field, across the years there is anything to look back on.
class _YearSwitcher extends ConsumerWidget {
  const _YearSwitcher({required this.year, required this.years});

  final int year;

  /// Newest first.
  final List<int> years;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final index = years.indexOf(year);
    Widget arrow(String tooltip, IconData icon, int? to) => IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      color: colors.onHeader,
      disabledColor: colors.onHeader.withValues(alpha: 0.3),
      icon: Icon(icon),
      onPressed: to == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              ref.read(reviewYearProvider.notifier).set(to);
            },
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          arrow(
            l10n.reviewPreviousYear,
            Icons.chevron_left_rounded,
            index >= 0 && index + 1 < years.length ? years[index + 1] : null,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: context.motion(AppMotion.standard),
              child: Text(
                localDigits(context, '$year'),
                key: ValueKey(year),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colors.onHeader),
              ),
            ),
          ),
          arrow(l10n.reviewNextYear, Icons.chevron_right_rounded, index > 0 ? years[index - 1] : null),
        ],
      ),
    );
  }
}

class _ReviewBody extends StatelessWidget {
  const _ReviewBody({required this.review, required this.currency, required this.cardKey, required this.onOpenMonth});

  final YearReview review;
  final String currency;
  final GlobalKey cardKey;
  final ValueChanged<DateTime> onOpenMonth;

  @override
  Widget build(BuildContext context) {
    if (review.isEmpty) {
      return EmptyState(
        icon: Icons.auto_graph_rounded,
        message: context.l10n.reviewEmpty(localDigits(context, '${review.year}')),
      );
    }
    // Not a lazy list: the card to share stays painted however far down the page is
    return SingleChildScrollView(
      key: PageStorageKey('year-review-${review.year}'),
      padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Entrance(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: RepaintBoundary(
                key: cardKey,
                // Rounded corners on the page's colour, not see-through: some apps turn those black
                child: ColoredBox(
                  color: context.colors.paper,
                  child: ReviewHeroCard(review: review, currency: currency),
                ),
              ),
            ),
          ),
          if (review.hasPrevious)
            Entrance(
              index: 1,
              child: ReviewVersusCard(review: review, currency: currency),
            ),
          Entrance(
            index: 2,
            child: ReviewMonthsCard(review: review, currency: currency, onOpenMonth: onOpenMonth),
          ),
          if (review.categories.isNotEmpty)
            Entrance(
              index: 3,
              child: ReviewCategoriesCard(review: review, currency: currency),
            ),
          Entrance(
            index: 4,
            child: ReviewHighlightsCard(review: review, currency: currency),
          ),
        ],
      ),
    );
  }
}

/// In place of the review when the plan lacks it, as after a downgrade.
class _LockedReview extends StatelessWidget {
  const _LockedReview({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(Icons.lock_outline_rounded, size: 40, color: scheme.primary.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: AppSpace.lg),
            Text(l10n.reviewTitle, style: text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.sm),
            Text(l10n.reviewLocked, style: text.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.xl),
            FilledButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: Text(l10n.planSeePlans),
            ),
          ],
        ),
      ),
    );
  }
}

/// The way into the year in review from the overview: the year it opens on,
/// with a lock while the plan lacks it.
class YearReviewTile extends ConsumerWidget {
  const YearReviewTile({super.key, required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    ref.watch(entitlementsProvider);
    final locked = featureLocked(ref, workspace, F.insightsYearReview);
    final year = defaultReviewYear(ref.watch(reviewTodayProvider));
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openYearReview(context, ref, workspace),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colors.header, colors.headerEnd]),
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: colors.gold),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reviewTileTitle(localDigits(context, '$year')), style: text.titleMedium),
                    Text(l10n.reviewTileBody, style: text.bodySmall?.copyWith(color: colors.muted)),
                  ],
                ),
              ),
              Icon(locked ? Icons.lock_outline_rounded : Icons.chevron_right_rounded, color: colors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
