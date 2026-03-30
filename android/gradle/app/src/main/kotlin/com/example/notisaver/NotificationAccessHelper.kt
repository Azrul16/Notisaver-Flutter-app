package com.example.notisaver

import android.content.ComponentName
import android.content.Context
import android.provider.Settings

object NotificationAccessHelper {
    fun isEnabled(context: Context): Boolean {
        val enabledListeners =
            Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")
                ?: return false
        val componentName = ComponentName(context, NotificationListener::class.java)
        return enabledListeners.contains(componentName.flattenToString())
    }
}
