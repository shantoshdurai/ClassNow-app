package com.example.flutter_firebase_test

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.*

class TimetableWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.timetable_widget_layout)
            
            // Get widget data from SharedPreferences
            val hasClass = widgetData.getBoolean("has_class", false)
            val isCurrent = widgetData.getBoolean("is_current", false)
            val subject = widgetData.getString("subject", "No Classes")
            val startTime = widgetData.getString("start_time", "")
            val endTime = widgetData.getString("end_time", "")
            val room = widgetData.getString("room", "")
            val timeRemaining = widgetData.getString("time_remaining", "")
            val progress = widgetData.getInt("progress", 0)
            
            // Get current time
            val currentTime = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())
            views.setTextViewText(R.id.current_time, currentTime)
            
            if (hasClass) {
                // Show class info
                views.setViewVisibility(R.id.empty_state, View.GONE)
                views.setViewVisibility(R.id.header, View.VISIBLE)
                views.setViewVisibility(R.id.subject_name, View.VISIBLE)
                views.setViewVisibility(R.id.time_info, View.VISIBLE)
                
                // Set status label
                views.setTextViewText(R.id.status_label, if (isCurrent) "NOW" else "NEXT UP")
                
                // set subject
                views.setTextViewText(R.id.subject_name, subject ?: "Unknown")
                
                // Set time range
                views.setTextViewText(R.id.time_range, "$startTime - $endTime")
                
                // Set room
                if (!room.isNullOrEmpty()) {
                    views.setTextViewText(R.id.room_number, "• Room $room")
                    views.setViewVisibility(R.id.room_number, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.room_number, View.GONE)
                }
                
                // Show/hide progress bar based on current status
                if (isCurrent) {
                    views.setViewVisibility(R.id.progress_bar, View.VISIBLE)
                    views.setViewVisibility(R.id.time_remaining, View.VISIBLE)
                    views.setProgressBar(R.id.progress_bar, 100, progress, false)
                    views.setTextViewText(R.id.time_remaining, timeRemaining)
                } else {
                    views.setViewVisibility(R.id.progress_bar, View.GONE)
                    views.setViewVisibility(R.id.time_remaining, View.VISIBLE)
                    views.setTextViewText(R.id.time_remaining, "Starts in $timeRemaining")
                }
            } else {
                // Show empty state
                views.setViewVisibility(R.id.empty_state, View.VISIBLE)
                views.setViewVisibility(R.id.header, View.GONE)
                views.setViewVisibility(R.id.subject_name, View.GONE)
                views.setViewVisibility(R.id.time_info, View.GONE)
                views.setViewVisibility(R.id.progress_bar, View.GONE)
                views.setViewVisibility(R.id.time_remaining, View.GONE)
            }
            
            // Add click handling to open app
            val pendingIntent = es.antonborri.home_widget.HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
