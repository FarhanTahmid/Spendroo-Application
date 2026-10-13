import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:spendroo/core/api/api_client.dart';
import 'package:spendroo/core/auth/auth_repository.dart';
import 'package:spendroo/core/auth/google_identity.dart';
import 'package:spendroo/core/providers.dart';

import 'app_flow_test.dart' show FakeServer, Harness;

const onboarded = '2026-10-01T00:00:00Z';
const webClientId = 'web-client.apps.googleusercontent.com';

/// Stands in for Google's account sheet.
class FakeGoogleIdentity implements GoogleIdentity {
  FakeGoogleIdentity({this.isAvailable = true});

  @override
  final bool isAvailable;

  @override
  String get clientId => webClientId;

  /// What the sheet gives back; null is the user backing out.
  String? token = 'good-id-token';

  /// Set to make Google itself fail.
  GoogleIdentityException? failure;

  var asked = 0;
  var signOuts = 0;

  @override
  Future<String?> idToken() async {
    asked++;
    if (failure != null) throw failure!;
    return token;
  }

  @override
  Future<void> signOut() async => signOuts++;
}

final googleButton = find.widgetWithText(OutlinedButton, 'Continue with Google');

Future<Harness> openLogin(WidgetTester tester, FakeServer server, FakeGoogleIdentity google) async {
  final app = Harness(tester, server, overrides: [googleIdentityProvider.overrideWithValue(google)]);
  await app.start();
  return app;
}

void main() {
  test('the ID token goes to the server with the client it was made for', () async {
    final server = FakeServer();
    final store = MemoryTokenStore();
    final auth = AuthRepository(ApiClient(baseUrl: 'http://api.test', tokenStore: store, httpClient: MockClient(server.handle)));

    final result = await auth.logInWithGoogle(idToken: 'good-id-token', clientId: webClientId);
    expect(result.step, AuthStep.signedIn);
    expect(store.token, 'token-1');
    expect(server.googleLogins.single, {
      'provider': 'google',
      'process': 'login',
      'token': {'client_id': webClientId, 'id_token': 'good-id-token'},
    });

    final refused = await auth.logInWithGoogle(idToken: 'forged', clientId: webClientId);
    expect((refused.step, refused.error), (null, 'The token is invalid.'));
  });

  testWidgets('no Google button when this build has no Google sign-in', (tester) async {
    final app = await openLogin(tester, FakeServer(), FakeGoogleIdentity(isAvailable: false));
    expect(find.text('Log in'), findsWidgets);
    expect(googleButton, findsNothing);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('continue with Google signs in without filling the form', (tester) async {
    final server = FakeServer(onboardedAt: onboarded);
    final google = FakeGoogleIdentity();
    final app = await openLogin(tester, server, google);

    await tester.tap(googleButton);
    await app.settle();
    expect(find.text('Enter your email or username'), findsNothing);
    expect(server.googleLogins.single['token'], {'client_id': webClientId, 'id_token': 'good-id-token'});
    expect(server.logins, isEmpty);
    expect(find.text('Total balance'), findsOneWidget);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('continue with Google from the sign-up screen', (tester) async {
    final server = FakeServer(onboardedAt: onboarded);
    final app = await openLogin(tester, server, FakeGoogleIdentity());
    await tester.tap(find.text('New here? Create an account'));
    await app.settle();
    expect(find.text('Confirm password'), findsOneWidget);

    // The login screen is still sliding away underneath
    await tester.tap(googleButton.last);
    await app.settle();
    expect(server.signups, isEmpty);
    expect(server.googleLogins, hasLength(1));
    expect(find.text('Total balance'), findsOneWidget);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('backing out of Google stays on the login screen and says nothing', (tester) async {
    final server = FakeServer();
    final google = FakeGoogleIdentity()..token = null;
    final app = await openLogin(tester, server, google);

    await tester.tap(googleButton);
    await app.settle();
    expect(google.asked, 1);
    expect(server.googleLogins, isEmpty);
    expect(find.byType(SnackBar), findsNothing);
    expect(googleButton, findsOneWidget);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('a Google failure is explained in the app\'s own words', (tester) async {
    final server = FakeServer();
    final google = FakeGoogleIdentity()..failure = const GoogleIdentityException('clientConfigurationError: 10');
    final app = await openLogin(tester, server, google);

    await tester.tap(googleButton);
    await app.settle();
    expect(find.text('Could not sign in with Google. Try again.'), findsOneWidget);
    expect(find.textContaining('clientConfigurationError'), findsNothing);
    expect(server.googleLogins, isEmpty);

    // The button works again afterwards
    google.failure = null;
    await tester.tap(googleButton);
    await app.settle();
    expect(server.googleLogins, hasLength(1));
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('a token the server refuses shows what the server said', (tester) async {
    final server = FakeServer();
    final google = FakeGoogleIdentity()..token = 'forged';
    final app = await openLogin(tester, server, google);

    await tester.tap(googleButton);
    await app.settle();
    expect(find.text('The token is invalid.'), findsOneWidget);
    expect(googleButton, findsOneWidget);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('a step the app has no screen for is a failure, not a silent return', (tester) async {
    final server = FakeServer()..googleStatus = 401;
    final app = await openLogin(tester, server, FakeGoogleIdentity());

    await tester.tap(googleButton);
    await app.settle();
    expect(find.text('Could not sign in with Google. Try again.'), findsOneWidget);
    expect(googleButton, findsOneWidget);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('logging out also signs out of Google', (tester) async {
    final server = FakeServer(onboardedAt: onboarded);
    final google = FakeGoogleIdentity();
    final app = await openLogin(tester, server, google);
    await tester.tap(googleButton);
    await app.settle();
    expect(google.signOuts, 0);

    await app.run(app.container.read(authControllerProvider.notifier).logOut());
    await app.settle();
    expect(google.signOuts, 1);
    expect(googleButton, findsOneWidget);
    await app.stop();
  }, timeout: const Timeout(Duration(seconds: 60)));
}
