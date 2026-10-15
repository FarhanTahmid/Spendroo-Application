import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/features/personal/ledger_repository.dart' show isoDate;
import 'package:spendroo/features/reports/report_repository.dart';

import 'app_flow_test.dart' show Harness, cashAccountId;
import 'plan_test.dart' show BillingServer, addAccounts, answer;

/// The fake API with reports: a PDF for everyone, Excel and chosen dates for Plus.
class ReportServer extends BillingServer {
  /// Every request that matters here, in the order it arrived.
  final log = <String>[];
  final asked = <Uri>[];

  @override
  Map<String, dynamic> get body => answer(
    plan: plan,
    locks: locks,
    offers: offers,
    features: {
      ...features,
      F.reportsExcel: {'kind': 'flag', 'enabled': plan != 'free'},
      F.reportsCustomRange: {'kind': 'flag', 'enabled': plan != 'free'},
    },
  );

  @override
  Future<http.Response> handle(http.Request request) async {
    final path = request.url.path;
    if (path == '/api/v1/sync/push/') log.add('push');
    if (path.startsWith('/api/v1/reports/')) {
      log.add('report');
      asked.add(request.url);
      final query = request.url.queryParameters;
      final custom = query['period'] == 'custom' || query.containsKey('type') || query.containsKey('category');
      final paid = query['file_type'] == 'xlsx' ? F.reportsExcel : (custom ? F.reportsCustomRange : null);
      if (paid != null && plan == 'free') {
        return http.Response(
          jsonEncode({
            'code': 'plan_limit',
            'detail': 'no',
            'feature': paid,
            'reason': 'feature',
            'limit': null,
            'current': null,
            'plan': 'free',
            'upgrade_to': 'plus',
          }),
          402,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response.bytes(
        utf8.encode('%PDF-1.7 report'),
        200,
        headers: {
          'content-type': 'application/pdf',
          'content-disposition': 'attachment; filename="spendroo-personal-20261001-20261031.${query['file_type']}"',
          'x-report-reference': 'SR-20261012-7F3K2A',
        },
      );
    }
    return super.handle(request);
  }
}

class FakeOpener implements ReportOpener {
  final opened = <String>[];
  final shared = <String>[];

  @override
  Future<bool> open(ReportFile file) async {
    opened.add(file.name);
    return true;
  }

  /// Null stands for a phone with no Downloads folder to write to.
  String? folder = 'Download/Spendroo';
  final saved = <String>[];

  @override
  Future<String?> saveToDownloads(ReportFile file) async {
    if (folder == null) return null;
    saved.add(file.name);
    return '$folder/${file.name}';
  }

  @override
  Future<void> share(ReportFile file) async => shared.add(file.name);
}

ApiClient clientAnswering(http.Response Function(http.Request request) answer) => ApiClient(
  baseUrl: 'http://test',
  tokenStore: MemoryTokenStore()..token = 'token-1',
  httpClient: MockClient((request) async => answer(request)),
);

http.Response refusal(int status, Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

void main() {
  late Directory folder;

  setUp(() => folder = Directory.systemTemp.createTempSync('spendroo-report-test'));
  tearDown(() => folder.deleteSync(recursive: true));

  group('ReportPeriod', () {
    test('a preset means the same days the server counts', () {
      final today = DateTime(2026, 10, 12);
      expect(ReportPeriod.thisMonth.range(today), ('2026-10-01', '2026-10-31'));
      expect(ReportPeriod.lastMonth.range(today), ('2026-09-01', '2026-09-30'));
      expect(ReportPeriod.last3Months.range(today), ('2026-08-01', '2026-10-31'));
      expect(ReportPeriod.thisYear.range(today), ('2026-01-01', '2026-12-31'));
      expect(ReportPeriod.lastMonth.range(DateTime(2026, 1, 5)), ('2025-12-01', '2025-12-31'));
      expect(ReportPeriod.custom.range(today), isNull);
    });
  });

  group('ReportRepository', () {
    const request = ReportRequest(
      scope: ReportScope.cashbook,
      subjectId: 'book-1',
      period: ReportPeriod.thisMonth,
      fileType: ReportFileType.pdf,
      language: 'bn',
    );

    ReportRepository repository(http.Response Function(http.Request request) answer) =>
        ReportRepository(clientAnswering(answer), folder: () async => folder);

    test('asks for the report and saves the file it gets', () async {
      late Uri asked;
      final repo = repository((request) {
        asked = request.url;
        return http.Response.bytes(
          [1, 2, 3],
          200,
          headers: {
            'content-disposition': 'attachment; filename="spendroo-cashbook-till-20261001-20261031.pdf"',
            'x-report-reference': 'SR-20261012-7F3K2A',
          },
        );
      });

      final file = await repo.download(request);

      expect(asked.path, '/api/v1/reports/cashbooks/book-1/');
      expect(asked.queryParameters, {'file_type': 'pdf', 'period': 'this_month', 'lang': 'bn'});
      expect(file.name, 'spendroo-cashbook-till-20261001-20261031.pdf');
      expect(file.reference, 'SR-20261012-7F3K2A');
      expect(File(file.path).readAsBytesSync(), [1, 2, 3]);
      expect(file.path, startsWith(folder.path));
    });

    test('chosen dates are sent only for a custom period', () async {
      late Uri asked;
      final repo = repository((request) {
        asked = request.url;
        return http.Response.bytes([1], 200);
      });
      await repo.download(
        const ReportRequest(
          scope: ReportScope.personal,
          period: ReportPeriod.custom,
          from: '2026-09-10',
          to: '2026-10-02',
          fileType: ReportFileType.excel,
          language: 'en',
        ),
      );
      expect(asked.path, '/api/v1/reports/personal/');
      expect(asked.queryParameters, {
        'file_type': 'xlsx',
        'period': 'custom',
        'lang': 'en',
        'from': '2026-09-10',
        'to': '2026-10-02',
      });
    });

    test('a custom report says which kinds of line and categories it wants', () async {
      late Uri asked;
      final repo = repository((request) {
        asked = request.url;
        return http.Response.bytes([1], 200);
      });
      const custom = ReportRequest(
        scope: ReportScope.business,
        subjectId: 'shop-1',
        period: ReportPeriod.custom,
        from: '2026-10-01',
        to: '2026-10-12',
        types: ['cash_out'],
        categoryIds: ['c-1', 'c-2'],
        uncategorised: true,
        fileType: ReportFileType.pdf,
        language: 'en',
      );
      await repo.download(custom);
      expect(asked.queryParameters['type'], 'cash_out');
      expect(asked.queryParameters['category'], 'c-1,c-2,none');
    });

    test('a file name from the server cannot leave the folder', () async {
      for (final name in ['../../outside.pdf', '/etc/passwd', '.hidden', 'রিপোর্ট.pdf']) {
        final repo = repository(
          (_) => http.Response.bytes(
            [1],
            200,
            headers: {'content-disposition': 'attachment; filename="${Uri.encodeFull(name)}"'},
          ),
        );
        final file = await repo.download(request);
        expect(File(file.path).parent.parent.path, folder.path, reason: name);
        expect(file.name, anyOf('outside.pdf', 'passwd', 'spendroo-cashbook.pdf'), reason: name);
      }
    });

    test('a refusal for the plan is a PlanLimitException', () async {
      final repo = repository(
        (_) => refusal(402, {
          'code': 'plan_limit',
          'feature': F.reportsExcel,
          'reason': 'feature',
          'plan': 'free',
          'upgrade_to': 'plus',
        }),
      );
      await expectLater(
        repo.download(request),
        throwsA(
          isA<PlanLimitException>()
              .having((e) => e.feature, 'feature', F.reportsExcel)
              .having((e) => e.reason, 'reason', PlanLimitException.reasonFeature)
              .having((e) => e.upgradeTo, 'upgradeTo', 'plus'),
        ),
      );
      expect(Directory('${folder.path}/reports').existsSync(), isFalse);
    });

    test('other refusals say what went wrong', () async {
      Future<ReportException> failing(http.Response response) async {
        try {
          await repository((_) => response).download(request);
        } on ReportException catch (problem) {
          return problem;
        }
        fail('nothing was thrown');
      }

      final tooLarge = await failing(refusal(400, {'code': 'report_too_large', 'rows': 2600, 'limit': 2000}));
      expect((tooLarge.reason, tooLarge.limit), (ReportException.tooLarge, 2000));
      expect((await failing(refusal(429, {'detail': 'slow down'}))).reason, ReportException.throttled);
      expect((await failing(refusal(404, {'detail': 'Report not found.'}))).reason, ReportException.failed);
      expect((await failing(http.Response('<html>Bad gateway</html>', 502))).reason, ReportException.failed);
    });
  });

  group('in the app', () {
    Future<(Harness, ReportServer, FakeOpener)> openApp(WidgetTester tester, {String plan = 'free'}) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);
      final server = ReportServer()..plan = plan;
      final opener = FakeOpener();
      final app = Harness(
        tester,
        server,
        overrides: [
          reportOpenerProvider.overrideWithValue(opener),
          reportRepositoryProvider.overrideWith(
            (ref) => ReportRepository(ref.watch(apiClientProvider), folder: () async => folder),
          ),
        ],
      );
      await app.start();
      await app.logIn();
      return (app, server, opener);
    }

    /// Taps a choice of the sheet, scrolling to it first on a short screen.
    Future<void> choose(WidgetTester tester, Harness app, Finder choice) async {
      await tester.ensureVisible(choice);
      await tester.pump();
      await tester.tap(choice);
      await app.settle();
    }

    Future<void> openSheet(WidgetTester tester, Harness app) async {
      await tester.tap(find.byIcon(Icons.download_rounded));
      await app.settle();
    }

    testWidgets('the sheet says what the report is and what each choice costs', (tester) async {
      final (app, server, _) = await openApp(tester);
      await openSheet(tester, app);

      expect(find.text('Download report'), findsOneWidget);
      expect(find.text('Personal report'), findsOneWidget);
      expect(find.text('All your personal accounts together.'), findsOneWidget);
      expect(find.text("What's inside"), findsOneWidget);
      expect(find.text('Income and spending by category'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget); // PDF
      expect(find.text('Paid plan'), findsOneWidget); // Excel
      // Excel, and custom dates; the overview behind has its own for chosen dates
      expect(find.descendant(of: find.byType(BottomSheet), matching: find.byIcon(Icons.lock_outline_rounded)),
          findsNWidgets(2));
      expect(find.text('Download PDF'), findsOneWidget);
      expect(server.asked, isEmpty);
      await app.stop();
    });

    testWidgets('a PDF downloads on the Free plan and can be opened or shared', (tester) async {
      final (app, server, opener) = await openApp(tester);
      await openSheet(tester, app);
      await choose(tester, app, find.byKey(const ValueKey('report-period-last_month')));
      await tester.tap(find.text('Download PDF'));
      // The file is written with real I/O, which takes its own time
      await app.settle();
      await app.settle();

      expect(server.asked.single.path, '/api/v1/reports/personal/');
      expect(server.asked.single.queryParameters, {'file_type': 'pdf', 'period': 'last_month', 'lang': 'en'});
      expect(find.text('Your report is ready'), findsOneWidget);
      expect(find.text('spendroo-personal-20261001-20261031.pdf'), findsOneWidget);
      expect(find.text('Reference SR-20261012-7F3K2A'), findsOneWidget);
      // It is on the phone without another tap, and the sheet says where
      expect(opener.saved, ['spendroo-personal-20261001-20261031.pdf']);
      expect(find.text('Saved on your phone in Download › Spendroo'), findsOneWidget);

      await tester.tap(find.text('Open'));
      await app.settle();
      await tester.tap(find.text('Share'));
      await app.settle();
      expect(opener.opened, ['spendroo-personal-20261001-20261031.pdf']);
      expect(opener.shared, ['spendroo-personal-20261001-20261031.pdf']);

      await tester.tap(find.text('Download another'));
      await app.settle();
      expect(find.text('Download PDF'), findsOneWidget);
      await app.stop();
    });

    testWidgets('a phone with no Downloads folder to write to is told to share', (tester) async {
      final (app, _, opener) = await openApp(tester);
      opener.folder = null;
      await openSheet(tester, app);
      await tester.tap(find.text('Download PDF'));
      await app.settle();
      await app.settle();

      expect(find.text('Your report is ready'), findsOneWidget);
      expect(find.textContaining('Use Share to keep a copy'), findsOneWidget);
      expect(find.textContaining('Saved on your phone'), findsNothing);
      await app.stop();
    });

    testWidgets('Excel on the Free plan opens the upgrade sheet and asks the server for nothing', (tester) async {
      final (app, server, _) = await openApp(tester);
      await openSheet(tester, app);
      await choose(tester, app, find.byKey(const ValueKey('report-file-xlsx')));

      expect(find.text('Get more from Spendroo'), findsOneWidget);
      expect(find.textContaining('Reports as Excel'), findsWidgets);
      expect(server.events.first, {'kind': 'paywall_view', 'feature': F.reportsExcel});
      expect(server.asked, isEmpty);
      await app.stop();
    });

    testWidgets('chosen dates on the Free plan open the upgrade sheet', (tester) async {
      final (app, server, _) = await openApp(tester);
      await openSheet(tester, app);
      await choose(tester, app, find.byKey(const ValueKey('report-period-custom')));

      expect(find.text('Get more from Spendroo'), findsOneWidget);
      expect(server.events.first, {'kind': 'paywall_view', 'feature': F.reportsCustomRange});
      expect(server.asked, isEmpty);
      await app.stop();
    });

    testWidgets('on Plus, Excel is one more choice', (tester) async {
      final (app, server, _) = await openApp(tester, plan: 'plus');
      await openSheet(tester, app);
      expect(find.text('Paid plan'), findsNothing);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);

      await choose(tester, app, find.byKey(const ValueKey('report-file-xlsx')));
      await tester.tap(find.text('Download Excel'));
      // The file is written with real I/O, which takes its own time
      await app.settle();
      await app.settle();

      expect(server.asked.single.queryParameters['file_type'], 'xlsx');
      expect(find.text('Your report is ready'), findsOneWidget);
      await app.stop();
    });

    testWidgets('on Plus, a custom report takes dates, types and categories', (tester) async {
      final (app, server, _) = await openApp(tester, plan: 'plus');
      await openSheet(tester, app);
      await choose(tester, app, find.byKey(const ValueKey('report-period-custom')));

      expect(find.text('Custom report'), findsOneWidget);
      expect(find.text('Choose none to include all.'), findsNWidgets(2));
      // Nothing is narrowed yet, so there is nothing to warn about
      expect(find.textContaining('A filtered report adds up only'), findsNothing);
      await choose(tester, app, find.byKey(const ValueKey('report-type-expense')));
      await choose(tester, app, find.widgetWithText(FilterChip, 'Food'));
      await choose(tester, app, find.widgetWithText(FilterChip, 'Uncategorised'));
      expect(find.textContaining('A filtered report adds up only'), findsOneWidget);
      await choose(tester, app, find.widgetWithText(FilledButton, 'Apply'));

      // Back on the first sheet, the choice is spelled out
      expect(find.text('Type: Expense'), findsOneWidget);
      expect(find.text('Categories: Food, Uncategorised'), findsOneWidget);
      await tester.tap(find.text('Download PDF'));
      await app.settle();
      await app.settle();

      final now = DateTime.now();
      expect(server.asked.single.queryParameters, {
        'file_type': 'pdf',
        'period': 'custom',
        'lang': 'en',
        'from': isoDate(DateTime(now.year, now.month)),
        'to': isoDate(DateTime(now.year, now.month, now.day)),
        'type': 'expense',
        'category': '00000000-0000-0000-0000-0000000000c1,none',
      });
      expect(find.text('Your report is ready'), findsOneWidget);
      await app.stop();
    });

    testWidgets('choosing only transfers leaves no categories to choose', (tester) async {
      final (app, _, _) = await openApp(tester, plan: 'plus');
      await openSheet(tester, app);
      await choose(tester, app, find.byKey(const ValueKey('report-period-custom')));
      expect(find.widgetWithText(FilterChip, 'Food'), findsOneWidget);
      await choose(tester, app, find.byKey(const ValueKey('report-type-transfer')));
      expect(find.widgetWithText(FilterChip, 'Food'), findsNothing);
      expect(find.widgetWithText(FilterChip, 'Uncategorised'), findsNothing);
      await app.stop();
    });

    testWidgets('changes still on the phone are sent before the report is asked for', (tester) async {
      final (app, server, _) = await openApp(tester);
      await addAccounts(app, 1);
      server.log.clear();
      await openSheet(tester, app);
      await tester.tap(find.text('Download PDF'));
      // The file is written with real I/O, which takes its own time
      await app.settle();
      await app.settle();

      expect(server.log, containsAllInOrder(['push', 'report']));
      await app.stop();
    });

    testWidgets('an account has its own statement', (tester) async {
      final (app, server, _) = await openApp(tester);
      await tester.tap(find.text('Accounts'));
      await app.settle();
      await tester.tap(find.text('Cash').first);
      await app.settle();
      await tester.tap(find.byIcon(Icons.download_rounded).last);
      await app.settle();

      expect(find.text('Account statement'), findsOneWidget);
      expect(find.text('Only the account Cash.'), findsOneWidget);
      await tester.tap(find.text('Download PDF'));
      // The file is written with real I/O, which takes its own time
      await app.settle();
      await app.settle();
      expect(server.asked.single.path, '/api/v1/reports/accounts/$cashAccountId/');
      await app.stop();
    });
  });
}
