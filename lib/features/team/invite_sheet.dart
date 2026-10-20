import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/ui.dart';
import 'team_repository.dart';
import 'team_roles.dart';

/// Invites someone by email or phone, then shows the code to pass on. Returns
/// the plan's refusal when the seats ran out, for the caller to explain once
/// the sheet is gone.
Future<PlanLimitException?> showInviteSheet(BuildContext context, {required Workspace workspace, Seats? seats}) =>
    showAppSheet<PlanLimitException>(
      context,
      builder: (_) => _InviteSheet(workspace: workspace, seats: seats),
    );

enum _Channel { email, phone }

class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet({required this.workspace, this.seats});

  final Workspace workspace;
  final Seats? seats;

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final _contact = TextEditingController();
  var _channel = _Channel.email;
  var _role = TeamRole.staff;
  var _busy = false;
  String? _error;
  var _shakes = 0;
  NewInvite? _sent;

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  String? _check(String value) {
    final l10n = context.l10n;
    if (value.isEmpty) return _channel == _Channel.email ? l10n.inviteEmailNeeded : l10n.invitePhoneNeeded;
    if (_channel == _Channel.email && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) return l10n.inviteEmailInvalid;
    if (_channel == _Channel.phone && value.replaceAll(RegExp(r'\D'), '').length < 6) return l10n.invitePhoneInvalid;
    return null;
  }

  Future<void> _send() async {
    final value = _contact.text.trim();
    final problem = _check(value);
    if (problem != null) {
      setState(() {
        _error = problem;
        _shakes++;
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final (sent, error) = await ref.read(teamRepositoryProvider).invite(
            widget.workspace.id,
            role: _role,
            email: _channel == _Channel.email ? value : null,
            phone: _channel == _Channel.phone ? value : null,
          );
      if (!mounted) return;
      if (sent == null) {
        setState(() {
          _busy = false;
          _error = teamErrorText(context.l10n, error!);
          _shakes++;
        });
        return;
      }
      showEventBurst(context, AppEvent.saved);
      setState(() {
        _busy = false;
        _sent = sent;
      });
    } on PlanLimitException catch (refusal) {
      if (mounted) Navigator.pop(context, refusal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sent = _sent;
    return AnimatedSize(
      duration: context.motion(AppMotion.emphasised),
      curve: AppMotion.ease,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: context.motion(AppMotion.emphasised),
        switchInCurve: AppMotion.ease,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(animation), child: child),
        ),
        child: sent == null ? _form(context) : _InviteTicket(key: const ValueKey('ticket'), workspace: widget.workspace, sent: sent),
      ),
    );
  }

  Widget _form(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final seats = widget.seats;
    final roles = TeamRole.assignable(widget.workspace.role);
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.inviteTitle(widget.workspace.name), style: text.titleLarge),
        const SizedBox(height: AppSpace.xs),
        Text(l10n.inviteIntro, style: text.bodySmall),
        const SizedBox(height: AppSpace.lg),
        SlidingSegmented<_Channel>(
          segments: {_Channel.email: l10n.email, _Channel.phone: l10n.phone},
          value: _channel,
          onChanged: (channel) => setState(() {
            _channel = channel;
            _error = null;
            _contact.clear();
          }),
        ),
        const SizedBox(height: AppSpace.md),
        Shake(
          trigger: _shakes,
          child: TextField(
            key: ValueKey(_channel),
            controller: _contact,
            autofocus: true,
            keyboardType: _channel == _Channel.email ? TextInputType.emailAddress : TextInputType.phone,
            autofillHints: [_channel == _Channel.email ? AutofillHints.email : AutofillHints.telephoneNumber],
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _send(),
            decoration: InputDecoration(
              labelText: _channel == _Channel.email ? l10n.email : l10n.phone,
              hintText: _channel == _Channel.email ? l10n.inviteEmailHint : l10n.invitePhoneHint,
              prefixIcon: Icon(_channel == _Channel.email ? Icons.alternate_email_rounded : Icons.phone_iphone_rounded),
              errorText: _error,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.xs),
        AnimatedSwitcher(
          duration: context.motion(AppMotion.standard),
          child: Text(
            _channel == _Channel.email ? l10n.inviteByEmailNote : l10n.inviteByPhoneNote,
            key: ValueKey(_channel),
            style: text.bodySmall?.copyWith(color: context.colors.muted),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        Text(l10n.inviteAs, style: text.titleSmall),
        const SizedBox(height: AppSpace.sm),
        for (final role in roles)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: RoleOption(role: role, selected: role == _role, onTap: () => setState(() => _role = role)),
          ),
        if (seats != null && seats.limited) ...[
          const SizedBox(height: AppSpace.xs),
          Row(
            children: [
              Icon(Icons.event_seat_outlined, size: 16, color: context.colors.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.inviteUsesSeat(seats.used + 1, seats.limit!),
                  style: text.bodySmall?.copyWith(color: context.colors.muted),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpace.lg),
        BusyButton(
          label: _channel == _Channel.email ? l10n.inviteSend : l10n.inviteMakeCode,
          icon: _channel == _Channel.email ? Icons.send_rounded : Icons.confirmation_number_outlined,
          busy: _busy,
          onPressed: _send,
        ),
      ],
    );
  }
}

/// A role to pick: its colour, name and what it allows, ringed when chosen.
class RoleOption extends StatelessWidget {
  const RoleOption({super.key, required this.role, required this.selected, required this.onTap, this.enabled = true});

  final String role;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = roleColor(context, role);
    final text = Theme.of(context).textTheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        child: AnimatedContainer(
          duration: context.motion(AppMotion.standard),
          curve: AppMotion.ease,
          padding: const EdgeInsets.all(AppSpace.md),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.08) : context.colors.field,
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
          ),
          child: Row(
            children: [
              IconBadge(roleIcon(role), color: color),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(roleLabel(context, role), style: text.titleSmall),
                    Text(roleHint(context, role), style: text.bodySmall),
                  ],
                ),
              ),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: context.motion(AppMotion.standard),
                curve: AppMotion.spring,
                child: Icon(Icons.check_circle_rounded, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The invitation as a ticket: the code big enough to read out, and the ways
/// to pass it on. The server shows the code only this once.
class _InviteTicket extends StatelessWidget {
  const _InviteTicket({super.key, required this.workspace, required this.sent});

  final Workspace workspace;
  final NewInvite sent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final code = formatInviteCode(sent.code);
    final message = l10n.inviteShareText(workspace.name, code);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipPath(
          clipper: const _TicketClipper(),
          child: Container(
            padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.xl, AppSpace.xl, AppSpace.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colors.header, colors.headerEnd]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.confirmation_number_rounded, color: colors.gold, size: 20),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        l10n.inviteTicketTitle(workspace.name),
                        style: text.titleSmall?.copyWith(color: colors.onHeader),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  '${sent.invite.contact} · ${roleLabel(context, sent.invite.role)}',
                  style: text.bodySmall?.copyWith(color: colors.onHeaderMuted),
                ),
                const SizedBox(height: AppSpace.xl),
                Center(child: _CodeReveal(code: code)),
                const SizedBox(height: AppSpace.xl),
                // The tear line
                Row(
                  children: [
                    for (var i = 0; i < 24; i++)
                      Expanded(
                        child: Container(
                          height: 1.5,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          color: i.isEven ? colors.onHeaderMuted.withValues(alpha: 0.4) : Colors.transparent,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                Row(
                  children: [
                    Icon(sent.emailed ? Icons.mark_email_read_outlined : Icons.info_outline_rounded, size: 16, color: colors.mint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        sent.emailed ? l10n.inviteEmailed(sent.invite.email) : l10n.inviteShareOnce,
                        style: text.bodySmall?.copyWith(color: colors.onHeader),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                Text(l10n.inviteValidDays(7), style: text.bodySmall?.copyWith(color: colors.onHeaderMuted)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  HapticFeedback.lightImpact();
                  if (context.mounted) context.showMessage(l10n.codeCopied);
                },
                icon: const Icon(Icons.copy_rounded),
                label: Text(l10n.copy),
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => SharePlus.instance.share(ShareParams(text: message, subject: l10n.inviteTicketTitle(workspace.name))),
                icon: const Icon(Icons.ios_share_rounded),
                label: Text(l10n.share),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.doneIt)),
      ],
    );
  }
}

/// The code's letters land one after another.
class _CodeReveal extends StatelessWidget {
  const _CodeReveal({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: context.colors.onHeader,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          fontFeatures: tabularFigures,
        );
    return Semantics(
      label: code.split('').join(' '),
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, letter) in code.split('').indexed)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: context.motion(Duration(milliseconds: 260 + 45 * i)),
                curve: Interval((45 * i) / (260 + 45 * i), 1, curve: AppMotion.ease),
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
                ),
                child: Text(letter, style: letter == '-' ? style?.copyWith(color: context.colors.gold) : style),
              ),
          ],
        ),
      ),
    );
  }
}

/// Rounded corners with a bite out of each side, where a ticket tears.
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();

  @override
  Path getClip(Size size) {
    const radius = AppRadius.card;
    const notch = 12.0;
    // The bites sit at the tear line, a little above the bottom
    final y = size.height - 76;
    return Path.combine(
      PathOperation.difference,
      Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(radius))),
      Path()
        ..addOval(Rect.fromCircle(center: Offset(0, y), radius: notch))
        ..addOval(Rect.fromCircle(center: Offset(size.width, y), radius: notch)),
    );
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) => false;
}
