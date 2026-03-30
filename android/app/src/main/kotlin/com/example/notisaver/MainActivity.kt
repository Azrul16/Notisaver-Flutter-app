package com.example.notisaver

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

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

                "getReliabilityStatus" -> {
                    result.success(
                        ReliabilityStore.snapshot(
                            context = this,
                            notificationAccessEnabled = NotificationAccessHelper.isEnabled(this),
                            batteryOptimizationIgnored = BatteryHelper.isIgnoringOptimizations(this),
                            pendingCount = NotificationStore.pendingCount(this)
                        )
                    )
                }

                "refreshListenerBinding" -> {
                    NotificationAccessHelper.refreshListenerBinding(this)
                    result.success(null)
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
    private const val pendingFileName = "pending_notifications.json"

    @Synchronized
    fun enqueue(context: android.content.Context, payload: Map<String, Any?>) {
        val file = pendingFile(context)
        val array = JSONArray(readQueue(file))
        array.put(JSONObject(payload))
        file.writeText(array.toString())
    }

    @Synchronized
    fun consumePending(context: android.content.Context): List<Map<String, Any?>> {
        val file = pendingFile(context)
        val array = JSONArray(readQueue(file))
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
        file.writeText("[]")
        return items
    }

    @Synchronized
    fun pendingCount(context: android.content.Context): Int {
        val file = pendingFile(context)
        return JSONArray(readQueue(file)).length()
    }

    private fun pendingFile(context: android.content.Context): File {
        return File(context.filesDir, pendingFileName)
    }

    private fun readQueue(file: File): String {
        return try {
            if (!file.exists()) {
                "[]"
            } else {
                file.readText().ifBlank { "[]" }
            }
        } catch (_: Exception) {
            "[]"
        }
    }
}
