import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/push/push_controller.dart';
import '../../core/ui.dart';

/// What to be told by push, and at what hours. Kept on the server, so every
/// phone the user signs in on follows it; the permission itself is this phone's.
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  late final AppLifecycleListener _lifecycle;
  var _testing = false;

  PushController get _push => ref.read(pushControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    // Back from the phone's own settings, where the permission may have been changed
    _lifecycle = AppLifecycleListener(onResume: () => _push.refresh());
    WidgetsBinding.instance.addPostFrameCallback((_) => _push.refresh());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _set(Map<String, dynamic> changes) async {
    final saved = await _push.update(changes);
    if (mounted && !saved) context.showMessage(context.l10n.needsConnection);
  }

  Future<void> _test() async {
    final l10n = context.l10n;
    setState(() => _testing = true);
    final result = await _push.sendTest();
    if (!mounted) return;
    setState(() => _testing = false);
    context.showMessage(switch (result) {
      null => l10n.needsConnection,
      (configured: false, devices: _, sent: _) => l10n.notifTestNotSetUp,
      (configured: _, devices: 0, sent: _) => l10n.notifTestNoDevice,
      (configured: _, devices: _, sent: 0) => l10n.notifTestFailed,
      _ => l10n.notifTestSent,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final state = ref.watch(pushControllerProvider);
    final prefs = state.prefs;
    final on = prefs.pushEnabled;
    const gap = SizedBox(height: 10);

    Widget time(String key, String label, String? value) => _TimePicker(
          key: Key('notif-$key'),
          label: label,
          value: value,
          onChanged: (picked) => _set({key: picked}),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.lg, AppSpace.page, AppSpace.xl),
        children: [
          if (!state.allowed)
            SectionCard(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IconBadge(Icons.notifications_off_outlined, color: AppTheme.errorColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.notifBlocked, style: text.bodyLarge),
                          const SizedBox(height: 4),
                          Text(l10n.notifBlockedHint, style: text.bodySmall?.copyWith(color: context.colors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _push.askPermission, child: Text(l10n.notifAllow)),
              ],
            ),
          SectionCard(
            children: [
              SwitchField(
                key: const Key('notif-push_enabled'),
                title: l10n.notifPush,
                subtitle: l10n.notifPushHint,
                value: on,
                onChanged: (value) => _set({'push_enabled': value}),
              ),
            ],
          ),
          SectionCard(
            title: l10n.notifWhat,
            children: [
              for (final (key, title, hint, value) in [
                ('bills', l10n.notifBills, l10n.notifBillsHint, prefs.bills),
                ('income', l10n.notifIncome, null, prefs.income),
                ('recorded', l10n.notifRecorded, l10n.notifRecordedHint, prefs.recorded),
                ('budgets', l10n.notifBudgets, l10n.notifBudgetsHint, prefs.budgets),
                ('daily_nudge', l10n.notifNudge, l10n.notifNudgeHint, prefs.dailyNudge),
              ]) ...[
                SwitchField(
                  key: Key('notif-$key'),
                  title: title,
                  subtitle: hint,
                  value: on && value,
                  onChanged: on ? (next) => _set({key: next}) : null,
                ),
                gap,
              ],
              if (on && prefs.dailyNudge) time('nudge_time', l10n.notifNudgeTime, prefs.nudgeTime),
            ],
          ),
          SectionCard(
            title: l10n.notifWhen,
            children: [
              time('reminder_time', l10n.notifReminderTime, prefs.reminderTime),
              const SizedBox(height: 6),
              Text(l10n.notifReminderTimeHint, style: text.bodySmall?.copyWith(color: context.colors.muted)),
              const SizedBox(height: 14),
              SwitchField(
                key: const Key('notif-quiet'),
                title: l10n.notifQuiet,
                subtitle: l10n.notifQuietHint,
                value: prefs.quietFrom != null,
                onChanged: (value) => _set(
                  value
                      ? {'quiet_from': '22:00:00', 'quiet_to': '07:00:00'}
                      : {'quiet_from': null, 'quiet_to': null},
                ),
              ),
              if (prefs.quietFrom != null) ...[
                gap,
                Row(
                  children: [
                    Expanded(child: time('quiet_from', l10n.notifQuietFrom, prefs.quietFrom)),
                    const SizedBox(width: 8),
                    Expanded(child: time('quiet_to', l10n.notifQuietTo, prefs.quietTo)),
                  ],
                ),
              ],
            ],
          ),
          OutlinedButton.icon(
            onPressed: _testing ? null : _test,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(l10n.notifTest),
          ),
        ],
      ),
    );
  }
}

/// A time of day, held as HH:mm:ss the way the server sends it.
class _TimePicker extends StatelessWidget {
  const _TimePicker({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final at = value == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay(hour: int.parse(value!.substring(0, 2)), minute: int.parse(value!.substring(3, 5)));
    return PickerField(
      label: label,
      icon: Icons.schedule_rounded,
      text: at.format(context),
      onOpen: () async {
        final picked = await showTimePicker(context: context, initialTime: at);
        if (picked != null) {
          onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00');
        }
      },
    );
  }
}
