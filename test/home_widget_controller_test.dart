import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/auth/auth_repository.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/db/local_store.dart';
import 'package:spendroo/core/design/segmented.dart';
import 'package:spendroo/core/entitlements/entitlements_controller.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/core/push/push_controller.dart';
import 'package:spendroo/features/goals/goals_repository.dart';
import 'package:spendroo/features/home_widget/home_widget_bridge.dart';
import 'package:spendroo/features/home_widget/home_widget_controller.dart';
import 'package:spendroo/features/home_widget/home_widget_providers.dart';
import 'package:spendroo/features/home_widget/quick_add_page.dart';
import 'package:spendroo/features/home_widget/widget_launch.dart';
import 'package:spendroo/features/personal/allocations.dart';
import 'package:spendroo/features/personal/personal_pages.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';

import 'home_widget_snapshot_test.dart' show plusWithWidget;
import 'personal_screens_test.dart' show FixedEntitlements, ScreenHarness, workspace;
import 'plan_test.dart' show entitlements;
import 'test_support.dart';

/// Someone is signed in (or not) without a server.
class FakeAuth extends AuthController {
  FakeAuth(this.initial);

  final AuthState initial;

  @override
  AuthState build() => initial;

  void set(AuthState next) => state = next;
}

/// Saturday 17 October 2026, whatever the clock says.
class FixedDay extends WidgetDayController {
  @override
  DateTime build() => DateTime(2026, 10, 17);
}

/// What the app would hand the Android widget, kept for the test to read.
class RecordingBridge implements HomeWidgetBridge {
  RecordingBridge({this.launch});

  final Uri? launch;
  final published = <Map<String, dynamic>>[];
  final taps = StreamController<Uri?>.broadcast();

  Map<String, dynamic> get last => published.last;

  @override
  Future<void> publish(String json) async => published.add((jsonDecode(json) as Map).cast<String, dynamic>());

  @override
  Future<bool> canPin() async => false;

  @override
  Future<void> requestPin() async {}

  @override
  Future<Uri?> initialLaunch() async => launch;

  @override
  Stream<Uri?> get clicks => taps.stream;
}

class Rig {
  Rig({Uri? launch}) : bridge = RecordingBridge(launch: launch) {
    db = memoryDatabase();
    store = LocalStore(db);
    ledger = LedgerRepository(db, store);
    goals = GoalsRepository(db, store, ledger);
    plan = FixedEntitlements(plusWithWidget());
    auth = FakeAuth(const AuthState(AuthStep.signedIn));
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      localStoreProvider.overrideWithValue(store),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
      authControllerProvider.overrideWith(() => auth),
      entitlementsProvider.overrideWith(() => plan),
      widgetDayProvider.overrideWith(FixedDay.new),
      homeWidgetBridgeProvider.overrideWithValue(bridge),
    ]);
  }

  final RecordingBridge bridge;
  late final AppDatabase db;
  late final LocalStore store;
  late final LedgerRepository ledger;
  late final GoalsRepository goals;
  late final FixedEntitlements plan;
  late final FakeAuth auth;
  late final ProviderContainer container;
  late Account cash;
  late String food;

  /// A cash book with October's spending, a bank account, a goal and someone else's business.
  Future<void> seed() async {
    await db.into(db.workspaces).insert(workspace);
    await db.into(db.workspaces).insert(const Workspace(
          id: '00000000-0000-0000-0000-000000000002',
          name: 'Shop',
          kind: 'business',
          defaultCurrency: 'BDT',
          isDemo: false,
          role: 'owner',
        ));
    await ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT', openingBalanceMinor: 100000);
    await ledger.addAccount(workspace.id, name: 'Bank', kind: 'bank', currency: 'BDT');
    final accounts = (await ledger.watchAccounts(workspace.id).first).map((a) => a.account).toList();
    cash = accounts.firstWhere((a) => a.name == 'Cash');
    final bank = accounts.firstWhere((a) => a.name == 'Bank');
    food = await ledger.addCategory(workspace.id, 'Food', 'expense');
    final taxi = await ledger.addCategory(workspace.id, 'Taxi', 'expense');

    Future<void> spend(int minor, String on, {List<SplitPart> splits = const []}) =>
        ledger.addTransaction(cash, kind: 'expense', amountMinor: minor, occurredOn: on, categoryId: food, splits: splits);
    await spend(45000, '2026-10-17');
    // A split counts once, for its whole amount
    await spend(5000, '2026-10-17',
        splits: [SplitPart(food, 2000), SplitPart(taxi, 3000)]);
    await spend(5000, '2026-10-16');
    await spend(70000, '2026-09-30');
    await ledger.addTransaction(cash, kind: 'income', amountMinor: 200000, occurredOn: '2026-10-17');
    // Moving money between own accounts is not spending
    await ledger.addTransfer(cash, bank, amountMinor: 10000, occurredOn: '2026-10-17');
    // A deleted expense counts for nothing
    final mistake = await ledger.addTransaction(cash, kind: 'expense', amountMinor: 99900, occurredOn: '2026-10-17');
    final row = await (db.select(db.transactions)..where((t) => t.id.equals(mistake))).getSingle();
    await ledger.deleteTransaction(row);
    // Money put in a goal is no longer there to spend
    final goalId = await goals.createGoal(workspace.id, name: 'Bike', targetMinor: 1000000, currency: 'BDT');
    final goal = await (db.select(db.savingsGoals)..where((g) => g.id.equals(goalId))).getSingle();
    final goalAccount = await (db.select(db.accounts)..where((a) => a.id.equals(goal.accountId))).getSingle();
    await ledger.addTransfer(cash, goalAccount, amountMinor: 20000, occurredOn: '2026-10-17');
  }

  void start() => container.listen(homeWidgetControllerProvider, (_, _) {});

  /// Waits for the next update the widget is sent.
  Future<Map<String, dynamic>> next() async {
    final seen = bridge.published.length;
    for (var i = 0; i < 100 && bridge.published.length == seen; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(bridge.published.length, greaterThan(seen), reason: 'the widget was sent nothing');
    return bridge.last;
  }

  /// Gives a would-be update time to arrive.
  Future<void> quiet() => Future<void>.delayed(HomeWidgetController.settle * 2);

  Future<void> stop() async {
    container.dispose();
    await bridge.taps.close();
    await db.close();
  }
}

