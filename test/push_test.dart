import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/providers.dart';
import 'package:spendroo/core/push/push_controller.dart';
import 'package:spendroo/core/push/push_service.dart';
import 'package:spendroo/features/home_widget/business/biz_widget_targets.dart';
import 'package:spendroo/features/personal/ledger_repository.dart';
import 'package:spendroo/features/recurring/inbox.dart';
import 'package:spendroo/features/settings/notification_settings_page.dart';

import 'app_flow_test.dart';
import 'biz_widget_background_test.dart' show FixedTargets;

/// The phone, as far as notifications go: what the app asked of it, and a way to make things arrive.
class FakePushService implements PushService {
  FakePushService({this.permitted = true});

  String? address = 'phone-token';
  bool permitted;
  var asked = 0;
  final shown = <PushMessage>[];

  /// The daily notification now set: (hour, minute, fromTomorrow), or null.
  (int, int, bool)? daily;
  String? dailyTitle;

  final _tokens = StreamController<String>.broadcast();
  void Function(PushMessage message)? _onMessage;
  void Function(Map<String, String> data)? _onOpen;

  void arrive(PushMessage message) => _onMessage!(message);
  void tap(Map<String, String> data) => _onOpen!(data);
  void newToken(String token) {
    address = token;
    _tokens.add(token);
  }

  @override
  Future<void> start({
    required void Function(PushMessage message) onMessage,
    required void Function(Map<String, String> data) onOpen,
  }) async {
    _onMessage = onMessage;
    _onOpen = onOpen;
  }

  @override
  Future<String?> token() async => address;

  @override
  Stream<String> get tokenChanges => _tokens.stream;

  @override
  Future<bool> allowed() async => permitted;

  @override
  Future<bool> ask() async {
    asked++;
    return permitted = true;
  }

  @override
  Future<String?> timeZone() async => 'Asia/Dhaka';

  @override
  Future<void> show(PushMessage message) async => shown.add(message);

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required bool fromTomorrow,
    required String title,
    required String body,
  }) async {
    daily = (hour, minute, fromTomorrow);
    dailyTitle = title;
  }

  @override
  Future<void> cancelDaily() async => daily = null;
}

