import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui.dart';

/// The shape of every main screen: a navy field holding the figure that
/// matters, and a pale sheet rising over it with the detail.
class PassbookBody extends StatelessWidget {
  const PassbookBody({super.key, required this.child, this.header});

  /// Sits on the navy field, above the sheet. Null gives just the sheet's rounded top.
  final Widget? header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return EntranceScope(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.header, colors.headerEnd],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                child: IconTheme.merge(
                  data: IconThemeData(color: colors.onHeader),
                  child: DefaultTextStyle.merge(style: TextStyle(color: colors.onHeader), child: header!),
                ),
              )
            else
              const SizedBox(height: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
                child: ColoredBox(color: colors.paper, child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A scaffold whose top bar continues the navy field of a [PassbookBody].
class PassbookScaffold extends StatelessWidget {
  const PassbookScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.header,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? header;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: headerAppBar(context, title: title, actions: actions),
        body: PassbookBody(header: header, child: body),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      );
}

AppBar headerAppBar(BuildContext context, {Widget? title, List<Widget>? actions}) {
  final colors = context.colors;
  return AppBar(
    backgroundColor: colors.header,
    foregroundColor: colors.onHeader,
    titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.onHeader),
    systemOverlayStyle: SystemUiOverlayStyle.light,
    title: title,
    actions: actions,
  );
}

/// The big number on the navy field, under a short label.
class HeaderFigure extends StatelessWidget {
  const HeaderFigure({super.key, required this.label, required this.amountMinor, required this.currency, this.color});

  final String label;
  final int amountMinor;
  final String currency;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.bodyMedium?.copyWith(color: colors.onHeaderMuted)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: MoneyText(
            amountMinor,
            currency,
            style: text.displaySmall?.copyWith(color: color ?? colors.onHeader),
          ),
        ),
      ],
    );
  }
}

/// A smaller labelled figure for the header's second row.
class HeaderStat extends StatelessWidget {
  const HeaderStat({super.key, required this.label, required this.amountMinor, required this.currency, this.color});

  final String label;
  final int amountMinor;
  final String currency;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.bodySmall?.copyWith(color: colors.onHeaderMuted)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: MoneyText(amountMinor, currency, style: text.titleMedium?.copyWith(color: color ?? colors.onHeader)),
          ),
        ],
      ),
    );
  }
}

/// "‹ October 2026 ›" on the navy field: steps a month back or forward.
/// [month] is any day in the month.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({super.key, required this.month, required this.onChanged});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = MaterialLocalizations.of(context).formatMonthYear(month);
    Widget arrow(String tooltip, IconData icon, int step) => IconButton(
          tooltip: tooltip,
          visualDensity: VisualDensity.compact,
          color: colors.onHeader,
          icon: Icon(icon),
          onPressed: () {
            HapticFeedback.selectionClick();
            onChanged(DateTime(month.year, month.month + step));
          },
        );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          arrow(context.l10n.previousMonth, Icons.chevron_left_rounded, -1),
          Expanded(
            child: AnimatedSwitcher(
              duration: context.motion(AppMotion.standard),
              child: Text(
                label,
                key: ValueKey(label),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colors.onHeader),
              ),
            ),
          ),
          arrow(context.l10n.nextMonth, Icons.chevron_right_rounded, 1),
        ],
      ),
    );
  }
}

/// A titled white card: one topic of a screen.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.children, this.title, this.trailing, this.padding});

  final String? title;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: AppSpace.md),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.md),
                  child: Row(
                    children: [
                      Expanded(child: Text(title!, style: Theme.of(context).textTheme.titleMedium)),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ),
              ...children,
            ],
          ),
        ),
      );
}

