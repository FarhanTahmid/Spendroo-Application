import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'biz_snapshot.dart';
import 'biz_widget_controller.dart' show PluginBizWidgetBridge;

/// The targets last told to the server, as [BizWidgetTargets.fingerprint].
const widgetTargetsSettingKey = 'widget_targets_sent';

/// What the business and cashbook widgets on this phone's home screen show.
/// The server sends a silent push only to phones whose widgets show a business
/// or book that changed (notifications/widgets.py there).
class BizWidgetTargets {
  const BizWidgetTargets({this.workspaces = const {}, this.books = const {}});

  /// Businesses shown whole, by a business widget.
  final Set<String> workspaces;

  /// Cashbooks shown by a cashbook widget.
  final Set<String> books;

  static const none = BizWidgetTargets();

  bool get isEmpty => workspaces.isEmpty && books.isEmpty;

  /// The fields of PUT /api/v1/me/devices/.
  Map<String, Object> toJson() => {
        'widget_workspaces': workspaces.toList()..sort(),
        'widget_books': books.toList()..sort(),
      };

  String get fingerprint => jsonEncode(toJson());

  /// Whether a change in [workspaceId] shows on these widgets. [bookBusiness]
  /// is book -> its business, from the catalog; a book it does not know yet
  /// (granted since) is taken to belong.
  bool shows(String workspaceId, Map<String, String> bookBusiness) =>
      workspaces.contains(workspaceId) ||
      books.any((book) => (bookBusiness[book] ?? workspaceId) == workspaceId);

  /// Book -> the business it belongs to, from the stored catalog.
  static Map<String, String> bookBusinessOf(String? catalogJson) {
    if (catalogJson == null) return const {};
    try {
      final catalog = jsonDecode(catalogJson) as Map<String, dynamic>;
      return {
        for (final business in (catalog['businesses'] as List? ?? const []).cast<Map<String, dynamic>>())
          for (final book in (business['books'] as List? ?? const []).cast<Map<String, dynamic>>())
            book['id'] as String: business['id'] as String,
      };
    } on Object {
      return const {};
    }
  }

  /// Reads them from the copies placed: each keeps its choice under
  /// `biz_target_<id>`, or shows the only business or book there is, as the
  /// Kotlin side does (BizWidgets.kt).
  static BizWidgetTargets of({
    required Iterable<(bool business, String? target)> copies,
    required String? catalogJson,
  }) {
    final businesses = <String>[];
    final books = <String>[];
    try {
      final catalog = catalogJson == null ? const <String, dynamic>{} : jsonDecode(catalogJson) as Map<String, dynamic>;
      for (final business in (catalog['businesses'] as List? ?? const []).cast<Map<String, dynamic>>()) {
        businesses.add(business['id'] as String);
        for (final book in (business['books'] as List? ?? const []).cast<Map<String, dynamic>>()) {
          books.add(book['id'] as String);
        }
      }
    } on Object {
      // No catalog yet: only explicit choices count
    }
    final workspaces = <String>{};
    final shownBooks = <String>{};
    for (final (business, target) in copies) {
      final only = business ? (businesses.length == 1 ? businesses.single : null) : (books.length == 1 ? books.single : null);
      final id = target ?? only;
      if (id == null) continue;
      (business ? workspaces : shownBooks).add(id);
    }
    return BizWidgetTargets(workspaces: workspaces, books: shownBooks);
  }
}

/// Where the targets are read from; tests stand in for the launcher.
abstract interface class BizWidgetTargetSource {
  /// Null when it cannot be told (no widgets on this platform, the plugin failed).
  Future<BizWidgetTargets?> read();
}

class PluginBizWidgetTargetSource implements BizWidgetTargetSource {
  const PluginBizWidgetTargetSource();

  @override
  Future<BizWidgetTargets?> read() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      final copies = <(bool, String?)>[];
      for (final widget in await HomeWidget.getInstalledWidgets()) {
        final id = widget.androidWidgetId;
        final business = widget.androidClassName == PluginBizWidgetBridge.businessReceiver;
        if (id == null || (!business && widget.androidClassName != PluginBizWidgetBridge.bookReceiver)) continue;
        copies.add((business, await HomeWidget.getWidgetData<String>('biz_target_$id')));
      }
      if (copies.isEmpty) return BizWidgetTargets.none;
      return BizWidgetTargets.of(copies: copies, catalogJson: await HomeWidget.getWidgetData<String>(BizKeys.catalog));
    } on PlatformException catch (error) {
      debugPrint('Widget targets could not be read: $error');
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

final bizWidgetTargetSourceProvider = Provider<BizWidgetTargetSource>((ref) => const PluginBizWidgetTargetSource());
