import 'package:google_sign_in/google_sign_in.dart';

/// Google could not sign the user in. [reason] is for logs, not for the screen.
class GoogleIdentityException implements Exception {
  const GoogleIdentityException(this.reason);

  final String reason;

  @override
  String toString() => 'GoogleIdentityException: $reason';
}

/// Google's part of signing in: it says who the user is with an ID token, and
/// the server checks that token and opens the session.
abstract class GoogleIdentity {
  /// False hides the button: no client ID in this build, or a platform without Google's sign-in sheet.
  bool get isAvailable;

  /// The OAuth client the ID token is made for. The server needs it to check the token.
  String get clientId;

  /// Shows Google's account sheet. Null when the user backed out.
  Future<String?> idToken();

  /// Forgets the chosen account, so the next sign-in asks which one to use.
  Future<void> signOut();
}

class GoogleSignInIdentity implements GoogleIdentity {
  GoogleSignInIdentity(this.clientId);

  /// The web client ID: Google puts it in the token as the audience, on Android and iOS alike.
  @override
  final String clientId;

  /// The plugin may be initialised only once.
  Future<void>? _ready;

  @override
  bool get isAvailable => clientId.isNotEmpty && GoogleSignIn.instance.supportsAuthenticate();

  Future<void> _initialize() => _ready ??= GoogleSignIn.instance.initialize(serverClientId: clientId).onError((error, stack) {
        _ready = null; // let the next tap try again
        Error.throwWithStackTrace(error!, stack);
      });

  @override
  Future<String?> idToken() async {
    try {
      await _initialize();
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null) throw const GoogleIdentityException('no ID token');
      return token;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      throw GoogleIdentityException('${error.code.name}: ${error.description}');
    }
  }

  @override
  Future<void> signOut() async {
    if (!isAvailable) return;
    try {
      await _initialize();
      await GoogleSignIn.instance.signOut();
    } on GoogleSignInException {
      // The Spendroo session is closed either way
    }
  }
}
