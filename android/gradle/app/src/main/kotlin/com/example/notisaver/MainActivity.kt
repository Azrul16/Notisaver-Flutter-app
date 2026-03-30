package com.example.notisaver

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "notisaver/methods"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationAccessEnabled" -> {
                    result.success(NotificationAccessHelper.isEnabled(this))
                }

                "openNotificationAccessSettings" -> {
                    startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                    result.success(null)
                }

                "isIgnoringBatteryOptimizations" -> {
                    result.success(BatteryHelper.isIgnoringOptimizations(this))
                }

                "requestIgnoreBatteryOptimizations" -> {
                    BatteryHelper.requestIgnoreOptimizations(this)
                    result.success(null)
                }

                "getInstalledApps" -> {
                    result.success(InstalledAppsHelper.getInstalledApps(this))
                }

                "consumePendingNotifications" -> {
                    result.success(NotificationStore.consumePending(this))
                }

                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "notisaver/events"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                NotificationBridge.eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                NotificationBridge.eventSink = null
            }
        })
    }
}

object NotificationBridge {
    var eventSink: EventChannel.EventSink? = null

    fun emit(payload: Map<String, Any?>) {
        eventSink?.success(payload)
    }
}

object NotificationStore {
    private const val preferencesName = "notisaver_pending"
    private const val pendingKey = "pending_notifications"

    @Synchronized
    fun enqueue(context: android.content.Context, payload: Map<String, Any?>) {
        val prefs =
            context.getSharedPreferences(preferencesName, android.content.Context.MODE_PRIVATE)
        val array = JSONArray(prefs.getString(pendingKey, "[]"))
        array.put(JSONObject(payload))
        prefs.edit().putString(pendingKey, array.toString()).apply()
    }

    @Synchronized
    fun consumePending(context: android.content.Context): List<Map<String, Any?>> {
        val prefs =
            context.getSharedPreferences(preferencesName, android.content.Context.MODE_PRIVATE)
        val array = JSONArray(prefs.getString(pendingKey, "[]"))
        val items = mutableListOf<Map<String, Any?>>()
        for (index in 0 until array.length()) {
            val item = array.optJSONObject(index) ?: continue
            items.add(
                mapOf(
                    "appName" to item.optString("appName"),
                    "packageName" to item.optString("packageName"),
                    "title" to item.optString("title"),
                    "message" to item.optString("message"),
                    "subText" to item.optString("subText"),
                    "timestamp" to item.optLong("timestamp"),
                    "notificationKey" to item.optString("notificationKey"),
                    "category" to item.optString("category").ifBlank { null },
                    "avatarPath" to item.optString("avatarPath").ifBlank { null },
                    "appIconPath" to item.optString("appIconPath").ifBlank { null }
                )
            )
        }
        prefs.edit().remove(pendingKey).apply()
        return items
    }
}
