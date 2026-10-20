import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../features/home_widget/business/biz_widget_targets.dart';
import '../../l10n/app_localizations.dart';
import '../api/api_client.dart';
import '../auth/auth_repository.dart';
import '../db/database.dart';
import '../providers.dart';
import 'push_service.dart';

const notificationPrefsSettingKey = 'notification_prefs';
const pushAskedSettingKey = 'push_asked';

/// What PUT /api/v1/me/devices/ is sent; null without a push address. Also
/// used with no app open, when a widget's choice changed (biz_widget_background.dart).
Future<Map<String, Object?>?> devicePayload(
  PushService service, {
  required String locale,
  BizWidgetTargets? targets,
}) async {
  final token = await service.token();
  if (token == null) return null;
  var version = '';
  try {
    final info = await PackageInfo.fromPlatform();
    version = '${info.version}+${info.buildNumber}';
  } on Object {
    // Not worth failing over
  }
  return {
    'token': token,
    'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
    'locale': locale,
    'timezone': await service.timeZone() ?? '',
    'app_version': version,
    ...?targets?.toJson(),
  };
}

/// What the user wants to be told, as /api/v1/me/notification-settings/ keeps it.
class NotificationPrefs {
  const NotificationPrefs({
    this.pushEnabled = true,
    this.bills = true,
    this.income = true,
    this.recorded = true,
    this.budgets = true,
    this.goals = true,
    this.dailyNudge = true,
    this.nudgeTime = '21:00:00',
    this.reminderTime = '09:00:00',
    this.quietFrom,
    this.quietTo,
  });

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) => NotificationPrefs(
        pushEnabled: json['push_enabled'] as bool? ?? true,
        bills: json['bills'] as bool? ?? true,
        income: json['income'] as bool? ?? true,
        recorded: json['recorded'] as bool? ?? true,
        budgets: json['budgets'] as bool? ?? true,
        goals: json['goals'] as bool? ?? true,
        dailyNudge: json['daily_nudge'] as bool? ?? true,
        nudgeTime: json['nudge_time'] as String? ?? '21:00:00',
        reminderTime: json['reminder_time'] as String? ?? '09:00:00',
        quietFrom: json['quiet_from'] as String?,
        quietTo: json['quiet_to'] as String?,
      );

  /// Everything off or on at once; the switches below it keep what they were set to.
  final bool pushEnabled;

  /// Bills coming up, due and waiting, and plain reminders.
  final bool bills;
  final bool income;

  /// What was recorded by itself, or could not be.
  final bool recorded;
  final bool budgets;

  /// Savings goals: milestones, falling behind, a long spell with nothing put in.
  final bool goals;

  /// "Did you spend anything today?", from the phone itself.
  final bool dailyNudge;

  /// HH:mm:ss, on the user's own clock.
  final String nudgeTime;
  final String reminderTime;

  /// Nothing is pushed between these. Both null: no quiet hours.
  final String? quietFrom;
  final String? quietTo;

  Map<String, dynamic> toJson() => {
        'push_enabled': pushEnabled,
        'bills': bills,
        'income': income,
        'recorded': recorded,
        'budgets': budgets,
        'goals': goals,
        'daily_nudge': dailyNudge,
        'nudge_time': nudgeTime,
        'reminder_time': reminderTime,
        'quiet_from': quietFrom,
        'quiet_to': quietTo,
      };

  NotificationPrefs changed(Map<String, dynamic> changes) => NotificationPrefs.fromJson({...toJson(), ...changes});
}

class PushState {
  const PushState({this.prefs = const NotificationPrefs(), this.allowed = false});

  final NotificationPrefs prefs;

  /// Whether the phone lets the app show notifications at all.
  final bool allowed;

  PushState copyWith({NotificationPrefs? prefs, bool? allowed}) =>
      PushState(prefs: prefs ?? this.prefs, allowed: allowed ?? this.allowed);
}

/// The screen a tapped notification asks for, until the app has gone there.
class PushRoute extends Notifier<String?> {
  /// Only screens a notification has a reason to open
  static const _known = {'/', '/inbox', '/recurring'};

