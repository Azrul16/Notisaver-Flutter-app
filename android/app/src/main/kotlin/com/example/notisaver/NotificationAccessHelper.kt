package com.example.notisaver

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings

object NotificationAccessHelper {
    fun isEnabled(context: Context): Boolean {
        val enabledListeners =
            Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")
                ?: return false
        val componentName = ComponentName(context, NotificationListener::class.java)
        return enabledListeners
            .split(':')
            .any { listener -> listener.equals(componentName.flattenToString(), ignoreCase = true) }
    }

    fun refreshListenerBinding(context: Context) {
        if (!isEnabled(context)) {
            return
        }

        ReliabilityStore.markRebindRequested(context)

        val componentName = ComponentName(context, NotificationListener::class.java)
        val packageManager = context.packageManager

        // Toggling the component nudges Android to reconnect the listener on
        // devices where a plain requestRebind is ignored or unavailable.
        packageManager.setComponentEnabledSetting(
            componentName,
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )
        packageManager.setComponentEnabledSetting(
            componentName,
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            android.service.notification.NotificationListenerService.requestRebind(componentName)
        }
    }
}
