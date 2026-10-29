# Pro Builder

Pro Builder is a Flutter app with an Arabic/English interface and an Android-native HTML-to-APK builder. The user selects one `.html` or `.htm` file; the app injects it into the bundled WebView template, signs the modified APK with apksig, and saves it in `Downloads/ProBuilder`.

## Cloud build pipeline

The GitHub Actions workflow builds `template_webview_source` into a real debug-signed `template.apk`, creates a test-only JKS debug key, and places both at `android/app/src/main/assets/` before building Pro Builder. It runs a JVM smoke test that replaces `assets/index.html` and verifies the resulting APK signature, then publishes the installable Pro Builder APK as a GitHub Release asset.

A locally downloaded source tree does not include the generated APK template or key. Run the Actions workflow to generate them; the workflow creates these files during CI and keeps the binary template and key out of source control.

## Using the on-device builder

1. Install Pro Builder on an Android phone.
2. Choose one readable `.html` or `.htm` file (maximum 100 MB).
3. Tap **Build APK on this phone**. The modified template is signed locally and saved in `Downloads/ProBuilder`.

Android 10 and newer use the Downloads MediaStore collection and return a `content://` URI to Flutter. Android 6–9 request storage permission and return the saved file path.

The template packages only the selected HTML file. Keep CSS, JavaScript, and images inline or reference them using reachable HTTPS URLs; separate local files are not bundled. Generated wrappers use the fixed application ID `com.example.probuildertemplate` and the fixed launcher label `Pro Builder Web`, so installing another generated wrapper replaces the previous one rather than installing side by side.

## Debug signing notice

The bundled JKS is a public, test-only Android debug key with the standard debug password. It is intentionally included so the app can sign generated test APKs on-device. Anyone with the Pro Builder APK can extract it. Do not use this key for production, commercial releases, trusted updates, or any app whose signing identity must remain private. Use a protected release key and a controlled signing service for production distribution.

## Requirements and commands

The hosted workflow uses Java 17, Gradle 8.13, Flutter 3.47.8, and Android SDK tools. To run the Flutter app locally after running the template-generation steps in the workflow:

```bash
flutter pub get
dart run flutter_launcher_icons
flutter run
```

Build the Pro Builder app locally after both generated assets exist:

```bash
flutter build apk --debug
```

The standalone `tools/build_template_apk.sh` remains available for host-side packaging when a JDK, Gradle, and Android SDK are installed. It is not required for builds initiated inside the installed Pro Builder app.

## Project map

- `lib/main.dart`: app startup, locale binding, and DashboardScreen entry point.
- `lib/screens/customization_screen.dart`: HTML-only picker and native build request.
- `lib/services/build_service.dart`: Flutter MethodChannel response handling.
- `android/app/src/main/kotlin/com/waelatef/probuilder/`: template injection, apksig signing, Downloads output, and permission handling.
- `template_webview_source/`: source for the embedded Android WebView wrapper.
- `.github/workflows/android-apk.yml`: CI template build, signing smoke test, and release publishing.
