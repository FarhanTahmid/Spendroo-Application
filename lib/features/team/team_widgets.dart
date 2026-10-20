import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/ui.dart';
import 'team_repository.dart';
import 'team_roles.dart';

/// Tints a face can take; each person keeps theirs, picked from their email.
const _faceTints = [
  Color(0xFF3B6FD8),
  Color(0xFF17804A),
  Color(0xFFB7791F),
  Color(0xFF8E4EC6),
  Color(0xFFD9534F),
  Color(0xFF0F8B8D),
  Color(0xFF5B6B84),
];

Color faceTint(String seed) => _faceTints[seed.codeUnits.fold<int>(0, (sum, c) => (sum * 31 + c) & 0x7fffffff) % _faceTints.length];

/// A person's initials on their own tint. With [hero], it flies between the
/// team list and their page.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.seed, required this.initials, this.size = 44, this.hero, this.pending = false});

  /// Picks the tint: the email, usually.
  final String seed;
  final String initials;
  final double size;
  final Object? hero;

  /// An invitation not yet taken up: an outline with a clock, no face yet.
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final tint = faceTint(seed);
    final face = pending
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.field,
              border: Border.all(color: context.colors.muted.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Icon(Icons.schedule_rounded, size: size * 0.45, color: context.colors.muted),
          )
        : Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(tint, Colors.white, 0.18)!, tint],
              ),
            ),
            child: Text(
              initials,
              style: TextStyle(color: Colors.white, fontSize: size * 0.38, fontWeight: FontWeight.w700),
            ),
          );
    return hero == null ? face : Hero(tag: hero!, child: face);
  }
}

/// Overlapping faces: who is in the business, at a glance.
class AvatarStack extends StatelessWidget {
  const AvatarStack({super.key, required this.members, this.size = 34, this.max = 5});

  final List<TeamMember> members;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = members.take(max).toList();
    final extra = members.length - shown.length;
    final step = size * 0.68;
    final count = shown.length + (extra > 0 ? 1 : 0);
    Widget ring(Widget child) => Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.header),
          child: child,
        );
    return SizedBox(
      height: size + 4,
      width: count == 0 ? 0 : step * (count - 1) + size + 4,
      child: Stack(
        children: [
          for (final (index, member) in shown.indexed)
            Positioned(
              left: index * step,
              child: Entrance(index: index, child: ring(MemberAvatar(seed: member.email, initials: member.initials, size: size))),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * step,
              child: ring(
                CircleAvatar(
                  radius: size / 2,
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  child: Text('+$extra', style: TextStyle(color: context.colors.onHeader, fontSize: size * 0.34)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The role as a small coloured pill.
class RoleChip extends StatelessWidget {
  const RoleChip({super.key, required this.role, this.dense = false});

  final String role;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = roleColor(context, role);
    return AnimatedContainer(
      duration: context.motion(AppMotion.standard),
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(roleIcon(role), size: dense ? 13 : 15, color: color),
          const SizedBox(width: 4),
          Text(
            roleLabel(context, role),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// "You" beside one's own name.
class YouTag extends StatelessWidget {
  const YouTag({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(context.l10n.you, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.primary)),
    );
  }
}

/// The seats as a row of pips on the navy header: taken by a member (solid),
/// held by an invitation (ring), or free (faint). They fill in one after the
/// other. A long row or no limit becomes a line of text.
class SeatMeter extends StatelessWidget {
  const SeatMeter({super.key, required this.seats, required this.members});

  final Seats seats;

  /// Members other than the owner; the rest of [Seats.used] are invitations.
  final int members;

  static const _maxPips = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final limit = seats.limit;
    if (!seats.limited || limit == null) {
      return Text(l10n.seatsUnlimited(seats.used), style: text.bodyMedium?.copyWith(color: colors.onHeaderMuted));
    }
    if (limit == 0) {
      return Row(
        children: [
          Icon(Icons.event_seat_outlined, size: 18, color: colors.gold),
          const SizedBox(width: AppSpace.sm),
          Flexible(
            child: Text(
              l10n.seatsNone,
              style: text.titleSmall?.copyWith(color: colors.onHeader),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    final tone = seats.full ? colors.gold : colors.mint;
    final caption = Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: seats.used.toDouble()),
            duration: context.motion(AppMotion.count),
            curve: AppMotion.ease,
            builder: (context, value, _) => Text(
              l10n.seatsUsed(value.round(), limit),
              style: text.titleSmall?.copyWith(color: colors.onHeader, fontFeatures: tabularFigures),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: context.motion(AppMotion.standard),
          child: Text(
            seats.full ? l10n.seatsFull : l10n.seatsLeft(math.max(0, limit - seats.used)),
            key: ValueKey(seats.full),
            style: text.bodySmall?.copyWith(color: tone, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
    if (limit > _maxPips) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [caption, const SizedBox(height: AppSpace.sm), LimitBar(value: seats.share, height: 8)],
      );
    }
    final pending = (seats.used - members).clamp(0, limit);
    final taken = (seats.used - pending).clamp(0, limit);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        caption,
        const SizedBox(height: AppSpace.sm),
        Semantics(
          label: l10n.seatsUsed(seats.used, limit),
          excludeSemantics: true,
          child: Row(
            children: [
              for (var i = 0; i < limit; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: i == limit - 1 ? 0 : 6),
                    child: _Pip(
                      index: i,
                      state: i < taken ? _PipState.taken : (i < taken + pending ? _PipState.held : _PipState.free),
                      color: tone,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _PipState { taken, held, free }

class _Pip extends StatelessWidget {
  const _Pip({required this.index, required this.state, required this.color});

  final int index;
  final _PipState state;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final delay = 0.08 * index;
    return TweenAnimationBuilder<double>(
      key: ValueKey(state),
      tween: Tween(begin: 0, end: 1),
      duration: context.motion(Duration(milliseconds: 320 + (delay * 1000).round())),
      curve: Interval(math.min(delay / (0.32 + delay), 0.9), 1, curve: AppMotion.ease),
      builder: (context, t, _) => Transform.scale(
        scaleY: state == _PipState.free ? 1 : 0.4 + 0.6 * t,
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            color: switch (state) {
              _PipState.taken => Color.lerp(Colors.white.withValues(alpha: 0.14), color, t),
              _PipState.held => color.withValues(alpha: 0.18 * t),
              _PipState.free => Colors.white.withValues(alpha: 0.14),
            },
            border: state == _PipState.held ? Border.all(color: color.withValues(alpha: t), width: 1.5) : null,
          ),
        ),
      ),
    );
  }
}

/// A heading over a group of the team, with how many are in it.
class GroupHeading extends StatelessWidget {
  const GroupHeading({super.key, required this.label, required this.count, this.icon, this.color});

  final String label;
  final int count;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tone = color ?? context.colors.muted;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, AppSpace.lg, 4, AppSpace.sm),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 16, color: tone), const SizedBox(width: 6)],
          Text(label.toUpperCase(), style: text.labelMedium?.copyWith(color: tone, letterSpacing: 0.8, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Text('$count', style: text.labelMedium?.copyWith(color: context.colors.muted)),
        ],
      ),
    );
  }
}
