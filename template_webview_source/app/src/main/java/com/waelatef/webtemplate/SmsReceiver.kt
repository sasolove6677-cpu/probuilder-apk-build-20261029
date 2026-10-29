package com.waelatef.webtemplate

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

/** Receives incoming SMS broadcasts and forwards complete sender/body pairs to the WebView. */
class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent).orEmpty()
        messages
            .groupBy { it.originatingAddress.orEmpty() }
            .forEach { (sender, parts) ->
                val body = parts.joinToString(separator = "") { it.messageBody.orEmpty() }
                if (body.isNotBlank()) WebViewEventDispatcher.sendSms(sender, body)
            }
    }
}
