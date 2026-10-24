import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/ui.dart';
import 'bill_repository.dart';
import 'bill_text.dart';
import 'bill_widgets.dart';

/// Opens [bills] full screen at [initial]. The tile's picture flies into
/// place. Returns the bill the person chose to remove, if any: the caller
/// removes it, since a bill not saved yet goes differently from a stored one.
Future<BillView?> openBillViewer(
  BuildContext context, {
  required List<BillView> bills,
  required int initial,
  bool canRemove = false,
}) =>
    Navigator.of(context).push<BillView>(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: context.motion(AppMotion.emphasised),
      reverseTransitionDuration: context.motion(AppMotion.standard),
      pageBuilder: (_, _, _) => BillViewerPage(bills: bills, initial: initial, canRemove: canRemove),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: CurvedAnimation(parent: animation, curve: AppMotion.ease), child: child),
    ));

class BillViewerPage extends ConsumerStatefulWidget {
  const BillViewerPage({super.key, required this.bills, this.initial = 0, this.canRemove = false});

  final List<BillView> bills;
  final int initial;
  final bool canRemove;

  @override
  ConsumerState<BillViewerPage> createState() => _BillViewerPageState();
}

class _BillViewerPageState extends ConsumerState<BillViewerPage> {
  late final _pages = PageController(initialPage: widget.initial);
  late int _index = widget.initial;

  /// The bars come and go with a tap, out of the way of the bill.
  bool _chrome = true;

  /// How far a photo has been pulled down to close the viewer.
  double _drag = 0;

  /// A zoomed photo pans instead of paging or closing.
  bool _zoomed = false;

  BillView get _bill => widget.bills[_index];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<File?> _file() async {
    try {
      return await ref.read(billFileProvider(_bill).future);
    } on BillUnavailable catch (problem) {
      if (!mounted) return null;
      final words = BillWording(context.l10n, receipt: _bill.receipt);
      context.showMessage(problem.offline ? words.openOffline : words.gone);
      return null;
    }
  }

