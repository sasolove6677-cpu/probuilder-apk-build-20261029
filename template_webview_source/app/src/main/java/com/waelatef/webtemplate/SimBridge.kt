package com.waelatef.webtemplate

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.telephony.TelephonyManager
import android.webkit.JavascriptInterface

/** Exposes SIM/network status to the generated app's local WebView content. */
class SimBridge(private val context: Context) {
    @JavascriptInterface
    fun getCarrierName(): String {
        if (!hasPhoneStatePermission()) return ""
        val telephonyManager = telephonyManager() ?: return ""
        return try {
            telephonyManager.networkOperatorName
                .takeIf { it.isNotBlank() }
                ?: telephonyManager.simOperatorName.orEmpty()
        } catch (_: SecurityException) {
            ""
        }
    }

    @JavascriptInterface
    fun getSimState(): Int {
        if (!hasPhoneStatePermission()) return TelephonyManager.SIM_STATE_UNKNOWN
        return try {
            telephonyManager()?.simState ?: TelephonyManager.SIM_STATE_UNKNOWN
        } catch (_: SecurityException) {
            TelephonyManager.SIM_STATE_UNKNOWN
        }
    }

    private fun hasPhoneStatePermission(): Boolean =
        context.checkSelfPermission(Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED

    private fun telephonyManager(): TelephonyManager? =
        context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
}
