package com.waelatef.webtemplate

import android.os.Handler
import android.os.Looper
import android.webkit.WebView
import org.json.JSONObject
import java.lang.ref.WeakReference
import java.util.ArrayDeque

/** Delivers local SMS/notification events to the active page without persisting message contents. */
internal object WebViewEventDispatcher {
    private const val MAX_PENDING_EVENTS = 100
    private val mainHandler = Handler(Looper.getMainLooper())
    private val pendingScripts = ArrayDeque<String>()
    private var webViewReference: WeakReference<WebView>? = null
    private var pageReady = false

    fun attach(webView: WebView) {
        mainHandler.post {
            webViewReference = WeakReference(webView)
            pageReady = false
        }
    }

    fun onPageReady(webView: WebView) {
        mainHandler.post {
            if (webViewReference?.get() !== webView) return@post
            pageReady = true
            while (pendingScripts.isNotEmpty()) {
                webView.evaluateJavascript(pendingScripts.removeFirst(), null)
            }
        }
    }

    fun detach(webView: WebView) {
        mainHandler.post {
            if (webViewReference?.get() === webView) {
                webViewReference = null
                pageReady = false
            }
        }
    }

    fun sendSms(sender: String, message: String) {
        val script = "if (typeof window.receiveSMS === 'function') " +
            "window.receiveSMS(${JSONObject.quote(sender)}, ${JSONObject.quote(message)});"
        dispatch(script)
    }

    fun sendNotification(appName: String, text: String) {
        val script = "if (typeof window.receiveNotification === 'function') " +
            "window.receiveNotification(${JSONObject.quote(appName)}, ${JSONObject.quote(text)});"
        dispatch(script)
    }

    private fun dispatch(script: String) {
        mainHandler.post {
            val webView = webViewReference?.get()
            if (webView != null && pageReady) {
                webView.evaluateJavascript(script, null)
            } else {
                if (pendingScripts.size >= MAX_PENDING_EVENTS) pendingScripts.removeFirst()
                pendingScripts.addLast(script)
            }
        }
    }
}
