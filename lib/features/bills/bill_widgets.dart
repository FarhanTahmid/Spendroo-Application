import 'dart:io';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../core/db/database.dart';
import '../../core/db/local_store.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../plan/plan_text.dart';
import '../plan/upgrade_sheet.dart';
import 'bill_picker.dart';
import 'bill_repository.dart';
import 'bill_text.dart';
import 'bill_viewer_page.dart';

const _tileSize = Size(78, 104);

/// Bills picked in the form of an entry that is not saved yet. The form keeps
/// them until Save, then [attachTo] queues them against the new entry.
class StagedBills extends ChangeNotifier {
  final _bills = <BillView>[];
  final _picked = <String, PickedBill>{};

  List<BillView> get bills => List.unmodifiable(_bills);
  int get bytes => _picked.values.fold(0, (sum, bill) => sum + bill.sizeBytes);

  void add(PickedBill picked) {
    final id = newId();
    _picked[id] = picked;
    _bills.add(BillView.staged(picked, id));
    notifyListeners();
  }

  void remove(String id) {
    _picked.remove(id);
    _bills.removeWhere((bill) => bill.id == id);
    notifyListeners();
  }

  Future<void> attachTo(BillRepository repo, {required String workspaceId, required String cashbookId, required String entryId}) async {
    for (final bill in _bills) {
      await repo.attach(_picked[bill.id]!, workspaceId: workspaceId, cashbookId: cashbookId, entryId: entryId, id: bill.id);
    }
  }
}

/// The bills of one entry: a strip of tiles that fly open into the viewer,
/// with a dashed tile to attach another. Without [entry] the bills are the
/// [staged] ones of a form not saved yet; otherwise every change is queued at once.
class BillsSection extends ConsumerStatefulWidget {
  const BillsSection({
    super.key,
    required this.workspace,
    this.entry,
    this.staged,
    this.canAttach = true,
    this.canRemove = true,
  }) : assert(entry != null || staged != null);

  final Workspace? workspace;
  final Entry? entry;
  final StagedBills? staged;
  final bool canAttach;
  final bool canRemove;

  @override
  ConsumerState<BillsSection> createState() => _BillsSectionState();
}

class _BillsSectionState extends ConsumerState<BillsSection> {
  BillRepository get _repo => ref.read(billRepositoryProvider);

  BillRules get _rules => BillRules.of(ref.read(entitlementsProvider).value, widget.workspace);

  @override
  void initState() {
    super.initState();
    widget.staged?.addListener(_restage);
  }

  @override
  void didUpdateWidget(BillsSection old) {
    super.didUpdateWidget(old);
    if (old.staged != widget.staged) {
      old.staged?.removeListener(_restage);
      widget.staged?.addListener(_restage);
    }
  }

  @override
  void dispose() {
    widget.staged?.removeListener(_restage);
    super.dispose();
  }

  void _restage() => setState(() {});

  Future<void> _attach() async {
    // Back from the sheet or the camera, the keyboard should not jump up again
    FocusManager.instance.primaryFocus?.unfocus();
    final rules = _rules;
    final picked = await showAttachBillSheet(context, rules);
    if (picked == null || !mounted) return;
    final entry = widget.entry;
    await guarded(context, () async {
      await _repo.check(picked, rules, alsoStaged: widget.staged?.bytes ?? 0);
      if (entry == null) {
        widget.staged!.add(picked);
        HapticFeedback.selectionClick();
        return;
      }
      await _repo.attach(picked, workspaceId: entry.workspaceId, cashbookId: entry.cashbookId, entryId: entry.id);
      HapticFeedback.selectionClick();
      if (mounted) context.showMessage(context.l10n.billAdded);
    });
  }

  Future<void> _remove(BillView bill) async {
    if (bill.status == BillStatus.staged) return widget.staged!.remove(bill.id);
    await _repo.remove(bill);
    if (!mounted) return;
    showEventBurst(context, AppEvent.deleted);
    context.showMessage(context.l10n.billRemoved);
  }

