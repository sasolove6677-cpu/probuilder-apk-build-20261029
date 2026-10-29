package com.waelatef.probuilder

import android.net.Uri
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.android.apksig.ApkVerifier
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipFile
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class ApkBuilderEngineInstrumentedTest {
    @Test
    fun buildsSignedHtmlApkAndSavesItToDownloads() {
        val context = ApplicationProvider.getApplicationContext<android.content.Context>()
        val htmlText = "<!doctype html><html><body><h1>On-device smoke test</h1></body></html>"
        val html = File(context.cacheDir, "instrumented-smoke.html").apply {
            writeText(htmlText, Charsets.UTF_8)
        }

        val outcome = ApkBuilderEngine(context).build(html.absolutePath)
        assertEquals("${outcome["errorCode"]}: ${outcome["message"]}", true, outcome["success"])
        val apkLocator = outcome["apkPath"] as? String
        assertNotNull("Builder did not return a Downloads URI", apkLocator)
        val apkUri = Uri.parse(apkLocator)
        val generated = File(context.cacheDir, "generated-smoke.apk")
        val input = context.contentResolver.openInputStream(apkUri)
        assertNotNull("The returned Downloads URI cannot be opened", input)
        input!!.use { source ->
            FileOutputStream(generated).use { destination -> source.copyTo(destination) }
        }

        val verification = ApkVerifier.Builder(generated).build().verify()
        assertTrue("Generated APK signature is invalid: $verification", verification.isVerified)
        ZipFile(generated).use { zip ->
            val htmlEntry = zip.getEntry("assets/index.html")
            assertNotNull("Generated APK is missing assets/index.html", htmlEntry)
            val packagedHtml = zip.getInputStream(htmlEntry).bufferedReader(Charsets.UTF_8).use { it.readText() }
            assertEquals(htmlText, packagedHtml)
        }
        context.contentResolver.delete(apkUri, null, null)
        html.delete()
        generated.delete()
    }
}
