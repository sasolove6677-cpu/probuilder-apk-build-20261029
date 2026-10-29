# Project files

This index links to the source and configuration files. CI generates the nested template APK and test signing key during the build; those binaries are not committed.

## Flutter source

- [lib/app_locale.dart](lib/app_locale.dart)
- [lib/app_theme.dart](lib/app_theme.dart)
- [lib/l10n/app_ar.arb](lib/l10n/app_ar.arb)
- [lib/l10n/app_en.arb](lib/l10n/app_en.arb)
- [lib/l10n/app_strings.dart](lib/l10n/app_strings.dart)
- [lib/main.dart](lib/main.dart)
- [lib/screens/customization_screen.dart](lib/screens/customization_screen.dart)
- [lib/screens/dashboard_screen.dart](lib/screens/dashboard_screen.dart)
- [lib/screens/settings_screen.dart](lib/screens/settings_screen.dart)
- [lib/services/build_service.dart](lib/services/build_service.dart)
- [lib/widgets/glass_card.dart](lib/widgets/glass_card.dart)

## Flutter configuration and documentation

- [.github/workflows/android-apk.yml](.github/workflows/android-apk.yml)
- [README.md](README.md)
- [pubspec.yaml](pubspec.yaml)

## Android host app

- [android/app/build.gradle](android/app/build.gradle)
- [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)
- [android/app/src/main/kotlin/com/waelatef/probuilder/ApkBuilderEngine.kt](android/app/src/main/kotlin/com/waelatef/probuilder/ApkBuilderEngine.kt)
- [android/app/src/main/kotlin/com/waelatef/probuilder/ApkTemplateAssembler.kt](android/app/src/main/kotlin/com/waelatef/probuilder/ApkTemplateAssembler.kt)
- [android/app/src/main/kotlin/com/waelatef/probuilder/ApkTemplateSigning.kt](android/app/src/main/kotlin/com/waelatef/probuilder/ApkTemplateSigning.kt)
- [android/app/src/main/kotlin/com/waelatef/probuilder/MainActivity.kt](android/app/src/main/kotlin/com/waelatef/probuilder/MainActivity.kt)
- [android/app/src/main/res/values/strings.xml](android/app/src/main/res/values/strings.xml)
- [android/app/src/main/res/values/styles.xml](android/app/src/main/res/values/styles.xml)
- [android/app/src/test/kotlin/com/waelatef/probuilder/ApkTemplateBuildTest.kt](android/app/src/test/kotlin/com/waelatef/probuilder/ApkTemplateBuildTest.kt)
- [android/app/src/androidTest/kotlin/com/waelatef/probuilder/ApkBuilderEngineInstrumentedTest.kt](android/app/src/androidTest/kotlin/com/waelatef/probuilder/ApkBuilderEngineInstrumentedTest.kt)
- [android/build.gradle](android/build.gradle)
- [android/gradle/wrapper/gradle-wrapper.jar](android/gradle/wrapper/gradle-wrapper.jar)
- [android/gradle/wrapper/gradle-wrapper.properties](android/gradle/wrapper/gradle-wrapper.properties)
- [android/gradle.properties](android/gradle.properties)
- [android/gradlew](android/gradlew)
- [android/gradlew.bat](android/gradlew.bat)
- [android/settings.gradle](android/settings.gradle)

## WebView APK template

- [template_webview_source/app/build.gradle](template_webview_source/app/build.gradle)
- [template_webview_source/app/src/main/AndroidManifest.xml](template_webview_source/app/src/main/AndroidManifest.xml)
- [template_webview_source/app/src/main/assets/index.html](template_webview_source/app/src/main/assets/index.html)
- [template_webview_source/app/src/main/java/com/waelatef/webtemplate/MainActivity.kt](template_webview_source/app/src/main/java/com/waelatef/webtemplate/MainActivity.kt)
- [template_webview_source/app/src/main/res/drawable-nodpi/launcher.png](template_webview_source/app/src/main/res/drawable-nodpi/launcher.png)
- [template_webview_source/app/src/main/res/values/strings.xml](template_webview_source/app/src/main/res/values/strings.xml)
- [template_webview_source/build.gradle](template_webview_source/build.gradle)
- [template_webview_source/gradle.properties](template_webview_source/gradle.properties)
- [template_webview_source/settings.gradle](template_webview_source/settings.gradle)

## Assets and tools

- [assets/launcher_icon.png](assets/launcher_icon.png)
- [tools/build_template_apk.sh](tools/build_template_apk.sh)