  Future<void> _open(List<BillView> bills, BillView bill) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (bill.needsAttention) return _explain(bill);
    final viewable = bills.where((b) => !b.needsAttention).toList();
    final removed = await openBillViewer(
      context,
      bills: viewable,
      initial: viewable.indexOf(bill),
      canRemove: widget.canRemove,
    );
    if (removed != null && mounted) await _remove(removed);
  }

  /// A bill the server or the plan would not take: why, and what can be done.
  Future<void> _explain(BillView bill) async {
    final l10n = context.l10n;
    final refused = bill.status == BillStatus.refused;
    final action = await showAppSheet<String>(
      context,
      title: refused ? l10n.billRefused : l10n.billFailed,
      builder: (sheet) {
        final text = Theme.of(sheet).textTheme;
        final plan = ref.read(entitlementsProvider).value?.plan.nameIn(sheet.languageCode) ?? '';
        final message = refused
            ? planLimitText(l10n, PlanLimitException(bill.error ?? F.storageMb, limit: _limitFor(bill.error)), plan)
            : billErrorText(l10n, bill.error);
        final canRetry = refused || const {'bill_forbidden', 'bill_gone', null}.contains(bill.error);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(
                  refused ? Icons.lock_outline_rounded : Icons.error_outline_rounded,
                  color: refused ? context.colors.gold : Theme.of(sheet).colorScheme.error,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(child: Text(message, style: text.bodyMedium)),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            if (refused)
              FilledButton.icon(
                icon: const Icon(Icons.workspace_premium_outlined),
                label: Text(l10n.planUpgradeTitle),
                onPressed: () => Navigator.pop(sheet, 'plans'),
              ),
            if (canRetry) ...[
              const SizedBox(height: AppSpace.sm),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.billRetry),
                onPressed: () => Navigator.pop(sheet, 'retry'),
              ),
            ],
            const SizedBox(height: AppSpace.sm),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Theme.of(sheet).colorScheme.error),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.billRemove),
              onPressed: () => Navigator.pop(sheet, 'remove'),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    switch (action) {
      case 'plans':
        await showUpgradeSheet(context, refusal: PlanLimitException(bill.error ?? F.storageMb, limit: _limitFor(bill.error)));
      case 'retry':
        await _repo.retry(bill);
      case 'remove':
        await _remove(bill);
    }
  }

  int? _limitFor(String? feature) => ref.read(entitlementsProvider).value?.limitOf(feature ?? F.storageMb);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final entry = widget.entry;
    final bills = entry == null
        ? widget.staged!.bills
        : ref.watch(entryBillsProvider(entry.id)).value ?? const <BillView>[];
    if (bills.isEmpty && !widget.canAttach) return const SizedBox.shrink();
    final rules = BillRules.of(ref.watch(entitlementsProvider).value, widget.workspace);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long_rounded, size: 18, color: context.colors.muted),
            const SizedBox(width: 6),
            Text(l10n.bills, style: text.titleSmall),
            const SizedBox(width: 6),
            PopSwitcher(
              child: bills.isEmpty
                  ? const SizedBox.shrink(key: ValueKey(0))
                  : _CountChip(key: ValueKey(bills.length), count: bills.length),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        AnimatedSize(
          duration: context.motion(AppMotion.emphasised),
          curve: AppMotion.ease,
          alignment: Alignment.topCenter,
          child: bills.isEmpty
              ? _AttachCard(onTap: _attach)
              : SizedBox(
                  height: _tileSize.height + 8,
                  child: _BillStrip(
                    bills: bills,
                    tile: (bill) => BillTile(bill: bill, onTap: () => _open(bills, bill)),
                    trailing: widget.canAttach ? _AttachTile(onTap: _attach) : null,
                  ),
                ),
        ),
        if (!widget.canAttach && bills.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.xs),
            child: Text(l10n.billViewOnly, style: text.bodySmall),
          ),
        if (widget.canAttach && rules.known && rules.totalMb != null) _StorageLine(rules: rules),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          '$count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontFeatures: tabularFigures,
              ),
        ),
      );
}

/// How much of the owner's storage bills use, and the most one bill may be.
class _StorageLine extends StatelessWidget {
  const _StorageLine({required this.rules});

  final BillRules rules;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = context.languageCode;
    final total = rules.totalMb! * megabyte;
    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LimitBar(value: rules.usedBytes / total, height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.billStorageUsed(formatBytes(rules.usedBytes, language), formatMegabytes(rules.totalMb!, language)),
                  style: style,
                ),
              ),
              if (rules.fileMb != null) Text(l10n.billPerFile(formatMegabytes(rules.fileMb!, language)), style: style),
            ],
          ),
        ],
      ),
    );
  }
}

