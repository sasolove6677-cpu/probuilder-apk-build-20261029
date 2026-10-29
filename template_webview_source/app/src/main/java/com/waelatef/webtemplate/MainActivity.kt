package com.waelatef.webtemplate

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient

class MainActivity : Activity() {
    private lateinit var webView: WebView

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
            webChromeClient = WebChromeClient()
        }
        WebViewEventDispatcher.attach(webView)
        setContentView(webView)
        webView.loadUrl("file:///android_asset/index.html")
        requestPhoneStatePermissionIfNeeded()
    }

    private fun requestPhoneStatePermissionIfNeeded() {
        if (checkSelfPermission(Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                arrayOf(Manifest.permission.READ_PHONE_STATE),
                REQUEST_PHONE_STATE_PERMISSION,
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
        const val REQUEST_PHONE_STATE_PERMISSION = 4101
        const val REQUEST_SMS_PERMISSIONS = 4102
        val SMS_PERMISSIONS = arrayOf(
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS,
        )
    }
}
