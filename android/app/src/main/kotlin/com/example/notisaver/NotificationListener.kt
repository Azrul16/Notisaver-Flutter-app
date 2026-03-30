package com.example.notisaver

import android.app.Notification
import android.content.ComponentName
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationListener : NotificationListenerService() {
    override fun onListenerConnected() {
        super.onListenerConnected()
        NotificationAccessHelper.refreshListenerBinding(this)
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        requestRebind(ComponentName(this, NotificationListener::class.java))
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName) {
            return
        }

        val extras = sbn.notification.extras
        val title = extras?.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
        val text = extras?.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()
        val bigText = extras?.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString().orEmpty()
        val textLines = extras?.getCharSequenceArray(Notification.EXTRA_TEXT_LINES)
            ?.joinToString("\n") { it.toString() }
            .orEmpty()
        val fullMessage = when {
            bigText.isNotBlank() -> bigText
            textLines.isNotBlank() -> textLines
            else -> text
        }
        val avatarPath = NotificationIconHelper.saveAvatar(this, sbn)
        val appIconPath = NotificationIconHelper.saveAppIcon(this, sbn.packageName)
        val payload = mapOf(
            "appName" to resolveAppName(sbn.packageName),
            "packageName" to sbn.packageName,
            "title" to title,
            "message" to fullMessage,
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
