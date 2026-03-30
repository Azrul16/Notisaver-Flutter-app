package com.example.notisaver

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager

object InstalledAppsHelper {
    fun getInstalledApps(context: Context): List<Map<String, String>> {
        val launcherIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }

        return context.packageManager.queryIntentActivities(launcherIntent, PackageManager.MATCH_ALL)
            .map { resolveInfo ->
                mapOf(
                    "appName" to resolveInfo.loadLabel(context.packageManager).toString(),
                    "packageName" to resolveInfo.activityInfo.packageName
                )
            }
            .distinctBy { app -> app["packageName"] }
            .sortedBy { app -> app["appName"]?.lowercase() }
    }
}
