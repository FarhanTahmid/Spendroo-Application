import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/entitlements/entitlements.dart';
import '../../core/ui.dart';
import 'team_repository.dart';
import 'team_roles.dart';
import 'team_widgets.dart';

/// Joining a business with the code someone shared. Once all ten characters
/// are in, the app asks what the code is for and shows it before anything
/// is joined.
class JoinPage extends ConsumerStatefulWidget {
  const JoinPage({super.key});

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  static const _length = 10;

  final _code = TextEditingController();
  InvitePreview? _preview;
  String? _error;
  var _checking = false;
  var _joining = false;
  var _shakes = 0;

  /// The code the last answer was for, so a late answer for an older code is dropped.
  String _asked = '';

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _changed(String value) {
    final clean = normalizeInviteCode(value);
    if (clean == _asked) return;
    setState(() {
      _preview = null;
      _error = null;
    });
    if (clean.length == _length) _look(clean);
  }

  Future<void> _look(String code) async {
    _asked = code;
    setState(() => _checking = true);
    final (preview, error) = await ref.read(teamRepositoryProvider).preview(code);
    if (!mounted || _asked != code) return;
    setState(() {
      _checking = false;
      _preview = preview;
      if (error != null) _fail(error);
    });
    if (preview != null) HapticFeedback.selectionClick();
  }

  void _fail(String error) {
    _error = teamErrorText(context.l10n, error);
    _shakes++;
  }

  Future<void> _join() async {
    final preview = _preview;
    if (preview == null) return;
    setState(() => _joining = true);
    String? error;
    try {
      (_, error) = await ref.read(teamRepositoryProvider).accept(_asked);
    } on PlanLimitException {
      // The business's owner is out of seats: theirs to fix, not this user's plan
      error = TeamError.noSeats;
    }
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _joining = false;
        _fail(error!);
      });
      return;
    }
    showEventBurst(context, AppEvent.saved, label: context.l10n.joinedBusiness(preview.workspaceName));
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final preview = _preview;
    return PassbookScaffold(
      title: Text(l10n.joinBusiness),
      header: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.vpn_key_rounded, color: colors.gold),
          ),
          const SizedBox(width: AppSpace.lg),
          Expanded(child: Text(l10n.joinIntro, style: text.bodyMedium?.copyWith(color: colors.onHeader))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.xl, AppSpace.page, AppSpace.xxl),
        children: [
          Shake(
            trigger: _shakes,
            child: TextField(
              controller: _code,
              autofocus: true,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [_InviteCodeFormatter()],
              onChanged: _changed,
              style: text.headlineSmall?.copyWith(letterSpacing: 4, fontWeight: FontWeight.w700, fontFeatures: tabularFigures),
              decoration: InputDecoration(
                hintText: 'XXXXX-XXXXX',
                hintStyle: text.headlineSmall?.copyWith(letterSpacing: 4, color: colors.muted.withValues(alpha: 0.4)),
                errorText: _error,
                errorMaxLines: 3,
                suffixIcon: _checking
                    ? const Padding(padding: EdgeInsets.all(14), child: AppLoader(size: 6))
                    : preview != null
                        ? Icon(Icons.check_circle_rounded, color: colors.moneyIn)
                        : IconButton(
                            tooltip: l10n.paste,
                            icon: const Icon(Icons.content_paste_rounded),
                            onPressed: () async {
                              final pasted = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
                              final value = _InviteCodeFormatter.format(pasted);
                              _code.value = TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length));
                              _changed(value);
                            },
                          ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(l10n.joinCodeHint, textAlign: TextAlign.center, style: text.bodySmall?.copyWith(color: colors.muted)),
          const SizedBox(height: AppSpace.xl),
          AnimatedSwitcher(
            duration: context.motion(AppMotion.emphasised),
            switchInCurve: AppMotion.spring,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: preview == null
                ? const SizedBox(key: ValueKey('none'), height: 0)
                : _PreviewCard(key: ValueKey(preview.workspaceId), preview: preview, joining: _joining, onJoin: _join),
          ),
        ],
      ),
    );
  }
}

/// What the code leads to, with the button that joins.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({super.key, required this.preview, required this.joining, required this.onJoin});

  final InvitePreview preview;
  final bool joining;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final days = preview.expiresAt.difference(DateTime.now()).inHours / 24;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          children: [
            MemberAvatar(seed: preview.workspaceId, initials: initialsOf(preview.workspaceName), size: 64),
            const SizedBox(height: AppSpace.md),
            Text(preview.workspaceName, style: text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.xs),
            if (preview.invitedBy.isNotEmpty)
              Text(l10n.invitedBy(preview.invitedBy), style: text.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.md),
            RoleChip(role: preview.role),
            const SizedBox(height: AppSpace.sm),
            Text(joinRoleHint(context, preview.role), style: text.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.xl),
            SizedBox(
              width: double.infinity,
              child: BusyButton(label: l10n.joinAs(roleLabel(context, preview.role)), icon: Icons.login_rounded, busy: joining, onPressed: onJoin),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(l10n.inviteExpiresIn(days.ceil().clamp(0, 99)), style: text.bodySmall?.copyWith(color: context.colors.muted)),
          ],
        ),
      ),
    );
  }
}

/// Keeps only the letters a code can have, in capitals, with a dash after
/// the fifth: "abcde fgh23" becomes "ABCDE-FGH23".
class _InviteCodeFormatter extends TextInputFormatter {
  static final _allowed = RegExp('[A-Z0-9]');

  static String format(String raw) {
    final clean = normalizeInviteCode(raw).split('').where(_allowed.hasMatch).take(10).join();
    return formatInviteCode(clean);
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = format(newValue.text);
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
