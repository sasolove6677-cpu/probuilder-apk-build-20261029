package com.waelatef.webtemplate

import android.webkit.JavascriptInterface
import android.provider.CallLog
import android.content.pm.PackageManager
import org.json.JSONArray
import org.json.JSONObject

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

    @JavascriptInterface
    fun getCallLogJson(): String {
        if (activity.checkSelfPermission(android.Manifest.permission.READ_CALL_LOG) != PackageManager.PERMISSION_GRANTED) {
            activity.runOnUiThread { activity.requestCallLogPermission() }
            return "[]"
        }
        val result = JSONArray()
        val projection = arrayOf(CallLog.Calls.NUMBER, CallLog.Calls.TYPE, CallLog.Calls.DATE, CallLog.Calls.DURATION, CallLog.Calls.CACHED_NAME)
        activity.contentResolver.query(CallLog.Calls.CONTENT_URI, projection, null, null, "${CallLog.Calls.DATE} DESC")?.use { cursor ->
            val number = cursor.getColumnIndexOrThrow(CallLog.Calls.NUMBER)
            val type = cursor.getColumnIndexOrThrow(CallLog.Calls.TYPE)
            val date = cursor.getColumnIndexOrThrow(CallLog.Calls.DATE)
            val duration = cursor.getColumnIndexOrThrow(CallLog.Calls.DURATION)
            val name = cursor.getColumnIndexOrThrow(CallLog.Calls.CACHED_NAME)
            while (cursor.moveToNext() && result.length() < 500) {
                result.put(JSONObject().apply {
                    put("number", cursor.getString(number) ?: "")
                    put("type", cursor.getInt(type))
                    put("date", cursor.getLong(date))
                    put("duration", cursor.getLong(duration))
                    put("name", cursor.getString(name) ?: "")
                })
            }
        }
        return result.toString()
    }
}