  @override
  String? build() => null;

  void open(String? route) => state = _known.contains(route) ? route : '/inbox';

  /// Screens a home-screen widget button opens (features/home_widget/widget_launch.dart).
  /// The business widgets add a cashbook, its entry form, and a business's book chooser.
  static final _fromWidget = RegExp(r'^(/|/plan|/add|/cashbook/[^/]+|/cashbook/[^/]+/entry|/business/[^/]+/add)$');

  void openFromWidget(String route) {
    if (_fromWidget.hasMatch(Uri.parse(route).path)) state = route;
  }

  void done() => state = null;
}

final pushRouteProvider = NotifierProvider<PushRoute, String?>(PushRoute.new);

/// Keeps the server knowing where this phone is while someone is signed in,
/// shows what arrives, and schedules the daily nudge.
class PushController extends Notifier<PushState> {
  StreamSubscription<String>? _tokens;
  StreamSubscription<bool>? _wroteToday;
  String? _registered;
  bool _loggedToday = false;
  bool _started = false;

  PushService get _service => ref.read(pushServiceProvider);
  ApiClient get _api => ref.read(apiClientProvider);
  AppDatabase get _db => ref.read(databaseProvider);
  bool get _signedIn => ref.read(authControllerProvider).step == AuthStep.signedIn;

  @override
  PushState build() {
    _service.start(onMessage: _arrived, onOpen: _opened);
    _tokens = _service.tokenChanges.listen((_) => register());
    ref.onDispose(() {
      _tokens?.cancel();
      _wroteToday?.cancel();
    });
    // A push is worded in the language the app is shown in
    ref.listen(localeProvider, (_, _) {
      if (!_signedIn) return;
      register();
      _nudge();
    });
    return const PushState();
  }

  /// Someone is signed in, now or since before the app opened. The sign-in
  /// state says so itself (AuthController): listening to it from here would
  /// have the two depend on each other.
  void signedIn() {
    if (_started) return;
    _started = true;
    _start();
  }

  Future<void> _start() async {
    final stored = await _db.getSetting(notificationPrefsSettingKey);
    if (stored != null) {
      try {
        state = state.copyWith(prefs: NotificationPrefs.fromJson((jsonDecode(stored) as Map).cast<String, dynamic>()));
      } on FormatException {
        // Fetched again below
      }
    }
    await refresh();
    await register();
    try {
      final response = await _api.get('/api/v1/me/notification-settings/');
      if (response.ok && response.body is Map) await _keep(NotificationPrefs.fromJson(response.json));
    } on OfflineException {
      // What was stored stands until next time
    }
  }

  /// Back in the app: the permission may have changed in the system's settings, and a new day may have begun.
  Future<void> refresh() async {
    state = state.copyWith(allowed: await _service.allowed());
    _watchToday();
    await _nudge();
  }

  /// Tells the server this phone's address, language, time zone and what its
  /// business widgets show. Safe to call again and again.
  Future<void> register() async {
    if (!_signedIn) return;
    final targets = await ref.read(bizWidgetTargetSourceProvider).read();
    final device = await devicePayload(_service, locale: ref.read(localeProvider).languageCode, targets: targets);
    if (device == null) return;
    try {
      final response = await _api.put('/api/v1/me/devices/', device);
      if (!response.ok) return;
      _registered = device['token'] as String;
      if (targets != null) await _db.setSetting(widgetTargetsSettingKey, targets.fingerprint);
    } on OfflineException {
      // Tried again at the next launch
    }
  }

  /// Before signing out, while the session still answers: this phone stops ringing for the user.
  Future<void> unregister() async {
    final token = _registered ?? await _service.token();
    await signedOut();
    if (token == null) return;
    try {
      await _api.post('/api/v1/me/devices/forget/', {'token': token});
    } on OfflineException {
      // The server forgets the phone when Firebase next says it is gone, or someone else signs in on it
    }
  }

