package com.waelatef.probuilder

import com.android.apksig.ApkVerifier
import java.io.File
import java.nio.file.Files
import java.util.zip.ZipFile
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ApkTemplateBuildTest {
    @Test
    fun replacesHtmlAndProducesAValidSignedApk() {
        val template = projectAsset("template.apk")
        val privateKey = projectAsset(ApkTemplateSigning.PRIVATE_KEY_ASSET)
        val certificate = projectAsset(ApkTemplateSigning.CERTIFICATE_ASSET)
        val work = Files.createTempDirectory("pro-builder-apk-test").toFile()
        try {
            val htmlText = "<!doctype html><html><body><h1>Device builder smoke test</h1></body></html>"
            val html = File(work, "sample.html").apply { writeText(htmlText, Charsets.UTF_8) }
            val unsigned = File(work, "injected-unsigned.apk")
            val signed = File(work, "injected-signed.apk")

            ApkTemplateAssembler.injectHtml(template, html, unsigned)
            ApkTemplateSigning.sign(unsigned, signed, privateKey, certificate)

            val verification = ApkVerifier.Builder(signed).build().verify()
            assertTrue("ApkSig did not verify the injected APK: $verification", verification.isVerified)
            ZipFile(signed).use { zip ->
                val htmlEntry = zip.getEntry("assets/index.html")
                assertNotNull("The generated APK is missing assets/index.html", htmlEntry)
                val actual = zip.getInputStream(htmlEntry).bufferedReader(Charsets.UTF_8).use { it.readText() }
                assertEquals(htmlText, actual)
            }
        } finally {
            work.deleteRecursively()
        }
    }

    private fun projectAsset(name: String): File {
        val candidates = listOf(
            File("src/main/assets/$name"),
            File("app/src/main/assets/$name"),
            File("android/app/src/main/assets/$name"),
        )
        return candidates.firstOrNull { it.isFile }
            ?: throw AssertionError("Generated Android asset is missing: $name")
    }
}