/// One bill: its photo or first page, with what is happening to it on top.
class BillTile extends ConsumerWidget {
  const BillTile({super.key, required this.bill, this.onTap});

  final BillView bill;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final semantics = switch (bill.status) {
      BillStatus.waiting => l10n.billWaiting,
      BillStatus.failed => l10n.billFailed,
      BillStatus.refused => l10n.billRefused,
      BillStatus.staged => l10n.billStaged,
      BillStatus.stored => bill.originalName,
    };
    return Semantics(
      button: true,
      label: '${bill.isPdf ? 'PDF' : l10n.bills}: $semantics',
      child: Pressable(
        onTap: onTap,
        child: Hero(
          tag: bill.heroTag,
          child: Container(
            width: _tileSize.width,
            height: _tileSize.height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.field,
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: colors.hairline),
              boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                BillPreview(bill: bill, thumbnail: true),
                if (bill.isPdf) const Positioned(left: 6, top: 6, child: _PdfBadge()),
                _StatusLayer(bill: bill),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PdfBadge extends StatelessWidget {
  const _PdfBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(color: const Color(0xFFD93025), borderRadius: BorderRadius.circular(4)),
        child: const Text('PDF', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
      );
}

/// Uploading, waiting for a connection, refused: shown over the tile, and
/// swapped with a small pop when it changes.
class _StatusLayer extends ConsumerWidget {
  const _StatusLayer({required this.bill});

  final BillView bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final progress = ref.watch(billProgressProvider.select((all) => all[bill.id]));
    final offline = ref.watch(syncControllerProvider.select((s) => s.offline));

    final Widget layer = switch (bill.status) {
      BillStatus.stored => const SizedBox.shrink(key: ValueKey('stored')),
      BillStatus.staged => _Corner(
          key: const ValueKey('staged'),
          color: scheme.surface,
          child: Icon(Icons.schedule_rounded, size: 13, color: colors.muted),
        ),
      BillStatus.waiting => _Corner(
          key: ValueKey(progress == null ? (offline ? 'offline' : 'queued') : 'sending'),
          color: scheme.surface,
          child: progress != null
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: context.motion(AppMotion.standard),
                    builder: (context, value, _) => CircularProgressIndicator(value: value, strokeWidth: 2.4),
                  ),
                )
              : Icon(offline ? Icons.cloud_off_rounded : Icons.cloud_upload_outlined, size: 13, color: colors.muted),
        ),
      BillStatus.failed => _Veil(
          key: const ValueKey('failed'),
          color: scheme.error,
          icon: Icons.priority_high_rounded,
        ),
      BillStatus.refused => _Veil(
          key: const ValueKey('refused'),
          color: colors.gold,
          icon: Icons.lock_outline_rounded,
        ),
    };
    return PopSwitcher(child: layer);
  }
}

class _Corner extends StatelessWidget {
  const _Corner({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(5),
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 6)],
          ),
          child: child,
        ),
      );
}

class _Veil extends StatelessWidget {
  const _Veil({super.key, required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        color: color.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: color),
        ),
      );
}

/// What a bill looks like: the photo itself, or a PDF's first page. A PDF is
/// only drawn from a copy on this phone; one never opened shows its paper
/// and page count until it is.
class BillPreview extends ConsumerWidget {
  const BillPreview({super.key, required this.bill, this.thumbnail = false});

  final BillView bill;

  /// Small: decoded at a fraction of its size.
  final bool thumbnail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bill.isPdf) {
      final file = ref.watch(billLocalFileProvider(bill)).value;
      return file == null ? _PaperPlaceholder(bill: bill) : _PdfFirstPage(file: file, bill: bill);
    }
    final file = ref.watch(billFileProvider(bill));
    return switch (file) {
      AsyncData(:final value) => Image.file(
          value,
          fit: BoxFit.cover,
          cacheWidth: thumbnail ? 240 : null,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, sync) => sync
              ? child
              : AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: context.motion(AppMotion.emphasised),
                  curve: AppMotion.ease,
                  child: child,
                ),
          errorBuilder: (context, error, stack) => const _BrokenPreview(),
        ),
      AsyncError() => const _BrokenPreview(),
      _ => const Skeleton(height: double.infinity, radius: 0),
    };
  }
}

class _PdfFirstPage extends StatelessWidget {
  const _PdfFirstPage({required this.file, required this.bill});

