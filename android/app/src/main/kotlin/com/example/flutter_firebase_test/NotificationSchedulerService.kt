package com.example.flutter_firebase_test

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.*

class NotificationSchedulerService(private val context: Context) {
    
    companion object {
        private const val TAG = "NotificationScheduler"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val SCHEDULE_DATA_KEY = "flutter.cached_schedule_data"
        private const val NOTIFICATIONS_ENABLED_KEY = "flutter.notifications_enabled"
        private const val ALL_SUBJECTS_KEY = "flutter.notifications_all_subjects"
        private const val SELECTED_SUBJECTS_KEY = "flutter.notification_selected_subjects"
        private const val LEAD_TIME_KEY = "flutter.notifications_lead_time"
    }
    
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val alarmManager: AlarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    
    /**
     * Schedule all notifications based on the cached schedule data and user preferences
     */
    fun scheduleAllNotifications() {
        Log.d(TAG, "Starting to schedule all notifications")
        
        // Check if notifications are enabled
        val enabled = prefs.getBoolean(NOTIFICATIONS_ENABLED_KEY, true)
        if (!enabled) {
            Log.d(TAG, "Notifications disabled, cancelling all")
            cancelAllNotifications()
            return
        }
        
        // Get user preferences
        val allSubjects = prefs.getBoolean(ALL_SUBJECTS_KEY, true)
        val selectedSubjectsJson = prefs.getString(SELECTED_SUBJECTS_KEY, "[]") ?: "[]"
        val selectedSubjects = parseStringList(selectedSubjectsJson)
        
        // Safely get lead time - Flutter might store as Long instead of Int
        val leadTimeMinutes = try {
            prefs.getInt(LEAD_TIME_KEY, 15)
        } catch (e: ClassCastException) {
            // If stored as Long, convert to Int
            prefs.getLong(LEAD_TIME_KEY, 15L).toInt()
        }
        
        // Get schedule data
        val scheduleJson = prefs.getString(SCHEDULE_DATA_KEY, null)
        if (scheduleJson == null) {
            Log.w(TAG, "No schedule data found")
            return
        }
        
        try {
            val scheduleArray = JSONArray(scheduleJson)
            var scheduledCount = 0
            
            for (i in 0 until scheduleArray.length()) {
                val classData = scheduleArray.getJSONObject(i)
                
                val subject = classData.optString("subject", "")
                val dayOfWeek = classData.optString("dayOfWeek", "")
                val startTime = classData.optString("startTime", "")
                val room = classData.optString("room", "")
                val id = classData.optString("id", "")
                
                // Filter based on user preferences
                if (!allSubjects && !selectedSubjects.contains(subject)) {
                    Log.d(TAG, "Skipping $subject - not in selected subjects")
                    continue
                }
                
                if (dayOfWeek.isEmpty() || startTime.isEmpty()) {
                    Log.w(TAG, "Invalid class data: missing dayOfWeek or startTime")
                    continue
                }
                
                // Schedule the notification
                scheduleClassNotification(
                    id = id,
                    subject = subject,
                    room = room,
                    dayOfWeek = dayOfWeek,
                    startTime = startTime,
                    leadTimeMinutes = leadTimeMinutes
                )
                scheduledCount++
            }
            
            Log.d(TAG, "Successfully scheduled $scheduledCount notifications")
        } catch (e: Exception) {
            Log.e(TAG, "Error scheduling notifications", e)
        }
    }
    
