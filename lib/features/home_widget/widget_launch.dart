import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/push/push_controller.dart';
import 'business/biz_quick_add.dart' show bizEntryTypes;
import 'home_widget_bridge.dart';

/// The kinds the widget's add buttons may open the form on.
const widgetAddKinds = {'expense', 'income', 'transfer'};

/// Workspace and cashbook ids are UUIDs; anything else in a link is not followed.
final _id = RegExp(r'^[0-9A-Za-z-]{1,64}$');

/// The screen a widget link asks for, or null for a link the app does not know
/// (WidgetLinks.kt on the Android side). The personal widget's links are
/// spendroo://home, spendroo://plan and spendroo://add?kind=income. The business
/// widgets' carry the workspace as `ws`, which the app switches to first:
/// - spendroo://business?ws=W: the business's home
/// - spendroo://book?id=B&ws=W: a cashbook
/// - spendroo://book-add?id=B&ws=W&type=cash_in: its entry form
/// - spendroo://business-add?ws=W&type=cash_out: which book, then the form
String? widgetRoute(Uri? uri) {
  if (uri == null || uri.scheme != 'spendroo') return null;
  final query = uri.queryParameters;
  final ws = query['ws'];
  final id = query['id'];
  final type = bizEntryTypes.contains(query['type']) ? query['type'] : 'cash_out';
  bool valid(String? value) => value != null && _id.hasMatch(value);
  switch (uri.host) {
    case 'home':
      return '/';
    case 'plan':
      return '/plan';
    case 'add':
      final kind = query['kind'];
      return widgetAddKinds.contains(kind) ? '/add?kind=$kind' : '/add';
    case 'business' when valid(ws):
      return '/?ws=$ws';
    case 'book' when valid(id) && valid(ws):
      return '/cashbook/$id?ws=$ws';
    case 'book-add' when valid(id) && valid(ws):
      return '/cashbook/$id/entry?type=$type&ws=$ws';
    case 'business-add' when valid(ws):
      return '/business/$ws/add?type=$type&ws=$ws';
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
