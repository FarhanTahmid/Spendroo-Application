import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui.dart';
import '../personal/spending_breakdown.dart' show localDigits;
import '../team/team_widgets.dart';
import 'history_repository.dart';
import 'history_text.dart';

/// One change on the timeline: who (a face with what they did as a badge),
/// what, and when. Tapping it opens the before and after of each field.
class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.event,
    required this.me,
    this.first = false,
    this.last = false,
    this.expanded = false,
    this.onToggle,
    this.showBook = true,
    this.onOpenEntry,
  });

  final HistoryEvent event;

  /// The signed-in user, who reads as "You".
  final String? me;

  /// The rail joins faces: none above the first of a day, none below the last.
  final bool first;
  final bool last;
  final bool expanded;
  final VoidCallback? onToggle;

  /// Off when the history is already narrowed to one book.
  final bool showBook;

  /// Shown on an open entry row: its own history.
  final VoidCallback? onOpenEntry;

  bool get _opens => event.changes.isNotEmpty || onOpenEntry != null;

  bool get _hasMeta => showBook && event.cashbookName.isNotEmpty || event.changes.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final (_, tone) = actionLook(context, event.action);
    final subject = historySubject(context, event);
    final amount = historyAmount(context, event);
    final who = actorName(context, event, me);
    final chevron = AnimatedRotation(
      turns: expanded ? 0.5 : 0,
      duration: context.motion(AppMotion.standard),
      curve: AppMotion.ease,
      child: Icon(Icons.expand_more_rounded, size: 20, color: colors.muted),
    );
    return Semantics(
      button: _opens,
      expanded: _opens ? expanded : null,
      child: InkWell(
        onTap: _opens
            ? () {
                HapticFeedback.selectionClick();
                onToggle?.call();
              }
            : null,
        child: Stack(
          children: [
            // The rail, behind the faces
            Positioned(
              left: AppSpace.lg + 19,
              width: 2,
              top: first ? 30 : 0,
              bottom: last ? null : 0,
              height: last ? 30 - (first ? 30 : 0) : null,
              child: ColoredBox(color: colors.hairline),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Face(event: event),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(text: who, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const TextSpan(text: '  '),
                                  TextSpan(text: historySentence(context, event), style: TextStyle(color: colors.muted)),
                                ]),
                                style: text.bodyMedium,
                              ),
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Text(
                              historyTime(context, event.at),
                              style: text.labelSmall?.copyWith(color: colors.muted, fontFeatures: tabularFigures),
                            ),
                          ],
                        ),
                        if (subject != null || amount != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Icon(kindIcon(event.kind), size: 16, color: tone),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    subject ?? '',
                                    style: text.titleSmall?.copyWith(
                                      decoration: event.action == HistoryAction.deleted ? TextDecoration.lineThrough : null,
                                      decorationColor: colors.moneyOut,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (amount != null)
                                  Text(
                                    amount,
                                    style: text.titleSmall?.copyWith(
                                      color: event.entryType == 'cash_in' ? colors.moneyIn : colors.moneyOut,
                                      fontFeatures: tabularFigures,
                                    ),
                                  ),
                                if (_opens && !_hasMeta) ...[const SizedBox(width: 4), chevron],
                              ],
                            ),
                          ),
                        if (_hasMeta)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                if (showBook && event.cashbookName.isNotEmpty) ...[
                                  Flexible(flex: 0, child: BookPill(name: event.cashbookName)),
                                  const SizedBox(width: AppSpace.sm),
                                ],
                                if (event.changes.isNotEmpty)
                                  Expanded(
                                    child: Text(
                                      changedFields(context, event),
                                      style: text.bodySmall?.copyWith(color: tone, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                else
                                  const Spacer(),
                                if (_opens) chevron,
                              ],
                            ),
                          ),
                        AnimatedSize(
                          duration: context.motion(AppMotion.emphasised),
                          curve: AppMotion.ease,
                          alignment: Alignment.topCenter,
                          child: expanded
                              ? _Details(event: event, onOpenEntry: onOpenEntry)
                              : const SizedBox(width: double.infinity),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Who did it, with what they did on a small badge.
class _Face extends StatelessWidget {
  const _Face({required this.event});

  final HistoryEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, tone) = actionLook(context, event.action);
    final actor = event.actor;
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (actor != null)
            MemberAvatar(seed: actor.email, initials: actor.initials, size: 40)
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.header),
              child: Icon(Icons.auto_awesome_rounded, size: 18, color: colors.gold),
            ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tone,
                border: Border.all(color: Theme.of(context).cardColor, width: 2),
              ),
              child: Icon(icon, size: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// The cashbook a change was in, as a quiet pill.
class BookPill extends StatelessWidget {
  const BookPill({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.field,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 12, color: colors.muted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Each field that changed: the old value struck through, then the new.
class _Details extends StatelessWidget {
  const _Details({required this.event, this.onOpenEntry});

  final HistoryEvent event;
  final VoidCallback? onOpenEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (event.changes.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpace.md),
              decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(AppRadius.control)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (i, change) in event.changes.indexed) ...[
                    if (i > 0) const SizedBox(height: AppSpace.md),
                    _Arrive(
                      delay: Duration(milliseconds: 40 * i),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fieldLabel(context, event, change.field).toUpperCase(),
                            style: text.labelSmall?.copyWith(color: colors.muted, letterSpacing: 0.8, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _Value(
                                text: fieldValue(context, event, change.field, change.before),
                                swatch: fieldSwatch(change.field, change.before),
                                old: true,
                              ),
                              Icon(Icons.arrow_forward_rounded, size: 14, color: colors.muted),
                              _Value(
                                text: fieldValue(context, event, change.field, change.after),
                                swatch: fieldSwatch(change.field, change.after),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (onOpenEntry != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                onPressed: onOpenEntry,
                icon: const Icon(Icons.history_rounded, size: 18),
                label: Text(l10n.historyOfEntry),
              ),
            ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({required this.text, this.swatch, this.old = false});

  final String? text;
  final Color? swatch;
  final bool old;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = Theme.of(context).textTheme.bodyMedium;
    final tone = old ? colors.moneyOut : colors.moneyIn;
    final empty = text == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: old ? 0.08 : 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (swatch != null) ...[ColorDot(swatch!), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              empty ? context.l10n.historyEmptyValue : text!,
              style: style?.copyWith(
                color: empty ? colors.muted : (old ? colors.muted : null),
                fontStyle: empty ? FontStyle.italic : null,
                fontWeight: old ? null : FontWeight.w600,
                decoration: old && !empty ? TextDecoration.lineThrough : null,
                decorationColor: colors.moneyOut,
                fontFeatures: tabularFigures,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades and rises in once, after [delay]: rows that arrive with a later
/// page, and the fields of a change being opened. With [animate] off it
/// simply shows; it never animates again once built.
class _Arrive extends StatelessWidget {
  const _Arrive({required this.child, this.delay = Duration.zero, this.animate = true});

  final Widget child;
  final Duration delay;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final rise = context.motion(AppMotion.emphasised);
    final total = rise + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate && rise > Duration.zero ? 0 : 1, end: 1),
      duration: total,
      curve: total == Duration.zero ? Curves.linear : Interval(delay.inMilliseconds / total.inMilliseconds, 1, curve: AppMotion.ease),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// [_Arrive] for rows of the history that came with a later page.
class ArriveOnce extends StatelessWidget {
  const ArriveOnce({super.key, required this.child, required this.animate});

  final Widget child;
  final bool animate;

  @override
  Widget build(BuildContext context) => _Arrive(animate: animate, child: child);
}

/// The day over its changes; it stays at the top while they scroll under it.
class DayHeaderDelegate extends SliverPersistentHeaderDelegate {
  DayHeaderDelegate({required this.label, required this.count, required this.background});

  final String label;

  /// Null while more of the day may still be on its way.
  final int? count;
  final Color background;

  static const height = 40.0;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(AppSpace.page + 4, 0, AppSpace.page + 4, 0),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          AnimatedContainer(
            duration: context.motion(AppMotion.standard),
            width: overlapsContent ? 10 : 6,
            height: 6,
            decoration: BoxDecoration(color: colors.gold, borderRadius: BorderRadius.circular(AppRadius.pill)),
          ),
          const SizedBox(width: AppSpace.sm),
          Text(
            label.toUpperCase(),
            style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
          ),
          const Spacer(),
          if (count != null)
            Text(
              localDigits(context, context.l10n.historyChangeCount(count!)),
              style: text.labelSmall?.copyWith(color: colors.muted),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(DayHeaderDelegate old) =>
      old.label != label || old.count != count || old.background != background;
}

/// A filter on the navy header: faint when it lets everything through, gold
/// with a ✕ when it narrows the history.
class HistoryFilterChip extends StatelessWidget {
  const HistoryFilterChip({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = active ? colors.onGold : colors.onHeader;
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(color: fg, fontWeight: FontWeight.w600);
    return Pressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: context.motion(AppMotion.standard),
        curve: AppMotion.ease,
        height: 36,
        padding: EdgeInsetsDirectional.only(start: 12, end: active && onClear != null ? 4 : 10),
        decoration: BoxDecoration(
          color: active ? colors.gold : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: active ? colors.gold : Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: AnimatedSwitcher(
                duration: context.motion(AppMotion.standard),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(sizeFactor: animation, axis: Axis.horizontal, child: child),
                ),
                child: Text(label, key: ValueKey(label), style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            if (active && onClear != null)
              Semantics(
                button: true,
                label: MaterialLocalizations.of(context).deleteButtonTooltip,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onClear!();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.close_rounded, size: 16, color: fg),
                  ),
                ),
              )
            else
              Icon(Icons.expand_more_rounded, size: 18, color: fg.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}

/// Where the history ends: everything has been shown.
class HistoryEnd extends StatelessWidget {
  const HistoryEnd({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xl),
      child: Row(
        children: [
          Expanded(child: Divider(color: colors.hairline, endIndent: AppSpace.md)),
          Icon(Icons.flag_outlined, size: 16, color: colors.muted),
          const SizedBox(width: 6),
          Text(context.l10n.historyTheStart, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.muted)),
          Expanded(child: Divider(color: colors.hairline, indent: AppSpace.md)),
        ],
      ),
    );
  }
}

/// What the edit history would show, blurred behind what the plan lacks.
class LockedHistory extends StatelessWidget {
  const LockedHistory({super.key, required this.onSeePlans});

  final VoidCallback onSeePlans;

  static List<HistoryEvent> _samples() {
    final now = DateTime.now();
    const rahim = HistoryActor(id: 's-1', email: 'rahim@sample', name: 'Rahim Uddin');
    const sadia = HistoryActor(id: 's-2', email: 'sadia@sample', name: 'Sadia Akter');
    return [
      HistoryEvent(
        id: '1', at: now, kind: HistoryKind.entry, action: HistoryAction.updated, objectId: '',
        actor: rahim, subject: 'Supplier payment', cashbookName: 'Main till', amountMinor: 450000, currency: 'BDT',
        entryType: 'cash_out', changes: const [FieldChange('amount_minor', 400000, 450000)],
      ),
      HistoryEvent(
        id: '2', at: now, kind: HistoryKind.entry, action: HistoryAction.created, objectId: '',
        actor: sadia, subject: 'Counter sales', cashbookName: 'Main till', amountMinor: 1285000, currency: 'BDT',
        entryType: 'cash_in',
      ),
      HistoryEvent(
        id: '3', at: now, kind: HistoryKind.entry, action: HistoryAction.deleted, objectId: '',
        actor: rahim, subject: 'Tea and snacks', cashbookName: 'Petty cash', amountMinor: 32000, currency: 'BDT',
        entryType: 'cash_out',
      ),
      HistoryEvent(
        id: '4', at: now, kind: HistoryKind.category, action: HistoryAction.created, objectId: '',
        actor: sadia, subject: 'Delivery', cashbookName: 'Main till',
      ),
      HistoryEvent(
        id: '5', at: now, kind: HistoryKind.entry, action: HistoryAction.updated, objectId: '',
        actor: sadia, subject: 'Rent', cashbookName: 'Main till', amountMinor: 2500000, currency: 'BDT',
        entryType: 'cash_out', changes: const [FieldChange('category', 'Other', 'Housing')],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final samples = _samples();
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, 0),
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final (i, event) in samples.indexed)
                          HistoryTile(event: event, me: null, first: i == 0, last: i == samples.length - 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.35, 0.6],
              colors: [colors.paper.withValues(alpha: 0.1), colors.paper.withValues(alpha: 0.75), colors.paper],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpace.page),
              child: Entrance(index: 1, child: _Upsell(onSeePlans: onSeePlans)),
            ),
          ),
        ),
      ],
    );
  }
}

class _Upsell extends StatelessWidget {
  const _Upsell({required this.onSeePlans});

  final VoidCallback onSeePlans;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpace.xl),
      decoration: BoxDecoration(
        color: colors.sheet,
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.alphaBlend(colors.gold.withValues(alpha: 0.2), colors.sheet), colors.sheet],
        ),
        border: Border.all(color: colors.gold.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Breathing(child: _LockBadge()),
          const SizedBox(height: AppSpace.lg),
          Text(l10n.historyLockedTitle, style: text.titleLarge),
          const SizedBox(height: AppSpace.sm),
          Text(l10n.historyLockedBody, style: text.bodyMedium),
          const SizedBox(height: AppSpace.md),
          for (final point in [l10n.historyLockedPoint1, l10n.historyLockedPoint2, l10n.historyLockedPoint3])
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: colors.gold),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(child: Text(point, style: text.bodyMedium)),
                ],
              ),
            ),
          const SizedBox(height: AppSpace.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: colors.gold, foregroundColor: colors.onGold),
              onPressed: onSeePlans,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: Text(l10n.planSeePlans),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.gold.withValues(alpha: 0.18),
        border: Border.all(color: colors.gold.withValues(alpha: 0.5)),
      ),
      child: Icon(Icons.history_rounded, color: colors.gold, size: 26),
    );
  }
}

/// Grows and shrinks a little, slowly, to draw the eye. Still under reduce motion.
class _Breathing extends StatefulWidget {
  const _Breathing({required this.child});

  final Widget child;

  @override
  State<_Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<_Breathing> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
        child: widget.child,
      );
}
