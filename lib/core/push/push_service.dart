import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../firebase.dart';

/// A notification as the app handles it: what it says, and what it is about.
class PushMessage {
  const PushMessage({this.title, this.body, this.data = const {}});

  final String? title;
  final String? body;

  /// From the server (notifications/delivery.py there): `route` is the screen a tap opens.
  final Map<String, String> data;
}

/// What the phone does for notifications. The app talks to this, so tests
/// can stand in for Firebase and the system tray.
abstract class PushService {
  /// Starts listening. [onMessage] is a push that arrived while the app is
  /// open; [onOpen] is a notification the user tapped, also the one that
  /// started the app.
  Future<void> start({
    required void Function(PushMessage message) onMessage,
    required void Function(Map<String, String> data) onOpen,
  });

  /// The phone's address for push; null when there is none (no Play services, offline at first launch).
  Future<String?> token();

  /// Firebase gives the phone a new address now and then.
  Stream<String> get tokenChanges;

  /// Whether the user lets the app show notifications.
  Future<bool> allowed();

  /// Asks for that. On Android 13 and later the system shows its question, once.
  Future<bool> ask();

  /// The phone's time zone as an IANA name, such as Asia/Dhaka.
  Future<String?> timeZone();

  /// Puts a notification in the tray now.
  Future<void> show(PushMessage message);

  /// One notification every day at this time, on the phone's own clock. It
  /// replaces the one set before. [fromTomorrow] leaves today's out.
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required bool fromTomorrow,
    required String title,
    required String body,
  });

  Future<void> cancelDaily();
}

/// Where there is no push: iOS for now, tests, a phone without Firebase.
class NoPushService implements PushService {
  const NoPushService();

  @override
  Future<void> start({
    required void Function(PushMessage message) onMessage,
    required void Function(Map<String, String> data) onOpen,
  }) async {}

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenChanges => const Stream.empty();

  @override
  Future<bool> allowed() async => false;

  @override
  Future<bool> ask() async => false;

  @override
  Future<String?> timeZone() async => null;

  @override
  Future<void> show(PushMessage message) async {}

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required bool fromTomorrow,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelDaily() async {}
}

/// Firebase Cloud Messaging for what the server sends, and the phone's own
/// notifications for what is shown while the app is open and for the daily nudge.
class FirebasePushService implements PushService {
  /// The channel the server names (notifications/push.py there) and the manifest defaults to.
  static const _reminders = AndroidNotificationChannel(
    'reminders',
    'Reminders',
    description: 'Bills, income and budgets',
    importance: Importance.high,
  );
  static const _daily = AndroidNotificationChannel(
    'daily',
    'Daily nudge',
    description: 'A reminder to write down the day',
  );
  static const _icon = 'ic_stat_spendroo';
  static const _dailyId = 1;

  final _local = FlutterLocalNotificationsPlugin();
  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  var _nextId = 100;

  @override
  Future<void> start({
    required void Function(PushMessage message) onMessage,
    required void Function(Map<String, String> data) onOpen,
  }) async {
    void opened(String? payload) {
      if (payload == null || payload.isEmpty) return;
      try {
        onOpen((jsonDecode(payload) as Map).map((key, value) => MapEntry('$key', '$value')));
      } on FormatException {
        // Not one of ours
      }
    }

    try {
      await _local.initialize(
        settings: const InitializationSettings(android: AndroidInitializationSettings(_icon)),
        onDidReceiveNotificationResponse: (response) => opened(response.payload),
      );
      await _android?.createNotificationChannel(_reminders);
      await _android?.createNotificationChannel(_daily);

      FirebaseMessaging.onMessage.listen((message) => onMessage(_read(message)));
      FirebaseMessaging.onMessageOpenedApp.listen((message) => onOpen(_read(message).data));

      // The app was closed and a tap on a notification opened it
      final first = await FirebaseMessaging.instance.getInitialMessage();
      if (first != null) {
        onOpen(_read(first).data);
      } else {
        final launch = await _local.getNotificationAppLaunchDetails();
        if (launch?.didNotificationLaunchApp ?? false) opened(launch!.notificationResponse?.payload);
      }
    } catch (error, stack) {
      debugPrint('Push did not start: $error\n$stack');
    }
  }

  PushMessage _read(RemoteMessage message) => PushMessage(
        title: message.notification?.title,
        body: message.notification?.body,
        data: message.data.map((key, value) => MapEntry(key, '$value')),
      );

  @override
  Future<String?> token() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (error) {
      debugPrint('No push token: $error');
      return null;
    }
  }

  @override
  Stream<String> get tokenChanges => FirebaseMessaging.instance.onTokenRefresh;

  @override
  Future<bool> allowed() async => await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<bool> ask() async => await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<String?> timeZone() async {
    try {
      return (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (error) {
      return null;
    }
  }

  @override
  Future<void> show(PushMessage message) => _local.show(
        id: _nextId++,
        title: message.title,
        body: message.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _reminders.id,
            _reminders.name,
            channelDescription: _reminders.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.data),
      );

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required bool fromTomorrow,
    required String title,
    required String body,
  }) async {
    tz_data.initializeTimeZones();
    final zone = await timeZone();
    tz.Location here;
    try {
      here = tz.getLocation(zone ?? 'UTC');
    } on Object {
      here = tz.UTC;
    }
    final now = tz.TZDateTime.now(here);
    var first = tz.TZDateTime(here, now.year, now.month, now.day, hour, minute);
    if (fromTomorrow || !first.isAfter(now)) first = first.add(const Duration(days: 1));
    await _local.zonedSchedule(
      id: _dailyId,
      title: title,
      body: body,
      scheduledDate: first,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(_daily.id, _daily.name, channelDescription: _daily.description),
      ),
      // Within a few minutes is close enough, and needs no extra permission
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: jsonEncode(const {'kind': 'nudge', 'route': '/'}),
    );
  }

  @override
  Future<void> cancelDaily() => _local.cancel(id: _dailyId);
}

final pushServiceProvider = Provider<PushService>(
  (ref) => firebaseStarted ? FirebasePushService() : const NoPushService(),
);
