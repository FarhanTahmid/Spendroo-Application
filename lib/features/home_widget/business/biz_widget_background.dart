import 'dart:async';
import 'dart:ui' show DartPluginRegistrant;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/config.dart';
import '../../../core/db/database.dart';
import '../../../core/db/local_store.dart';
import '../../../core/entitlements/entitlements.dart';
import '../../../core/entitlements/entitlements_controller.dart';
import '../../../core/firebase.dart';
import '../../../core/providers.dart';
import '../../../core/push/push_controller.dart' show devicePayload;
import '../../../core/push/push_service.dart';
import '../../../core/sync/sync_engine.dart';
import 'biz_snapshot.dart';
import 'biz_widget_controller.dart';
import 'biz_widget_providers.dart';
import 'biz_widget_targets.dart';

/// A silent push from the server (notifications/widgets.py): a teammate
/// changed something in [workspaceId], whose changes now go up to [seq].
class WidgetPing {
  const WidgetPing(this.workspaceId, this.seq);

  static const kind = 'widgets';

  final String workspaceId;
  final int seq;

  static WidgetPing? from(Map<String, dynamic> data) {
    final workspace = data['workspace_id'];
    final seq = int.tryParse('${data['seq']}');
    if (data['kind'] != kind || workspace is! String || seq == null) return null;
    return WidgetPing(workspace, seq);
  }
}

/// How a run with no app open ended; written to the log.
enum BizRefreshOutcome {
  signedOut,

  /// No widget here shows that business or its books.
  notShown,

  /// This phone already has those changes, as when it made them itself.
  upToDate,
  offline,

  /// The session was refused. The app signs out when it next opens; nothing is wiped from here.
  sessionEnded,
  redrawn,

  /// The widgets' choices were told to the server, or were already known there.
  targetsReported,
}

/// What a widget does with no app open: on a silent push, pull that one
/// business and redraw its widgets; when a widget's choice changed, tell the
/// server. Plain objects, so tests can drive it.
class BizWidgetRefresher {
  BizWidgetRefresher({
    required this.db,
    required this.api,
    required this.bridge,
    required this.targets,
    required this.device,
  });

  final AppDatabase db;
  final ApiClient api;
  final BizWidgetBridge bridge;
  final BizWidgetTargetSource targets;

  /// What PUT /api/v1/me/devices/ is sent with these targets; null without a push address.
  final Future<Map<String, Object?>?> Function(BizWidgetTargets targets, String locale) device;

  /// How long the widgets may wait for the books to be read.
  static const readTimeout = Duration(seconds: 10);

  Future<BizRefreshOutcome> onPing(WidgetPing ping) async {
    // Everything up to the pull is on the phone: most pings end here without the network
    if (!await _signedIn()) return BizRefreshOutcome.signedOut;
    final shown = await targets.read();
    if (shown != null) {
      final books = BizWidgetTargets.bookBusinessOf(await bridge.read(BizKeys.catalog));
      if (!shown.shows(ping.workspaceId, books)) return BizRefreshOutcome.notShown;
    }
    final engine = SyncEngine(db, api, LocalStore(db));
    if (await engine.cursorOf(ping.workspaceId) >= ping.seq) return BizRefreshOutcome.upToDate;
    try {
      await engine.pullWorkspace(ping.workspaceId);
    } on SessionExpiredException {
      return BizRefreshOutcome.sessionEnded;
    } on OfflineException {
      return BizRefreshOutcome.offline;
    } on SyncException {
      return BizRefreshOutcome.offline;
    }
    await redraw(workspaceId: ping.workspaceId);
    return BizRefreshOutcome.redrawn;
  }

  /// A widget was given a business or book, or removed: the server learns
  /// which changes this phone wants to hear of. Only when that differs from
  /// what it was last told.
  Future<BizRefreshOutcome> reportTargets() async {
    if (!await _signedIn()) return BizRefreshOutcome.signedOut;
    final shown = await targets.read();
    if (shown == null || shown.fingerprint == await db.getSetting(widgetTargetsSettingKey)) {
      return BizRefreshOutcome.targetsReported;
    }
    final payload = await device(shown, await db.getSetting(localeSettingKey) ?? 'en');
    if (payload == null) return BizRefreshOutcome.offline;
    try {
      final response = await api.put('/api/v1/me/devices/', payload);
      if (response.statusCode == 401 || response.statusCode == 403) return BizRefreshOutcome.sessionEnded;
      if (!response.ok) return BizRefreshOutcome.offline;
    } on OfflineException {
      return BizRefreshOutcome.offline;
    }
    await db.setSetting(widgetTargetsSettingKey, shown.fingerprint);
    return BizRefreshOutcome.targetsReported;
  }

