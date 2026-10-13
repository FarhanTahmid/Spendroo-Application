# Releasing the Android app

## Flavours

| Flavour | Application ID | Config | Talks to | Use |
|---|---|---|---|---|
| `dev` | `<id>.dev` | `config/dev.json` | a local `runserver` (plain HTTP allowed) | development |
| `staging` | `<id>.stg` | `config/staging.json` | the staging API (HTTPS) | testers, closed beta stage 1 |
| `prod` | `<id>` | `config/prod.json` | production (HTTPS) | Play Store |

`<id>` is `baseApplicationId` in `android/app/build.gradle.kts`: `com.spendroo.app`
(the company owns spendroo.com).

Dev and staging builds show **Settings → Server**, where a tester can point the
app at another API (for example a Cloudflare tunnel to a developer's machine).
Switching signs out and clears the phone. Prod builds always use `API_URL`.

## Signing

`android/key.properties` (gitignored) points at the upload keystore:

```
storeFile=C:/path/to/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

- With it, debug and release builds are signed with that key (so the SHA-1
  registered for Google sign-in matches in both).
- Without it (CI, a fresh clone), debug builds use Android's default debug key
  and release builds stop with an error instead of producing an unsigned package.

Keep the keystore and its passwords outside the repository and backed up. Once
Play App Signing is on, Google holds the app signing key; losing the upload key
is recoverable through Play Console support, but slowly.

## Build

```
# Dev, for the emulator or a USB phone
flutter build apk --debug --flavor dev --dart-define-from-file=config/dev.json

# Staging APK for testers (stage 1 of the beta)
flutter build apk --release --flavor staging --dart-define-from-file=config/staging.json --build-number=<n>

# Play upload
flutter build appbundle --release --flavor prod --dart-define-from-file=config/prod.json --build-number=<n>
```

`--build-number` becomes the Android `versionCode`; every upload needs a higher
one. The version name comes from `version:` in `pubspec.yaml`.

## The application ID

The ID is `com.spendroo.app`. Play never allows it to change after the first
upload, even to a test track. Before that upload it can still be changed:

1. `python tool/set_app_id.py <id>` — updates `baseApplicationId`, `namespace`,
   the Kotlin package of `MainActivity.kt` and the iOS bundle IDs.
2. `flutter clean`, rebuild, run the app.

### Accounts that must match the ID

- **Google sign-in:** create Android OAuth clients in Google Cloud for
  `<id>`, `<id>.stg` and `<id>.dev`, each with the SHA-1 of the key that signs
  it (`keytool -list -v -keystore <keystore>`; for Play builds also add the
  Play App Signing SHA-1 from Play Console). The Android clients only have to
  exist, in the same Google Cloud project as a **Web application** client: the
  app asks for a token made for the web client. Put that web client ID in
  `GOOGLE_SERVER_CLIENT_ID` in the config files and in the API's
  `WEB_OAUTH2_CLIENT_ID`; the two must be the same value.
  A missing or wrong SHA-1 shows up as the Google sheet closing at once, as if
  the user had backed out. iOS also needs its own client ID as `GIDClientID`
  and the reversed ID as a URL scheme in `ios/Runner/Info.plist`.
- **Firebase:** the Firebase project is `spendroo-dev`, the same Google Cloud
  project as the OAuth clients, on the free Spark plan (keep it without a
  billing account). The three IDs are registered there as Android apps and
  `android/app/google-services.json` lists all three; it holds no secrets and
  is committed. The app starts Firebase on Android in `lib/core/firebase.dart`.
  After adding a signing key (a new upload key, the Play App Signing key), add
  its SHA-1 and SHA-256 to each app (Firebase console → Project settings →
  Your apps → Add fingerprint), download `google-services.json` again and
  replace the file. If the ID ever changes, register the new IDs the same way.
  iOS is not registered yet.
- **API:** production is `https://api.spendroo.com` and staging
  `https://staging-api.spendroo.com` (`config/prod.json`, `config/staging.json`);
  set the API's `ALLOWED_HOSTS`/`CSRF_TRUSTED_ORIGINS` to match.

## Closed beta

### Stage 1 — staging APK, shared directly (possible now)

1. Run staging as described in the API's `docs/staging-local.md` and note the
   tunnel address it prints.
2. Build the staging APK (above) and share `build/app/outputs/flutter-apk/app-staging-release.apk`.
3. Testers install it (allow "install unknown apps"), open **Settings → Server**,
   paste the tunnel address, then sign up. Email codes arrive from the
   SMTP account configured for staging.
4. Set `FEEDBACK_EMAIL` in `config/staging.json` to show a "Send feedback" entry.

Instead of sharing the file by hand, send it through Firebase App Distribution
(free). Testers get an email with an install link:

```
npx -y firebase-tools appdistribution:distribute build/app/outputs/flutter-apk/app-staging-release.apk \
  --project spendroo-dev --app 1:1035441867051:android:a3999ce38cd6e60dfa5d6e \
  --groups testers --release-notes "<what changed>"
```

Add testers with `npx -y firebase-tools appdistribution:testers:add --project spendroo-dev --group-alias testers <email> ...`.

The quick-tunnel address changes whenever the tunnel restarts; testers then
update **Settings → Server**. A named tunnel on a real domain removes this step.

### Stage 2 — Play closed testing (needs the founder's accounts)

- [x] Final application ID chosen and applied (`com.spendroo.app`)
- [ ] Play Console developer account
- [ ] Privacy policy URL (e.g. `https://spendroo.com/privacy`), Data safety form, content rating, app category
- [ ] Upload keystore created; Play App Signing enabled on first upload
- [ ] Stable staging host (named tunnel or server) in a `config/beta.json`, or production live
- [ ] Google OAuth clients for the new IDs
- [ ] `flutter build appbundle --flavor prod ...` uploaded to the closed testing track

New personal Play developer accounts must run a closed test with at least
12 testers for 14 consecutive days before they can apply for production access,
so gather the tester list early.