void main() {
  const onboarded = '2026-10-01T00:00:00Z';

  Harness harness(WidgetTester tester, FakePushService phone, [FakeServer? server]) => Harness(
        tester,
        server ?? FakeServer(onboardedAt: onboarded),
        overrides: [pushServiceProvider.overrideWithValue(phone)],
      );

  testWidgets('signing in registers the phone, and signing out takes it back first', (tester) async {
    final phone = FakePushService();
    final app = harness(tester, phone);
    await app.start();
    expect(app.server.devices, isEmpty);
    await app.logIn();
    expect(app.server.devices, [
      {'token': 'phone-token', 'platform': 'android', 'locale': 'en', 'timezone': 'Asia/Dhaka', 'app_version': ''},
    ]);
    // Allowed already: nothing to ask
    expect(phone.asked, 0);

    // Firebase moves the phone, and the app is shown in Bangla: the server hears of both
    phone.newToken('phone-token-2');
    await app.settle();
    await app.run(app.container.read(localeProvider.notifier).set(const Locale('bn')));
    await app.settle();
    expect(app.server.devices.last, containsPair('token', 'phone-token-2'));
    expect(app.server.devices.last, containsPair('locale', 'bn'));
    expect(phone.dailyTitle, 'আজ কিছু খরচ করেছেন?');

    await app.run(app.container.read(authControllerProvider.notifier).logOut());
    await app.settle();
    expect(app.server.devices.where((device) => device['token'] == 'phone-token-2'), isEmpty);
    expect(app.server.pushCalls.sublist(app.server.pushCalls.length - 2), ['forget', 'logout']);
    expect(phone.daily, isNull);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('the server hears what the business widgets show, and their silent push shows nothing', (tester) async {
    final phone = FakePushService();
    final app = Harness(
      tester,
      FakeServer(onboardedAt: onboarded),
      overrides: [
        pushServiceProvider.overrideWithValue(phone),
        bizWidgetTargetSourceProvider.overrideWithValue(
          FixedTargets(const BizWidgetTargets(workspaces: {'shop'}, books: {'till', 'bank'})),
        ),
      ],
    );
    await app.start();
    await app.logIn();
    expect(app.server.devices.last, containsPair('widget_workspaces', ['shop']));
    expect(app.server.devices.last, containsPair('widget_books', ['bank', 'till']));

    phone.arrive(const PushMessage(data: {'kind': 'widgets', 'workspace_id': 'shop', 'seq': '9'}));
    await app.settle();
    expect(phone.shown, isEmpty);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('the app asks to show notifications once, on the home screen', (tester) async {
    final phone = FakePushService(permitted: false);
    final app = harness(tester, phone);
    await app.start();
    expect(phone.asked, 0);
    await app.logIn();
    expect(phone.asked, 1);
    expect(app.container.read(pushControllerProvider).allowed, isTrue);
    await app.run(app.container.read(pushControllerProvider.notifier).askOnce());
    expect(phone.asked, 1);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('a push that arrives is shown, and a tap opens the reminders', (tester) async {
    final phone = FakePushService();
    final app = harness(tester, phone);
    await app.start();
    await app.logIn();

    phone.arrive(const PushMessage(title: 'Rent is due today', body: 'BDT 1,500.00', data: {'route': '/inbox'}));
    await app.settle();
    expect(phone.shown.single.title, 'Rent is due today');
    expect(find.byType(InboxPage), findsNothing);

    phone.tap(const {'route': '/inbox', 'type': 'due'});
    await app.settle();
    expect(find.byType(InboxPage), findsOneWidget);
    await tester.pageBack();
    await app.settle();
    expect(find.text('Total balance'), findsOneWidget);

    // Somewhere a notification has no business sending the user
    phone.tap(const {'route': '/plan/keep'});
    await app.settle();
    expect(find.byType(InboxPage), findsOneWidget);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('the daily nudge follows the preferences and leaves out a day already written down', (tester) async {
    final phone = FakePushService();
    final app = harness(tester, phone);
    await app.start();
    await app.logIn();
    expect(phone.daily, (21, 0, false));
    expect(phone.dailyTitle, 'Did you spend anything today?');

    final push = app.container.read(pushControllerProvider.notifier);
    expect(await app.run(push.update({'nudge_time': '20:30:00'})), isTrue);
    expect(phone.daily, (20, 30, false));
    expect(app.server.notificationSettings['nudge_time'], '20:30:00');

    final cash = await app.run((app.db.select(app.db.accounts)..where((a) => a.id.equals(cashAccountId))).getSingle());
    await app.run(app.container.read(ledgerRepositoryProvider).addTransaction(
          cash,
          kind: 'expense',
          amountMinor: 5000,
          occurredOn: DateTime.now().toIso8601String().substring(0, 10),
        ));
    await app.settle();
    expect(phone.daily, (20, 30, true));

    expect(await app.run(push.update({'daily_nudge': false})), isTrue);
    expect(phone.daily, isNull);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('the notification settings screen changes what the server keeps', (tester) async {
    final phone = FakePushService(permitted: false);
    final server = FakeServer(onboardedAt: onboarded)..notificationSettings['budgets'] = false;
    final app = harness(tester, phone, server);
    await app.start();
    await app.logIn();
    phone.permitted = false; // taken back in the phone's settings

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await app.settle();
    await tester.dragUntilVisible(find.text('Notifications'), find.byType(ListView).last, const Offset(0, -150));
    await app.settle();
    await tester.tap(find.text('Notifications'));
    await app.settle();
    expect(find.byType(NotificationSettingsPage), findsOneWidget);
    expect(find.text('This phone is not letting Spendroo show notifications.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Allow notifications'));
    await app.settle();
    expect(find.text('This phone is not letting Spendroo show notifications.'), findsNothing);

    Switch toggle(String key) =>
        tester.widget<Switch>(find.descendant(of: find.byKey(Key('notif-$key')), matching: find.byType(Switch)));
    expect(toggle('budgets').value, isFalse);
    expect(toggle('bills').value, isTrue);

    await tester.tap(find.byKey(const Key('notif-budgets')));
    await app.settle();
    expect(server.notificationSettings['budgets'], isTrue);
    expect(toggle('budgets').value, isTrue);

    await tester.dragUntilVisible(find.byKey(const Key('notif-quiet')), find.byType(ListView).last, const Offset(0, -150));
    await app.settle();
    await tester.tap(find.byKey(const Key('notif-quiet')));
    await app.settle();
    expect((server.notificationSettings['quiet_from'], server.notificationSettings['quiet_to']), ('22:00:00', '07:00:00'));

    await tester.dragUntilVisible(find.text('Send a test notification'), find.byType(ListView).last, const Offset(0, -150));
    await app.settle();
    await tester.tap(find.text('Send a test notification'));
    await app.settle();
    expect(server.pushTests, 1);
    expect(find.text('Sent. It should arrive in a moment.'), findsOneWidget);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 90)));
}
