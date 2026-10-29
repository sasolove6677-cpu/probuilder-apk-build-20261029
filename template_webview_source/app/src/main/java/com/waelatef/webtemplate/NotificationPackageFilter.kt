package com.waelatef.webtemplate

import android.content.Context
import org.json.JSONArray
import org.json.JSONException

/** Keeps notification forwarding opt-in to exact package IDs selected by the HTML app. */
internal object NotificationPackageFilter {
    private const val PREFERENCES_NAME = "generated_app_notification_filter"
    private const val KEY_ALLOWED_PACKAGES = "allowed_packages"
    private const val MAX_PACKAGES = 64
    private val packageIdPattern = Regex("[A-Za-z0-9_.]+")

    fun setAllowedPackages(context: Context, packagesJson: String): Boolean {
        val json = try {
            JSONArray(packagesJson)
        } catch (_: JSONException) {
            return false
        }
        if (json.length() > MAX_PACKAGES) return false

        val packages = linkedSetOf<String>()
        for (index in 0 until json.length()) {
            val packageId = json.optString(index).trim()
            if (packageId.isEmpty() || !packageIdPattern.matches(packageId) || '.' !in packageId) {
                return false
            }
            packages += packageId
        }

        context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            .edit()
            .putStringSet(KEY_ALLOWED_PACKAGES, packages)
            .apply()
        return true
    }

    fun isAllowed(context: Context, packageId: String): Boolean {
        val allowed = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            .getStringSet(KEY_ALLOWED_PACKAGES, emptySet())
            ?.toSet()
            .orEmpty()
        return packageId in allowed
    }
}