  final File file;
  final BillView bill;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.white,
        child: PdfDocumentViewBuilder.file(
          file.path,
          builder: (context, document) => document == null
              ? _PaperPlaceholder(bill: bill)
              : PdfPageView(document: document, pageNumber: 1, alignment: Alignment.topCenter),
        ),
      );
}

class _PaperPlaceholder extends StatelessWidget {
  const _PaperPlaceholder({required this.bill});

  final BillView bill;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.muted;
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 26, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final width in const [0.9, 0.7, 0.8, 0.5, 0.75])
              FractionallySizedBox(
                widthFactor: width,
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(color: muted.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(2)),
                ),
              ),
            const Spacer(),
            if (bill.pageCount != null)
              Text(
                context.l10n.billPages(bill.pageCount!),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}

class _BrokenPreview extends StatelessWidget {
  const _BrokenPreview();

  @override
  Widget build(BuildContext context) =>
      Center(child: Icon(Icons.image_not_supported_outlined, color: context.colors.muted, size: 22));
}

/// Tiles in a row. A new one springs in, a removed one folds away, and the rest slide over.
class _BillStrip extends StatefulWidget {
  const _BillStrip({required this.bills, required this.tile, this.trailing});

  final List<BillView> bills;
  final Widget Function(BillView bill) tile;
  final Widget? trailing;

  @override
  State<_BillStrip> createState() => _BillStripState();
}

class _BillStripState extends State<_BillStrip> {
  late List<BillView> _shown = widget.bills;
  final _leaving = <String>{};

  @override
  void didUpdateWidget(_BillStrip old) {
    super.didUpdateWidget(old);
    final next = widget.bills;
    final ids = {for (final bill in next) bill.id};
    final merged = [...next];
    for (final (index, bill) in _shown.indexed) {
      if (ids.contains(bill.id)) continue;
      _leaving.add(bill.id);
      merged.insert(index.clamp(0, merged.length), bill);
    }
    _shown = merged;
  }

  void _gone(String id) {
    if (!mounted) return;
    setState(() {
      _leaving.remove(id);
      _shown = _shown.where((bill) => bill.id != id || widget.bills.any((b) => b.id == id)).toList();
    });
  }

  @override
  Widget build(BuildContext context) => ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          for (final bill in _shown)
            _Arrive(
              key: ValueKey(bill.id),
              leaving: _leaving.contains(bill.id),
              onGone: () => _gone(bill.id),
              child: Padding(padding: const EdgeInsets.only(right: AppSpace.sm), child: widget.tile(bill)),
            ),
          if (widget.trailing != null) widget.trailing!,
        ],
      );
}

class _Arrive extends StatefulWidget {
  const _Arrive({super.key, required this.child, required this.leaving, required this.onGone});

  final Widget child;
  final bool leaving;
  final VoidCallback onGone;

  @override
  State<_Arrive> createState() => _ArriveState();
}

class _ArriveState extends State<_Arrive> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: AppMotion.emphasised, value: 0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.motion(AppMotion.emphasised);
    if (_controller.value == 0 && !widget.leaving) _controller.forward();
  }

  @override
  void didUpdateWidget(_Arrive old) {
    super.didUpdateWidget(old);
    if (widget.leaving && !old.leaving) {
      _controller.reverse().whenComplete(widget.onGone);
    } else if (!widget.leaving && old.leaving) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grow = CurvedAnimation(parent: _controller, curve: AppMotion.ease, reverseCurve: Curves.easeIn);
    final pop = CurvedAnimation(parent: _controller, curve: AppMotion.spring, reverseCurve: Curves.easeIn);
    return SizeTransition(
      sizeFactor: grow,
      axis: Axis.horizontal,
      alignment: Alignment.centerLeft,
      child: FadeTransition(
        opacity: grow,
        child: ScaleTransition(scale: Tween(begin: 0.6, end: 1.0).animate(pop), child: widget.child),
      ),
    );
  }
}

