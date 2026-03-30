package com.example.notisaver

import android.content.Context
import androidx.core.content.edit

object ReliabilityStore {
    private const val prefsName = "notisaver_reliability"
    private const val lastListenerConnectedAtKey = "last_listener_connected_at"
    private const val lastNotificationCapturedAtKey = "last_notification_captured_at"
    private const val lastRebindRequestedAtKey = "last_rebind_requested_at"

    fun markListenerConnected(context: Context) {
        prefs(context).edit {
            putLong(lastListenerConnectedAtKey, System.currentTimeMillis())
        }
    }

    fun markNotificationCaptured(context: Context) {
        prefs(context).edit {
            putLong(lastNotificationCapturedAtKey, System.currentTimeMillis())
        }
    }

    fun markRebindRequested(context: Context) {
        prefs(context).edit {
            putLong(lastRebindRequestedAtKey, System.currentTimeMillis())
        }
    }

    fun snapshot(
        context: Context,
        notificationAccessEnabled: Boolean,
        batteryOptimizationIgnored: Boolean,
        pendingCount: Int,
    ): Map<String, Any> {
        val prefs = prefs(context)
        return mapOf(
            "notificationAccessEnabled" to notificationAccessEnabled,
            "batteryOptimizationIgnored" to batteryOptimizationIgnored,
            "lastListenerConnectedAt" to prefs.getLong(lastListenerConnectedAtKey, 0L),
            "lastNotificationCapturedAt" to prefs.getLong(lastNotificationCapturedAtKey, 0L),
            "lastRebindRequestedAt" to prefs.getLong(lastRebindRequestedAtKey, 0L),
            "pendingCount" to pendingCount,
        )
    }

    private fun prefs(context: Context) =
        context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
}
