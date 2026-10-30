package com.waelatef.webtemplate

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import android.webkit.WebChromeClient
import android.webkit.PermissionRequest
import android.webkit.WebView
import android.webkit.WebViewClient

class MainActivity : Activity() {
    private lateinit var webView: WebView
    private var pendingMediaRequest: PermissionRequest? = null

    @Suppress("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        webView = WebView(this).apply {
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.allowFileAccess = true
            settings.allowContentAccess = false
            addJavascriptInterface(SimBridge(this@MainActivity), "AndroidSIM")
            addJavascriptInterface(AndroidBridge(this@MainActivity), "AndroidBridge")
            webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView?, url: String?) {
                    super.onPageFinished(view, url)
                    view?.let(WebViewEventDispatcher::onPageReady)
                }
            }
            webChromeClient = object : WebChromeClient() {
                override fun onPermissionRequest(request: PermissionRequest) {
                    runOnUiThread {
                        val allowedResources = request.resources.filter { resource ->
                            resource == PermissionRequest.RESOURCE_VIDEO_CAPTURE ||
                                resource == PermissionRequest.RESOURCE_AUDIO_CAPTURE
                        }.toTypedArray()
                        val missing = REQUIRED_PERMISSIONS.filter {
                            checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED
                        }
                        if (allowedResources.isNotEmpty() &&
                            request.origin.toString().startsWith("file:", ignoreCase = true) &&
                            missing.isEmpty()
                        ) {
                            request.grant(allowedResources)
                        } else if (allowedResources.isNotEmpty() && missing.isNotEmpty()) {
                            pendingMediaRequest = request
                            requestPermissions(missing.toTypedArray(), REQUEST_MEDIA_PERMISSIONS)
                        } else {
                            request.deny()
                        }
                    }
                }
            }
        }
        WebViewEventDispatcher.attach(webView)
        setContentView(webView)
        webView.loadUrl("file:///android_asset/index.html")
        requestRuntimePermissionsIfNeeded()
    }

    private fun requestRuntimePermissionsIfNeeded() {
        val missing = REQUIRED_PERMISSIONS.filter {
            checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isNotEmpty()) {
            requestPermissions(
                missing.toTypedArray(),
                REQUEST_RUNTIME_PERMISSIONS,
            )
        }
    }

    internal fun requestSmsPermissions() {
        val missing = SMS_PERMISSIONS.filter {
            checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isNotEmpty()) {
            requestPermissions(missing.toTypedArray(), REQUEST_SMS_PERMISSIONS)
        }
    }

    internal fun requestCallLogPermission() {
        if (checkSelfPermission(Manifest.permission.READ_CALL_LOG) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(arrayOf(Manifest.permission.READ_CALL_LOG), REQUEST_CALL_LOG_PERMISSION)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_MEDIA_PERMISSIONS) return
        val request = pendingMediaRequest ?: return
        pendingMediaRequest = null
        if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
            request.grant(request.resources)
        } else {
            request.deny()
        }
    }

    internal fun openNotificationListenerSettings() {
        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
    }

    @Deprecated("Deprecated in Android SDK")
    override fun onBackPressed() {
        if (::webView.isInitialized && webView.canGoBack()) webView.goBack()
        else super.onBackPressed()
    }

    override fun onDestroy() {
        if (::webView.isInitialized) {
            WebViewEventDispatcher.detach(webView)
            webView.destroy()
        }
        super.onDestroy()
    }

    private companion object {
        const val REQUEST_RUNTIME_PERMISSIONS = 4101
        const val REQUEST_SMS_PERMISSIONS = 4102
        const val REQUEST_MEDIA_PERMISSIONS = 4103
        const val REQUEST_CALL_LOG_PERMISSION = 4104
        val REQUIRED_PERMISSIONS = arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.READ_CALL_LOG,
        )
        val SMS_PERMISSIONS = arrayOf(
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS,
        )
    }
}