void main() {
  group('the widget follows the ledger', () {
    late Rig rig;

    setUp(() async {
      rig = Rig();
      await rig.seed();
    });

    tearDown(() => rig.stop());

    test('the month, today and what is left of the month come from the personal workspace', () async {
      rig.start();
      final s = await rig.next();
      expect(s['signedIn'], isTrue);
      expect(s['unlocked'], isTrue);
      expect(s['date'], '2026-10-17');
      // 450 and the 50 split; not the transfer, nor the deleted 999
      expect(s['today'], '৳500');
      // With yesterday's 50; September stays in September
      expect(s['monthTotal'], '৳550');
      expect(s['monthLabel'], isNotEmpty);
      expect((s['daily'] as List)[16], 50000);
      expect((s['daily'] as List)[15], 5000);
      // October's 2,000 in less its 550 out: no opening balance, no September, no transfers or goals
      expect(s['left'], {'label': 'Left this month', 'value': '৳1,450'});
      expect(s['leftNegative'], isFalse);
      expect(s['updated'], startsWith('Updated '));
    });

    test('a new expense reaches the widget, and so does deleting it', () async {
      rig.start();
      await rig.next();
      final id = await rig.ledger.addTransaction(rig.cash, kind: 'expense', amountMinor: 12000, occurredOn: '2026-10-17');
      expect((await rig.next())['today'], '৳620');
      final row = await (rig.db.select(rig.db.transactions)..where((t) => t.id.equals(id))).getSingle();
      await rig.ledger.deleteTransaction(row);
      expect((await rig.next())['today'], '৳500');
    });

    test('a burst of writes is one update, and a write that changes nothing is none', () async {
      rig.start();
      await rig.next();
      final sent = rig.bridge.published.length;
      for (var i = 0; i < 5; i++) {
        await rig.ledger.addTransaction(rig.cash, kind: 'expense', amountMinor: 100, occurredOn: '2026-10-17');
      }
      expect((await rig.next())['today'], '৳505');
      await rig.quiet();
      expect(rig.bridge.published.length, sent + 1);
      // A budget is a write, but this one moves no figure the widget shows... until it does
      await rig.ledger.setBudget(rig.workspaceId, rig.food, 310000, 'BDT');
      final budgeted = await rig.next();
      expect(budgeted['paceTone'], 'safe');
      expect(budgeted['budgetPerDay'], 10000);
      await rig.db.setSetting('unrelated', 'x');
      await rig.quiet();
      expect(rig.bridge.published.length, sent + 2);
    });

    test('a downgrade locks the bigger sizes, an upgrade opens them again', () async {
      rig.start();
      expect((await rig.next())['unlocked'], isTrue);
      rig.plan.change(entitlements());
      expect((await rig.next())['unlocked'], isFalse);
      rig.plan.change(plusWithWidget());
      expect((await rig.next())['unlocked'], isTrue);
    });

    test('signing out clears the figures from the home screen', () async {
      rig.start();
      await rig.next();
      rig.auth.set(const AuthState(AuthStep.signedOut));
      final s = await rig.next();
      expect(s['signedIn'], isFalse);
      expect(s['today'], '');
      expect(s['monthTotal'], '');
      expect(s['left'], {'label': '', 'value': ''});
    });

    test('the widget speaks the app language', () async {
      rig.start();
      await rig.next();
      await rig.container.read(localeProvider.notifier).set(const Locale('bn'));
      final s = await rig.next();
      expect(s['today'], '৳৫০০');
      expect((s['strings'] as Map)['today'], 'আজ');
      expect((s['strings'] as Map)['spentThisMonth'], 'এই মাসের খরচ');
    });
  });

  group('widget buttons', () {
    test('the link the app was started with opens its screen', () async {
      final rig = Rig(launch: Uri.parse('spendroo://add?kind=income'));
      addTearDown(rig.stop);
      rig.container.read(widgetLaunchControllerProvider);
      await Future<void>.delayed(Duration.zero);
      expect(rig.container.read(pushRouteProvider), '/add?kind=income');
    });

    test('taps while the app runs open theirs; the same tap reported twice opens once', () async {
      final rig = Rig(launch: Uri.parse('spendroo://plan'));
      addTearDown(rig.stop);
      rig.container.read(widgetLaunchControllerProvider);
      await Future<void>.delayed(Duration.zero);
      expect(rig.container.read(pushRouteProvider), '/plan');
      rig.container.read(pushRouteProvider.notifier).done();
      // A cold start can deliver the launching tap a second time
      rig.bridge.taps.add(Uri.parse('spendroo://plan'));
      await Future<void>.delayed(Duration.zero);
      expect(rig.container.read(pushRouteProvider), isNull);
      rig.bridge.taps.add(Uri.parse('spendroo://add?kind=transfer'));
      await Future<void>.delayed(Duration.zero);
      expect(rig.container.read(pushRouteProvider), '/add?kind=transfer');
      // Links the app does not know are dropped
      rig.container.read(pushRouteProvider.notifier).done();
      rig.bridge.taps.add(Uri.parse('https://example.com'));
      await Future<void>.delayed(Duration.zero);
      expect(rig.container.read(pushRouteProvider), isNull);
    });
  });

  group('quick add', () {
    Future<String> kindShown(WidgetTester tester, String? kind) async {
      final app = ScreenHarness(tester);
      await app.run(() async {
        await app.ledger.addAccount(workspace.id, name: 'Cash', kind: 'cash', currency: 'BDT');
        await app.ledger.addCategory(workspace.id, 'Food', 'expense');
      });
      await app.show(QuickAddPage(kind: kind));
      // The personal workspace's own form, not a loader
      expect(find.byType(TransactionFormPage), findsOneWidget);
      final value = tester.widget<SlidingSegmented<String>>(find.byKey(const ValueKey('kind-switch'))).value;
      await app.stop();
      return value;
    }

    testWidgets('opens the form on the kind the widget button asked for', (tester) async {
      expect(await kindShown(tester, 'income'), 'income');
      expect(await kindShown(tester, 'transfer'), 'transfer');
      expect(await kindShown(tester, 'expense'), 'expense');
    });

    testWidgets('anything else opens on expense', (tester) async {
      expect(await kindShown(tester, null), 'expense');
      expect(await kindShown(tester, 'save'), 'expense');
    });
  });
}

extension on Rig {
  String get workspaceId => workspace.id;
}
