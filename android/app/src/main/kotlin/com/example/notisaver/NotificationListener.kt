package com.example.notisaver

import android.app.Notification
import android.content.ComponentName
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationListener : NotificationListenerService() {
    override fun onListenerConnected() {
        super.onListenerConnected()
        ReliabilityStore.markListenerConnected(this)
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        NotificationAccessHelper.refreshListenerBinding(this)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName) {
            return
        }

        try {
            val payload = buildPayload(sbn)
            ReliabilityStore.markNotificationCaptured(applicationContext)
            NotificationStore.enqueue(applicationContext, payload)
            runCatching {
                NotificationBridge.emit(payload)
            }
        } catch (_: Exception) {
            val fallbackPayload = buildFallbackPayload(sbn)
            ReliabilityStore.markNotificationCaptured(applicationContext)
            runCatching {
                NotificationStore.enqueue(applicationContext, fallbackPayload)
            }
        }
    }

    private fun resolveAppName(packageName: String): String {
        return try {
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(applicationInfo).toString()
        } catch (_: Exception) {
            packageName
        }
    }

    private fun buildPayload(sbn: StatusBarNotification): Map<String, Any?> {
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

        return buildFallbackPayload(
            sbn = sbn,
            title = title,
            message = fullMessage,
            subText = extras?.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString().orEmpty(),
            avatarPath = NotificationIconHelper.saveAvatar(this, sbn),
            appIconPath = NotificationIconHelper.saveAppIcon(this, sbn.packageName),
        )
    }

    private fun buildFallbackPayload(
        sbn: StatusBarNotification,
        title: String? = null,
        message: String? = null,
        subText: String? = null,
        avatarPath: String? = null,
        appIconPath: String? = null,
    ): Map<String, Any?> {
        val extras = sbn.notification.extras
        return mapOf(
            "appName" to resolveAppName(sbn.packageName),
            "packageName" to sbn.packageName,
            "title" to (title ?: extras?.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()),
            "message" to (
                message ?: extras?.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()
            ),
            "subText" to (
                subText ?: extras?.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString().orEmpty()
            ),
            "timestamp" to sbn.postTime,
            "notificationKey" to (sbn.key ?: ""),
            "category" to (sbn.notification.category ?: ""),
            "avatarPath" to avatarPath,
            "appIconPath" to appIconPath,
        )
    }
}
