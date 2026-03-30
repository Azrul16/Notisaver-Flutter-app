package com.example.notisaver

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationListener : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName) {
            return
        }

        val extras = sbn.notification.extras
        val avatarPath = NotificationIconHelper.saveAvatar(this, sbn)
        val appIconPath = NotificationIconHelper.saveAppIcon(this, sbn.packageName)
        val payload = mapOf(
            "appName" to resolveAppName(sbn.packageName),
            "packageName" to sbn.packageName,
            "title" to extras?.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty(),
            "message" to extras?.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty(),
            "subText" to extras?.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString().orEmpty(),
            "timestamp" to sbn.postTime,
            "notificationKey" to (sbn.key ?: ""),
            "category" to (sbn.notification.category ?: ""),
            "avatarPath" to avatarPath,
            "appIconPath" to appIconPath
        )

        NotificationStore.enqueue(applicationContext, payload)
        NotificationBridge.emit(payload)
    }

    private fun resolveAppName(packageName: String): String {
        return try {
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(applicationInfo).toString()
        } catch (_: Exception) {
            packageName
        }
    }
}
