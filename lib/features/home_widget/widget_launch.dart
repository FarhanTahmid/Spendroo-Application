import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/push/push_controller.dart';
import 'home_widget_bridge.dart';

/// The kinds the widget's add buttons may open the form on.
const widgetAddKinds = {'expense', 'income', 'transfer'};

/// The screen a widget link asks for, or null for a link the app does not know.
/// Links are spendroo://home, spendroo://plan and spendroo://add?kind=income
/// (WidgetLinks.kt on the Android side).
String? widgetRoute(Uri? uri) {
  if (uri == null || uri.scheme != 'spendroo') return null;
  switch (uri.host) {
    case 'home':
      return '/';
    case 'plan':
      return '/plan';
    case 'add':
      final kind = uri.queryParameters['kind'];
      return widgetAddKinds.contains(kind) ? '/add?kind=$kind' : '/add';
  }
  return null;
}

/// Opens the screen a widget button asks for, once someone is signed in
/// (SpendrooApp follows [pushRouteProvider], as for a tapped notification).
class WidgetLaunchController extends Notifier<void> {
  Uri? _last;
  DateTime? _lastAt;

  @override
  void build() {
    final bridge = ref.read(homeWidgetBridgeProvider);
    final clicks = bridge.clicks.listen(_open);
    ref.onDispose(clicks.cancel);
    bridge.initialLaunch().then(_open);
  }

  void _open(Uri? uri) {
    // A cold start can report the same tap as the launch link and as a click
    final now = DateTime.now();
    if (uri == _last && _lastAt != null && now.difference(_lastAt!) < const Duration(seconds: 2)) return;
    _last = uri;
    _lastAt = now;
    final route = widgetRoute(uri);
    if (route != null) ref.read(pushRouteProvider.notifier).openFromWidget(route);
  }
}

final widgetLaunchControllerProvider = NotifierProvider<WidgetLaunchController, void>(WidgetLaunchController.new);