  /// Nobody is signed in any more: nothing of theirs is left to ring here.
  Future<void> signedOut() async {
    _started = false;
    _registered = null;
    await _service.cancelDaily();
    await _wroteToday?.cancel();
    _wroteToday = null;
    state = PushState(allowed: state.allowed);
  }

  /// Asks the system to let the app show notifications. True when it may.
  Future<bool> askPermission() async {
    await _db.setSetting(pushAskedSettingKey, '1');
    final allowed = await _service.ask();
    state = state.copyWith(allowed: allowed);
    if (allowed) {
      await register();
      await _nudge();
    }
    return allowed;
  }

  /// The same, but only the first time on this phone: after that it is the user's to change in Settings.
  Future<void> askOnce() async {
    if (await _db.getSetting(pushAskedSettingKey) != null) return;
    if (await _service.allowed()) {
      state = state.copyWith(allowed: true);
      return;
    }
    await askPermission();
  }

  /// Changes preferences here at once and on the server. False when it could not be saved; nothing changes then.
  Future<bool> update(Map<String, dynamic> changes) async {
    final before = state.prefs;
    state = state.copyWith(prefs: before.changed(changes));
    try {
      final response = await _api.patch('/api/v1/me/notification-settings/', changes);
      if (response.ok && response.body is Map) {
        await _keep(NotificationPrefs.fromJson(response.json));
        return true;
      }
    } on OfflineException {
      // Put back below
    }
    state = state.copyWith(prefs: before);
    return false;
  }

  /// Asks the server to send one to this user's phones. Null when it could not be reached.
  Future<({bool configured, int devices, int sent})?> sendTest() async {
    await register();
    try {
      final response = await _api.post('/api/v1/me/notification-settings/test/');
      if (!response.ok || response.body is! Map) return null;
      final json = response.json;
      return (
        configured: json['configured'] as bool? ?? false,
        devices: json['devices'] as int? ?? 0,
        sent: json['sent'] as int? ?? 0,
      );
    } on OfflineException {
      return null;
    }
  }

  Future<void> _keep(NotificationPrefs prefs) async {
    state = state.copyWith(prefs: prefs);
    await _db.setSetting(notificationPrefsSettingKey, jsonEncode(prefs.toJson()));
    await _nudge();
  }

  void _arrived(PushMessage message) {
    // The system shows nothing while the app is open: the app does, and fetches what it is about
    if (message.title != null) _service.show(message);
    ref.read(syncControllerProvider.notifier).schedule(immediately: true);
  }

  void _opened(Map<String, String> data) {
    ref.read(syncControllerProvider.notifier).schedule(immediately: true);
    ref.read(pushRouteProvider.notifier).open(data['route']);
  }

  /// Whether anything was written down today, kept current: the nudge is for days nothing was.
  void _watchToday() {
    _wroteToday?.cancel();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _wroteToday = _db
        .customSelect(
          'SELECT EXISTS(SELECT 1 FROM transactions WHERE occurred_on = ? AND deleted_at IS NULL) AS found',
          variables: [Variable<String>(today)],
          readsFrom: {_db.transactions},
        )
        .watchSingle()
        .map((row) => row.read<bool>('found'))
        .distinct()
        .listen((found) {
      _loggedToday = found;
      _nudge();
    });
  }

  /// Sets the daily nudge to what the preferences say, skipping today once something is written down.
  Future<void> _nudge() async {
    final prefs = state.prefs;
    if (!_signedIn || !prefs.pushEnabled || !prefs.dailyNudge || !state.allowed) {
      await _service.cancelDaily();
      return;
    }
    final l10n = lookupAppLocalizations(Locale(ref.read(localeProvider).languageCode));
    await _service.scheduleDaily(
      hour: int.parse(prefs.nudgeTime.substring(0, 2)),
      minute: int.parse(prefs.nudgeTime.substring(3, 5)),
      fromTomorrow: _loggedToday,
      title: l10n.nudgeTitle,
      body: l10n.nudgeBody,
    );
  }
}

final pushControllerProvider = NotifierProvider<PushController, PushState>(PushController.new);
