# Pro Builder

Starter project for the Pro Builder Flutter interface: dark glassmorphism dashboard, Arabic/English localization, project customization form, icon preview, Android MethodChannel boundary, and an Android WebView source template.

## Important build-engine limitation

The app's Kotlin `ApkBuilderEngine` validates the request and returns `HOST_BUILDER_REQUIRED`; it does **not** pretend to have created an APK. An Android APK cannot reliably be compiled inside an ordinary Android app because the Android SDK and Gradle build toolchain are not present there. The included template can instead be packaged from a computer with a JDK, Gradle, and Android SDK. The provided shell script creates a **debug-signed test APK**, not a production release. ZIP and PDF selection is shown in the UI, but the source template currently packages HTML/HTM only.

The `apksig` and BouncyCastle Gradle dependencies are included as requested for a future signing implementation. The current app does not embed or distribute a private release key.

## Requirements

- Flutter SDK 3.27 or newer (Dart 3.6+ recommended)
- Android Studio with Android SDK and platform tools
- JDK 17
- For template APK generation: Gradle 8.7 available on `PATH`

## Run the Flutter app

From the project root, run these commands:

```bash
flutter doctor
flutter doctor --android-licenses
flutter pub get
dart run flutter_launcher_icons
flutter run
```

To build the Flutter Android app for installation:

```bash
flutter build apk --debug
```

## Build a sample WebView APK from HTML

On Linux/macOS, from the project root:

```bash
chmod +x tools/build_template_apk.sh
./tools/build_template_apk.sh /absolute/path/to/page.html "My Web App" com.example.mywebapp /absolute/path/to/icon.png
```

The icon argument is optional; if omitted, the attached project icon is used. The generated file is saved under `~/Downloads/ProBuilder/`. The script accepts only `.html`/`.htm`, embeds the page as `assets/index.html`, patches the package name and displayed app name, and uses Gradle's debug signing. For distribution, configure your own release signing credentials securely; never put a production keystore password or private key in source control or ship it inside the app.

## Project map

- `lib/main.dart`: app shell, locale state binding, and floating bottom navigation.
- `lib/screens/dashboard_screen.dart`: dashboard/projects Bento-style UI and sample projects.
- `lib/screens/customization_screen.dart`: input selection, app metadata, icon preview, and native call.
- `lib/screens/settings_screen.dart`: live AR/EN toggle, output directory display, version, branding.
- `lib/widgets/glass_card.dart`: reusable blurred glass card.
- `lib/l10n/`: in-app localization and ARB translation resources.
- `android/app/src/main/kotlin/com/waelatef/probuilder/`: Android MethodChannel and explicit build-engine boundary.
- `template_webview_source/`: standalone Android WebView template source (no `template.apk` binary required).
- `tools/build_template_apk.sh`: workstation-side debug APK generator from HTML.
- `assets/launcher_icon.png`: the provided launcher artwork.