/// The dashed tile at the end of the strip.
class _AttachTile extends StatelessWidget {
  const _AttachTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: context.l10n.billAttach,
      child: Pressable(
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorder(color: scheme.primary.withValues(alpha: 0.55)),
          child: SizedBox(
            width: _tileSize.width,
            height: _tileSize.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: scheme.primary, size: 22),
                const SizedBox(height: 6),
                ExcludeSemantics(
                  child: Text(
                    context.l10n.billAttach,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What the section shows before the first bill: an invitation, not a gap.
class _AttachCard extends StatelessWidget {
  const _AttachCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      child: Pressable(
        scale: 0.98,
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorder(color: scheme.primary.withValues(alpha: 0.45)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.md),
            child: Row(
              children: [
                IconBadge(Icons.document_scanner_outlined, color: scheme.primary),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.billAttach, style: text.titleSmall?.copyWith(color: scheme.primary)),
                      Text(context.l10n.billsHint, style: text.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  _DashedBorder({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final outline = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(AppRadius.control)));
    for (final PathMetric metric in outline.computeMetrics()) {
      for (double start = 0; start < metric.length; start += 9) {
        canvas.drawPath(metric.extractPath(start, start + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}

/// Camera, gallery or a PDF. Returns the chosen file, checked to be a photo
/// or a PDF; a locked PDF choice opens the upgrade sheet instead.
Future<PickedBill?> showAttachBillSheet(BuildContext context, BillRules rules) => showAppSheet<PickedBill>(
      context,
      title: context.l10n.billAttach,
      builder: (_) => _AttachSheet(rules: rules, host: context),
    );

class _AttachSheet extends ConsumerStatefulWidget {
  const _AttachSheet({required this.rules, required this.host});

  final BillRules rules;

  /// The screen under the sheet, which shows the upgrade sheet once this one is gone.
  final BuildContext host;

  @override
  ConsumerState<_AttachSheet> createState() => _AttachSheetState();
}

class _AttachSheetState extends ConsumerState<_AttachSheet> {
  String? _error;
  bool _busy = false;

  Future<void> _pick(Future<PickedBill?> Function(BillPicker picker) choose) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final picked = await choose(ref.read(billPickerProvider));
      if (!mounted) return;
      if (picked != null) return Navigator.pop(context, picked);
    } on NotABillException {
      if (mounted) setState(() => _error = context.l10n.billErrorType);
    } on PlatformException {
      // Camera or files refused by the system, or no app to pick with
      if (mounted) setState(() => _error = context.l10n.billErrorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _pdfLocked() {
    final host = widget.host;
    Navigator.pop(context);
    if (host.mounted) {
      showUpgradeSheet(host, refusal: const PlanLimitException(F.storagePdf, reason: PlanLimitException.reasonFeature));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rules = widget.rules;
    final colors = context.colors;
    final language = context.languageCode;
    final room = rules.totalMb == null ? null : (rules.totalMb! * megabyte - rules.usedBytes).clamp(0, 1 << 62);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Entrance(
          index: 0,
          child: _Choice(
            icon: Icons.photo_camera_outlined,
            color: colors.moneyIn,
            title: l10n.billTakePhoto,
            hint: l10n.billTakePhotoHint,
            onTap: _busy ? null : () => _pick((picker) => picker.photo(camera: true)),
          ),
        ),
        Entrance(
          index: 1,
          child: _Choice(
            icon: Icons.photo_library_outlined,
            color: Theme.of(context).colorScheme.primary,
            title: l10n.billChoosePhoto,
            hint: l10n.billChoosePhotoHint,
            onTap: _busy ? null : () => _pick((picker) => picker.photo(camera: false)),
          ),
        ),
        Entrance(
          index: 2,
          child: _Choice(
            icon: Icons.picture_as_pdf_outlined,
            color: const Color(0xFFD93025),
            title: l10n.billChoosePdf,
            hint: l10n.billChoosePdfHint,
            locked: !rules.pdf,
            onTap: _busy ? null : (!rules.pdf ? _pdfLocked : () => _pick((picker) => picker.pdf())),
          ),
        ),
        AnimatedSize(
          duration: context.motion(AppMotion.standard),
          child: _error == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
        ),
        if (rules.known && rules.fileMb != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.md),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: colors.muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [
                      l10n.billPerFile(formatMegabytes(rules.fileMb!, language)),
                      if (room != null) l10n.billRoomLeft(formatBytes(room, language)),
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.color,
    required this.title,
    required this.hint,
    this.onTap,
    this.locked = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String hint;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Material(
        color: context.colors.field,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.md),
            child: Row(
              children: [
                IconBadge(icon, color: locked ? context.colors.muted : color),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.titleSmall),
                      Text(hint, style: text.bodySmall),
                    ],
                  ),
                ),
                if (locked) const LockedTag() else Icon(Icons.chevron_right_rounded, color: context.colors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
