package com.waelatef.probuilder

import java.io.File

/**
 * Native MethodChannel boundary for APK builds.
 *
 * An Android app cannot safely run the Android Gradle Plugin/SDK as an embedded build tool.
 * This class validates the incoming request and returns an explicit host-builder requirement;
 * it intentionally never reports success or returns a fake APK path. The separately supplied
 * template_webview_source and tools/build_template_apk.sh perform a debug build on a computer.
 */
class ApkBuilderEngine {
    fun build(
        htmlPath: String?,
        appName: String?,
        packageName: String?,
        iconPath: String?,
    ): Map<String, Any?> {
        val html = htmlPath?.let(::File)
        val safeName = appName?.trim().orEmpty()
        val safePackage = packageName?.trim().orEmpty()

        if (html == null || !html.isFile || !html.canRead()) {
            return failure("INVALID_HTML", "The selected HTML file is missing or unreadable.")
        }
        val extension = html.extension.lowercase()
        if (extension != "html" && extension != "htm") {
            return failure("UNSUPPORTED_FILE", "The source template currently accepts HTML/HTM files only.")
        }
        if (html.length() > MAX_HTML_BYTES) {
            return failure("FILE_TOO_LARGE", "HTML input exceeds the 100 MB limit.")
        }
        if (safeName.isBlank()) {
            return failure("INVALID_APP_NAME", "App name cannot be empty.")
        }
        if (!PACKAGE_PATTERN.matches(safePackage)) {
            return failure("INVALID_PACKAGE_NAME", "Use a package name such as com.example.app.")
        }
        if (!iconPath.isNullOrBlank()) {
            val icon = File(iconPath)
            if (!icon.isFile || !icon.canRead()) {
                return failure("INVALID_ICON", "The selected icon is missing or unreadable.")
            }
        }

        return failure(
            "HOST_BUILDER_REQUIRED",
            "Request validated. To create the APK, run tools/build_template_apk.sh on a computer with JDK, Gradle and Android SDK installed. The Android app itself does not embed those build tools.",
        )
    }

    private fun failure(code: String, message: String): Map<String, Any?> = mapOf(
        "success" to false,
        "errorCode" to code,
        "message" to message,
        "apkPath" to null,
    )

    companion object {
        private const val MAX_HTML_BYTES = 100L * 1024L * 1024L
        private val PACKAGE_PATTERN = Regex("^[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)+$")
    }
}