    /**
     * Schedule a single class notification
     */
    private fun scheduleClassNotification(
        id: String,
        subject: String,
        room: String,
        dayOfWeek: String,
        startTime: String,
        leadTimeMinutes: Int
    ) {
        try {
            // Parse the start time
            val timeParts = startTime.split(":")
            if (timeParts.size != 2) {
                Log.w(TAG, "Invalid time format: $startTime")
                return
            }
            
            val hour = timeParts[0].toInt()
            val minute = timeParts[1].toInt()
            
            // Get the day index (1 = Monday, 7 = Sunday)
            val dayIndex = getDayIndex(dayOfWeek)
            if (dayIndex == -1) {
                Log.w(TAG, "Invalid day of week: $dayOfWeek")
                return
            }
            
            // Calculate the notification time
            val calendar = Calendar.getInstance()
            calendar.set(Calendar.HOUR_OF_DAY, hour)
            calendar.set(Calendar.MINUTE, minute)
            calendar.set(Calendar.SECOND, 0)
            calendar.set(Calendar.MILLISECOND, 0)
            
            // Subtract lead time
            calendar.add(Calendar.MINUTE, -leadTimeMinutes)
            
            // Find the next occurrence of this day
            val currentDayOfWeek = calendar.get(Calendar.DAY_OF_WEEK)
            var daysUntilTarget = dayIndex - currentDayOfWeek
            
            if (daysUntilTarget < 0) {
                daysUntilTarget += 7
            } else if (daysUntilTarget == 0 && calendar.timeInMillis <= System.currentTimeMillis()) {
                // If it's today but the time has passed, schedule for next week
                daysUntilTarget = 7
            }
            
            calendar.add(Calendar.DAY_OF_WEEK, daysUntilTarget)
            
            val triggerTime = calendar.timeInMillis
            
            // Create the intent for the notification
            val intent = Intent(context, NotificationReceiver::class.java).apply {
                putExtra("subject", subject)
                putExtra("room", room)
                putExtra("leadTime", leadTimeMinutes)
                putExtra("dayOfWeek", dayOfWeek)
                putExtra("startTime", startTime)
            }
            
            // Use a unique request code based on the class ID
            val requestCode = id.hashCode()
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Schedule the alarm
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // Android 12+ - check if we can schedule exact alarms
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTime,
                        pendingIntent
                    )
                    Log.d(TAG, "Scheduled exact alarm for $subject on $dayOfWeek at ${SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault()).format(Date(triggerTime))}")
                } else {
                    // Fallback to inexact alarm
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTime,
                        pendingIntent
                    )
                    Log.w(TAG, "Scheduled inexact alarm for $subject (exact alarm permission not granted)")
                }
            } else {
                // Pre-Android 12
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTime,
                    pendingIntent
                )
                Log.d(TAG, "Scheduled exact alarm for $subject on $dayOfWeek at ${SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault()).format(Date(triggerTime))}")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error scheduling notification for $subject", e)
        }
    }
    
    /**
     * Cancel all scheduled notifications
     */
    fun cancelAllNotifications() {
        Log.d(TAG, "Cancelling all notifications")
        
        val scheduleJson = prefs.getString(SCHEDULE_DATA_KEY, null) ?: return
        
        try {
            val scheduleArray = JSONArray(scheduleJson)
            
            for (i in 0 until scheduleArray.length()) {
                val classData = scheduleArray.getJSONObject(i)
                val id = classData.optString("id", "")
                
                val intent = Intent(context, NotificationReceiver::class.java)
                val requestCode = id.hashCode()
                
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    requestCode,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                
                alarmManager.cancel(pendingIntent)
            }
            
            Log.d(TAG, "Cancelled all notifications")
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling notifications", e)
        }
    }
    
    /**
     * Convert day name to Calendar day index
     */
    private fun getDayIndex(dayName: String): Int {
        return when (dayName.lowercase(Locale.getDefault())) {
            "monday" -> Calendar.MONDAY
            "tuesday" -> Calendar.TUESDAY
            "wednesday" -> Calendar.WEDNESDAY
            "thursday" -> Calendar.THURSDAY
            "friday" -> Calendar.FRIDAY
            "saturday" -> Calendar.SATURDAY
            "sunday" -> Calendar.SUNDAY
            else -> -1
        }
    }
    
    /**
     * Parse a JSON string list
     */
    private fun parseStringList(json: String): List<String> {
        return try {
            val jsonArray = JSONArray(json)
            List(jsonArray.length()) { i -> jsonArray.getString(i) }
        } catch (e: Exception) {
            emptyList()
        }
    }
}