  /// Rebuilds what the widgets show from the phone's books, as the open app
  /// would, and writes the catalog and the snapshots of [workspaceId].
  Future<void> redraw({required String workspaceId}) async {
    final locale = Locale(await db.getSetting(localeSettingKey) ?? 'en');
    // Month and day names: the open app loads them with its localizations, this isolate has none
    await initializeDateFormatting(locale.languageCode);
    final stored = await db.getSetting(entitlementsSettingKey);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(api),
        authControllerProvider.overrideWith(_SignedIn.new),
        entitlementsProvider.overrideWith(() => _StoredEntitlements(stored == null ? null : Entitlements.decode(stored))),
        localeProvider.overrideWith(() => _FixedLocale(locale)),
        bizWidgetBridgeProvider.overrideWithValue(bridge),
      ],
    );
    try {
      final ready = Completer<BizPublication>();
      container.listen<BizPublication?>(
        bizWidgetPublicationProvider,
        (_, next) {
          if (next != null && !ready.isCompleted) ready.complete(next);
        },
        fireImmediately: true,
      );
      final publication = await ready.future.timeout(readTimeout);
      final keys = {
        for (final MapEntry(:key, :value) in publication.snapshots.entries)
          if (value.workspaceId == workspaceId) key,
      };
      await BizWidgetPublisher(bridge).publish(publication, locale, only: keys);
    } finally {
      container.dispose();
    }
  }

  Future<bool> _signedIn() async =>
      await db.getSetting(authStepSettingKey) == AuthStep.signedIn.name && await api.tokenStore.read() != null;
}

/// Signed in, as the stored step says; checked with the server only when the app opens.
class _SignedIn extends AuthController {
  @override
  AuthState build() => const AuthState(AuthStep.signedIn);
}

/// The plan as last stored; never asked of the server from here.
class _StoredEntitlements extends EntitlementsController {
  _StoredEntitlements(this.plan);

  final Entitlements? plan;

  @override
  Future<Entitlements?> build() async => plan;
}

class _FixedLocale extends LocaleController {
  _FixedLocale(this.locale);

  final Locale locale;

  @override
  Locale build() => locale;
}

/// Firebase calls this in an isolate of its own for a push that arrives while
/// the app is not in front. Only the widgets' silent push is acted on; a
/// notification is shown by the system without it.
@pragma('vm:entry-point')
Future<void> bizWidgetPushHandler(RemoteMessage message) async {
  final ping = WidgetPing.from(message.data);
  if (ping == null) return;
  await _headless('push', (refresher) => refresher.onPing(ping));
}

/// home_widget calls this, also in an isolate of its own, when the picker
/// (WidgetPickerActivity.kt) gave a widget its business or book, or a widget was removed.
@pragma('vm:entry-point')
Future<void> bizWidgetCallback(Uri? uri) async {
  if (uri?.host != 'targets') return;
  await _headless('targets', (refresher) => refresher.reportTargets());
}

/// Lets the widget picker reach [bizWidgetCallback]. Android only; never stops the app.
Future<void> registerBizWidgetCallback() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await HomeWidget.registerInteractivityCallback(bizWidgetCallback);
  } on Object catch (error) {
    debugPrint('Business widget callback not registered: $error');
  }
}

Future<void> _headless(String why, Future<BizRefreshOutcome> Function(BizWidgetRefresher refresher) work) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  // The same database the app has open, if it is: see AppDatabase
  final db = AppDatabase();
  try {
    final server = AppConfig.allowsServerOverride ? await db.getSetting(serverUrlSettingKey) : null;
    final refresher = BizWidgetRefresher(
      db: db,
      api: ApiClient(baseUrl: server ?? AppConfig.apiUrl, tokenStore: SecureTokenStore()),
      bridge: PluginBizWidgetBridge(),
      targets: const PluginBizWidgetTargetSource(),
      device: (targets, locale) async {
        await initFirebase();
        if (!firebaseStarted) return null;
        return devicePayload(FirebasePushService(), locale: locale, targets: targets);
      },
    );
    // Android gives a background message about 20 seconds
    final outcome = await work(refresher).timeout(const Duration(seconds: 18));
    debugPrint('Business widgets ($why): ${outcome.name}');
  } on TimeoutException {
    debugPrint('Business widgets ($why): ran out of time');
  } catch (error, stack) {
    debugPrint('Business widgets ($why) failed: $error\n$stack');
  } finally {
    await db.close();
  }
}
