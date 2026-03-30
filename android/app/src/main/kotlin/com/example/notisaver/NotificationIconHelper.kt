package com.example.notisaver

import android.app.Notification
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.service.notification.StatusBarNotification
import java.io.File
import java.io.FileOutputStream

object NotificationIconHelper {
    fun saveAvatar(context: Context, sbn: StatusBarNotification): String? {
        val drawable = extractLargeIconDrawable(context, sbn) ?: return null
        return saveDrawable(
            context = context,
            drawable = drawable,
            fileName = "avatar_${sbn.packageName.hashCode()}_${sbn.postTime}.png"
        )
    }

    fun saveAppIcon(context: Context, packageName: String): String? {
        return try {
            val drawable = context.packageManager.getApplicationIcon(packageName)
            saveDrawable(
                context = context,
                drawable = drawable,
                fileName = "app_${packageName.hashCode()}.png"
            )
        } catch (_: Exception) {
            null
        }
    }

    private fun extractLargeIconDrawable(
        context: Context,
        sbn: StatusBarNotification
    ): Drawable? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            sbn.notification.getLargeIcon()?.loadDrawable(context)?.let { return it }
        }

        val bitmap =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                sbn.notification.extras?.getParcelable(Notification.EXTRA_LARGE_ICON, Bitmap::class.java)
            } else {
                @Suppress("DEPRECATION")
                sbn.notification.extras?.getParcelable(Notification.EXTRA_LARGE_ICON) as? Bitmap
            }
        return if (bitmap != null) BitmapDrawable(context.resources, bitmap) else null
    }

    private fun saveDrawable(
        context: Context,
        drawable: Drawable,
        fileName: String
    ): String? {
        return try {
            val directory = File(context.filesDir, "notification_icons").apply {
                mkdirs()
            }
            val file = File(directory, fileName)
            FileOutputStream(file).use { output ->
                drawableToBitmap(drawable).compress(Bitmap.CompressFormat.PNG, 100, output)
            }
            file.absolutePath
        } catch (_: Exception) {
            null
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable && drawable.bitmap != null) {
            return drawable.bitmap
        }

        val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 128
        val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 128
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
}
