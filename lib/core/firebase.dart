import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Whether Firebase started: without it there is no push.
var firebaseStarted = false;

/// Starts Firebase from the flavour's `google-services.json`. Android only for
/// now. The app works offline, so a failure here is logged and never stops it.
Future<void> initFirebase() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await Firebase.initializeApp();
    firebaseStarted = true;
  } catch (error, stack) {
    debugPrint('Firebase did not start: $error\n$stack');
  }
}
