import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config.dart';
import 'core/db/database.dart';
import 'core/firebase.dart';
import 'core/providers.dart';
import 'features/home_widget/business/biz_widget_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  // Teammates' changes reach the business widgets while the app is closed
  if (firebaseStarted) FirebaseMessaging.onBackgroundMessage(bizWidgetPushHandler);
  unawaited(registerBizWidgetCallback());
  final db = AppDatabase();
  final server = AppConfig.allowsServerOverride ? await db.getSetting(serverUrlSettingKey) : null;
  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      serverUrlProvider.overrideWith(() => ServerUrlController(server)),
    ],
    child: const SpendrooApp(),
  ));
}
 