/// One labelled figure with a small coloured sign, for a row of two or three.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.amountMinor,
    required this.currency,
    required this.color,
    required this.icon,
  });

  final String label;
  final int amountMinor;
  final String currency;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Flexible(child: Text(label, style: text.bodySmall, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: MoneyText(amountMinor, currency, style: text.titleMedium?.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

/// A bar that fills to [value] (0 to 1) when it appears or changes. Green
/// while there is room, gold when close to the limit, red once over it.
class LimitBar extends StatelessWidget {
  const LimitBar({super.key, required this.value, this.marker, this.height = 10});

  /// Spent as a share of the limit; may exceed 1.
  final double value;

  /// Where "today" falls in the period (0 to 1), drawn as a tick.
  final double? marker;
  final double height;

  static Color colorFor(BuildContext context, double value) =>
      value > 1 ? AppTheme.errorColor : (value >= 0.85 ? AppTheme.warningColor : AppTheme.successColor);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: context.motion(const Duration(milliseconds: 450)),
      curve: AppMotion.ease,
      builder: (context, fill, _) => SizedBox(
        height: height + 8,
        child: LayoutBuilder(
          builder: (context, box) => Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
              Container(
                height: height,
                width: box.maxWidth * fill,
                decoration: BoxDecoration(
                  color: colorFor(context, value),
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
              if (marker != null)
                Positioned(
                  left: (box.maxWidth * marker!.clamp(0.0, 1.0) - 1.5).clamp(0.0, box.maxWidth - 3),
                  child: Container(
                    width: 3,
                    height: height + 8,
                    decoration: BoxDecoration(color: scheme.onSurface, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What an empty screen says, and the one thing to do about it.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message, this.actionLabel, this.onAction});

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: context.motion(const Duration(milliseconds: 450)),
              curve: AppMotion.spring,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: Icon(icon, size: 40, color: scheme.primary.withValues(alpha: 0.7)),
              ),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonalIcon(onPressed: onAction, icon: const Icon(Icons.add_rounded), label: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Renders a stream-backed provider: placeholder rows while loading, the error
/// if it fails, and a soft fade to the content when it arrives.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.builder});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: context.motion(AppMotion.standard),
        child: value.when(
          data: (data) => KeyedSubtree(key: const ValueKey('data'), child: builder(data)),
          loading: () => const Align(
            key: ValueKey('loading'),
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 8),
              child: SkeletonList(),
            ),
          ),
          error: (error, _) => Center(
            key: const ValueKey('error'),
            child: Padding(padding: const EdgeInsets.all(24), child: Text('$error', textAlign: TextAlign.center)),
          ),
        ),
      );
}

/// Tappable field that opens a date picker. Dates are ISO strings (yyyy-MM-dd).
class DateField extends StatelessWidget {
  const DateField({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => PickerField(
        label: context.l10n.date,
        text: friendlyDate(context, value),
        icon: Icons.calendar_today_rounded,
        onOpen: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.parse(value),
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) onChanged(picked.toIso8601String().substring(0, 10));
        },
      );
}

/// A ring that fills to [value] (0 to 1) around whatever sits in its middle,
/// usually the percentage it stands for. With [half] it is a gauge: the upper
/// half of the ring, filling from left to right.
class PercentRing extends StatelessWidget {
  const PercentRing({
    super.key,
    required this.value,
    this.size = 44,
    this.stroke = 5,
    this.color,
    this.marker,
    this.half = false,
    this.child,
  });

  /// May exceed 1; the ring is then full.
  final double value;
  final double size;
  final double stroke;

  /// Without one the ring says how close the limit is, as [LimitBar] does.
  final Color? color;

  /// Where "today" falls in the period (0 to 1), drawn as a tick across the ring.
  final double? marker;
  final bool half;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.isFinite ? value.clamp(0.0, 1.0) : 0),
      duration: context.motion(const Duration(milliseconds: 600)),
      curve: AppMotion.ease,
      builder: (context, fill, child) => CustomPaint(
        painter: _RingPainter(
          fill: fill,
          stroke: stroke,
          color: color ?? LimitBar.colorFor(context, value),
          track: scheme.surfaceContainerHighest,
          marker: marker,
          markerColor: scheme.onSurface,
          half: half,
        ),
        child: child,
      ),
      child: SizedBox(
        width: size,
        height: half ? size / 2 + stroke / 2 : size,
        child: child == null
            ? null
            : Align(
                alignment: half ? Alignment.bottomCenter : Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: stroke + 3),
                  child: FittedBox(fit: BoxFit.scaleDown, child: child),
                ),
              ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fill,
    required this.stroke,
    required this.color,
    required this.track,
    required this.marker,
    required this.markerColor,
    required this.half,
  });

  final double fill;
  final double stroke;
  final Color color;
  final Color track;
  final double? marker;
  final Color markerColor;
  final bool half;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - stroke / 2;
    final centre = Offset(size.width / 2, half ? size.height - stroke / 2 : size.height / 2);
    final rect = Rect.fromCircle(center: centre, radius: radius);
    final start = half ? math.pi : -math.pi / 2;
    final whole = half ? math.pi : 2 * math.pi;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, whole, false, paint..color = track);
    if (fill > 0) canvas.drawArc(rect, start, whole * fill, false, paint..color = color);
    final at = marker;
    if (at != null) {
      final angle = start + whole * at.clamp(0.0, 1.0);
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        centre + direction * (radius - stroke / 2 - 3),
        centre + direction * (radius + stroke / 2 + 3),
        Paint()
          ..color = markerColor
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fill != fill || old.color != color || old.track != track || old.marker != marker || old.markerColor != markerColor;
}

/// A small fact under a chart: what it is, and the figure. Goes in a row of two or three;
/// with [onTap] it opens what the figure is made of.
class FactTile extends StatelessWidget {
  const FactTile({super.key, required this.label, required this.value, this.detail, this.color, this.onTap});

  final String label;
  final String value;
  final String? detail;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    return Expanded(
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(AppRadius.control)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(label, style: text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (onTap != null) Icon(Icons.chevron_right_rounded, size: 14, color: colors.muted),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: text.titleSmall?.copyWith(color: color, fontFeatures: tabularFigures),
                ),
              ),
              if (detail != null)
                Text(detail!, style: text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// [FactTile]s side by side, all as tall as the tallest.
class FactRow extends StatelessWidget {
  const FactRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );
}

/// A coloured key and what it stands for, under a chart.
class LegendKey extends StatelessWidget {
  const LegendKey({super.key, required this.color, required this.label, this.dashed = false});

  final Color color;
  final String label;

  /// Drawn as a broken line rather than a block: a reference line, not a series of bars.
  final bool dashed;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dashed)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(width: 4, height: 2, margin: const EdgeInsets.only(right: 2), color: color),
              ],
            )
          else
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
        ],
      );
}
