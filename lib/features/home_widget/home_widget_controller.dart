import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import 'home_widget_bridge.dart';
import 'home_widget_providers.dart';
import 'widget_snapshot.dart';

/// Keeps the home-screen widget showing what the ledger says, for as long as
/// the app is open. Every write, local or synced, moves a drift stream under
/// [homeWidgetSnapshotProvider]; bursts (a sync landing fifty rows) settle
/// before one update goes out, and an update that changes nothing is skipped.
class HomeWidgetController extends Notifier<void> {
  /// How long the figures must hold still before the widget redraws.
  static const settle = Duration(milliseconds: 400);

  Timer? _pending;
  String? _sent;

  @override
  void build() {
    ref.onDispose(() => _pending?.cancel());
    ref.listen<HomeWidgetSnapshot?>(homeWidgetSnapshotProvider, (_, next) => _schedule(next), fireImmediately: true);
  }

  void _schedule(HomeWidgetSnapshot? snapshot) {
    if (snapshot == null) return;
    _pending?.cancel();
    _pending = Timer(settle, () => _publish(snapshot));
  }

  Future<void> _publish(HomeWidgetSnapshot snapshot) async {
    final fingerprint = snapshot.fingerprint;
    if (fingerprint == _sent) return;
    _sent = fingerprint;
    final locale = ref.read(localeProvider);
    final l10n = lookupAppLocalizations(locale);
    var time = clockTime(DateTime.now());
    if (locale.languageCode == 'bn') time = Money.toBengaliDigits(time);
    await ref.read(homeWidgetBridgeProvider).publish(snapshot.stamped(l10n.widgetUpdated(time)).encode());
  }
}

final homeWidgetControllerProvider = NotifierProvider<HomeWidgetController, void>(HomeWidgetController.new);

/// "09:05": by hand, since intl's date formats are not loaded until the app's
/// localizations are, and the widget may be updated before that.
String clockTime(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
