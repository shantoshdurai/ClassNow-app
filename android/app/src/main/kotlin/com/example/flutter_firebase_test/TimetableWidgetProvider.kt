package com.example.flutter_firebase_test

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class TimetableWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "TimetableWidget"
        private const val PREFS_NAME = "HomeWidgetPreferences"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                updateWidget(context, appWidgetManager, appWidgetId)
            } catch (t: Throwable) {
                Log.e(TAG, "Widget update failed", t)
                try {
                    val fallback = RemoteViews(context.packageName, R.layout.timetable_widget_layout)
                    fallback.setTextViewText(R.id.subject_name, "Widget error")
                    fallback.setTextViewText(R.id.time_range, t.javaClass.simpleName)
                    appWidgetManager.updateAppWidget(appWidgetId, fallback)
                } catch (_: Throwable) { /* swallow */ }
            }
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val views = RemoteViews(context.packageName, R.layout.timetable_widget_layout)

        views.setInt(R.id.refresh_button, "setColorFilter", 0xFF4DB6FF.toInt())

        val hasClass   = prefs.getBoolean("has_class", false)
        val isCurrent  = prefs.getBoolean("is_current", false)
        val subject    = prefs.getString("subject", "No Classes") ?: "No Classes"
        val startTime  = prefs.getString("start_time", "") ?: ""
        val endTime    = prefs.getString("end_time", "") ?: ""
        val room       = prefs.getString("room", "") ?: ""
        val timeRemain = prefs.getString("time_remaining", "") ?: ""
        val progress   = prefs.getInt("progress", 0)

        val timeFmt  = SimpleDateFormat("HH:mm", Locale.getDefault())
        val stampFmt = SimpleDateFormat("h:mm a", Locale.getDefault())
        val now = Date()
        views.setTextViewText(R.id.current_time, timeFmt.format(now))
        views.setTextViewText(R.id.last_updated, "UPDATED ${stampFmt.format(now)}")

        if (hasClass && subject != "No Classes") {
            views.setViewVisibility(R.id.class_content, View.VISIBLE)
            views.setViewVisibility(R.id.empty_state, View.GONE)

            if (isCurrent) {
                views.setTextViewText(R.id.status_label, "● IN SESSION")
                views.setTextColor(R.id.status_label, 0xFF34C759.toInt())
                views.setInt(R.id.status_label, "setBackgroundResource", R.drawable.widget_pill_live)
            } else {
                views.setTextViewText(R.id.status_label, "◷ NEXT UP")
                views.setTextColor(R.id.status_label, 0xFF4DB6FF.toInt())
                views.setInt(R.id.status_label, "setBackgroundResource", R.drawable.widget_pill_next)
            }

            views.setTextViewText(R.id.subject_name, subject)

            val roomPart = if (room.isNotEmpty()) "  ·  Room $room" else ""
            val timeLine = if (startTime.isNotEmpty() && endTime.isNotEmpty())
                "$startTime – $endTime$roomPart"
            else
                roomPart.trimStart()
            views.setTextViewText(R.id.time_range, timeLine)

            if (timeRemain.isNotEmpty()) {
                val label = if (isCurrent) "$timeRemain left" else "in $timeRemain"
                views.setTextViewText(R.id.time_remaining, label)
                views.setViewVisibility(R.id.time_remaining, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.time_remaining, View.GONE)
            }

            if (isCurrent && progress > 0) {
                views.setViewVisibility(R.id.progress_bar, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.progress_bar, View.GONE)
            }
        } else {
            views.setViewVisibility(R.id.class_content, View.GONE)
            views.setViewVisibility(R.id.empty_state, View.VISIBLE)
            views.setTextViewText(R.id.status_label, "✓ ALL DONE")
            views.setTextColor(R.id.status_label, 0xFF7A7D8A.toInt())
            views.setInt(R.id.status_label, "setBackgroundResource", 0)
        }

        // Tap the refresh icon to TRIGGER A REFRESH (not open the app)
        val refreshIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("timetable://update")
        )
        views.setOnClickPendingIntent(R.id.refresh_button, refreshIntent)

        // Tap the widget background to open the app
        val openIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (openIntent != null) {
            openIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            val pi = PendingIntent.getActivity(
                context, appWidgetId, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pi)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
