package com.waelatef.probuilder

import com.android.apksig.ApkSigner
import java.security.Security
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.security.KeyFactory
import java.security.PrivateKey
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import java.security.spec.PKCS8EncodedKeySpec
import org.bouncycastle.jce.provider.BouncyCastleProvider

/** Signs the injected template using a test-only, unencrypted PKCS#8 RSA key. */
internal object ApkTemplateSigning {
    const val PRIVATE_KEY_ASSET = "probuilder-debug.pk8"
    const val CERTIFICATE_ASSET = "probuilder-debug-cert.der"
    private const val SIGNER_NAME = "androiddebugkey"

    init {
        if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
            Security.addProvider(BouncyCastleProvider())
        }
    }

    fun sign(
        unsignedApk: File,
        signedApk: File,
        privateKeyFile: File,
        certificateFile: File,
    ) {
        if (!unsignedApk.isFile || !unsignedApk.canRead()) {
            throw IOException("The modified APK is missing or unreadable.")
        }
        if (!privateKeyFile.isFile || !privateKeyFile.canRead()) {
            throw IOException("The APK signing private key is missing or unreadable.")
        }
        if (!certificateFile.isFile || !certificateFile.canRead()) {
            throw IOException("The APK signing certificate is missing or unreadable.")
        }

        val privateKey = try {
            val encodedKey = FileInputStream(privateKeyFile).use { it.readBytes() }
            loadPrivateKey(encodedKey)
        } catch (error: Exception) {
            throw IOException("The Android-compatible PKCS#8 signing key could not be loaded.", error)
        }

        val certificate = try {
            FileInputStream(certificateFile).use { input ->
                CertificateFactory.getInstance("X.509").generateCertificate(input) as? X509Certificate
                    ?: throw IOException("The APK signing certificate is not an X.509 certificate.")
            }
        } catch (error: Exception) {
            throw IOException("The APK signing X.509 certificate could not be loaded.", error)
        }

        val signer = ApkSigner.SignerConfig.Builder(
            SIGNER_NAME,
            privateKey,
            listOf(certificate),
        ).build()

        ApkSigner.Builder(listOf(signer))
            .setInputApk(unsignedApk)
            .setOutputApk(signedApk)
            .setMinSdkVersion(23)
            .setV1SigningEnabled(true)
            .setV2SigningEnabled(true)
            .setV3SigningEnabled(true)
            .build()
            .sign()
    }

    private fun loadPrivateKey(encodedKey: ByteArray): PrivateKey {
        val keySpec = PKCS8EncodedKeySpec(encodedKey)
        return try {
            KeyFactory.getInstance("RSA", BouncyCastleProvider.PROVIDER_NAME)
                .generatePrivate(keySpec)
        } catch (bouncyCastleError: Exception) {
            try {
                KeyFactory.getInstance("RSA").generatePrivate(keySpec)
            } catch (platformError: Exception) {
                platformError.addSuppressed(bouncyCastleError)
                throw platformError
            }
        }
    }
}
