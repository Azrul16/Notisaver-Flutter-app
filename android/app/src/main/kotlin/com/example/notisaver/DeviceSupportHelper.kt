package com.example.notisaver

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings

object DeviceSupportHelper {
    fun powerProfile(): Map<String, Any> {
        val manufacturer = Build.MANUFACTURER.orEmpty()
        val brand = Build.BRAND.orEmpty()
        val normalizedManufacturer = manufacturer.lowercase()
        val normalizedBrand = brand.lowercase()
        val isXiaomiFamily = normalizedManufacturer.contains("xiaomi") ||
            normalizedBrand.contains("xiaomi") ||
            normalizedBrand.contains("redmi") ||
            normalizedBrand.contains("poco")

        return mapOf(
            "manufacturer" to manufacturer,
            "brand" to brand,
            "model" to Build.MODEL.orEmpty(),
            "isXiaomiFamily" to isXiaomiFamily,
        )
    }

    fun openAutoStartSettings(context: Context): Boolean {
        val intents = listOf(
            Intent().apply {
                component = ComponentName(
                    "com.miui.securitycenter",
                    "com.miui.permcenter.autostart.AutoStartManagementActivity"
                )
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
            Intent().apply {
                component = ComponentName(
                    "com.miui.securitycenter",
                    "com.miui.appmanager.ApplicationsDetailsActivity"
                )
                putExtra("package_name", context.packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.parse("package:${context.packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
        )

        return launchFirstAvailable(context, intents)
    }

    fun openAppDetailsSettings(context: Context): Boolean {
        val intents = listOf(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.parse("package:${context.packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
        )
        return launchFirstAvailable(context, intents)
    }

    private fun launchFirstAvailable(context: Context, intents: List<Intent>): Boolean {
        for (intent in intents) {
            val resolveInfo = context.packageManager.resolveActivity(intent, 0)
            if (resolveInfo != null) {
                runCatching {
                    context.startActivity(intent)
                }.onSuccess {
                    return true
                }
            }
        }
        return false
    }
}
