import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

/// The app's side of the Android home-screen widget: hands it a snapshot to
/// draw, asks the launcher to place it, and hears which button opened the app.
abstract interface class HomeWidgetBridge {
  /// Stores [json] where the widget reads it, then asks it to redraw.
  Future<void> publish(String json);

  /// Whether the launcher can place the widget for the user (Android 8+, most launchers).
  Future<bool> canPin();

  /// Shows the launcher's own "Add to home screen" prompt.
  Future<void> requestPin();

  /// The widget link the app was started with, if a widget started it.
  Future<Uri?> initialLaunch();

  /// Widget links tapped while the app is already running.
  Stream<Uri?> get clicks;
}

/// home_widget on Android; elsewhere there is no widget and every call is a no-op.
class PluginHomeWidgetBridge implements HomeWidgetBridge {
  /// The Glance receiver (android/app/src/main/kotlin/com/spendroo/app/widget).
  /// The package stays com.spendroo.app in every flavour; only the app id changes.
  static const receiver = 'com.spendroo.app.widget.SpendrooWidgetReceiver';

  /// The preference the widget reads (WidgetSnapshot.KEY on the Kotlin side).
  static const dataKey = 'snapshot';

  bool get _supported => !kIsWeb && Platform.isAndroid;

  @override
  Future<void> publish(String json) async {
    if (!_supported) return;
    try {
      await HomeWidget.saveWidgetData<String>(dataKey, json);
      await HomeWidget.updateWidget(qualifiedAndroidName: receiver);
      // The widget turns today to nothing spent at midnight even if the app stays closed
      await HomeWidget.scheduleWidgetUpdates(nextMidnights(DateTime.now()), qualifiedAndroidName: receiver);
    } on PlatformException catch (error) {
      // Never worth stopping the app for: the widget keeps its last picture
      debugPrint('Home widget update failed: $error');
    } on MissingPluginException {
      // Tests and platforms without the plugin
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
  Future<void> requestPin() async {
    if (!_supported) return;
    await HomeWidget.requestPinWidget(qualifiedAndroidName: receiver);
  }

  @override
  Future<Uri?> initialLaunch() async {
    if (!_supported) return null;
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } on PlatformException {
      return null;
    }
  }

  @override
  Stream<Uri?> get clicks => _supported ? HomeWidget.widgetClicked : const Stream.empty();
}

/// The next week of midnights after [now], a few seconds in so the new day has surely begun.
/// Each publish replaces the list, so it never runs out while the app is used.
List<DateTime> nextMidnights(DateTime now, {int days = 7}) => [
      for (var i = 1; i <= days; i++) DateTime(now.year, now.month, now.day + i, 0, 0, 5),
    ];

final homeWidgetBridgeProvider = Provider<HomeWidgetBridge>((ref) => PluginHomeWidgetBridge());
