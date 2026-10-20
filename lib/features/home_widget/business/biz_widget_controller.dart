import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/money.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../home_widget_bridge.dart' show nextMidnights;
import '../home_widget_controller.dart' show clockTime;
import 'biz_snapshot.dart';
import 'biz_widget_providers.dart';

/// Which of the two business widgets.
enum BizWidgetKind { business, book }

/// The app's side of the business and cashbook widgets: stores their snapshots
/// where they read them, redraws them, and asks the launcher to place one.
abstract interface class BizWidgetBridge {
  /// Stores each value under its key (null removes the key), then redraws both widgets.
  Future<void> publish(Map<String, String?> values);

  /// What is stored under [key], if anything.
  Future<String?> read(String key);

  Future<bool> canPin();

  Future<void> requestPin(BizWidgetKind kind);
}

/// home_widget on Android; elsewhere there are no widgets and every call is a no-op.
class PluginBizWidgetBridge implements BizWidgetBridge {
  /// The Glance receivers (android/.../widget/business). The package stays com.spendroo.app in every flavour.
  static const businessReceiver = 'com.spendroo.app.widget.business.BusinessWidgetReceiver';
  static const bookReceiver = 'com.spendroo.app.widget.business.CashbookWidgetReceiver';

  bool get _supported => !kIsWeb && Platform.isAndroid;

  @override
  Future<void> publish(Map<String, String?> values) async {
    if (!_supported) return;
    try {
      for (final entry in values.entries) {
        await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
      }
      final midnights = nextMidnights(DateTime.now());
      for (final receiver in const [businessReceiver, bookReceiver]) {
        await HomeWidget.updateWidget(qualifiedAndroidName: receiver);
        // Today turns to nothing at midnight even while the app stays closed
        await HomeWidget.scheduleWidgetUpdates(midnights, qualifiedAndroidName: receiver);
      }
    } on PlatformException catch (error) {
      // Never worth stopping the app for: the widgets keep their last picture
      debugPrint('Business widget update failed: $error');
    } on MissingPluginException {
      // Tests and platforms without the plugin
    }
  }

  @override
  Future<String?> read(String key) async {
    if (!_supported) return null;
    try {
      return await HomeWidget.getWidgetData<String>(key);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<bool> canPin() async {
    if (!_supported) return false;
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> requestPin(BizWidgetKind kind) async {
    if (!_supported) return;
    await HomeWidget.requestPinWidget(
      qualifiedAndroidName: kind == BizWidgetKind.business ? businessReceiver : bookReceiver,
    );
  }
}

final bizWidgetBridgeProvider = Provider<BizWidgetBridge>((ref) => PluginBizWidgetBridge());

/// Writes what the widgets should show: only the keys whose figures changed
/// since it last wrote them, and removes keys of books or businesses that are
/// gone so nothing of theirs stays on the home screen.
class BizWidgetPublisher {
  BizWidgetPublisher(this.bridge);

  final BizWidgetBridge bridge;

  /// Key -> fingerprint of what was last written there.
  final _sent = <String, String>{};

  /// Snapshot keys stored now; read back from the widgets' storage on the first publish.
  Set<String>? _stored;

  /// With [only], just those snapshot keys and the catalog are written, and
  /// nothing is removed: the rest was not looked at.
  Future<void> publish(BizPublication publication, Locale locale, {Set<String>? only}) async {
    final values = <String, String?>{};
    if (only == null) _stored ??= _decodeKeys(await bridge.read(BizKeys.published));

    var time = clockTime(DateTime.now());
    if (locale.languageCode == 'bn') time = Money.toBengaliDigits(time);
    final updated = lookupAppLocalizations(locale).widgetUpdated(time);

    final catalog = publication.catalog.encode();
    if (_sent[BizKeys.catalog] != catalog) {
      values[BizKeys.catalog] = catalog;
      _sent[BizKeys.catalog] = catalog;
    }
    publication.snapshots.forEach((key, snapshot) {
      if (only != null && !only.contains(key)) return;
      final fingerprint = snapshot.fingerprint;
      if (_sent[key] == fingerprint) return;
      values[key] = snapshot.stamped(updated).encode();
      _sent[key] = fingerprint;
    });
    if (only == null) {
      final keys = publication.snapshots.keys.toSet();
      for (final gone in _stored!.difference(keys)) {
        values[gone] = null;
        _sent.remove(gone);
      }
      if (!setEquals(keys, _stored)) values[BizKeys.published] = jsonEncode(keys.toList()..sort());
      _stored = keys;
    }
    if (values.isEmpty) return;
    await bridge.publish(values);
  }

  static Set<String> _decodeKeys(String? json) {
    if (json == null) return {};
    try {
      return {for (final key in jsonDecode(json) as List) '$key'};
    } on Object {
      return {};
    }
  }
}

/// Keeps the business and cashbook widgets showing what the books say, for as
/// long as the app is open. Bursts of writes settle before anything goes out.
/// While the app is closed, a teammate's change reaches them through a silent
/// push instead (biz_widget_background.dart).
class BizWidgetController extends Notifier<void> {
  /// How long the figures must hold still before the widgets redraw.
  static const settle = Duration(milliseconds: 400);

  Timer? _pending;
  late final _publisher = BizWidgetPublisher(ref.read(bizWidgetBridgeProvider));

  /// Publishes run one after another, never interleaved.
  Future<void> _queue = Future.value();

  @override
  void build() {
    ref.onDispose(() => _pending?.cancel());
    ref.listen<BizPublication?>(bizWidgetPublicationProvider, (_, next) => _schedule(next), fireImmediately: true);
  }

  void _schedule(BizPublication? publication) {
    if (publication == null) return;
    _pending?.cancel();
    _pending = Timer(
      settle,
      () => _queue = _queue.then((_) => _publisher.publish(publication, ref.read(localeProvider))),
    );
  }
}

final bizWidgetControllerProvider = NotifierProvider<BizWidgetController, void>(BizWidgetController.new);
