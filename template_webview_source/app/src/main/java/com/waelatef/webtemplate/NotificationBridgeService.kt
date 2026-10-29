package com.waelatef.webtemplate

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/** Reads notification title/body only for package IDs explicitly allowlisted by the HTML app. */
class NotificationBridgeService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val isGroupSummary = sbn.notification.flags and Notification.FLAG_GROUP_SUMMARY != 0
        if (isGroupSummary || !NotificationPackageFilter.isAllowed(this, sbn.packageName)) return

        val extras = sbn.notification.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty().trim()
        val body = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
            ?.takeIf { it.isNotBlank() }
            ?: extras.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()
        val message = listOf(title, body).filter { it.isNotBlank() }.joinToString("\n")
        if (message.isBlank()) return

        val appName = try {
            val appInfo = packageManager.getApplicationInfo(sbn.packageName, 0)
            packageManager.getApplicationLabel(appInfo).toString()
        } catch (_: Exception) {
            sbn.packageName
        }
        WebViewEventDispatcher.sendNotification(appName, message)
    }
}