  Future<void> _share() async {
    final file = await _file();
    if (file == null) return;
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], subject: _bill.originalName));
  }

  Future<void> _openElsewhere() async {
    final file = await _file();
    if (file != null) await OpenFilex.open(file.path);
  }

  Future<void> _remove() async {
    if (!await confirm(context, BillWording(context.l10n, receipt: _bill.receipt).removeConfirm)) return;
    if (mounted) Navigator.pop(context, _bill);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final words = BillWording(l10n, receipt: _bill.receipt);
    final total = widget.bills.length;
    final fade = (1 - (_drag.abs() / 400)).clamp(0.0, 1.0);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: fade),
        body: Stack(
          children: [
            GestureDetector(
              onTap: () => setState(() => _chrome = !_chrome),
              onVerticalDragUpdate: _zoomed || _bill.isPdf ? null : (d) => setState(() => _drag += d.delta.dy),
              onVerticalDragEnd: _zoomed || _bill.isPdf
                  ? null
                  : (d) {
                      if (_drag.abs() > 120 || d.velocity.pixelsPerSecond.dy.abs() > 900) {
                        Navigator.pop(context);
                      } else {
                        setState(() => _drag = 0);
                      }
                    },
              child: AnimatedContainer(
                duration: _drag == 0 ? context.motion(AppMotion.standard) : Duration.zero,
                curve: AppMotion.ease,
                transform: Matrix4.translationValues(0, _drag, 0),
                child: PageView.builder(
                  controller: _pages,
                  physics: _zoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
                  itemCount: total,
                  onPageChanged: (index) => setState(() {
                    _index = index;
                    _zoomed = false;
                  }),
                  itemBuilder: (context, index) => _BillPage(
                    bill: widget.bills[index],
                    onZoom: (zoomed) {
                      if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
                    },
                  ),
                ),
              ),
            ),
            // Top bar: close, where we are, and what can be done with the bill
            AnimatedPositioned(
              duration: context.motion(AppMotion.standard),
              curve: AppMotion.ease,
              top: _chrome && _drag == 0 ? 0 : -120,
              left: 0,
              right: 0,
              child: _Bar(
                top: true,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _bill.originalName.isEmpty ? words.title : _bill.originalName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          if (total > 1)
                            Text(l10n.billOf(_index + 1, total),
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.billShare,
                      icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
                      onPressed: _share,
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                      onSelected: (action) => action == 'open' ? _openElsewhere() : _remove(),
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'open', child: Text(l10n.billOpenElsewhere)),
                        if (widget.canRemove)
                          PopupMenuItem(
                            value: 'remove',
                            child: Text(words.remove, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Bottom: size, pages, and dots to show there is more to swipe to
            AnimatedPositioned(
              duration: context.motion(AppMotion.standard),
              curve: AppMotion.ease,
              bottom: _chrome && _drag == 0 ? 0 : -120,
              left: 0,
              right: 0,
              child: _Bar(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          [
                            if (_bill.sizeBytes > 0) formatBytes(_bill.sizeBytes, context.languageCode),
                            if (_bill.pageCount != null) l10n.billPages(_bill.pageCount!),
                            if (_bill.status == BillStatus.waiting) l10n.billWaiting,
                            if (_bill.status == BillStatus.staged) l10n.billStaged,
                          ].join(' · '),
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                      if (total > 1)
                        Row(
                          children: [
                            for (var i = 0; i < total; i++)
                              AnimatedContainer(
                                duration: context.motion(AppMotion.standard),
                                margin: const EdgeInsets.only(left: 5),
                                width: i == _index ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: i == _index ? Colors.white : Colors.white38,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A soft gradient behind the bars, so white text reads on any bill.
class _Bar extends StatelessWidget {
  const _Bar({required this.top, required this.child});

  final bool top;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: top ? Alignment.topCenter : Alignment.bottomCenter,
            end: top ? Alignment.bottomCenter : Alignment.topCenter,
            colors: const [Color(0xCC000000), Color(0x00000000)],
          ),
        ),
        child: SafeArea(top: top, bottom: !top, child: child),
      );
}

/// One bill, full size: a photo to pinch and double-tap, or a PDF to scroll.
class _BillPage extends ConsumerStatefulWidget {
  const _BillPage({required this.bill, required this.onZoom});

  final BillView bill;
  final ValueChanged<bool> onZoom;

  @override
  ConsumerState<_BillPage> createState() => _BillPageState();
}

class _BillPageState extends ConsumerState<_BillPage> with SingleTickerProviderStateMixin {
  final _zoom = TransformationController();
  late final _animator = AnimationController(vsync: this, duration: AppMotion.emphasised)
    ..addListener(() => _zoom.value = _animation!.value);
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTap;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(() => widget.onZoom(_zoom.value.getMaxScaleOnAxis() > 1.01));
  }

  @override
  void dispose() {
    _animator.dispose();
    _zoom.dispose();
    super.dispose();
  }

  /// Double tap: in to where the finger was, or back out.
  void _toggleZoom() {
    final zoomedIn = _zoom.value.getMaxScaleOnAxis() > 1.01;
    final point = _doubleTap?.localPosition ?? Offset.zero;
    const scale = 2.6;
    final target = zoomedIn
        ? Matrix4.identity()
        : (Matrix4.identity()
          ..translateByDouble(-point.dx * (scale - 1), -point.dy * (scale - 1), 0, 1)
          ..scaleByDouble(scale, scale, 1, 1));
    _animation = Matrix4Tween(begin: _zoom.value, end: target)
        .animate(CurvedAnimation(parent: _animator, curve: AppMotion.ease));
    _animator
      ..duration = context.motion(AppMotion.emphasised)
      ..forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final file = ref.watch(billFileProvider(bill));
    // Fetched now: the tile's first-page preview can draw from it too
    ref.listen(billFileProvider(bill), (_, next) {
      if (next.hasValue) ref.invalidate(billLocalFileProvider(bill));
    });
    return switch (file) {
      AsyncData(:final value) when bill.isPdf => SafeArea(
          child: PdfViewer.file(
            value.path,
            params: PdfViewerParams(
              backgroundColor: Colors.black,
              margin: 12,
              loadingBannerBuilder: (context, bytesDownloaded, totalBytes) =>
                  const Center(child: AppLoader(color: Colors.white)),
            ),
          ),
        ),
      AsyncData(:final value) => GestureDetector(
          onDoubleTapDown: (details) => _doubleTap = details,
          onDoubleTap: _toggleZoom,
          child: InteractiveViewer(
            transformationController: _zoom,
            maxScale: 5,
            child: Center(
              child: Hero(
                tag: bill.heroTag,
                child: Image.file(value, fit: BoxFit.contain, gaplessPlayback: true),
              ),
            ),
          ),
        ),
      AsyncError(:final error) => _Problem(
          message: error is BillUnavailable && error.offline
              ? BillWording(context.l10n, receipt: bill.receipt).openOffline
              : BillWording(context.l10n, receipt: bill.receipt).openFailed,
          onRetry: () => ref.invalidate(billFileProvider(bill)),
        ),
      // While it downloads: the thumbnail, already on screen, holds the place
      _ => Center(
          child: Hero(
            tag: bill.heroTag,
            child: SizedBox(
              width: 220,
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(AppRadius.control), child: BillPreview(bill: bill)),
                  const Center(child: AppLoader(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
    };
  }
}

class _Problem extends StatelessWidget {
  const _Problem({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: Colors.white54, size: 48),
              const SizedBox(height: AppSpace.md),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: AppSpace.lg),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38)),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.l10n.billRetry),
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      );
}
