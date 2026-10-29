package com.waelatef.webtemplate

import android.webkit.JavascriptInterface

/** User-controlled entry points exposed to the generated app's local HTML. */
class AndroidBridge(private val activity: MainActivity) {
    @JavascriptInterface
    fun requestSmsPermission() {
        activity.runOnUiThread { activity.requestSmsPermissions() }
    }

    @JavascriptInterface
    fun openNotificationListenerSettings() {
        activity.runOnUiThread { activity.openNotificationListenerSettings() }
    }

    /** Pass a JSON array of exact Android package IDs to receive notification callbacks. */
    @JavascriptInterface
    fun setTargetNotificationPackages(packagesJson: String): Boolean =
        NotificationPackageFilter.setAllowedPackages(activity.applicationContext, packagesJson)
}
