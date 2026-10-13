import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/api/api_client.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/providers.dart';
import '../personal/ledger_repository.dart' show isoDate, monthRange;

/// What a report is about. The server builds each one (reports/ in the API).
enum ReportScope { personal, account, cashbook, business }

/// The periods a report can cover, as the server names them (reports/periods.py).
enum ReportPeriod {
  thisMonth('this_month'),
  lastMonth('last_month'),
  last3Months('last_3_months'),
  thisYear('this_year'),

  /// Chosen dates, kinds of line and categories. A plan feature ([F.reportsCustomRange]).
  custom('custom');

  const ReportPeriod(this.code);

  final String code;

  /// First and last day of a preset counted from [now], as ISO dates; the
  /// server counts the same way. Null for [custom].
  (String, String)? range([DateTime? now]) {
    final today = now ?? DateTime.now();
    return switch (this) {
      thisMonth => monthRange(today),
      lastMonth => monthRange(DateTime(today.year, today.month - 1)),
      last3Months => (isoDate(DateTime(today.year, today.month - 2)), monthRange(today).$2),
      thisYear => (isoDate(DateTime(today.year)), isoDate(DateTime(today.year, 12, 31))),
      custom => null,
    };
  }
}

enum ReportFileType {
  pdf('pdf'),

  /// A plan feature ([F.reportsExcel]).
  excel('xlsx');

  const ReportFileType(this.code);

  final String code;
}

/// One report to ask the server for.
class ReportRequest {
  const ReportRequest({
    required this.scope,
    required this.period,
    required this.fileType,
    required this.language,
    this.subjectId,
    this.from,
    this.to,
    this.types = const [],
    this.categoryIds = const [],
    this.uncategorised = false,
  });

  final ReportScope scope;

  /// The account, cashbook or business. Null for the personal report, which is always one's own.
  final String? subjectId;
  final ReportPeriod period;

  /// ISO dates, for [ReportPeriod.custom].
  final String? from;
  final String? to;

  /// A custom report narrowed to these kinds of line and categories; empty for all.
  final List<String> types;
  final List<String> categoryIds;

  /// Lines with no category, alongside [categoryIds].
  final bool uncategorised;
  final ReportFileType fileType;
  final String language;

  String get path => switch (scope) {
    ReportScope.personal => '/api/v1/reports/personal/',
    ReportScope.account => '/api/v1/reports/accounts/$subjectId/',
    ReportScope.cashbook => '/api/v1/reports/cashbooks/$subjectId/',
    ReportScope.business => '/api/v1/reports/businesses/$subjectId/',
  };

  Map<String, String> get query => {
    'file_type': fileType.code,
    'period': period.code,
    'lang': language,
    if (period == ReportPeriod.custom) ...{
      'from': ?from,
      'to': ?to,
      if (types.isNotEmpty) 'type': types.join(','),
      if (categoryIds.isNotEmpty || uncategorised) 'category': [...categoryIds, if (uncategorised) 'none'].join(','),
    },
  };
}

/// A report saved on the phone.
class ReportFile {
  const ReportFile({required this.path, required this.reference});

  final String path;

  /// Printed in the report's footer, e.g. SR-20261012-7F3K2A. Empty when the server sent none.
  final String reference;

  String get name => p.basename(path);
}

/// Why no file came back, other than the plan (a [PlanLimitException]) or the
/// network (an [OfflineException]).
class ReportException implements Exception {
  const ReportException(this.reason, {this.limit});

  static const tooLarge = 'too_large';
  static const throttled = 'throttled';
  static const failed = 'failed';

  final String reason;

  /// For [tooLarge]: the most lines one file holds.
  final int? limit;

  @override
  String toString() => 'ReportException($reason)';
}

class ReportRepository {
  ReportRepository(this.api, {Future<Directory> Function()? folder}) : _folder = folder ?? getTemporaryDirectory;

  final ApiClient api;

  /// Where files are kept until the phone clears them: they are copies, and
  /// the user keeps one by sharing or saving it.
  final Future<Directory> Function() _folder;

  /// Asks the server for the report and saves it on the phone.
  Future<ReportFile> download(ReportRequest request) async {
    final response = await api.download(request.path, query: request.query);
    if (response.statusCode != 200) throw _refusal(response.statusCode, response.bodyBytes);

    final folder = Directory(p.join((await _folder()).path, 'reports'));
    await folder.create(recursive: true);
    final name =
        _filename(response.headers['content-disposition']) ?? 'spendroo-${request.scope.name}.${request.fileType.code}';
    final file = File(p.join(folder.path, name));
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return ReportFile(path: file.path, reference: response.headers['x-report-reference'] ?? '');
  }

  Exception _refusal(int status, List<int> body) {
    Map<String, dynamic> json = const {};
    try {
      final decoded = jsonDecode(utf8.decode(body));
      if (decoded is Map) json = decoded.cast<String, dynamic>();
    } on FormatException {
      // An HTML error page from a proxy
    }
    if (status == 402 && json['code'] == 'plan_limit') return PlanLimitException.fromJson(json);
    if (status == 400 && json['code'] == 'report_too_large') {
      return ReportException(ReportException.tooLarge, limit: (json['limit'] as num?)?.toInt());
    }
    if (status == 429) return const ReportException(ReportException.throttled);
    return const ReportException(ReportException.failed);
  }

  /// The name the server gave the file. Only its last part is used, so a name
  /// can never point outside the folder.
  String? _filename(String? disposition) {
    final match = RegExp(r'filename="([^"]+)"').firstMatch(disposition ?? '');
    final name = match == null ? '' : p.basename(match.group(1)!);
    return RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(name) && !name.startsWith('.') ? name : null;
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) => ReportRepository(ref.watch(apiClientProvider)));

/// Hands a downloaded report to the phone: into its Downloads folder, to an
/// app that can show it, or to the share sheet.
class ReportOpener {
  const ReportOpener();

  static const _downloads = MethodChannel('spendroo/downloads');

  /// Copies the report into the phone's Downloads folder (MainActivity.kt) and
  /// returns where it now is, e.g. "Download/Spendroo/report.pdf". Null where
  /// the phone gives no such folder to write to: Android 9 and older, and iOS.
  Future<String?> saveToDownloads(ReportFile file) async {
    if (!Platform.isAndroid) return null;
    try {
      return await _downloads.invokeMethod<String>('save', {
        'path': file.path,
        'name': file.name,
        'mime': file.name.endsWith('.pdf')
            ? 'application/pdf'
            : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      });
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// False when no app on the phone opens this kind of file.
  Future<bool> open(ReportFile file) async => (await OpenFilex.open(file.path)).type == ResultType.done;

  Future<void> share(ReportFile file) => SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}

final reportOpenerProvider = Provider<ReportOpener>((ref) => const ReportOpener());
