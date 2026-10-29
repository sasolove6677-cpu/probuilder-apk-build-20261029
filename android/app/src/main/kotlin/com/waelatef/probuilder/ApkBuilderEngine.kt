package com.waelatef.probuilder

import android.Manifest
import android.content.ContentValues
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.UUID

/** Builds an installable WebView APK on the device from one HTML/HTM file. */
class ApkBuilderEngine(private val context: Context) {
    fun build(htmlPath: String?): Map<String, Any?> {
        val html = htmlPath?.let(::File)
        if (html == null || !html.isFile || !html.canRead()) {
            return failure("INVALID_HTML", "The selected HTML file is missing or unreadable.")
        }
        if (html.extension.lowercase() !in setOf("html", "htm")) {
            return failure("UNSUPPORTED_FILE", "Select an .html or .htm file.")
        }
        if (html.length() > MAX_HTML_BYTES) {
            return failure("FILE_TOO_LARGE", "HTML input exceeds the 100 MB limit.")
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q &&
            context.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
        ) {
            return failure("STORAGE_PERMISSION_REQUIRED", "Allow storage access to save the APK in Downloads.")
        }

        val workDir = File(context.cacheDir, "pro-builder-${UUID.randomUUID()}")
        if (!workDir.mkdirs()) {
            return failure("CACHE_UNAVAILABLE", "Could not create temporary build files.")
        }

        try {
            val templateApk = File(workDir, "template.apk")
            val keystore = File(workDir, ApkTemplateSigning.KEYSTORE_ASSET)
            val unsignedApk = File(workDir, "modified-unsigned.apk")
            val signedApk = File(workDir, "modified-signed.apk")

            try {
                context.assets.open(TEMPLATE_ASSET).use { input ->
                    FileOutputStream(templateApk).use { output -> input.copyTo(output) }
                }
            } catch (_: IOException) {
                return failure("TEMPLATE_MISSING", "This Pro Builder build does not contain its WebView template.")
            }

            try {
                context.assets.open(ApkTemplateSigning.KEYSTORE_ASSET).use { input ->
                    FileOutputStream(keystore).use { output -> input.copyTo(output) }
                }
            } catch (_: IOException) {
                return failure("SIGNING_KEY_MISSING", "The test signing key is missing from this build.")
            }

            ApkTemplateAssembler.injectHtml(templateApk, html, unsignedApk)
            ApkTemplateSigning.sign(unsignedApk, signedApk, keystore)
            val outputName = makeOutputName(html)
            val savedLocation = saveToDownloads(signedApk, outputName)

            return mapOf(
                "success" to true,
                "errorCode" to null,
                "message" to "APK created: Downloads/ProBuilder/$outputName",
                "apkPath" to savedLocation,
            )
        } catch (error: Exception) {
            return failure(
                "BUILD_FAILED",
                "APK creation failed: ${error.localizedMessage ?: error.javaClass.simpleName}",
            )
        } finally {
            workDir.deleteRecursively()
        }
    }

    private fun saveToDownloads(apk: File, outputName: String): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, outputName)
                put(MediaStore.MediaColumns.MIME_TYPE, APK_MIME_TYPE)
                put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/ProBuilder")
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val resolver = context.contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IOException("Could not create a Downloads entry.")
            try {
                val destination = resolver.openOutputStream(uri, "w")
                    ?: throw IOException("Could not open the Downloads entry.")
                destination.use { output ->
                    apk.inputStream().buffered().use { input -> input.copyTo(output) }
                }
                val published = ContentValues().apply {
                    put(MediaStore.MediaColumns.IS_PENDING, 0)
                }
                if (resolver.update(uri, published, null, null) <= 0) {
                    throw IOException("Could not publish the APK in Downloads.")
                }
            } catch (error: Exception) {
                resolver.delete(uri, null, null)
                throw error
            }
            return uri.toString()
        }

        @Suppress("DEPRECATION")
        val downloads = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            "ProBuilder",
        )
        if (!downloads.exists() && !downloads.mkdirs()) {
            throw IOException("Could not create the Downloads/ProBuilder folder.")
        }
        val destination = File(downloads, outputName)
        apk.inputStream().buffered().use { input ->
            FileOutputStream(destination).buffered().use { output -> input.copyTo(output) }
        }
        return destination.absolutePath
    }

    private fun makeOutputName(html: File): String =
        "${safeBaseName(html)}_${System.currentTimeMillis()}.apk"

    private fun safeBaseName(html: File): String {
        val safe = html.nameWithoutExtension
            .map { char -> if (char.isLetterOrDigit() || char == '-' || char == '_') char else '_' }
            .joinToString("")
            .trim('_')
            .take(48)
        return safe.ifBlank { "web_app" }
    }

    private fun failure(code: String, message: String): Map<String, Any?> = mapOf(
        "success" to false,
        "errorCode" to code,
        "message" to message,
        "apkPath" to null,
    )

    companion object {
        private const val TEMPLATE_ASSET = "template.apk"
        private const val APK_MIME_TYPE = "application/vnd.android.package-archive"
        private const val MAX_HTML_BYTES = 100L * 1024L * 1024L
    }
}
