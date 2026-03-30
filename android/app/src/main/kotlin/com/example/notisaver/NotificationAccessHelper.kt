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
        return enabledListeners.contains(componentName.flattenToString())
    }

    fun refreshListenerBinding(context: Context) {
        if (!isEnabled(context)) {
            return
        }

        val componentName = ComponentName(context, NotificationListener::class.java)
        val packageManager = context.packageManager
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
